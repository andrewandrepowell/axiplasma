library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package plasoc_timer_pack is

    -- Default Interrupt Controller parameters. These values are modifiable. If these parameters are 
	-- modified, though, modifications will also be necessary for the corresponding header file. 
    constant default_timer_width : integer := 32;                                       --! Defines the width of the timer's Trigger and Tick Value registers.
    constant default_timer_axi_control_offset : integer := 0;                           --! For the Control register, defines the default offset from the instantiation's base address
    constant default_timer_axi_control_start_bit_loc : integer := 0;                    --! For the Start bit, defines the bit location in the Control register.
    constant default_timer_axi_control_reload_bit_loc : integer := 1;                   --! For the Reload bit, defines the bit location in the Control register.
    constant default_timer_axi_control_ack_bit_loc : integer := 2;                      --! For the Ack bit, defines the bit location in the Control register.
    constant default_timer_axi_control_done_bit_loc : integer := 3;                     --! For the Done bit, defines the bit location in the Control register.
    constant default_timer_axi_trig_value_offset : integer := 4;                        --! For the Trigger Value register, defines the default offset from the instantiation's base address.
    constant default_timer_axi_tick_value_offset : integer := 8;                        --! For the Tick Value register, defines the default offset from the instantiation's base address.

    constant axi_resp_okay : std_logic_vector := "00";
    
    function remove_baseFaddress(  address : in std_logic_vector; base_address : in std_logic_vector ) return std_logic_vector;

    component plasoc_timer is
        generic (
            timer_width : integer := default_timer_width;
            axi_address_width : integer := 16;
            axi_data_width : integer := 32;
            axi_base_address : std_logic_vector := X"0000";
            axi_control_offset : integer := default_timer_axi_control_offset;
            axi_control_start_bit_loc : integer := default_timer_axi_control_start_bit_loc;
            axi_control_reload_bit_loc : integer := default_timer_axi_control_reload_bit_loc;
            axi_control_ack_bit_loc : integer := default_timer_axi_control_ack_bit_loc;
            axi_control_done_bit_loc : integer := default_timer_axi_control_done_bit_loc;
            axi_trig_value_offset : integer := default_timer_axi_trig_value_offset;
            axi_tick_value_offset : integer := default_timer_axi_tick_value_offset);
        port (
            aclk : in std_logic;
            aresetn : in std_logic;
            axi_awaddr : in std_logic_vector(axi_address_width-1 downto 0);
            axi_awprot : in std_logic_vector(2 downto 0);
            axi_awvalid : in std_logic;
            axi_awready : out std_logic;
            axi_wvalid : in std_logic;
            axi_wready : out std_logic;
            axi_wdata : in std_logic_vector(axi_data_width-1 downto 0);
            axi_wstrb : in std_logic_vector(axi_data_width/8-1 downto 0);
            axi_bvalid : out std_logic;
            axi_bready : in std_logic;
            axi_bresp : out std_logic_vector(1 downto 0);
            axi_araddr : in std_logic_vector(axi_address_width-1 downto 0);
            axi_arprot : in std_logic_vector(2 downto 0);
            axi_arvalid : in std_logic;
            axi_arready : out std_logic;
            axi_rdata : out std_logic_vector(axi_data_width-1 downto 0) := (others=>'0');
            axi_rvalid : out std_logic;
            axi_rready : in std_logic;
            axi_rresp : out std_logic_vector(1 downto 0);
            done : out std_logic);
    end component;
end;

package body plasoc_timer_pack is

    function remove_baseFaddress(  address : in std_logic_vector; base_address : in std_logic_vector ) return std_logic_vector is
        variable result : std_logic_vector(base_address'length-1 downto 0);
        variable address_0 : integer :=  to_integer(unsigned(address));
        variable base_address_0 : integer :=  to_integer(unsigned(base_address));
    begin
        result := std_logic_vector(to_unsigned(address_0-base_address_0,base_address'length));
        return result;
    end;

end;