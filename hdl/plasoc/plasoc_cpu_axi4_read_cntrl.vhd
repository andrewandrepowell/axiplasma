-------------------------------------------------------
--! @author Andrew Powell
--! @date January 17, 2017
--! @brief Contains the entity and architecture of the 
--! CPU's Master AXI4-Full Read Memory Controller.
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.plasoc_cpu_pack.all;

--! The Read Memory Controller implements a Master AXI4-Full Read 
--! interface in order to allow the CPU to perform reads from
--! main memory and other devices external to the CPU. Much optimization
--! of the Write and Read Memory Controllers is needed for future revisions,
--! considering the current revision is implemented in a sequential, blocking
--! manner. Specifically, for the sake simplicity, the AXI4-Full Read Address,
--! and Read Data are implemented as a state machine, rather than as separate 
--! processes that can permit concurrent execution.
--!
--! Information specific to the AXI4-Full
--! protocol is excluded from this documentation since the information can
--! be found in official ARM AMBA4 AXI documentation.
entity plasoc_cpu_axi4_read_cntrl is
    generic (
        -- CPU parameters.
        cpu_address_width : integer := 16;      --! Defines the address width of the CPU. This should normally be equal to the CPU's width.	
        cpu_data_width : integer := 32;         --! Defines the data width of the CPU. This should normally be equal to the CPU's width.
        -- Cache parameters.
        cache_offset_width : integer := 5;      --! Indicates whether the requested address of the CPU is cacheable or noncacheable.
        -- axi read constants
        axi_aruser_width : integer := 0;        --! Width of user-define AXI4-Full Address Read signal.
        axi_ruser_width : integer := 0          --! Width of user-define AXI4-Full Read Data signal.
	);
    port(
        -- Global interfaces.
        clock : in std_logic;                                                               --! Clock. Tested with 50 MHz.
        nreset : in std_logic;                                                              --! Reset on low.
        -- Memory interface.
        mem_read_address : in std_logic_vector(cpu_address_width-1 downto 0);               --! The requested address sent to the read memory controller.
        mem_read_data : out std_logic_vector(cpu_data_width-1 downto 0) := (others=>'0');   --! The word read from the read memory controller.
        mem_read_enable : in std_logic;                                                     --! Enables the operation of the read memory controller.
        mem_read_valid : out std_logic;                                                     --! Indicates the read memory controller has a valid word on mem_read_data.
        mem_read_ready : in std_logic;                                                      --! Indicates the cache is ready to sample a word from mem_read_data.
        -- Cache interface.
        cache_cacheable : in std_logic;                                                     --! Indicates whether the requested address of the CPU is cacheable or noncacheable.	
        -- Master AXI4-Full Read interface.
        axi_arid : out std_logic_vector(-1 downto 0);                                        --! AXI4-Full Address Read signal.
        axi_araddr : out std_logic_vector(cpu_address_width-1 downto 0) := (others=>'0');   --! AXI4-Full Address Read signal.
        axi_arlen : out std_logic_vector(7 downto 0);                                       --! AXI4-Full Address Read signal.	
        axi_arsize : out std_logic_vector(2 downto 0);                                      --! AXI4-Full Address Read signal.
        axi_arburst : out std_logic_vector(1 downto 0);                                     --! AXI4-Full Address Read signal.
        axi_arlock : out std_logic;                                                         --! AXI4-Full Address Read signal.	
        axi_arcache : out std_logic_vector(3 downto 0);                                     --! AXI4-Full Address Read signal.	
        axi_arprot : out std_logic_vector(2 downto 0);                                      --! AXI4-Full Address Read signal.	
        axi_arqos : out std_logic_vector(3 downto 0);                                       --! AXI4-Full Address Read signal.		
        axi_arregion : out std_logic_vector(3 downto 0);                                    --! AXI4-Full Address Read signal.	
        axi_aruser : out std_logic_vector(axi_aruser_width-1 downto 0);                     --! AXI4-Full Address Read signal.		
        axi_arvalid : out std_logic;                                                        --! AXI4-Full Address Read signal.	
        axi_arready : in std_logic;                                                         --! AXI4-Full Address Read signal.	
        axi_rid : in std_logic_vector(-1 downto 0);                                          --! AXI4-Full Read Data signal.
        axi_rdata : in std_logic_vector(cpu_data_width-1 downto 0);                         --! AXI4-Full Read Data signal.
        axi_rresp : in std_logic_vector(1 downto 0);                                        --! AXI4-Full Read Data signal.
        axi_rlast : in std_logic;                                                           --! AXI4-Full Read Data signal.
        axi_ruser : in std_logic_vector(axi_ruser_width-1 downto 0);                        --! AXI4-Full Read Data signal.
        axi_rvalid : in std_logic;                                                          --! AXI4-Full Read Data signal.
        axi_rready : out std_logic;                                                         --! AXI4-Full Read Data signal.
        -- Error interface.
        error_data : out std_logic_vector(3 downto 0) := (others=>'0')                      --! Returns value signifying error in the transaction.
	);
end plasoc_cpu_axi4_read_cntrl;

architecture Behavioral of plasoc_cpu_axi4_read_cntrl is
    subtype error_data_type is std_logic_vector(error_data'high downto error_data'low);
    constant cpu_bytes_per_word : integer := cpu_data_width/8;
    constant cache_words_per_line : integer := 2**cache_offset_width/cpu_bytes_per_word;
    constant axi_burst_len_noncacheable : integer := 0;
    constant axi_burst_len_cacheable : integer := cache_words_per_line-1;
    type state_type is (state_wait,state_read,state_error);
    signal state : state_type := state_wait;
    signal counter : integer range 0 to cache_words_per_line;
    signal axi_finished : boolean := False;
    signal axi_arlen_buff : std_logic_vector(7 downto 0) := (others=>'0');
    signal axi_arvalid_buff : std_logic := '0';
    signal axi_rready_buff : std_logic  := '0';
    signal mem_read_valid_buff : std_logic  := '0';
    
    constant fifo_index_width : integer := cache_offset_width-clogb2(cpu_data_width/8);
    type fifo_type is array(0 to 2**fifo_index_width-1) of std_logic_vector(cpu_data_width-1 downto 0);
    signal fifo : fifo_type := (others=>(others=>'0'));
    signal m_ptr : integer range 0 to 2**fifo_index_width-1 := 0;
    signal s_ptr : integer range 0 to 2**fifo_index_width-1 := 0;
begin

    axi_arid <= (others=>'0');
    axi_arlen <= axi_arlen_buff;
    axi_arsize <= std_logic_vector(to_unsigned(clogb2(cpu_bytes_per_word),axi_arsize'length));
    axi_arburst <= axi_burst_incr;
    axi_arlock <= axi_lock_normal_access;
    axi_arcache <= axi_cache_device_nonbufferable;
    axi_arprot <= axi_prot_instr & not axi_prot_sec & not axi_prot_priv;
    axi_arqos <= (others=>'0');
    axi_arregion <= (others=>'0');
    axi_aruser <= (others=>'0');
    axi_arvalid <= axi_arvalid_buff;
    axi_rready <= axi_rready_buff;
    mem_read_valid <= mem_read_valid_buff;
    
    mem_read_data <= fifo(s_ptr);
    
    process (clock)
        variable burst_len : integer range 0 to 2**axi_arlen'length-1;
        variable error_data_buff : error_data_type := (others=>'0');
    begin
        if rising_edge(clock) then
            if nreset='0' then
                error_data <= (others=>'0');
                error_data_buff := (others=>'0');
                axi_arvalid_buff <= '0';
                axi_rready_buff <= '0';
                mem_read_valid_buff <= '0';
                state <= state_wait;
            else
                case state is
                -- WAIT mode.
                when state_wait =>
                    -- Wait until the memory read interface requests data.
                    if mem_read_enable='1' then
                        -- Set control information. 
                        axi_araddr <= mem_read_address;
                        -- The burst length will change according to whether the memory access is cacheable or not.
                        if cache_cacheable='1' then
                            burst_len := axi_burst_len_cacheable;
                        else
                            burst_len := axi_burst_len_noncacheable;
                        end if;
                        axi_arlen_buff <= std_logic_vector(to_unsigned(burst_len,axi_arlen'length));
                        -- Set counter to keep track the number of words read from the burst.
                        counter <= 0;
                        s_ptr <= 0;
                        m_ptr <= 0;
                        -- Reset finish indicator.
                        axi_finished <= False;
                        -- Wait until handshake before reading data.
                        if axi_arvalid_buff='1' and axi_arready='1' then
                            axi_arvalid_buff <= '0';
                            axi_rready_buff <= '1';
                            state <= state_read;
                        else
                            axi_arvalid_buff <= '1';
                        end if;
                    end if;
                -- READ mode.
                when state_read=>
                
                    if axi_rvalid='1' and axi_rready_buff='1' then
                        fifo(m_ptr) <= axi_rdata;
                    end if;
                    
                    if m_ptr/=s_ptr and mem_read_valid_buff='1' and mem_read_ready='1' then
                        if s_ptr=2**fifo_index_width-1 then
                            s_ptr <= 0;
                        else
                            s_ptr <= s_ptr+1;
                        end if;
                    end if;
                    if axi_rvalid='1' and axi_rready_buff='1' and ((m_ptr+1) mod 2**fifo_index_width)/=s_ptr then
                        if m_ptr=2**fifo_index_width-1 then
                            m_ptr <= 0;
                        else
                            m_ptr <= m_ptr+1;
                        end if;
                    end if;
                    if mem_read_valid_buff='1' and mem_read_ready='1' and counter/=axi_arlen_buff then
                        counter <= counter+1;
                    end if;
                    
                    if axi_rvalid='1' and axi_rready_buff='1' and axi_rlast='1' then
                        axi_finished <= True;
                    end if;
                    
                    if (axi_rvalid='1' and axi_rready_buff='1' and axi_rlast='1') or axi_finished then
                        axi_rready_buff <= '0';
                    elsif ((m_ptr+1) mod 2**fifo_index_width)/=s_ptr then
                        axi_rready_buff <= '1';
                    else
                        axi_rready_buff <= '0';
                    end if;
                    if mem_read_valid_buff='1' and mem_read_ready='1' and counter=axi_arlen_buff then
                        mem_read_valid_buff <= '0';
                    elsif m_ptr/=s_ptr then
                        mem_read_valid_buff <= '1';
                    else
                        mem_read_valid_buff <= '0';
                    end if; 
                
                    if mem_read_valid_buff='1' and mem_read_ready='1' and counter=axi_arlen_buff then
                        state <= state_wait;
                    end if;
                -- block in ERROR mode.
                when state_error=>
                end case;
            end if;
        end if;
    end process;

end Behavioral;
