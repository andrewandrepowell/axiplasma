-------------------------------------------------------
--! @author Andrew Powell
--! @date March 16, 2017
--! @brief Contains the entity and architecture of the 
--! Wrapper Plasma-SoC Top Module.
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.plasoc_cpu_pack.plasoc_cpu;
use work.plasoc_int_pack.plasoc_int;
use work.plasoc_int_pack.default_interrupt_total;
use work.plasoc_timer_pack.plasoc_timer;
use work.plasoc_gpio_pack.plasoc_gpio;
use work.plasoc_uart_pack.plasoc_uart;
use work.plasoc_0_crossbar_wrap_pack.plasoc_0_crossbar_wrap; 
use work.plasoc_0_crossbar_wrap_pack.clogb2;
use work.plasoc_axi4_full2lite_pack.plasoc_axi4_full2lite;
use work.vc707_pack.vc707_default_gpio_width;

entity axiplasma_wrapper is
    generic (
        lower_app : string := "boot";
        upper_app : string := "none";
        upper_ext : boolean := true); -- Setting upper_ext to false for hardware deployment isn't supported!
    port( 
        sys_clk_p : in std_logic; -- 200 MHz on the VC707.
        sys_clk_n : in std_logic; -- 200 MHz on the VC707.
        sys_rst : in std_logic;
        gpio_output : out std_logic_vector(vc707_default_gpio_width-1 downto 0);
        gpio_input : in std_logic_vector(vc707_default_gpio_width-1 downto 0);
        uart_tx : out std_logic;
        uart_rx : in std_logic;
        DDR3_addr : out std_logic_vector(13 downto 0);
        DDR3_ba : out std_logic_vector(2 downto 0);
        DDR3_cas_n : out std_logic;
        DDR3_ck_n : out std_logic_vector(0 downto 0);
        DDR3_ck_p : out std_logic_vector(0 downto 0);
        DDR3_cke : out std_logic_vector(0 downto 0);
        DDR3_cs_n : out std_logic_vector(0 downto 0);
        DDR3_dm : out std_logic_vector(7 downto 0);
        DDR3_dq : inout std_logic_vector(63 downto 0);
        DDR3_dqs_n : inout std_logic_vector(7 downto 0);
        DDR3_dqs_p : inout std_logic_vector(7 downto 0);
        DDR3_odt : out std_logic_vector(0 downto 0);
        DDR3_ras_n : out std_logic;
        DDR3_reset_n : out std_logic;
        DDR3_we_n : out std_logic);
end axiplasma_wrapper;

architecture Behavioral of axiplasma_wrapper is
    component clk_wiz_0 is
        port (
            aclk : out std_logic;
            sys_rst : in std_logic;
            locked : out std_logic;
            sys_clk_p : in std_logic;
            sys_clk_n : in std_logic);
    end component;
    component proc_sys_reset_0 IS
        PORT (
            slowest_sync_clk : IN STD_LOGIC;
            ext_reset_in : IN STD_LOGIC;
            aux_reset_in : IN STD_LOGIC;
            mb_debug_sys_rst : IN STD_LOGIC;
            dcm_locked : IN STD_LOGIC;
            mb_reset : OUT STD_LOGIC;
            bus_struct_reset : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            peripheral_reset : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            interconnect_aresetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            peripheral_aresetn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
    end component;
    component mig_wrap_wrapper is
        port (
            DDR3_addr : out STD_LOGIC_VECTOR ( 13 downto 0 );
            DDR3_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
            DDR3_cas_n : out STD_LOGIC;
            DDR3_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
            DDR3_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
            DDR3_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
            DDR3_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
            DDR3_dm : out STD_LOGIC_VECTOR ( 7 downto 0 );
            DDR3_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
            DDR3_dqs_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
            DDR3_dqs_p : inout STD_LOGIC_VECTOR ( 7 downto 0 );
            DDR3_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
            DDR3_ras_n : out STD_LOGIC;
            DDR3_reset_n : out STD_LOGIC;
            DDR3_we_n : out STD_LOGIC;
            S00_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
            S00_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
            S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_arready : out STD_LOGIC;
            S00_AXI_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_arvalid : in STD_LOGIC;
            S00_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
            S00_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
            S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_awready : out STD_LOGIC;
            S00_AXI_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_awvalid : in STD_LOGIC;
            S00_AXI_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_bready : in STD_LOGIC;
            S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_bvalid : out STD_LOGIC;
            S00_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_rlast : out STD_LOGIC;
            S00_AXI_rready : in STD_LOGIC;
            S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_rvalid : out STD_LOGIC;
            S00_AXI_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_wlast : in STD_LOGIC;
            S00_AXI_wready : out STD_LOGIC;
            S00_AXI_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_wvalid : in STD_LOGIC;
            SYS_CLK_clk_n : in STD_LOGIC;
            SYS_CLK_clk_p : in STD_LOGIC;
            interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
            peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
            sys_rst : in STD_LOGIC;
            ui_addn_clk_0 : out STD_LOGIC;
            ui_clk_sync_rst : out STD_LOGIC);
    end component;
    -- Component declarations.
    component bram is
        generic (
            select_app : string := "none"; -- jump, boot, main
            address_width : integer := 18;
            data_width : integer := 32;
            bram_depth : integer := 65536);
        port(
            bram_rst_a : in std_logic;
            bram_clk_a : in std_logic;
            bram_en_a : in std_logic;
            bram_we_a : in std_logic_vector(data_width/8-1 downto 0);
            bram_addr_a : in std_logic_vector(address_width-1 downto 0);
            bram_wrdata_a : in std_logic_vector(data_width-1 downto 0);
            bram_rddata_a : out std_logic_vector(data_width-1 downto 0) := (others=>'0'));
    end component;
    component axi_cdma_0 is
        port (
            m_axi_aclk : in std_logic;
            s_axi_lite_aclk : in std_logic;
            s_axi_lite_aresetn : in std_logic;
            cdma_introut : out std_logic;
            s_axi_lite_awready : out std_logic;
            s_axi_lite_awvalid : in std_logic;
            s_axi_lite_awaddr : in std_logic_vector(5 downto 0);
            s_axi_lite_wready : out std_logic;
            s_axi_lite_wvalid : in std_logic;
            s_axi_lite_wdata : in std_logic_vector(31 downto 0);
            s_axi_lite_bready : in std_logic;
            s_axi_lite_bvalid : out std_logic;
            s_axi_lite_bresp : out std_logic_vector(1 downto 0);
            s_axi_lite_arready : out std_logic;
            s_axi_lite_arvalid : in std_logic;
            s_axi_lite_araddr : in std_logic_vector(5 downto 0);
            s_axi_lite_rready : in std_logic;
            s_axi_lite_rvalid : out std_logic;
            s_axi_lite_rdata : out std_logic_vector(31 downto 0);
            s_axi_lite_rresp : out std_logic_vector(1 downto 0);
            m_axi_arready : in std_logic;
            m_axi_arvalid : out std_logic;
            m_axi_araddr : out std_logic_vector(31 downto 0);
            m_axi_arlen : out std_logic_vector(7 downto 0);
            m_axi_arsize : out std_logic_vector(2 downto 0);
            m_axi_arburst : out std_logic_vector(1 downto 0);
            m_axi_arprot : out std_logic_vector(2 downto 0);
            m_axi_arcache : out std_logic_vector(3 downto 0);
            m_axi_rready : out std_logic;
            m_axi_rvalid : in std_logic;
            m_axi_rdata : in std_logic_vector(31 downto 0);
            m_axi_rresp : in std_logic_vector(1 downto 0);
            m_axi_rlast : in std_logic;
            m_axi_awready : in std_logic;
            m_axi_awvalid : out std_logic;
            m_axi_awaddr : out std_logic_vector(31 downto 0);
            m_axi_awlen : out std_logic_vector(7 downto 0);
            m_axi_awsize : out std_logic_vector(2 downto 0);
            m_axi_awburst : out std_logic_vector(1 downto 0);
            m_axi_awprot : out std_logic_vector(2 downto 0);
            m_axi_awcache : out std_logic_vector(3 downto 0);
            m_axi_wready : in std_logic;
            m_axi_wvalid : out std_logic;
            m_axi_wdata : out std_logic_vector(31 downto 0);
            m_axi_wstrb : out std_logic_vector(3 downto 0);
            m_axi_wlast : out std_logic;
            m_axi_bready : out std_logic;
            m_axi_bvalid : in std_logic;
            m_axi_bresp : in std_logic_vector(1 downto 0);
            cdma_tvect_out : out std_logic_vector(31 downto 0));
    end component;
    component axi_bram_ctrl_0 is
        port (
            s_axi_aclk : in std_logic;
            s_axi_aresetn : in std_logic;
            s_axi_awid : in std_logic_vector(0 downto 0);
            s_axi_awaddr : in std_logic_vector(15 downto 0);
            s_axi_awlen : in std_logic_vector(7 downto 0);
            s_axi_awsize : in std_logic_vector(2 downto 0);
            s_axi_awburst : in std_logic_vector(1 downto 0);
            s_axi_awlock : in std_logic;
            s_axi_awcache : in std_logic_vector(3 downto 0);
            s_axi_awprot : in std_logic_vector(2 downto 0);
            s_axi_awvalid : in std_logic;
            s_axi_awready : out std_logic;
            s_axi_wdata : in std_logic_vector(31 downto 0);
            s_axi_wstrb : in std_logic_vector(3 downto 0);
            s_axi_wlast : in std_logic;
            s_axi_wvalid : in std_logic;
            s_axi_wready : out std_logic;
            s_axi_bid : out std_logic_vector(0 downto 0);
            s_axi_bresp : out std_logic_vector(1 downto 0);
            s_axi_bvalid : out std_logic;
            s_axi_bready : in std_logic;
            s_axi_arid : in std_logic_vector(0 downto 0);
            s_axi_araddr : in std_logic_vector(15 downto 0);
            s_axi_arlen : in std_logic_vector(7 downto 0);
            s_axi_arsize : in std_logic_vector(2 downto 0);
            s_axi_arburst : in std_logic_vector(1 downto 0);
            s_axi_arlock : in std_logic;
            s_axi_arcache : in std_logic_vector(3 downto 0);
            s_axi_arprot : in std_logic_vector(2 downto 0);
            s_axi_arvalid : in std_logic;
            s_axi_arready : out std_logic;
            s_axi_rid : out std_logic_vector(0 downto 0);
            s_axi_rdata : out std_logic_vector(31 downto 0);
            s_axi_rresp : out std_logic_vector(1 downto 0);
            s_axi_rlast : out std_logic;
            s_axi_rvalid : out std_logic;
            s_axi_rready : in std_logic;
            bram_rst_a : out std_logic;
            bram_clk_a : out std_logic;
            bram_en_a : out std_logic;
            bram_we_a : out std_logic_vector(3 downto 0);
            bram_addr_a : out std_logic_vector(15 downto 0);
            bram_wrdata_a : out std_logic_vector(31 downto 0);
            bram_rddata_a : in std_logic_vector(31 downto 0));
    end component;
    component axi_bram_ctrl_1 is
        port (
            s_axi_aclk : in std_logic;
            s_axi_aresetn : in std_logic;
            s_axi_awid : in std_logic_vector(0 downto 0);
            s_axi_awaddr : in std_logic_vector(17 downto 0);
            s_axi_awlen : in std_logic_vector(7 downto 0);
            s_axi_awsize : in std_logic_vector(2 downto 0);
            s_axi_awburst : in std_logic_vector(1 downto 0);
            s_axi_awlock : in std_logic;
            s_axi_awcache : in std_logic_vector(3 downto 0);
            s_axi_awprot : in std_logic_vector(2 downto 0);
            s_axi_awvalid : in std_logic;
            s_axi_awready : out std_logic;
            s_axi_wdata : in std_logic_vector(31 downto 0);
            s_axi_wstrb : in std_logic_vector(3 downto 0);
            s_axi_wlast : in std_logic;
            s_axi_wvalid : in std_logic;
            s_axi_wready : out std_logic;
            s_axi_bid : out std_logic_vector(0 downto 0);
            s_axi_bresp : out std_logic_vector(1 downto 0);
            s_axi_bvalid : out std_logic;
            s_axi_bready : in std_logic;
            s_axi_arid : in std_logic_vector(0 downto 0);
            s_axi_araddr : in std_logic_vector(17 downto 0);
            s_axi_arlen : in std_logic_vector(7 downto 0);
            s_axi_arsize : in std_logic_vector(2 downto 0);
            s_axi_arburst : in std_logic_vector(1 downto 0);
            s_axi_arlock : in std_logic;
            s_axi_arcache : in std_logic_vector(3 downto 0);
            s_axi_arprot : in std_logic_vector(2 downto 0);
            s_axi_arvalid : in std_logic;
            s_axi_arready : out std_logic;
            s_axi_rid : out std_logic_vector(0 downto 0);
            s_axi_rdata : out std_logic_vector(31 downto 0);
            s_axi_rresp : out std_logic_vector(1 downto 0);
            s_axi_rlast : out std_logic;
            s_axi_rvalid : out std_logic;
            s_axi_rready : in std_logic;
            bram_rst_a : out std_logic;
            bram_clk_a : out std_logic;
            bram_en_a : out std_logic;
            bram_we_a : out std_logic_vector(3 downto 0);
            bram_addr_a : out std_logic_vector(17 downto 0);
            bram_wrdata_a : out std_logic_vector(31 downto 0);
            bram_rddata_a : in std_logic_vector(31 downto 0));
    end component;
    constant axi_address_width : integer := 32;
    constant axi_data_width : integer := 32;
    constant axi_master_amount : integer := 5;
    constant axi_slave_amount : integer := 2;
    constant axi_slave_id_width : integer := 0;
    constant axi_master_id_width : integer := clogb2(axi_slave_amount)+axi_slave_id_width;
    constant axi_lite_address_width : integer := 16; -- a misnomer. 
    constant axi_ram_address_width : integer := 18;
    constant axi_ram_depth : integer := 65536;
    signal aclk : std_logic;
    signal ddr_reset : std_logic;
    signal ddr_clock : std_logic;
    signal aresetn : std_logic_vector(0 downto 0);
    signal cross_aresetn : std_logic_vector(0 downto 0);
    signal dcm_locked : std_logic;
    signal cpu_axi_full_awid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cpu_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal cpu_axi_full_awlen : std_logic_vector(7 downto 0);
    signal cpu_axi_full_awsize : std_logic_vector(2 downto 0);
    signal cpu_axi_full_awburst : std_logic_vector(1 downto 0);
    signal cpu_axi_full_awlock : std_logic;
    signal cpu_axi_full_awcache : std_logic_vector(3 downto 0);
    signal cpu_axi_full_awprot : std_logic_vector(2 downto 0);
    signal cpu_axi_full_awqos : std_logic_vector(3 downto 0);
    signal cpu_axi_full_awregion : std_logic_vector(3 downto 0);
    signal cpu_axi_full_awvalid : std_logic;
    signal cpu_axi_full_awready : std_logic;
    signal cpu_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cpu_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal cpu_axi_full_wlast : std_logic;
    signal cpu_axi_full_wvalid : std_logic;
    signal cpu_axi_full_wready : std_logic;
    signal cpu_axi_full_bid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cpu_axi_full_bresp : std_logic_vector(1 downto 0);
    signal cpu_axi_full_bvalid : std_logic;
    signal cpu_axi_full_bready : std_logic;
    signal cpu_axi_full_arid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cpu_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal cpu_axi_full_arlen : std_logic_vector(7 downto 0);
    signal cpu_axi_full_arsize : std_logic_vector(2 downto 0);
    signal cpu_axi_full_arburst : std_logic_vector(1 downto 0);
    signal cpu_axi_full_arlock : std_logic;
    signal cpu_axi_full_arcache : std_logic_vector(3 downto 0);
    signal cpu_axi_full_arprot : std_logic_vector(2 downto 0);
    signal cpu_axi_full_arqos : std_logic_vector(3 downto 0);
    signal cpu_axi_full_arregion : std_logic_vector(3 downto 0);
    signal cpu_axi_full_arvalid : std_logic;
    signal cpu_axi_full_arready : std_logic;
    signal cpu_axi_full_rid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cpu_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cpu_axi_full_rresp : std_logic_vector(1 downto 0);
    signal cpu_axi_full_rlast : std_logic;
    signal cpu_axi_full_rvalid : std_logic;
    signal cpu_axi_full_rready : std_logic;
    signal cdma_axi_full_awid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cdma_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal cdma_axi_full_awlen : std_logic_vector(7 downto 0);
    signal cdma_axi_full_awsize : std_logic_vector(2 downto 0);
    signal cdma_axi_full_awburst : std_logic_vector(1 downto 0);
    signal cdma_axi_full_awlock : std_logic;
    signal cdma_axi_full_awcache : std_logic_vector(3 downto 0);
    signal cdma_axi_full_awprot : std_logic_vector(2 downto 0);
    signal cdma_axi_full_awqos : std_logic_vector(3 downto 0);
    signal cdma_axi_full_awregion : std_logic_vector(3 downto 0);
    signal cdma_axi_full_awvalid : std_logic;
    signal cdma_axi_full_awready : std_logic;
    signal cdma_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cdma_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal cdma_axi_full_wlast : std_logic;
    signal cdma_axi_full_wvalid : std_logic;
    signal cdma_axi_full_wready : std_logic;
    signal cdma_axi_full_bid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cdma_axi_full_bresp : std_logic_vector(1 downto 0);
    signal cdma_axi_full_bvalid : std_logic;
    signal cdma_axi_full_bready : std_logic;
    signal cdma_axi_full_arid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cdma_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal cdma_axi_full_arlen : std_logic_vector(7 downto 0);
    signal cdma_axi_full_arsize : std_logic_vector(2 downto 0);
    signal cdma_axi_full_arburst : std_logic_vector(1 downto 0);
    signal cdma_axi_full_arlock : std_logic;
    signal cdma_axi_full_arcache : std_logic_vector(3 downto 0);
    signal cdma_axi_full_arprot : std_logic_vector(2 downto 0);
    signal cdma_axi_full_arqos : std_logic_vector(3 downto 0);
    signal cdma_axi_full_arregion : std_logic_vector(3 downto 0);
    signal cdma_axi_full_arvalid : std_logic;
    signal cdma_axi_full_arready : std_logic;
    signal cdma_axi_full_rid : std_logic_vector(axi_slave_id_width-1 downto 0);
    signal cdma_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cdma_axi_full_rresp : std_logic_vector(1 downto 0);
    signal cdma_axi_full_rlast : std_logic;
    signal cdma_axi_full_rvalid : std_logic;
    signal cdma_axi_full_rready : std_logic;
    signal bram_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal bram_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal bram_axi_full_awlen : std_logic_vector(7 downto 0);
    signal bram_axi_full_awsize : std_logic_vector(2 downto 0);
    signal bram_axi_full_awburst : std_logic_vector(1 downto 0);
    signal bram_axi_full_awlock : std_logic;
    signal bram_axi_full_awcache : std_logic_vector(3 downto 0);
    signal bram_axi_full_awprot : std_logic_vector(2 downto 0);
    signal bram_axi_full_awqos : std_logic_vector(3 downto 0);
    signal bram_axi_full_awregion : std_logic_vector(3 downto 0);
    signal bram_axi_full_awvalid : std_logic;
    signal bram_axi_full_awready : std_logic;
    signal bram_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal bram_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal bram_axi_full_wlast : std_logic;
    signal bram_axi_full_wvalid : std_logic;
    signal bram_axi_full_wready : std_logic;
    signal bram_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal bram_axi_full_bresp : std_logic_vector(1 downto 0);
    signal bram_axi_full_bvalid : std_logic;
    signal bram_axi_full_bready : std_logic;
    signal bram_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal bram_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal bram_axi_full_arlen : std_logic_vector(7 downto 0);
    signal bram_axi_full_arsize : std_logic_vector(2 downto 0);
    signal bram_axi_full_arburst : std_logic_vector(1 downto 0);
    signal bram_axi_full_arlock : std_logic;
    signal bram_axi_full_arcache : std_logic_vector(3 downto 0);
    signal bram_axi_full_arprot : std_logic_vector(2 downto 0);
    signal bram_axi_full_arqos : std_logic_vector(3 downto 0);
    signal bram_axi_full_arregion : std_logic_vector(3 downto 0);
    signal bram_axi_full_arvalid : std_logic;
    signal bram_axi_full_arready : std_logic;
    signal bram_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal bram_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal bram_axi_full_rresp : std_logic_vector(1 downto 0);
    signal bram_axi_full_rlast : std_logic;
    signal bram_axi_full_rvalid : std_logic;
    signal bram_axi_full_rready : std_logic;
    signal bram_bram_rst_a : STD_LOGIC;
    signal bram_bram_clk_a : STD_LOGIC;
    signal bram_bram_en_a : STD_LOGIC;
    signal bram_bram_we_a : STD_LOGIC_VECTOR(axi_data_width/8-1 DOWNTO 0);
    signal bram_bram_addr_a : STD_LOGIC_VECTOR(axi_lite_address_width-1 DOWNTO 0);
    signal bram_bram_wrdata_a : STD_LOGIC_VECTOR(axi_data_width-1 DOWNTO 0);
    signal bram_bram_rddata_a : STD_LOGIC_VECTOR(axi_data_width-1 DOWNTO 0);
    signal ram_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal ram_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal ram_axi_full_awlen : std_logic_vector(7 downto 0);
    signal ram_axi_full_awsize : std_logic_vector(2 downto 0);
    signal ram_axi_full_awburst : std_logic_vector(1 downto 0);
    signal ram_axi_full_awlock : std_logic;
    signal ram_axi_full_awcache : std_logic_vector(3 downto 0);
    signal ram_axi_full_awprot : std_logic_vector(2 downto 0);
    signal ram_axi_full_awqos : std_logic_vector(3 downto 0);
    signal ram_axi_full_awregion : std_logic_vector(3 downto 0);
    signal ram_axi_full_awvalid : std_logic;
    signal ram_axi_full_awready : std_logic;
    signal ram_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal ram_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal ram_axi_full_wlast : std_logic;
    signal ram_axi_full_wvalid : std_logic;
    signal ram_axi_full_wready : std_logic;
    signal ram_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal ram_axi_full_bresp : std_logic_vector(1 downto 0);
    signal ram_axi_full_bvalid : std_logic;
    signal ram_axi_full_bready : std_logic;
    signal ram_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal ram_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal ram_axi_full_arlen : std_logic_vector(7 downto 0);
    signal ram_axi_full_arsize : std_logic_vector(2 downto 0);
    signal ram_axi_full_arburst : std_logic_vector(1 downto 0);
    signal ram_axi_full_arlock : std_logic;
    signal ram_axi_full_arcache : std_logic_vector(3 downto 0);
    signal ram_axi_full_arprot : std_logic_vector(2 downto 0);
    signal ram_axi_full_arqos : std_logic_vector(3 downto 0);
    signal ram_axi_full_arregion : std_logic_vector(3 downto 0);
    signal ram_axi_full_arvalid : std_logic;
    signal ram_axi_full_arready : std_logic;
    signal ram_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal ram_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal ram_axi_full_rresp : std_logic_vector(1 downto 0);
    signal ram_axi_full_rlast : std_logic;
    signal ram_axi_full_rvalid : std_logic;
    signal ram_axi_full_rready : std_logic;
    signal ram_axi_full_arlock_slv : std_logic_vector (0 downto 0);
    signal ram_axi_full_awlock_slv : std_logic_vector (0 downto 0);
    signal ram_axi_full_arid_slv : std_logic_vector(3 downto 0) := (others=>'0');
    signal ram_axi_full_awid_slv : std_logic_vector(3 downto 0) := (others=>'0');
    signal ram_axi_full_bid_slv : std_logic_vector(3 downto 0) := (others=>'0');
    signal ram_axi_full_rid_slv : std_logic_vector(3 downto 0) := (others=>'0');
    signal ram_bram_rst_a : std_logic;
    signal ram_bram_clk_a : std_logic;
    signal ram_bram_en_a : std_logic;
    signal ram_bram_we_a : std_logic_vector(axi_data_width/8-1 downto 0);
    signal ram_bram_addr_a : std_logic_vector(axi_ram_address_width-1 downto 0);
    signal ram_bram_wrdata_a : std_logic_vector(axi_data_width-1 downto 0);
    signal ram_bram_rddata_a : std_logic_vector(axi_data_width-1 downto 0);
    signal int_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal int_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal int_axi_full_awlen : std_logic_vector(7 downto 0);
    signal int_axi_full_awsize : std_logic_vector(2 downto 0);
    signal int_axi_full_awburst : std_logic_vector(1 downto 0);
    signal int_axi_full_awlock : std_logic;
    signal int_axi_full_awcache : std_logic_vector(3 downto 0);
    signal int_axi_full_awprot : std_logic_vector(2 downto 0);
    signal int_axi_full_awqos : std_logic_vector(3 downto 0);
    signal int_axi_full_awregion : std_logic_vector(3 downto 0);
    signal int_axi_full_awvalid : std_logic;
    signal int_axi_full_awready : std_logic;
    signal int_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal int_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal int_axi_full_wlast : std_logic;
    signal int_axi_full_wvalid : std_logic;
    signal int_axi_full_wready : std_logic;
    signal int_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal int_axi_full_bresp : std_logic_vector(1 downto 0);
    signal int_axi_full_bvalid : std_logic;
    signal int_axi_full_bready : std_logic;
    signal int_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal int_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal int_axi_full_arlen : std_logic_vector(7 downto 0);
    signal int_axi_full_arsize : std_logic_vector(2 downto 0);
    signal int_axi_full_arburst : std_logic_vector(1 downto 0);
    signal int_axi_full_arlock : std_logic;
    signal int_axi_full_arcache : std_logic_vector(3 downto 0);
    signal int_axi_full_arprot : std_logic_vector(2 downto 0);
    signal int_axi_full_arqos : std_logic_vector(3 downto 0);
    signal int_axi_full_arregion : std_logic_vector(3 downto 0);
    signal int_axi_full_arvalid : std_logic;
    signal int_axi_full_arready : std_logic;
    signal int_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal int_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal int_axi_full_rresp : std_logic_vector(1 downto 0);
    signal int_axi_full_rlast : std_logic;
    signal int_axi_full_rvalid : std_logic;
    signal int_axi_full_rready : std_logic;
    signal timer_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal timer_axi_full_awlen : std_logic_vector(7 downto 0);
    signal timer_axi_full_awsize : std_logic_vector(2 downto 0);
    signal timer_axi_full_awburst : std_logic_vector(1 downto 0);
    signal timer_axi_full_awlock : std_logic;
    signal timer_axi_full_awcache : std_logic_vector(3 downto 0);
    signal timer_axi_full_awprot : std_logic_vector(2 downto 0);
    signal timer_axi_full_awqos : std_logic_vector(3 downto 0);
    signal timer_axi_full_awregion : std_logic_vector(3 downto 0);
    signal timer_axi_full_awvalid : std_logic;
    signal timer_axi_full_awready : std_logic;
    signal timer_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal timer_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal timer_axi_full_wlast : std_logic;
    signal timer_axi_full_wvalid : std_logic;
    signal timer_axi_full_wready : std_logic;
    signal timer_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_axi_full_bresp : std_logic_vector(1 downto 0);
    signal timer_axi_full_bvalid : std_logic;
    signal timer_axi_full_bready : std_logic;
    signal timer_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal timer_axi_full_arlen : std_logic_vector(7 downto 0);
    signal timer_axi_full_arsize : std_logic_vector(2 downto 0);
    signal timer_axi_full_arburst : std_logic_vector(1 downto 0);
    signal timer_axi_full_arlock : std_logic;
    signal timer_axi_full_arcache : std_logic_vector(3 downto 0);
    signal timer_axi_full_arprot : std_logic_vector(2 downto 0);
    signal timer_axi_full_arqos : std_logic_vector(3 downto 0);
    signal timer_axi_full_arregion : std_logic_vector(3 downto 0);
    signal timer_axi_full_arvalid : std_logic;
    signal timer_axi_full_arready : std_logic;
    signal timer_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal timer_axi_full_rresp : std_logic_vector(1 downto 0);
    signal timer_axi_full_rlast : std_logic;
    signal timer_axi_full_rvalid : std_logic;
    signal timer_axi_full_rready : std_logic;
    signal gpio_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal gpio_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal gpio_axi_full_awlen : std_logic_vector(7 downto 0);
    signal gpio_axi_full_awsize : std_logic_vector(2 downto 0);
    signal gpio_axi_full_awburst : std_logic_vector(1 downto 0);
    signal gpio_axi_full_awlock : std_logic;
    signal gpio_axi_full_awcache : std_logic_vector(3 downto 0);
    signal gpio_axi_full_awprot : std_logic_vector(2 downto 0);
    signal gpio_axi_full_awqos : std_logic_vector(3 downto 0);
    signal gpio_axi_full_awregion : std_logic_vector(3 downto 0);
    signal gpio_axi_full_awvalid : std_logic;
    signal gpio_axi_full_awready : std_logic;
    signal gpio_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal gpio_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal gpio_axi_full_wlast : std_logic;
    signal gpio_axi_full_wvalid : std_logic;
    signal gpio_axi_full_wready : std_logic;
    signal gpio_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal gpio_axi_full_bresp : std_logic_vector(1 downto 0);
    signal gpio_axi_full_bvalid : std_logic;
    signal gpio_axi_full_bready : std_logic;
    signal gpio_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal gpio_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal gpio_axi_full_arlen : std_logic_vector(7 downto 0);
    signal gpio_axi_full_arsize : std_logic_vector(2 downto 0);
    signal gpio_axi_full_arburst : std_logic_vector(1 downto 0);
    signal gpio_axi_full_arlock : std_logic;
    signal gpio_axi_full_arcache : std_logic_vector(3 downto 0);
    signal gpio_axi_full_arprot : std_logic_vector(2 downto 0);
    signal gpio_axi_full_arqos : std_logic_vector(3 downto 0);
    signal gpio_axi_full_arregion : std_logic_vector(3 downto 0);
    signal gpio_axi_full_arvalid : std_logic;
    signal gpio_axi_full_arready : std_logic;
    signal gpio_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal gpio_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal gpio_axi_full_rresp : std_logic_vector(1 downto 0);
    signal gpio_axi_full_rlast : std_logic;
    signal gpio_axi_full_rvalid : std_logic;
    signal gpio_axi_full_rready : std_logic;
    signal cdmareg_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal cdmareg_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal cdmareg_axi_full_awlen : std_logic_vector(7 downto 0);
    signal cdmareg_axi_full_awsize : std_logic_vector(2 downto 0);
    signal cdmareg_axi_full_awburst : std_logic_vector(1 downto 0);
    signal cdmareg_axi_full_awlock : std_logic;
    signal cdmareg_axi_full_awcache : std_logic_vector(3 downto 0);
    signal cdmareg_axi_full_awprot : std_logic_vector(2 downto 0);
    signal cdmareg_axi_full_awqos : std_logic_vector(3 downto 0);
    signal cdmareg_axi_full_awregion : std_logic_vector(3 downto 0);
    signal cdmareg_axi_full_awvalid : std_logic;
    signal cdmareg_axi_full_awready : std_logic;
    signal cdmareg_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cdmareg_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal cdmareg_axi_full_wlast : std_logic;
    signal cdmareg_axi_full_wvalid : std_logic;
    signal cdmareg_axi_full_wready : std_logic;
    signal cdmareg_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal cdmareg_axi_full_bresp : std_logic_vector(1 downto 0);
    signal cdmareg_axi_full_bvalid : std_logic;
    signal cdmareg_axi_full_bready : std_logic;
    signal cdmareg_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal cdmareg_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal cdmareg_axi_full_arlen : std_logic_vector(7 downto 0);
    signal cdmareg_axi_full_arsize : std_logic_vector(2 downto 0);
    signal cdmareg_axi_full_arburst : std_logic_vector(1 downto 0);
    signal cdmareg_axi_full_arlock : std_logic;
    signal cdmareg_axi_full_arcache : std_logic_vector(3 downto 0);
    signal cdmareg_axi_full_arprot : std_logic_vector(2 downto 0);
    signal cdmareg_axi_full_arqos : std_logic_vector(3 downto 0);
    signal cdmareg_axi_full_arregion : std_logic_vector(3 downto 0);
    signal cdmareg_axi_full_arvalid : std_logic;
    signal cdmareg_axi_full_arready : std_logic;
    signal cdmareg_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal cdmareg_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cdmareg_axi_full_rresp : std_logic_vector(1 downto 0);
    signal cdmareg_axi_full_rlast : std_logic;
    signal cdmareg_axi_full_rvalid : std_logic;
    signal cdmareg_axi_full_rready : std_logic;
    signal timer_extra_0_axi_full_awid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_extra_0_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal timer_extra_0_axi_full_awlen : std_logic_vector(7 downto 0);
    signal timer_extra_0_axi_full_awsize : std_logic_vector(2 downto 0);
    signal timer_extra_0_axi_full_awburst : std_logic_vector(1 downto 0);
    signal timer_extra_0_axi_full_awlock : std_logic;
    signal timer_extra_0_axi_full_awcache : std_logic_vector(3 downto 0);
    signal timer_extra_0_axi_full_awprot : std_logic_vector(2 downto 0);
    signal timer_extra_0_axi_full_awqos : std_logic_vector(3 downto 0);
    signal timer_extra_0_axi_full_awregion : std_logic_vector(3 downto 0);
    signal timer_extra_0_axi_full_awvalid : std_logic;
    signal timer_extra_0_axi_full_awready : std_logic;
    signal timer_extra_0_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal timer_extra_0_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal timer_extra_0_axi_full_wlast : std_logic;
    signal timer_extra_0_axi_full_wvalid : std_logic;
    signal timer_extra_0_axi_full_wready : std_logic;
    signal timer_extra_0_axi_full_bid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_extra_0_axi_full_bresp : std_logic_vector(1 downto 0);
    signal timer_extra_0_axi_full_bvalid : std_logic;
    signal timer_extra_0_axi_full_bready : std_logic;
    signal timer_extra_0_axi_full_arid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_extra_0_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal timer_extra_0_axi_full_arlen : std_logic_vector(7 downto 0);
    signal timer_extra_0_axi_full_arsize : std_logic_vector(2 downto 0);
    signal timer_extra_0_axi_full_arburst : std_logic_vector(1 downto 0);
    signal timer_extra_0_axi_full_arlock : std_logic;
    signal timer_extra_0_axi_full_arcache : std_logic_vector(3 downto 0);
    signal timer_extra_0_axi_full_arprot : std_logic_vector(2 downto 0);
    signal timer_extra_0_axi_full_arqos : std_logic_vector(3 downto 0);
    signal timer_extra_0_axi_full_arregion : std_logic_vector(3 downto 0);
    signal timer_extra_0_axi_full_arvalid : std_logic;
    signal timer_extra_0_axi_full_arready : std_logic;
    signal timer_extra_0_axi_full_rid : std_logic_vector(axi_master_id_width-1 downto 0);
    signal timer_extra_0_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal timer_extra_0_axi_full_rresp : std_logic_vector(1 downto 0);
    signal timer_extra_0_axi_full_rlast : std_logic;
    signal timer_extra_0_axi_full_rvalid : std_logic;
    signal timer_extra_0_axi_full_rready : std_logic;
    signal uart_axi_full_awid : std_logic_vector((clogb2(axi_slave_amount)+axi_slave_id_width)-1 downto 0);
    signal uart_axi_full_awaddr : std_logic_vector(axi_address_width-1 downto 0);
    signal uart_axi_full_awlen : std_logic_vector(7 downto 0);
    signal uart_axi_full_awsize : std_logic_vector(2 downto 0);
    signal uart_axi_full_awburst : std_logic_vector(1 downto 0);
    signal uart_axi_full_awlock : std_logic;
    signal uart_axi_full_awcache : std_logic_vector(3 downto 0);
    signal uart_axi_full_awprot : std_logic_vector(2 downto 0);
    signal uart_axi_full_awqos : std_logic_vector(3 downto 0);
    signal uart_axi_full_awregion : std_logic_vector(3 downto 0);
    signal uart_axi_full_awvalid : std_logic;
    signal uart_axi_full_awready : std_logic;
    signal uart_axi_full_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal uart_axi_full_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal uart_axi_full_wlast : std_logic;
    signal uart_axi_full_wvalid : std_logic;
    signal uart_axi_full_wready : std_logic;
    signal uart_axi_full_bid : std_logic_vector((clogb2(axi_slave_amount)+axi_slave_id_width)-1 downto 0);
    signal uart_axi_full_bresp : std_logic_vector(1 downto 0);
    signal uart_axi_full_bvalid : std_logic;
    signal uart_axi_full_bready : std_logic;
    signal uart_axi_full_arid : std_logic_vector((clogb2(axi_slave_amount)+axi_slave_id_width)-1 downto 0);
    signal uart_axi_full_araddr : std_logic_vector(axi_address_width-1 downto 0);
    signal uart_axi_full_arlen : std_logic_vector(7 downto 0);
    signal uart_axi_full_arsize : std_logic_vector(2 downto 0);
    signal uart_axi_full_arburst : std_logic_vector(1 downto 0);
    signal uart_axi_full_arlock : std_logic;
    signal uart_axi_full_arcache : std_logic_vector(3 downto 0);
    signal uart_axi_full_arprot : std_logic_vector(2 downto 0);
    signal uart_axi_full_arqos : std_logic_vector(3 downto 0);
    signal uart_axi_full_arregion : std_logic_vector(3 downto 0);
    signal uart_axi_full_arvalid : std_logic;
    signal uart_axi_full_arready : std_logic;
    signal uart_axi_full_rid : std_logic_vector((clogb2(axi_slave_amount)+axi_slave_id_width)-1 downto 0);
    signal uart_axi_full_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal uart_axi_full_rresp : std_logic_vector(1 downto 0);
    signal uart_axi_full_rlast : std_logic;
    signal uart_axi_full_rvalid : std_logic;
    signal uart_axi_full_rready : std_logic;
    signal int_axi_lite_awaddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal int_axi_lite_awprot : std_logic_vector(2 downto 0);
    signal int_axi_lite_awvalid : std_logic;
    signal int_axi_lite_awready : std_logic;
    signal int_axi_lite_wvalid : std_logic;
    signal int_axi_lite_wready : std_logic;
    signal int_axi_lite_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal int_axi_lite_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal int_axi_lite_bvalid : std_logic;
    signal int_axi_lite_bready : std_logic;
    signal int_axi_lite_bresp : std_logic_vector(1 downto 0);
    signal int_axi_lite_araddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal int_axi_lite_arprot : std_logic_vector(2 downto 0);
    signal int_axi_lite_arvalid : std_logic;
    signal int_axi_lite_arready : std_logic;
    signal int_axi_lite_rdata : std_logic_vector(axi_data_width-1 downto 0) := (others=>'0');
    signal int_axi_lite_rvalid : std_logic;
    signal int_axi_lite_rready : std_logic;
    signal int_axi_lite_rresp : std_logic_vector(1 downto 0);
    signal timer_axi_lite_awaddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal timer_axi_lite_awprot : std_logic_vector(2 downto 0);
    signal timer_axi_lite_awvalid : std_logic;
    signal timer_axi_lite_awready : std_logic;
    signal timer_axi_lite_wvalid : std_logic;
    signal timer_axi_lite_wready : std_logic;
    signal timer_axi_lite_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal timer_axi_lite_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal timer_axi_lite_bvalid : std_logic;
    signal timer_axi_lite_bready : std_logic;
    signal timer_axi_lite_bresp : std_logic_vector(1 downto 0);
    signal timer_axi_lite_araddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal timer_axi_lite_arprot : std_logic_vector(2 downto 0);
    signal timer_axi_lite_arvalid : std_logic;
    signal timer_axi_lite_arready : std_logic;
    signal timer_axi_lite_rdata : std_logic_vector(axi_data_width-1 downto 0) := (others=>'0');
    signal timer_axi_lite_rvalid : std_logic;
    signal timer_axi_lite_rready : std_logic;
    signal timer_axi_lite_rresp : std_logic_vector(1 downto 0);
    signal gpio_axi_lite_awaddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal gpio_axi_lite_awprot : std_logic_vector(2 downto 0);
    signal gpio_axi_lite_awvalid : std_logic;
    signal gpio_axi_lite_awready : std_logic;
    signal gpio_axi_lite_wvalid : std_logic;
    signal gpio_axi_lite_wready : std_logic;
    signal gpio_axi_lite_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal gpio_axi_lite_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal gpio_axi_lite_bvalid : std_logic;
    signal gpio_axi_lite_bready : std_logic;
    signal gpio_axi_lite_bresp : std_logic_vector(1 downto 0);
    signal gpio_axi_lite_araddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal gpio_axi_lite_arprot : std_logic_vector(2 downto 0);
    signal gpio_axi_lite_arvalid : std_logic;
    signal gpio_axi_lite_arready : std_logic;
    signal gpio_axi_lite_rdata : std_logic_vector(axi_data_width-1 downto 0) := (others=>'0');
    signal gpio_axi_lite_rvalid : std_logic;
    signal gpio_axi_lite_rready : std_logic;
    signal gpio_axi_lite_rresp : std_logic_vector(1 downto 0);
    signal cdmareg_axi_lite_awaddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal cdmareg_axi_lite_awprot : std_logic_vector(2 downto 0);
    signal cdmareg_axi_lite_awvalid : std_logic;
    signal cdmareg_axi_lite_awready : std_logic;
    signal cdmareg_axi_lite_wvalid : std_logic;
    signal cdmareg_axi_lite_wready : std_logic;
    signal cdmareg_axi_lite_wdata : std_logic_vector(axi_data_width-1 downto 0);
    signal cdmareg_axi_lite_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);
    signal cdmareg_axi_lite_bvalid : std_logic;
    signal cdmareg_axi_lite_bready : std_logic;
    signal cdmareg_axi_lite_bresp : std_logic_vector(1 downto 0);
    signal cdmareg_axi_lite_araddr : std_logic_vector(axi_lite_address_width-1 downto 0);
    signal cdmareg_axi_lite_arprot : std_logic_vector(2 downto 0);
    signal cdmareg_axi_lite_arvalid : std_logic;
    signal cdmareg_axi_lite_arready : std_logic;
    signal cdmareg_axi_lite_rdata : std_logic_vector(axi_data_width-1 downto 0) := (others=>'0');
    signal cdmareg_axi_lite_rvalid : std_logic;
    signal cdmareg_axi_lite_rready : std_logic;
    signal cdmareg_axi_lite_rresp : std_logic_vector(1 downto 0);
    signal uart_axi_lite_awaddr : std_logic_vector(axi_lite_address_width-1 downto 0);                 
    signal uart_axi_lite_awprot : std_logic_vector(2 downto 0);                                   
    signal uart_axi_lite_awvalid : std_logic;                                                     
    signal uart_axi_lite_awready : std_logic;                                                    
    signal uart_axi_lite_wvalid : std_logic;                                                      
    signal uart_axi_lite_wready : std_logic;                                                     
    signal uart_axi_lite_wdata : std_logic_vector(axi_data_width-1 downto 0);                     
    signal uart_axi_lite_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);                   
    signal uart_axi_lite_bvalid : std_logic;                                                     
    signal uart_axi_lite_bready : std_logic;                                                      
    signal uart_axi_lite_bresp : std_logic_vector(1 downto 0);                     
    signal uart_axi_lite_araddr : std_logic_vector(axi_lite_address_width-1 downto 0);                 
    signal uart_axi_lite_arprot : std_logic_vector(2 downto 0);                                   
    signal uart_axi_lite_arvalid : std_logic;                                                     
    signal uart_axi_lite_arready : std_logic;                                                    
    signal uart_axi_lite_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal uart_axi_lite_rvalid : std_logic;                                                     
    signal uart_axi_lite_rready : std_logic;                                                      
    signal uart_axi_lite_rresp : std_logic_vector(1 downto 0);  
    signal timer_extra_0_axi_lite_awaddr : std_logic_vector(axi_lite_address_width-1 downto 0);                 
    signal timer_extra_0_axi_lite_awprot : std_logic_vector(2 downto 0);                                   
    signal timer_extra_0_axi_lite_awvalid : std_logic;                                                     
    signal timer_extra_0_axi_lite_awready : std_logic;                                                    
    signal timer_extra_0_axi_lite_wvalid : std_logic;                                                      
    signal timer_extra_0_axi_lite_wready : std_logic;                                                     
    signal timer_extra_0_axi_lite_wdata : std_logic_vector(axi_data_width-1 downto 0);                     
    signal timer_extra_0_axi_lite_wstrb : std_logic_vector(axi_data_width/8-1 downto 0);                   
    signal timer_extra_0_axi_lite_bvalid : std_logic;                                                     
    signal timer_extra_0_axi_lite_bready : std_logic;                                                      
    signal timer_extra_0_axi_lite_bresp : std_logic_vector(1 downto 0);                     
    signal timer_extra_0_axi_lite_araddr : std_logic_vector(axi_lite_address_width-1 downto 0);                 
    signal timer_extra_0_axi_lite_arprot : std_logic_vector(2 downto 0);                                   
    signal timer_extra_0_axi_lite_arvalid : std_logic;                                                     
    signal timer_extra_0_axi_lite_arready : std_logic;                                                    
    signal timer_extra_0_axi_lite_rdata : std_logic_vector(axi_data_width-1 downto 0);
    signal timer_extra_0_axi_lite_rvalid : std_logic;                                                     
    signal timer_extra_0_axi_lite_rready : std_logic;                                                      
    signal timer_extra_0_axi_lite_rresp : std_logic_vector(1 downto 0);     
    signal cpu_int : std_logic;
    signal int_dev_ints : std_logic_vector(default_interrupt_total-1 downto 0) := (others=>'0');
    signal timer_int : std_logic;
    signal gpio_int : std_logic;
    signal cdma_int : std_logic;
    signal uart_int : std_logic;
    signal timer_extra_0_int : std_logic;
    
--    attribute mark_debug : boolean;
--    attribute mark_debug of cpu_axi_full_awaddr : signal is true;
--    attribute mark_debug of cpu_axi_full_awvalid : signal is true;
--    attribute mark_debug of cpu_axi_full_awready : signal is true;
--    attribute mark_debug of cpu_axi_full_wdata : signal is true;
--    attribute mark_debug of cpu_axi_full_wstrb : signal is true;
--    attribute mark_debug of cpu_axi_full_wlast : signal is true;
--    attribute mark_debug of cpu_axi_full_wvalid : signal is true;
--    attribute mark_debug of cpu_axi_full_wready : signal is true;
--    attribute mark_debug of cpu_axi_full_bresp : signal is true;
--    attribute mark_debug of cpu_axi_full_bvalid : signal is true;
--    attribute mark_debug of cpu_axi_full_bready : signal is true;
--    attribute mark_debug of cpu_axi_full_araddr : signal is true;
--    attribute mark_debug of cpu_axi_full_arvalid : signal is true;
--    attribute mark_debug of cpu_axi_full_arready : signal is true;
--    attribute mark_debug of cpu_axi_full_rdata : signal is true;
--    attribute mark_debug of cpu_axi_full_rlast : signal is true;
--    attribute mark_debug of cpu_axi_full_rvalid : signal is true;
--    attribute mark_debug of cpu_axi_full_rready : signal is true;
begin
    int_dev_ints(0) <= timer_int;
    int_dev_ints(1) <= gpio_int;
    int_dev_ints(2) <= cdma_int;
    int_dev_ints(3) <= uart_int;
    int_dev_ints(4) <= timer_extra_0_int;
    
    cdma_axi_full_awlock <= '0';
    cdma_axi_full_arlock <= '0';
    
    ram_axi_full_arlock_slv(0) <= ram_axi_full_arlock;
    ram_axi_full_awlock_slv(0) <= ram_axi_full_awlock;
    ram_axi_full_arid_slv(axi_master_id_width-1 downto 0) <= ram_axi_full_arid;
    ram_axi_full_awid_slv(axi_master_id_width-1 downto 0) <= ram_axi_full_awid;
    ram_axi_full_bid_slv(axi_master_id_width-1 downto 0) <= ram_axi_full_bid;
    ram_axi_full_rid_slv(axi_master_id_width-1 downto 0) <= ram_axi_full_rid;
            
    -- Crossbar instantiation.
    plasoc_0_crossbar_wrap_inst : plasoc_0_crossbar_wrap
        port map (
            cpu_s_axi_awid => cpu_axi_full_awid,
            cpu_s_axi_awaddr => cpu_axi_full_awaddr,
            cpu_s_axi_awlen => cpu_axi_full_awlen,
            cpu_s_axi_awsize => cpu_axi_full_awsize,
            cpu_s_axi_awburst => cpu_axi_full_awburst,
            cpu_s_axi_awlock => cpu_axi_full_awlock,
            cpu_s_axi_awcache => cpu_axi_full_awcache,
            cpu_s_axi_awprot => cpu_axi_full_awprot,
            cpu_s_axi_awqos => cpu_axi_full_awqos,
            cpu_s_axi_awregion => cpu_axi_full_awregion,
            cpu_s_axi_awvalid => cpu_axi_full_awvalid,
            cpu_s_axi_awready => cpu_axi_full_awready,
            cpu_s_axi_wdata => cpu_axi_full_wdata,
            cpu_s_axi_wstrb => cpu_axi_full_wstrb,
            cpu_s_axi_wlast => cpu_axi_full_wlast,
            cpu_s_axi_wvalid => cpu_axi_full_wvalid,
            cpu_s_axi_wready => cpu_axi_full_wready,
            cpu_s_axi_bid => cpu_axi_full_bid,
            cpu_s_axi_bresp => cpu_axi_full_bresp,
            cpu_s_axi_bvalid => cpu_axi_full_bvalid,
            cpu_s_axi_bready => cpu_axi_full_bready,
            cpu_s_axi_arid => cpu_axi_full_arid,
            cpu_s_axi_araddr => cpu_axi_full_araddr,
            cpu_s_axi_arlen => cpu_axi_full_arlen,
            cpu_s_axi_arsize => cpu_axi_full_arsize,
            cpu_s_axi_arburst => cpu_axi_full_arburst,
            cpu_s_axi_arlock => cpu_axi_full_arlock,
            cpu_s_axi_arcache => cpu_axi_full_arcache,
            cpu_s_axi_arprot => cpu_axi_full_arprot,
            cpu_s_axi_arqos => cpu_axi_full_arqos,
            cpu_s_axi_arregion => cpu_axi_full_arregion,
            cpu_s_axi_arvalid => cpu_axi_full_arvalid,
            cpu_s_axi_arready => cpu_axi_full_arready,
            cpu_s_axi_rid => cpu_axi_full_rid,
            cpu_s_axi_rdata => cpu_axi_full_rdata,
            cpu_s_axi_rresp => cpu_axi_full_rresp,
            cpu_s_axi_rlast => cpu_axi_full_rlast,
            cpu_s_axi_rvalid => cpu_axi_full_rvalid,
            cpu_s_axi_rready => cpu_axi_full_rready,
            cdma_s_axi_awid => cdma_axi_full_awid,
            cdma_s_axi_awaddr => cdma_axi_full_awaddr,
            cdma_s_axi_awlen => cdma_axi_full_awlen,
            cdma_s_axi_awsize => cdma_axi_full_awsize,
            cdma_s_axi_awburst => cdma_axi_full_awburst,
            cdma_s_axi_awlock => cdma_axi_full_awlock,
            cdma_s_axi_awcache => cdma_axi_full_awcache,
            cdma_s_axi_awprot => cdma_axi_full_awprot,
            cdma_s_axi_awqos => cdma_axi_full_awqos,
            cdma_s_axi_awregion => cdma_axi_full_awregion,
            cdma_s_axi_awvalid => cdma_axi_full_awvalid,
            cdma_s_axi_awready => cdma_axi_full_awready,
            cdma_s_axi_wdata => cdma_axi_full_wdata,
            cdma_s_axi_wstrb => cdma_axi_full_wstrb,
            cdma_s_axi_wlast => cdma_axi_full_wlast,
            cdma_s_axi_wvalid => cdma_axi_full_wvalid,
            cdma_s_axi_wready => cdma_axi_full_wready,
            cdma_s_axi_bid => cdma_axi_full_bid,
            cdma_s_axi_bresp => cdma_axi_full_bresp,
            cdma_s_axi_bvalid => cdma_axi_full_bvalid,
            cdma_s_axi_bready => cdma_axi_full_bready,
            cdma_s_axi_arid => cdma_axi_full_arid,
            cdma_s_axi_araddr => cdma_axi_full_araddr,
            cdma_s_axi_arlen => cdma_axi_full_arlen,
            cdma_s_axi_arsize => cdma_axi_full_arsize,
            cdma_s_axi_arburst => cdma_axi_full_arburst,
            cdma_s_axi_arlock => cdma_axi_full_arlock,
            cdma_s_axi_arcache => cdma_axi_full_arcache,
            cdma_s_axi_arprot => cdma_axi_full_arprot,
            cdma_s_axi_arqos => cdma_axi_full_arqos,
            cdma_s_axi_arregion => cdma_axi_full_arregion,
            cdma_s_axi_arvalid => cdma_axi_full_arvalid,
            cdma_s_axi_arready => cdma_axi_full_arready,
            cdma_s_axi_rid => cdma_axi_full_rid,
            cdma_s_axi_rdata => cdma_axi_full_rdata,
            cdma_s_axi_rresp => cdma_axi_full_rresp,
            cdma_s_axi_rlast => cdma_axi_full_rlast,
            cdma_s_axi_rvalid => cdma_axi_full_rvalid,
            cdma_s_axi_rready => cdma_axi_full_rready,
            bram_m_axi_awid => bram_axi_full_awid,
            bram_m_axi_awaddr => bram_axi_full_awaddr,
            bram_m_axi_awlen => bram_axi_full_awlen,
            bram_m_axi_awsize => bram_axi_full_awsize,
            bram_m_axi_awburst => bram_axi_full_awburst,
            bram_m_axi_awlock => bram_axi_full_awlock,
            bram_m_axi_awcache => bram_axi_full_awcache,
            bram_m_axi_awprot => bram_axi_full_awprot,
            bram_m_axi_awqos => bram_axi_full_awqos,
            bram_m_axi_awregion => bram_axi_full_awregion,
            bram_m_axi_awvalid => bram_axi_full_awvalid,
            bram_m_axi_awready => bram_axi_full_awready,
            bram_m_axi_wdata => bram_axi_full_wdata,
            bram_m_axi_wstrb => bram_axi_full_wstrb,
            bram_m_axi_wlast => bram_axi_full_wlast,
            bram_m_axi_wvalid => bram_axi_full_wvalid,
            bram_m_axi_wready => bram_axi_full_wready,
            bram_m_axi_bid => bram_axi_full_bid,
            bram_m_axi_bresp => bram_axi_full_bresp,
            bram_m_axi_bvalid => bram_axi_full_bvalid,
            bram_m_axi_bready => bram_axi_full_bready,
            bram_m_axi_arid => bram_axi_full_arid,
            bram_m_axi_araddr => bram_axi_full_araddr,
            bram_m_axi_arlen => bram_axi_full_arlen,
            bram_m_axi_arsize => bram_axi_full_arsize,
            bram_m_axi_arburst => bram_axi_full_arburst,
            bram_m_axi_arlock => bram_axi_full_arlock,
            bram_m_axi_arcache => bram_axi_full_arcache,
            bram_m_axi_arprot => bram_axi_full_arprot,
            bram_m_axi_arqos => bram_axi_full_arqos,
            bram_m_axi_arregion => bram_axi_full_arregion,
            bram_m_axi_arvalid => bram_axi_full_arvalid,
            bram_m_axi_arready => bram_axi_full_arready,
            bram_m_axi_rid => bram_axi_full_rid,
            bram_m_axi_rdata => bram_axi_full_rdata,
            bram_m_axi_rresp => bram_axi_full_rresp,
            bram_m_axi_rlast => bram_axi_full_rlast,
            bram_m_axi_rvalid => bram_axi_full_rvalid,
            bram_m_axi_rready => bram_axi_full_rready,
            ram_m_axi_awid => ram_axi_full_awid,
            ram_m_axi_awaddr => ram_axi_full_awaddr,
            ram_m_axi_awlen => ram_axi_full_awlen,
            ram_m_axi_awsize => ram_axi_full_awsize,
            ram_m_axi_awburst => ram_axi_full_awburst,
            ram_m_axi_awlock => ram_axi_full_awlock,
            ram_m_axi_awcache => ram_axi_full_awcache,
            ram_m_axi_awprot => ram_axi_full_awprot,
            ram_m_axi_awqos => ram_axi_full_awqos,
            ram_m_axi_awregion => ram_axi_full_awregion,
            ram_m_axi_awvalid => ram_axi_full_awvalid,
            ram_m_axi_awready => ram_axi_full_awready,
            ram_m_axi_wdata => ram_axi_full_wdata,
            ram_m_axi_wstrb => ram_axi_full_wstrb,
            ram_m_axi_wlast => ram_axi_full_wlast,
            ram_m_axi_wvalid => ram_axi_full_wvalid,
            ram_m_axi_wready => ram_axi_full_wready,
            ram_m_axi_bid => ram_axi_full_bid,
            ram_m_axi_bresp => ram_axi_full_bresp,
            ram_m_axi_bvalid => ram_axi_full_bvalid,
            ram_m_axi_bready => ram_axi_full_bready,
            ram_m_axi_arid => ram_axi_full_arid,
            ram_m_axi_araddr => ram_axi_full_araddr,
            ram_m_axi_arlen => ram_axi_full_arlen,
            ram_m_axi_arsize => ram_axi_full_arsize,
            ram_m_axi_arburst => ram_axi_full_arburst,
            ram_m_axi_arlock => ram_axi_full_arlock,
            ram_m_axi_arcache => ram_axi_full_arcache,
            ram_m_axi_arprot => ram_axi_full_arprot,
            ram_m_axi_arqos => ram_axi_full_arqos,
            ram_m_axi_arregion => ram_axi_full_arregion,
            ram_m_axi_arvalid => ram_axi_full_arvalid,
            ram_m_axi_arready => ram_axi_full_arready,
            ram_m_axi_rid => ram_axi_full_rid,
            ram_m_axi_rdata => ram_axi_full_rdata,
            ram_m_axi_rresp => ram_axi_full_rresp,
            ram_m_axi_rlast => ram_axi_full_rlast,
            ram_m_axi_rvalid => ram_axi_full_rvalid,
            ram_m_axi_rready => ram_axi_full_rready,
            int_m_axi_awid => int_axi_full_awid,
            int_m_axi_awaddr => int_axi_full_awaddr,
            int_m_axi_awlen => int_axi_full_awlen,
            int_m_axi_awsize => int_axi_full_awsize,
            int_m_axi_awburst => int_axi_full_awburst,
            int_m_axi_awlock => int_axi_full_awlock,
            int_m_axi_awcache => int_axi_full_awcache,
            int_m_axi_awprot => int_axi_full_awprot,
            int_m_axi_awqos => int_axi_full_awqos,
            int_m_axi_awregion => int_axi_full_awregion,
            int_m_axi_awvalid => int_axi_full_awvalid,
            int_m_axi_awready => int_axi_full_awready,
            int_m_axi_wdata => int_axi_full_wdata,
            int_m_axi_wstrb => int_axi_full_wstrb,
            int_m_axi_wlast => int_axi_full_wlast,
            int_m_axi_wvalid => int_axi_full_wvalid,
            int_m_axi_wready => int_axi_full_wready,
            int_m_axi_bid => int_axi_full_bid,
            int_m_axi_bresp => int_axi_full_bresp,
            int_m_axi_bvalid => int_axi_full_bvalid,
            int_m_axi_bready => int_axi_full_bready,
            int_m_axi_arid => int_axi_full_arid,
            int_m_axi_araddr => int_axi_full_araddr,
            int_m_axi_arlen => int_axi_full_arlen,
            int_m_axi_arsize => int_axi_full_arsize,
            int_m_axi_arburst => int_axi_full_arburst,
            int_m_axi_arlock => int_axi_full_arlock,
            int_m_axi_arcache => int_axi_full_arcache,
            int_m_axi_arprot => int_axi_full_arprot,
            int_m_axi_arqos => int_axi_full_arqos,
            int_m_axi_arregion => int_axi_full_arregion,
            int_m_axi_arvalid => int_axi_full_arvalid,
            int_m_axi_arready => int_axi_full_arready,
            int_m_axi_rid => int_axi_full_rid,
            int_m_axi_rdata => int_axi_full_rdata,
            int_m_axi_rresp => int_axi_full_rresp,
            int_m_axi_rlast => int_axi_full_rlast,
            int_m_axi_rvalid => int_axi_full_rvalid,
            int_m_axi_rready => int_axi_full_rready,
            timer_m_axi_awid => timer_axi_full_awid,
            timer_m_axi_awaddr => timer_axi_full_awaddr,
            timer_m_axi_awlen => timer_axi_full_awlen,
            timer_m_axi_awsize => timer_axi_full_awsize,
            timer_m_axi_awburst => timer_axi_full_awburst,
            timer_m_axi_awlock => timer_axi_full_awlock,
            timer_m_axi_awcache => timer_axi_full_awcache,
            timer_m_axi_awprot => timer_axi_full_awprot,
            timer_m_axi_awqos => timer_axi_full_awqos,
            timer_m_axi_awregion => timer_axi_full_awregion,
            timer_m_axi_awvalid => timer_axi_full_awvalid,
            timer_m_axi_awready => timer_axi_full_awready,
            timer_m_axi_wdata => timer_axi_full_wdata,
            timer_m_axi_wstrb => timer_axi_full_wstrb,
            timer_m_axi_wlast => timer_axi_full_wlast,
            timer_m_axi_wvalid => timer_axi_full_wvalid,
            timer_m_axi_wready => timer_axi_full_wready,
            timer_m_axi_bid => timer_axi_full_bid,
            timer_m_axi_bresp => timer_axi_full_bresp,
            timer_m_axi_bvalid => timer_axi_full_bvalid,
            timer_m_axi_bready => timer_axi_full_bready,
            timer_m_axi_arid => timer_axi_full_arid,
            timer_m_axi_araddr => timer_axi_full_araddr,
            timer_m_axi_arlen => timer_axi_full_arlen,
            timer_m_axi_arsize => timer_axi_full_arsize,
            timer_m_axi_arburst => timer_axi_full_arburst,
            timer_m_axi_arlock => timer_axi_full_arlock,
            timer_m_axi_arcache => timer_axi_full_arcache,
            timer_m_axi_arprot => timer_axi_full_arprot,
            timer_m_axi_arqos => timer_axi_full_arqos,
            timer_m_axi_arregion => timer_axi_full_arregion,
            timer_m_axi_arvalid => timer_axi_full_arvalid,
            timer_m_axi_arready => timer_axi_full_arready,
            timer_m_axi_rid => timer_axi_full_rid,
            timer_m_axi_rdata => timer_axi_full_rdata,
            timer_m_axi_rresp => timer_axi_full_rresp,
            timer_m_axi_rlast => timer_axi_full_rlast,
            timer_m_axi_rvalid => timer_axi_full_rvalid,
            timer_m_axi_rready => timer_axi_full_rready,
            gpio_m_axi_awid => gpio_axi_full_awid,
            gpio_m_axi_awaddr => gpio_axi_full_awaddr,
            gpio_m_axi_awlen => gpio_axi_full_awlen,
            gpio_m_axi_awsize => gpio_axi_full_awsize,
            gpio_m_axi_awburst => gpio_axi_full_awburst,
            gpio_m_axi_awlock => gpio_axi_full_awlock,
            gpio_m_axi_awcache => gpio_axi_full_awcache,
            gpio_m_axi_awprot => gpio_axi_full_awprot,
            gpio_m_axi_awqos => gpio_axi_full_awqos,
            gpio_m_axi_awregion => gpio_axi_full_awregion,
            gpio_m_axi_awvalid => gpio_axi_full_awvalid,
            gpio_m_axi_awready => gpio_axi_full_awready,
            gpio_m_axi_wdata => gpio_axi_full_wdata,
            gpio_m_axi_wstrb => gpio_axi_full_wstrb,
            gpio_m_axi_wlast => gpio_axi_full_wlast,
            gpio_m_axi_wvalid => gpio_axi_full_wvalid,
            gpio_m_axi_wready => gpio_axi_full_wready,
            gpio_m_axi_bid => gpio_axi_full_bid,
            gpio_m_axi_bresp => gpio_axi_full_bresp,
            gpio_m_axi_bvalid => gpio_axi_full_bvalid,
            gpio_m_axi_bready => gpio_axi_full_bready,
            gpio_m_axi_arid => gpio_axi_full_arid,
            gpio_m_axi_araddr => gpio_axi_full_araddr,
            gpio_m_axi_arlen => gpio_axi_full_arlen,
            gpio_m_axi_arsize => gpio_axi_full_arsize,
            gpio_m_axi_arburst => gpio_axi_full_arburst,
            gpio_m_axi_arlock => gpio_axi_full_arlock,
            gpio_m_axi_arcache => gpio_axi_full_arcache,
            gpio_m_axi_arprot => gpio_axi_full_arprot,
            gpio_m_axi_arqos => gpio_axi_full_arqos,
            gpio_m_axi_arregion => gpio_axi_full_arregion,
            gpio_m_axi_arvalid => gpio_axi_full_arvalid,
            gpio_m_axi_arready => gpio_axi_full_arready,
            gpio_m_axi_rid => gpio_axi_full_rid,
            gpio_m_axi_rdata => gpio_axi_full_rdata,
            gpio_m_axi_rresp => gpio_axi_full_rresp,
            gpio_m_axi_rlast => gpio_axi_full_rlast,
            gpio_m_axi_rvalid => gpio_axi_full_rvalid,
            gpio_m_axi_rready => gpio_axi_full_rready,
            cdma_m_axi_awid => cdmareg_axi_full_awid,
            cdma_m_axi_awaddr => cdmareg_axi_full_awaddr,
            cdma_m_axi_awlen => cdmareg_axi_full_awlen,
            cdma_m_axi_awsize => cdmareg_axi_full_awsize,
            cdma_m_axi_awburst => cdmareg_axi_full_awburst,
            cdma_m_axi_awlock => cdmareg_axi_full_awlock,
            cdma_m_axi_awcache => cdmareg_axi_full_awcache,
            cdma_m_axi_awprot => cdmareg_axi_full_awprot,
            cdma_m_axi_awqos => cdmareg_axi_full_awqos,
            cdma_m_axi_awregion => cdmareg_axi_full_awregion,
            cdma_m_axi_awvalid => cdmareg_axi_full_awvalid,
            cdma_m_axi_awready => cdmareg_axi_full_awready,
            cdma_m_axi_wdata => cdmareg_axi_full_wdata,
            cdma_m_axi_wstrb => cdmareg_axi_full_wstrb,
            cdma_m_axi_wlast => cdmareg_axi_full_wlast,
            cdma_m_axi_wvalid => cdmareg_axi_full_wvalid,
            cdma_m_axi_wready => cdmareg_axi_full_wready,
            cdma_m_axi_bid => cdmareg_axi_full_bid,
            cdma_m_axi_bresp => cdmareg_axi_full_bresp,
            cdma_m_axi_bvalid => cdmareg_axi_full_bvalid,
            cdma_m_axi_bready => cdmareg_axi_full_bready,
            cdma_m_axi_arid => cdmareg_axi_full_arid,
            cdma_m_axi_araddr => cdmareg_axi_full_araddr,
            cdma_m_axi_arlen => cdmareg_axi_full_arlen,
            cdma_m_axi_arsize => cdmareg_axi_full_arsize,
            cdma_m_axi_arburst => cdmareg_axi_full_arburst,
            cdma_m_axi_arlock => cdmareg_axi_full_arlock,
            cdma_m_axi_arcache => cdmareg_axi_full_arcache,
            cdma_m_axi_arprot => cdmareg_axi_full_arprot,
            cdma_m_axi_arqos => cdmareg_axi_full_arqos,
            cdma_m_axi_arregion => cdmareg_axi_full_arregion,
            cdma_m_axi_arvalid => cdmareg_axi_full_arvalid,
            cdma_m_axi_arready => cdmareg_axi_full_arready,
            cdma_m_axi_rid => cdmareg_axi_full_rid,
            cdma_m_axi_rdata => cdmareg_axi_full_rdata,
            cdma_m_axi_rresp => cdmareg_axi_full_rresp,
            cdma_m_axi_rlast => cdmareg_axi_full_rlast,
            cdma_m_axi_rvalid => cdmareg_axi_full_rvalid,
            cdma_m_axi_rready => cdmareg_axi_full_rready,
            uart_m_axi_awid => uart_axi_full_awid,
            uart_m_axi_awaddr => uart_axi_full_awaddr,
            uart_m_axi_awlen => uart_axi_full_awlen,
            uart_m_axi_awsize => uart_axi_full_awsize,
            uart_m_axi_awburst => uart_axi_full_awburst,
            uart_m_axi_awlock => uart_axi_full_awlock,
            uart_m_axi_awcache => uart_axi_full_awcache,
            uart_m_axi_awprot => uart_axi_full_awprot,
            uart_m_axi_awqos => uart_axi_full_awqos,
            uart_m_axi_awregion => uart_axi_full_awregion,
            uart_m_axi_awvalid => uart_axi_full_awvalid,
            uart_m_axi_awready => uart_axi_full_awready,
            uart_m_axi_wdata => uart_axi_full_wdata,
            uart_m_axi_wstrb => uart_axi_full_wstrb,
            uart_m_axi_wlast => uart_axi_full_wlast,
            uart_m_axi_wvalid => uart_axi_full_wvalid,
            uart_m_axi_wready => uart_axi_full_wready,
            uart_m_axi_bid => uart_axi_full_bid,
            uart_m_axi_bresp => uart_axi_full_bresp,
            uart_m_axi_bvalid => uart_axi_full_bvalid,
            uart_m_axi_bready => uart_axi_full_bready,
            uart_m_axi_arid => uart_axi_full_arid,
            uart_m_axi_araddr => uart_axi_full_araddr,
            uart_m_axi_arlen => uart_axi_full_arlen,
            uart_m_axi_arsize => uart_axi_full_arsize,
            uart_m_axi_arburst => uart_axi_full_arburst,
            uart_m_axi_arlock => uart_axi_full_arlock,
            uart_m_axi_arcache => uart_axi_full_arcache,
            uart_m_axi_arprot => uart_axi_full_arprot,
            uart_m_axi_arqos => uart_axi_full_arqos,
            uart_m_axi_arregion => uart_axi_full_arregion,
            uart_m_axi_arvalid => uart_axi_full_arvalid,
            uart_m_axi_arready => uart_axi_full_arready,
            uart_m_axi_rid => uart_axi_full_rid,
            uart_m_axi_rdata => uart_axi_full_rdata,
            uart_m_axi_rresp => uart_axi_full_rresp,
            uart_m_axi_rlast => uart_axi_full_rlast,
            uart_m_axi_rvalid => uart_axi_full_rvalid,
            uart_m_axi_rready => uart_axi_full_rready,
            timer_extra_0_m_axi_awid => timer_extra_0_axi_full_awid,
            timer_extra_0_m_axi_awaddr => timer_extra_0_axi_full_awaddr,
            timer_extra_0_m_axi_awlen => timer_extra_0_axi_full_awlen,
            timer_extra_0_m_axi_awsize => timer_extra_0_axi_full_awsize,
            timer_extra_0_m_axi_awburst => timer_extra_0_axi_full_awburst,
            timer_extra_0_m_axi_awlock => timer_extra_0_axi_full_awlock,
            timer_extra_0_m_axi_awcache => timer_extra_0_axi_full_awcache,
            timer_extra_0_m_axi_awprot => timer_extra_0_axi_full_awprot,
            timer_extra_0_m_axi_awqos => timer_extra_0_axi_full_awqos,
            timer_extra_0_m_axi_awregion => timer_extra_0_axi_full_awregion,
            timer_extra_0_m_axi_awvalid => timer_extra_0_axi_full_awvalid,
            timer_extra_0_m_axi_awready => timer_extra_0_axi_full_awready,
            timer_extra_0_m_axi_wdata => timer_extra_0_axi_full_wdata,
            timer_extra_0_m_axi_wstrb => timer_extra_0_axi_full_wstrb,
            timer_extra_0_m_axi_wlast => timer_extra_0_axi_full_wlast,
            timer_extra_0_m_axi_wvalid => timer_extra_0_axi_full_wvalid,
            timer_extra_0_m_axi_wready => timer_extra_0_axi_full_wready,
            timer_extra_0_m_axi_bid => timer_extra_0_axi_full_bid,
            timer_extra_0_m_axi_bresp => timer_extra_0_axi_full_bresp,
            timer_extra_0_m_axi_bvalid => timer_extra_0_axi_full_bvalid,
            timer_extra_0_m_axi_bready => timer_extra_0_axi_full_bready,
            timer_extra_0_m_axi_arid => timer_extra_0_axi_full_arid,
            timer_extra_0_m_axi_araddr => timer_extra_0_axi_full_araddr,
            timer_extra_0_m_axi_arlen => timer_extra_0_axi_full_arlen,
            timer_extra_0_m_axi_arsize => timer_extra_0_axi_full_arsize,
            timer_extra_0_m_axi_arburst => timer_extra_0_axi_full_arburst,
            timer_extra_0_m_axi_arlock => timer_extra_0_axi_full_arlock,
            timer_extra_0_m_axi_arcache => timer_extra_0_axi_full_arcache,
            timer_extra_0_m_axi_arprot => timer_extra_0_axi_full_arprot,
            timer_extra_0_m_axi_arqos => timer_extra_0_axi_full_arqos,
            timer_extra_0_m_axi_arregion => timer_extra_0_axi_full_arregion,
            timer_extra_0_m_axi_arvalid => timer_extra_0_axi_full_arvalid,
            timer_extra_0_m_axi_arready => timer_extra_0_axi_full_arready,
            timer_extra_0_m_axi_rid => timer_extra_0_axi_full_rid,
            timer_extra_0_m_axi_rdata => timer_extra_0_axi_full_rdata,
            timer_extra_0_m_axi_rresp => timer_extra_0_axi_full_rresp,
            timer_extra_0_m_axi_rlast => timer_extra_0_axi_full_rlast,
            timer_extra_0_m_axi_rvalid => timer_extra_0_axi_full_rvalid,
            timer_extra_0_m_axi_rready => timer_extra_0_axi_full_rready,
            aclk => aclk,
            aresetn => cross_aresetn(0));
        
    plasoc_cpu_inst : plasoc_cpu
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            intr_in => cpu_int,
            axi_awid => cpu_axi_full_awid,
            axi_awaddr => cpu_axi_full_awaddr,
            axi_awlen => cpu_axi_full_awlen,
            axi_awsize => cpu_axi_full_awsize,
            axi_awburst => cpu_axi_full_awburst,
            axi_awlock => cpu_axi_full_awlock,
            axi_awcache => cpu_axi_full_awcache,
            axi_awprot => cpu_axi_full_awprot,
            axi_awqos => cpu_axi_full_awqos,
            axi_awregion => cpu_axi_full_awregion,
            axi_awvalid => cpu_axi_full_awvalid,
            axi_awready => cpu_axi_full_awready,
            axi_wdata => cpu_axi_full_wdata,
            axi_wstrb => cpu_axi_full_wstrb,
            axi_wlast => cpu_axi_full_wlast,
            axi_wvalid => cpu_axi_full_wvalid,
            axi_wready => cpu_axi_full_wready,
            axi_bid => cpu_axi_full_bid,
            axi_bresp => cpu_axi_full_bresp,
            axi_bvalid => cpu_axi_full_bvalid,
            axi_bready => cpu_axi_full_bready,
            axi_arid => cpu_axi_full_arid,
            axi_araddr => cpu_axi_full_araddr,
            axi_arlen => cpu_axi_full_arlen,
            axi_arsize => cpu_axi_full_arsize,
            axi_arburst => cpu_axi_full_arburst,
            axi_arlock => cpu_axi_full_arlock,
            axi_arcache => cpu_axi_full_arcache,
            axi_arprot => cpu_axi_full_arprot,
            axi_arqos => cpu_axi_full_arqos,
            axi_arregion => cpu_axi_full_arregion,
            axi_arvalid => cpu_axi_full_arvalid,
            axi_arready => cpu_axi_full_arready,
            axi_rid => cpu_axi_full_rid,
            axi_rdata => cpu_axi_full_rdata,
            axi_rresp => cpu_axi_full_rresp,
            axi_rlast => cpu_axi_full_rlast,
            axi_rvalid => cpu_axi_full_rvalid,
            axi_rready => cpu_axi_full_rready);
            
    int_full2lite_inst : plasoc_axi4_full2lite
        generic map (
            axi_slave_id_width => axi_master_id_width,
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            s_axi_awid => int_axi_full_awid,
            s_axi_awaddr => int_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => int_axi_full_awlen,
            s_axi_awsize => int_axi_full_awsize,
            s_axi_awburst => int_axi_full_awburst,
            s_axi_awlock => int_axi_full_awlock,
            s_axi_awcache => int_axi_full_awcache,
            s_axi_awprot => int_axi_full_awprot,
            s_axi_awqos => int_axi_full_awqos,
            s_axi_awregion => int_axi_full_awregion,
            s_axi_awvalid => int_axi_full_awvalid,
            s_axi_awready => int_axi_full_awready,
            s_axi_wdata => int_axi_full_wdata,
            s_axi_wstrb => int_axi_full_wstrb,
            s_axi_wlast => int_axi_full_wlast,
            s_axi_wvalid => int_axi_full_wvalid,
            s_axi_wready => int_axi_full_wready,
            s_axi_bid => int_axi_full_bid,
            s_axi_bresp => int_axi_full_bresp,
            s_axi_bvalid => int_axi_full_bvalid,
            s_axi_bready => int_axi_full_bready,
            s_axi_arid => int_axi_full_arid,
            s_axi_araddr => int_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => int_axi_full_arlen,
            s_axi_arsize => int_axi_full_arsize,
            s_axi_arburst => int_axi_full_arburst,
            s_axi_arlock => int_axi_full_arlock,
            s_axi_arcache => int_axi_full_arcache,
            s_axi_arprot => int_axi_full_arprot,
            s_axi_arqos => int_axi_full_arqos,
            s_axi_arregion => int_axi_full_arregion,
            s_axi_arvalid => int_axi_full_arvalid,
            s_axi_arready => int_axi_full_arready,
            s_axi_rid => int_axi_full_rid,
            s_axi_rdata => int_axi_full_rdata,
            s_axi_rresp => int_axi_full_rresp,
            s_axi_rlast => int_axi_full_rlast,
            s_axi_rvalid => int_axi_full_rvalid,
            s_axi_rready => int_axi_full_rready,
            m_axi_awaddr => int_axi_lite_awaddr,
            m_axi_awprot => int_axi_lite_awprot,
            m_axi_awvalid => int_axi_lite_awvalid,
            m_axi_awready => int_axi_lite_awready,
            m_axi_wvalid => int_axi_lite_wvalid,
            m_axi_wready => int_axi_lite_wready,
            m_axi_wdata => int_axi_lite_wdata,
            m_axi_wstrb => int_axi_lite_wstrb,
            m_axi_bvalid => int_axi_lite_bvalid,
            m_axi_bready => int_axi_lite_bready,
            m_axi_bresp => int_axi_lite_bresp,
            m_axi_araddr => int_axi_lite_araddr,
            m_axi_arprot => int_axi_lite_arprot,
            m_axi_arvalid => int_axi_lite_arvalid,
            m_axi_arready => int_axi_lite_arready,
            m_axi_rdata => int_axi_lite_rdata,
            m_axi_rvalid => int_axi_lite_rvalid,
            m_axi_rready => int_axi_lite_rready,
            m_axi_rresp => int_axi_lite_rresp);
            
    timer_full2lite_inst : plasoc_axi4_full2lite
        generic map (
            axi_slave_id_width => axi_master_id_width,
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            s_axi_awid => timer_axi_full_awid,
            s_axi_awaddr => timer_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => timer_axi_full_awlen,
            s_axi_awsize => timer_axi_full_awsize,
            s_axi_awburst => timer_axi_full_awburst,
            s_axi_awlock => timer_axi_full_awlock,
            s_axi_awcache => timer_axi_full_awcache,
            s_axi_awprot => timer_axi_full_awprot,
            s_axi_awqos => timer_axi_full_awqos,
            s_axi_awregion => timer_axi_full_awregion,
            s_axi_awvalid => timer_axi_full_awvalid,
            s_axi_awready => timer_axi_full_awready,
            s_axi_wdata => timer_axi_full_wdata,
            s_axi_wstrb => timer_axi_full_wstrb,
            s_axi_wlast => timer_axi_full_wlast,
            s_axi_wvalid => timer_axi_full_wvalid,
            s_axi_wready => timer_axi_full_wready,
            s_axi_bid => timer_axi_full_bid,
            s_axi_bresp => timer_axi_full_bresp,
            s_axi_bvalid => timer_axi_full_bvalid,
            s_axi_bready => timer_axi_full_bready,
            s_axi_arid => timer_axi_full_arid,
            s_axi_araddr => timer_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => timer_axi_full_arlen,
            s_axi_arsize => timer_axi_full_arsize,
            s_axi_arburst => timer_axi_full_arburst,
            s_axi_arlock => timer_axi_full_arlock,
            s_axi_arcache => timer_axi_full_arcache,
            s_axi_arprot => timer_axi_full_arprot,
            s_axi_arqos => timer_axi_full_arqos,
            s_axi_arregion => timer_axi_full_arregion,
            s_axi_arvalid => timer_axi_full_arvalid,
            s_axi_arready => timer_axi_full_arready,
            s_axi_rid => timer_axi_full_rid,
            s_axi_rdata => timer_axi_full_rdata,
            s_axi_rresp => timer_axi_full_rresp,
            s_axi_rlast => timer_axi_full_rlast,
            s_axi_rvalid => timer_axi_full_rvalid,
            s_axi_rready => timer_axi_full_rready,
            m_axi_awaddr => timer_axi_lite_awaddr,
            m_axi_awprot => timer_axi_lite_awprot,
            m_axi_awvalid => timer_axi_lite_awvalid,
            m_axi_awready => timer_axi_lite_awready,
            m_axi_wvalid => timer_axi_lite_wvalid,
            m_axi_wready => timer_axi_lite_wready,
            m_axi_wdata => timer_axi_lite_wdata,
            m_axi_wstrb => timer_axi_lite_wstrb,
            m_axi_bvalid => timer_axi_lite_bvalid,
            m_axi_bready => timer_axi_lite_bready,
            m_axi_bresp => timer_axi_lite_bresp,
            m_axi_araddr => timer_axi_lite_araddr,
            m_axi_arprot => timer_axi_lite_arprot,
            m_axi_arvalid => timer_axi_lite_arvalid,
            m_axi_arready => timer_axi_lite_arready,
            m_axi_rdata => timer_axi_lite_rdata,
            m_axi_rvalid => timer_axi_lite_rvalid,
            m_axi_rready => timer_axi_lite_rready,
            m_axi_rresp => timer_axi_lite_rresp);
    
    gpio_full2lite_inst : plasoc_axi4_full2lite
        generic map (
            axi_slave_id_width => axi_master_id_width,
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            s_axi_awid => gpio_axi_full_awid,
            s_axi_awaddr => gpio_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => gpio_axi_full_awlen,
            s_axi_awsize => gpio_axi_full_awsize,
            s_axi_awburst => gpio_axi_full_awburst,
            s_axi_awlock => gpio_axi_full_awlock,
            s_axi_awcache => gpio_axi_full_awcache,
            s_axi_awprot => gpio_axi_full_awprot,
            s_axi_awqos => gpio_axi_full_awqos,
            s_axi_awregion => gpio_axi_full_awregion,
            s_axi_awvalid => gpio_axi_full_awvalid,
            s_axi_awready => gpio_axi_full_awready,
            s_axi_wdata => gpio_axi_full_wdata,
            s_axi_wstrb => gpio_axi_full_wstrb,
            s_axi_wlast => gpio_axi_full_wlast,
            s_axi_wvalid => gpio_axi_full_wvalid,
            s_axi_wready => gpio_axi_full_wready,
            s_axi_bid => gpio_axi_full_bid,
            s_axi_bresp => gpio_axi_full_bresp,
            s_axi_bvalid => gpio_axi_full_bvalid,
            s_axi_bready => gpio_axi_full_bready,
            s_axi_arid => gpio_axi_full_arid,
            s_axi_araddr => gpio_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => gpio_axi_full_arlen,
            s_axi_arsize => gpio_axi_full_arsize,
            s_axi_arburst => gpio_axi_full_arburst,
            s_axi_arlock => gpio_axi_full_arlock,
            s_axi_arcache => gpio_axi_full_arcache,
            s_axi_arprot => gpio_axi_full_arprot,
            s_axi_arqos => gpio_axi_full_arqos,
            s_axi_arregion => gpio_axi_full_arregion,
            s_axi_arvalid => gpio_axi_full_arvalid,
            s_axi_arready => gpio_axi_full_arready,
            s_axi_rid => gpio_axi_full_rid,
            s_axi_rdata => gpio_axi_full_rdata,
            s_axi_rresp => gpio_axi_full_rresp,
            s_axi_rlast => gpio_axi_full_rlast,
            s_axi_rvalid => gpio_axi_full_rvalid,
            s_axi_rready => gpio_axi_full_rready,
            m_axi_awaddr => gpio_axi_lite_awaddr,
            m_axi_awprot => gpio_axi_lite_awprot,
            m_axi_awvalid => gpio_axi_lite_awvalid,
            m_axi_awready => gpio_axi_lite_awready,
            m_axi_wvalid => gpio_axi_lite_wvalid,
            m_axi_wready => gpio_axi_lite_wready,
            m_axi_wdata => gpio_axi_lite_wdata,
            m_axi_wstrb => gpio_axi_lite_wstrb,
            m_axi_bvalid => gpio_axi_lite_bvalid,
            m_axi_bready => gpio_axi_lite_bready,
            m_axi_bresp => gpio_axi_lite_bresp,
            m_axi_araddr => gpio_axi_lite_araddr,
            m_axi_arprot => gpio_axi_lite_arprot,
            m_axi_arvalid => gpio_axi_lite_arvalid,
            m_axi_arready => gpio_axi_lite_arready,
            m_axi_rdata => gpio_axi_lite_rdata,
            m_axi_rvalid => gpio_axi_lite_rvalid,
            m_axi_rready => gpio_axi_lite_rready,
            m_axi_rresp => gpio_axi_lite_rresp);
            
    cdmareg_full2lite_inst : plasoc_axi4_full2lite
        generic map (
            axi_slave_id_width => axi_master_id_width,
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            s_axi_awid => cdmareg_axi_full_awid,
            s_axi_awaddr => cdmareg_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => cdmareg_axi_full_awlen,
            s_axi_awsize => cdmareg_axi_full_awsize,
            s_axi_awburst => cdmareg_axi_full_awburst,
            s_axi_awlock => cdmareg_axi_full_awlock,
            s_axi_awcache => cdmareg_axi_full_awcache,
            s_axi_awprot => cdmareg_axi_full_awprot,
            s_axi_awqos => cdmareg_axi_full_awqos,
            s_axi_awregion => cdmareg_axi_full_awregion,
            s_axi_awvalid => cdmareg_axi_full_awvalid,
            s_axi_awready => cdmareg_axi_full_awready,
            s_axi_wdata => cdmareg_axi_full_wdata,
            s_axi_wstrb => cdmareg_axi_full_wstrb,
            s_axi_wlast => cdmareg_axi_full_wlast,
            s_axi_wvalid => cdmareg_axi_full_wvalid,
            s_axi_wready => cdmareg_axi_full_wready,
            s_axi_bid => cdmareg_axi_full_bid,
            s_axi_bresp => cdmareg_axi_full_bresp,
            s_axi_bvalid => cdmareg_axi_full_bvalid,
            s_axi_bready => cdmareg_axi_full_bready,
            s_axi_arid => cdmareg_axi_full_arid,
            s_axi_araddr => cdmareg_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => cdmareg_axi_full_arlen,
            s_axi_arsize => cdmareg_axi_full_arsize,
            s_axi_arburst => cdmareg_axi_full_arburst,
            s_axi_arlock => cdmareg_axi_full_arlock,
            s_axi_arcache => cdmareg_axi_full_arcache,
            s_axi_arprot => cdmareg_axi_full_arprot,
            s_axi_arqos => cdmareg_axi_full_arqos,
            s_axi_arregion => cdmareg_axi_full_arregion,
            s_axi_arvalid => cdmareg_axi_full_arvalid,
            s_axi_arready => cdmareg_axi_full_arready,
            s_axi_rid => cdmareg_axi_full_rid,
            s_axi_rdata => cdmareg_axi_full_rdata,
            s_axi_rresp => cdmareg_axi_full_rresp,
            s_axi_rlast => cdmareg_axi_full_rlast,
            s_axi_rvalid => cdmareg_axi_full_rvalid,
            s_axi_rready => cdmareg_axi_full_rready,
            m_axi_awaddr => cdmareg_axi_lite_awaddr,
            m_axi_awprot => cdmareg_axi_lite_awprot,
            m_axi_awvalid => cdmareg_axi_lite_awvalid,
            m_axi_awready => cdmareg_axi_lite_awready,
            m_axi_wvalid => cdmareg_axi_lite_wvalid,
            m_axi_wready => cdmareg_axi_lite_wready,
            m_axi_wdata => cdmareg_axi_lite_wdata,
            m_axi_wstrb => cdmareg_axi_lite_wstrb,
            m_axi_bvalid => cdmareg_axi_lite_bvalid,
            m_axi_bready => cdmareg_axi_lite_bready,
            m_axi_bresp => cdmareg_axi_lite_bresp,
            m_axi_araddr => cdmareg_axi_lite_araddr,
            m_axi_arprot => cdmareg_axi_lite_arprot,
            m_axi_arvalid => cdmareg_axi_lite_arvalid,
            m_axi_arready => cdmareg_axi_lite_arready,
            m_axi_rdata => cdmareg_axi_lite_rdata,
            m_axi_rvalid => cdmareg_axi_lite_rvalid,
            m_axi_rready => cdmareg_axi_lite_rready,
            m_axi_rresp => cdmareg_axi_lite_rresp);
            
    uart_full2lite_inst : plasoc_axi4_full2lite
        generic map (
            axi_slave_id_width => axi_master_id_width,
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            s_axi_awid => uart_axi_full_awid,
            s_axi_awaddr => uart_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => uart_axi_full_awlen,
            s_axi_awsize => uart_axi_full_awsize,
            s_axi_awburst => uart_axi_full_awburst,
            s_axi_awlock => uart_axi_full_awlock,
            s_axi_awcache => uart_axi_full_awcache,
            s_axi_awprot => uart_axi_full_awprot,
            s_axi_awqos => uart_axi_full_awqos,
            s_axi_awregion => uart_axi_full_awregion,
            s_axi_awvalid => uart_axi_full_awvalid,
            s_axi_awready => uart_axi_full_awready,
            s_axi_wdata => uart_axi_full_wdata,
            s_axi_wstrb => uart_axi_full_wstrb,
            s_axi_wlast => uart_axi_full_wlast,
            s_axi_wvalid => uart_axi_full_wvalid,
            s_axi_wready => uart_axi_full_wready,
            s_axi_bid => uart_axi_full_bid,
            s_axi_bresp => uart_axi_full_bresp,
            s_axi_bvalid => uart_axi_full_bvalid,
            s_axi_bready => uart_axi_full_bready,
            s_axi_arid => uart_axi_full_arid,
            s_axi_araddr => uart_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => uart_axi_full_arlen,
            s_axi_arsize => uart_axi_full_arsize,
            s_axi_arburst => uart_axi_full_arburst,
            s_axi_arlock => uart_axi_full_arlock,
            s_axi_arcache => uart_axi_full_arcache,
            s_axi_arprot => uart_axi_full_arprot,
            s_axi_arqos => uart_axi_full_arqos,
            s_axi_arregion => uart_axi_full_arregion,
            s_axi_arvalid => uart_axi_full_arvalid,
            s_axi_arready => uart_axi_full_arready,
            s_axi_rid => uart_axi_full_rid,
            s_axi_rdata => uart_axi_full_rdata,
            s_axi_rresp => uart_axi_full_rresp,
            s_axi_rlast => uart_axi_full_rlast,
            s_axi_rvalid => uart_axi_full_rvalid,
            s_axi_rready => uart_axi_full_rready,
            m_axi_awaddr => uart_axi_lite_awaddr,
            m_axi_awprot => uart_axi_lite_awprot,
            m_axi_awvalid => uart_axi_lite_awvalid,
            m_axi_awready => uart_axi_lite_awready,
            m_axi_wvalid => uart_axi_lite_wvalid,
            m_axi_wready => uart_axi_lite_wready,
            m_axi_wdata => uart_axi_lite_wdata,
            m_axi_wstrb => uart_axi_lite_wstrb,
            m_axi_bvalid => uart_axi_lite_bvalid,
            m_axi_bready => uart_axi_lite_bready,
            m_axi_bresp => uart_axi_lite_bresp,
            m_axi_araddr => uart_axi_lite_araddr,
            m_axi_arprot => uart_axi_lite_arprot,
            m_axi_arvalid => uart_axi_lite_arvalid,
            m_axi_arready => uart_axi_lite_arready,
            m_axi_rdata => uart_axi_lite_rdata,
            m_axi_rvalid => uart_axi_lite_rvalid,
            m_axi_rready => uart_axi_lite_rready,
            m_axi_rresp => uart_axi_lite_rresp);
            
    timer_extra_0_full2lite_inst : plasoc_axi4_full2lite
        generic map (
            axi_slave_id_width => axi_master_id_width,
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            s_axi_awid => timer_extra_0_axi_full_awid,
            s_axi_awaddr => timer_extra_0_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => timer_extra_0_axi_full_awlen,
            s_axi_awsize => timer_extra_0_axi_full_awsize,
            s_axi_awburst => timer_extra_0_axi_full_awburst,
            s_axi_awlock => timer_extra_0_axi_full_awlock,
            s_axi_awcache => timer_extra_0_axi_full_awcache,
            s_axi_awprot => timer_extra_0_axi_full_awprot,
            s_axi_awqos => timer_extra_0_axi_full_awqos,
            s_axi_awregion => timer_extra_0_axi_full_awregion,
            s_axi_awvalid => timer_extra_0_axi_full_awvalid,
            s_axi_awready => timer_extra_0_axi_full_awready,
            s_axi_wdata => timer_extra_0_axi_full_wdata,
            s_axi_wstrb => timer_extra_0_axi_full_wstrb,
            s_axi_wlast => timer_extra_0_axi_full_wlast,
            s_axi_wvalid => timer_extra_0_axi_full_wvalid,
            s_axi_wready => timer_extra_0_axi_full_wready,
            s_axi_bid => timer_extra_0_axi_full_bid,
            s_axi_bresp => timer_extra_0_axi_full_bresp,
            s_axi_bvalid => timer_extra_0_axi_full_bvalid,
            s_axi_bready => timer_extra_0_axi_full_bready,
            s_axi_arid => timer_extra_0_axi_full_arid,
            s_axi_araddr => timer_extra_0_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => timer_extra_0_axi_full_arlen,
            s_axi_arsize => timer_extra_0_axi_full_arsize,
            s_axi_arburst => timer_extra_0_axi_full_arburst,
            s_axi_arlock => timer_extra_0_axi_full_arlock,
            s_axi_arcache => timer_extra_0_axi_full_arcache,
            s_axi_arprot => timer_extra_0_axi_full_arprot,
            s_axi_arqos => timer_extra_0_axi_full_arqos,
            s_axi_arregion => timer_extra_0_axi_full_arregion,
            s_axi_arvalid => timer_extra_0_axi_full_arvalid,
            s_axi_arready => timer_extra_0_axi_full_arready,
            s_axi_rid => timer_extra_0_axi_full_rid,
            s_axi_rdata => timer_extra_0_axi_full_rdata,
            s_axi_rresp => timer_extra_0_axi_full_rresp,
            s_axi_rlast => timer_extra_0_axi_full_rlast,
            s_axi_rvalid => timer_extra_0_axi_full_rvalid,
            s_axi_rready => timer_extra_0_axi_full_rready,
            m_axi_awaddr => timer_extra_0_axi_lite_awaddr,
            m_axi_awprot => timer_extra_0_axi_lite_awprot,
            m_axi_awvalid => timer_extra_0_axi_lite_awvalid,
            m_axi_awready => timer_extra_0_axi_lite_awready,
            m_axi_wvalid => timer_extra_0_axi_lite_wvalid,
            m_axi_wready => timer_extra_0_axi_lite_wready,
            m_axi_wdata => timer_extra_0_axi_lite_wdata,
            m_axi_wstrb => timer_extra_0_axi_lite_wstrb,
            m_axi_bvalid => timer_extra_0_axi_lite_bvalid,
            m_axi_bready => timer_extra_0_axi_lite_bready,
            m_axi_bresp => timer_extra_0_axi_lite_bresp,
            m_axi_araddr => timer_extra_0_axi_lite_araddr,
            m_axi_arprot => timer_extra_0_axi_lite_arprot,
            m_axi_arvalid => timer_extra_0_axi_lite_arvalid,
            m_axi_arready => timer_extra_0_axi_lite_arready,
            m_axi_rdata => timer_extra_0_axi_lite_rdata,
            m_axi_rvalid => timer_extra_0_axi_lite_rvalid,
            m_axi_rready => timer_extra_0_axi_lite_rready,
            m_axi_rresp => timer_extra_0_axi_lite_rresp);
            
    bram_cntrl_inst : axi_bram_ctrl_0
        port map (
            s_axi_aclk => aclk,
            s_axi_aresetn => aresetn(0),
            s_axi_awid => bram_axi_full_awid,
            s_axi_awaddr => bram_axi_full_awaddr(axi_lite_address_width-1 downto 0),
            s_axi_awlen => bram_axi_full_awlen,
            s_axi_awsize => bram_axi_full_awsize,
            s_axi_awburst => bram_axi_full_awburst,
            s_axi_awlock => bram_axi_full_awlock,
            s_axi_awcache => bram_axi_full_awcache,
            s_axi_awprot => bram_axi_full_awprot,
            s_axi_awvalid => bram_axi_full_awvalid,
            s_axi_awready => bram_axi_full_awready,
            s_axi_wdata => bram_axi_full_wdata,
            s_axi_wstrb => bram_axi_full_wstrb,
            s_axi_wlast => bram_axi_full_wlast,
            s_axi_wvalid => bram_axi_full_wvalid,
            s_axi_wready => bram_axi_full_wready,
            s_axi_bid => bram_axi_full_bid,
            s_axi_bresp => bram_axi_full_bresp,
            s_axi_bvalid => bram_axi_full_bvalid,
            s_axi_bready => bram_axi_full_bready,
            s_axi_arid => bram_axi_full_arid,
            s_axi_araddr => bram_axi_full_araddr(axi_lite_address_width-1 downto 0),
            s_axi_arlen => bram_axi_full_arlen,
            s_axi_arsize => bram_axi_full_arsize,
            s_axi_arburst => bram_axi_full_arburst,
            s_axi_arlock => bram_axi_full_arlock,
            s_axi_arcache => bram_axi_full_arcache,
            s_axi_arprot => bram_axi_full_arprot,
            s_axi_arvalid => bram_axi_full_arvalid,
            s_axi_arready => bram_axi_full_arready,
            s_axi_rid => bram_axi_full_rid,
            s_axi_rdata => bram_axi_full_rdata,
            s_axi_rresp => bram_axi_full_rresp,
            s_axi_rlast => bram_axi_full_rlast,
            s_axi_rvalid => bram_axi_full_rvalid,
            s_axi_rready => bram_axi_full_rready,
            bram_rst_a => bram_bram_rst_a,
            bram_clk_a => bram_bram_clk_a,
            bram_en_a => bram_bram_en_a,
            bram_we_a => bram_bram_we_a,
            bram_addr_a => bram_bram_addr_a,
            bram_wrdata_a => bram_bram_wrdata_a,
            bram_rddata_a => bram_bram_rddata_a);
            
    bram_inst : bram 
        generic map (
            select_app => lower_app,
            address_width => axi_lite_address_width,
            data_width => axi_data_width,
            bram_depth => 1024 )
        port map (
            bram_rst_a => bram_bram_rst_a,
            bram_clk_a => bram_bram_clk_a,
            bram_en_a => bram_bram_en_a,
            bram_we_a => bram_bram_we_a,
            bram_addr_a => bram_bram_addr_a,
            bram_wrdata_a => bram_bram_wrdata_a,
            bram_rddata_a => bram_bram_rddata_a);
            
    gen_int_mm :
    if upper_ext=false generate 
        ram_cntrl_inst : axi_bram_ctrl_1 
            port map (
                s_axi_aclk => aclk,
                s_axi_aresetn => aresetn(0),
                s_axi_awid => ram_axi_full_awid,
                s_axi_awaddr => ram_axi_full_awaddr(axi_ram_address_width-1 downto 0),
                s_axi_awlen => ram_axi_full_awlen,
                s_axi_awsize => ram_axi_full_awsize,
                s_axi_awburst => ram_axi_full_awburst,
                s_axi_awlock => ram_axi_full_awlock,
                s_axi_awcache => ram_axi_full_awcache,
                s_axi_awprot => ram_axi_full_awprot,
                s_axi_awvalid => ram_axi_full_awvalid,
                s_axi_awready => ram_axi_full_awready,
                s_axi_wdata => ram_axi_full_wdata,
                s_axi_wstrb => ram_axi_full_wstrb,
                s_axi_wlast => ram_axi_full_wlast,
                s_axi_wvalid => ram_axi_full_wvalid,
                s_axi_wready => ram_axi_full_wready,
                s_axi_bid => ram_axi_full_bid,
                s_axi_bresp => ram_axi_full_bresp,
                s_axi_bvalid => ram_axi_full_bvalid,
                s_axi_bready => ram_axi_full_bready,
                s_axi_arid => ram_axi_full_arid,
                s_axi_araddr => ram_axi_full_araddr(axi_ram_address_width-1 downto 0),
                s_axi_arlen => ram_axi_full_arlen,
                s_axi_arsize => ram_axi_full_arsize,
                s_axi_arburst => ram_axi_full_arburst,
                s_axi_arlock => ram_axi_full_arlock,
                s_axi_arcache => ram_axi_full_arcache,
                s_axi_arprot => ram_axi_full_arprot,
                s_axi_arvalid => ram_axi_full_arvalid,
                s_axi_arready => ram_axi_full_arready,
                s_axi_rid => ram_axi_full_rid,
                s_axi_rdata => ram_axi_full_rdata,
                s_axi_rresp => ram_axi_full_rresp,
                s_axi_rlast => ram_axi_full_rlast,
                s_axi_rvalid => ram_axi_full_rvalid,
                s_axi_rready => ram_axi_full_rready,
                bram_rst_a => ram_bram_rst_a,
                bram_clk_a => ram_bram_clk_a,
                bram_en_a => ram_bram_en_a,
                bram_we_a => ram_bram_we_a,
                bram_addr_a => ram_bram_addr_a,
                bram_wrdata_a => ram_bram_wrdata_a,
                bram_rddata_a => ram_bram_rddata_a);
        ram_inst : bram 
            generic map (
                select_app => upper_app,
                address_width => axi_ram_address_width,
                data_width => axi_data_width,
                bram_depth => axi_ram_depth)
            port map (
                bram_rst_a => ram_bram_rst_a,
                bram_clk_a => ram_bram_clk_a,
                bram_en_a => ram_bram_en_a,
                bram_we_a => ram_bram_we_a,
                bram_addr_a => ram_bram_addr_a,
                bram_wrdata_a => ram_bram_wrdata_a,
                bram_rddata_a => ram_bram_rddata_a);
        clk_wiz_0_inst : clk_wiz_0 
            port map (
                aclk => aclk,
                sys_rst => sys_rst,
                locked => dcm_locked,
                sys_clk_p => sys_clk_p,
                sys_clk_n => sys_clk_n);
        proc_sys_reset_0_inst : proc_sys_reset_0 
            port map (
                slowest_sync_clk => aclk,
                ext_reset_in => sys_rst,
                aux_reset_in => '0',
                mb_debug_sys_rst => '0',
                dcm_locked => dcm_locked,
                mb_reset => open,
                bus_struct_reset => open,
                peripheral_reset => open,
                interconnect_aresetn => cross_aresetn,
                peripheral_aresetn => aresetn);
    end generate;
    
    gen_ext_mm :
    if upper_ext=true generate         
        mig_wrap_wrapper_inst : 
        mig_wrap_wrapper 
            port map (
                DDR3_addr => DDR3_addr,
                DDR3_ba => DDR3_ba,
                DDR3_cas_n => DDR3_cas_n,
                DDR3_ck_n => DDR3_ck_n,
                DDR3_ck_p => DDR3_ck_p,
                DDR3_cke => DDR3_cke,
                DDR3_cs_n => DDR3_cs_n,
                DDR3_dm => DDR3_dm,
                DDR3_dq => DDR3_dq,
                DDR3_dqs_n => DDR3_dqs_n,
                DDR3_dqs_p => DDR3_dqs_p,
                DDR3_odt => DDR3_odt,
                DDR3_ras_n => DDR3_ras_n,
                DDR3_reset_n => DDR3_reset_n,
                DDR3_we_n => DDR3_we_n,
                S00_AXI_araddr => ram_axi_full_araddr,
                S00_AXI_arburst => ram_axi_full_arburst,
                S00_AXI_arcache => ram_axi_full_arcache,
                S00_AXI_arid => ram_axi_full_arid_slv,
                S00_AXI_arlen => ram_axi_full_arlen,
                S00_AXI_arlock => ram_axi_full_arlock_slv,
                S00_AXI_arprot => ram_axi_full_arprot,
                S00_AXI_arqos => ram_axi_full_arqos,
                S00_AXI_arready => ram_axi_full_arready,
                S00_AXI_arregion => ram_axi_full_arregion,
                S00_AXI_arsize => ram_axi_full_arsize,
                S00_AXI_arvalid => ram_axi_full_arvalid,
                S00_AXI_awaddr => ram_axi_full_awaddr,
                S00_AXI_awburst => ram_axi_full_awburst,
                S00_AXI_awcache => ram_axi_full_awcache,
                S00_AXI_awid => ram_axi_full_awid_slv,
                S00_AXI_awlen => ram_axi_full_awlen,
                S00_AXI_awlock => ram_axi_full_awlock_slv,
                S00_AXI_awprot => ram_axi_full_awprot,
                S00_AXI_awqos => ram_axi_full_awqos,
                S00_AXI_awready => ram_axi_full_awready,
                S00_AXI_awregion => ram_axi_full_awregion,
                S00_AXI_awsize => ram_axi_full_awsize,
                S00_AXI_awvalid => ram_axi_full_awvalid,
                S00_AXI_bid => ram_axi_full_bid_slv,
                S00_AXI_bready => ram_axi_full_bready,
                S00_AXI_bresp => ram_axi_full_bresp,
                S00_AXI_bvalid => ram_axi_full_bvalid,
                S00_AXI_rdata => ram_axi_full_rdata,
                S00_AXI_rid => ram_axi_full_rid_slv,
                S00_AXI_rlast => ram_axi_full_rlast,
                S00_AXI_rready => ram_axi_full_rready,
                S00_AXI_rresp => ram_axi_full_rresp,
                S00_AXI_rvalid => ram_axi_full_rvalid,
                S00_AXI_wdata => ram_axi_full_wdata,
                S00_AXI_wlast => ram_axi_full_wlast,
                S00_AXI_wready => ram_axi_full_wready,
                S00_AXI_wstrb => ram_axi_full_wstrb,
                S00_AXI_wvalid => ram_axi_full_wvalid,
                SYS_CLK_clk_n => sys_clk_n,
                SYS_CLK_clk_p => sys_clk_p,
                interconnect_aresetn => cross_aresetn,
                peripheral_aresetn => aresetn,
                sys_rst => sys_rst,
                ui_addn_clk_0 => aclk,
                ui_clk_sync_rst => open);
    end generate;
            
    plasoc_int_inst : plasoc_int 
        generic map (
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            cpu_int => cpu_int,
            dev_ints => int_dev_ints,
            axi_awaddr => int_axi_lite_awaddr,
            axi_awprot => int_axi_lite_awprot,
            axi_awvalid => int_axi_lite_awvalid,
            axi_awready => int_axi_lite_awready,
            axi_wvalid => int_axi_lite_wvalid,
            axi_wready => int_axi_lite_wready,
            axi_wdata => int_axi_lite_wdata,
            axi_wstrb => int_axi_lite_wstrb,
            axi_bvalid => int_axi_lite_bvalid,
            axi_bready => int_axi_lite_bready,
            axi_bresp => int_axi_lite_bresp,
            axi_araddr => int_axi_lite_araddr,
            axi_arprot => int_axi_lite_arprot,
            axi_arvalid => int_axi_lite_arvalid,
            axi_arready => int_axi_lite_arready,
            axi_rdata => int_axi_lite_rdata,
            axi_rvalid => int_axi_lite_rvalid,
            axi_rready => int_axi_lite_rready,
            axi_rresp => int_axi_lite_rresp);    
            
    plasoc_timer_inst : plasoc_timer 
        generic map (
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            axi_awaddr => timer_axi_lite_awaddr,
            axi_awprot => timer_axi_lite_awprot,
            axi_awvalid => timer_axi_lite_awvalid,
            axi_awready => timer_axi_lite_awready,
            axi_wvalid => timer_axi_lite_wvalid,
            axi_wready => timer_axi_lite_wready,
            axi_wdata => timer_axi_lite_wdata,
            axi_wstrb => timer_axi_lite_wstrb,
            axi_bvalid => timer_axi_lite_bvalid,
            axi_bready => timer_axi_lite_bready,
            axi_bresp => timer_axi_lite_bresp,
            axi_araddr => timer_axi_lite_araddr,
            axi_arprot => timer_axi_lite_arprot,
            axi_arvalid => timer_axi_lite_arvalid,
            axi_arready => timer_axi_lite_arready,
            axi_rdata => timer_axi_lite_rdata,
            axi_rvalid => timer_axi_lite_rvalid,
            axi_rready => timer_axi_lite_rready,
            axi_rresp => timer_axi_lite_rresp,
            done => timer_int);
            
    plasoc_gpio_inst : plasoc_gpio
        generic map (
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width,
            data_in_width => vc707_default_gpio_width,
            data_out_width => vc707_default_gpio_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            data_in => gpio_input,
            data_out => gpio_output,
            int => gpio_int,
            axi_awaddr => gpio_axi_lite_awaddr,
            axi_awprot => gpio_axi_lite_awprot,
            axi_awvalid => gpio_axi_lite_awvalid,
            axi_awready => gpio_axi_lite_awready,
            axi_wvalid => gpio_axi_lite_wvalid,
            axi_wready => gpio_axi_lite_wready,
            axi_wdata => gpio_axi_lite_wdata,
            axi_wstrb => gpio_axi_lite_wstrb,
            axi_bvalid => gpio_axi_lite_bvalid,
            axi_bready => gpio_axi_lite_bready,
            axi_bresp => gpio_axi_lite_bresp,
            axi_araddr => gpio_axi_lite_araddr,
            axi_arprot => gpio_axi_lite_arprot,
            axi_arvalid => gpio_axi_lite_arvalid,
            axi_arready => gpio_axi_lite_arready,
            axi_rdata => gpio_axi_lite_rdata,
            axi_rvalid => gpio_axi_lite_rvalid,
            axi_rready => gpio_axi_lite_rready,
            axi_rresp => gpio_axi_lite_rresp);
            
   axi_cdma_inst : axi_cdma_0
       PORT map (
         m_axi_aclk => aclk,
         s_axi_lite_aclk => aclk,
         s_axi_lite_aresetn => aresetn(0),
         cdma_introut => cdma_int,
         s_axi_lite_awaddr => cdmareg_axi_lite_awaddr(5 downto 0),
         s_axi_lite_awvalid => cdmareg_axi_lite_awvalid,
         s_axi_lite_awready => cdmareg_axi_lite_awready,
         s_axi_lite_wvalid => cdmareg_axi_lite_wvalid,
         s_axi_lite_wready => cdmareg_axi_lite_wready,
         s_axi_lite_wdata => cdmareg_axi_lite_wdata,
         s_axi_lite_bvalid => cdmareg_axi_lite_bvalid,
         s_axi_lite_bready => cdmareg_axi_lite_bready,
         s_axi_lite_bresp => cdmareg_axi_lite_bresp,
         s_axi_lite_araddr => cdmareg_axi_lite_araddr(5 downto 0),
         s_axi_lite_arvalid => cdmareg_axi_lite_arvalid,
         s_axi_lite_arready => cdmareg_axi_lite_arready,
         s_axi_lite_rdata => cdmareg_axi_lite_rdata,
         s_axi_lite_rvalid => cdmareg_axi_lite_rvalid,
         s_axi_lite_rready => cdmareg_axi_lite_rready,
         s_axi_lite_rresp => cdmareg_axi_lite_rresp,
         m_axi_arready => cdma_axi_full_arready,
         m_axi_arvalid => cdma_axi_full_arvalid,
         m_axi_araddr => cdma_axi_full_araddr,
         m_axi_arlen => cdma_axi_full_arlen,
         m_axi_arsize => cdma_axi_full_arsize,
         m_axi_arburst => cdma_axi_full_arburst,
         m_axi_arprot => cdma_axi_full_arprot,
         m_axi_arcache => cdma_axi_full_arcache,
         m_axi_rready => cdma_axi_full_rready,
         m_axi_rvalid => cdma_axi_full_rvalid,
         m_axi_rdata => cdma_axi_full_rdata,
         m_axi_rresp => cdma_axi_full_rresp,
         m_axi_rlast => cdma_axi_full_rlast,
         m_axi_awready => cdma_axi_full_awready,
         m_axi_awvalid => cdma_axi_full_awvalid,
         m_axi_awaddr => cdma_axi_full_awaddr,
         m_axi_awlen => cdma_axi_full_awlen,
         m_axi_awsize => cdma_axi_full_awsize,
         m_axi_awburst => cdma_axi_full_awburst,
         m_axi_awprot => cdma_axi_full_awprot,
         m_axi_awcache => cdma_axi_full_awcache,
         m_axi_wready => cdma_axi_full_wready,
         m_axi_wvalid => cdma_axi_full_wvalid,
         m_axi_wdata => cdma_axi_full_wdata,
         m_axi_wstrb => cdma_axi_full_wstrb,
         m_axi_wlast => cdma_axi_full_wlast,
         m_axi_bready => cdma_axi_full_bready,
         m_axi_bvalid => cdma_axi_full_bvalid,
         m_axi_bresp => cdma_axi_full_bresp,
         cdma_tvect_out => open);
         
    plasoc_uart_inst : plasoc_uart 
        generic map (
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            axi_awaddr => uart_axi_lite_awaddr,
            axi_awprot => uart_axi_lite_awprot,
            axi_awvalid => uart_axi_lite_awvalid,
            axi_awready => uart_axi_lite_awready,
            axi_wvalid => uart_axi_lite_wvalid,
            axi_wready => uart_axi_lite_wready,
            axi_wdata => uart_axi_lite_wdata,
            axi_wstrb => uart_axi_lite_wstrb,
            axi_bvalid => uart_axi_lite_bvalid,
            axi_bready => uart_axi_lite_bready,
            axi_bresp => uart_axi_lite_bresp,
            axi_araddr => uart_axi_lite_araddr,
            axi_arprot => uart_axi_lite_arprot,
            axi_arvalid => uart_axi_lite_arvalid,
            axi_arready => uart_axi_lite_arready,
            axi_rdata => uart_axi_lite_rdata,
            axi_rvalid => uart_axi_lite_rvalid,
            axi_rready => uart_axi_lite_rready,
            axi_rresp => uart_axi_lite_rresp,
            tx => uart_tx,
            rx => uart_rx,
            status_in_avail => uart_int);
            
    plasoc_timer_extra_0_inst : plasoc_timer
        generic map (
            axi_address_width => axi_lite_address_width,
            axi_data_width => axi_data_width)
        port map (
            aclk => aclk,
            aresetn => aresetn(0),
            axi_awaddr => timer_extra_0_axi_lite_awaddr,
            axi_awprot => timer_extra_0_axi_lite_awprot,
            axi_awvalid => timer_extra_0_axi_lite_awvalid,
            axi_awready => timer_extra_0_axi_lite_awready,
            axi_wvalid => timer_extra_0_axi_lite_wvalid,
            axi_wready => timer_extra_0_axi_lite_wready,
            axi_wdata => timer_extra_0_axi_lite_wdata,
            axi_wstrb => timer_extra_0_axi_lite_wstrb,
            axi_bvalid => timer_extra_0_axi_lite_bvalid,
            axi_bready => timer_extra_0_axi_lite_bready,
            axi_bresp => timer_extra_0_axi_lite_bresp,
            axi_araddr => timer_extra_0_axi_lite_araddr,
            axi_arprot => timer_extra_0_axi_lite_arprot,
            axi_arvalid => timer_extra_0_axi_lite_arvalid,
            axi_arready => timer_extra_0_axi_lite_arready,
            axi_rdata => timer_extra_0_axi_lite_rdata,
            axi_rvalid => timer_extra_0_axi_lite_rvalid,
            axi_rready => timer_extra_0_axi_lite_rready,
            axi_rresp => timer_extra_0_axi_lite_rresp,
            done => timer_extra_0_int);
            
end Behavioral;
