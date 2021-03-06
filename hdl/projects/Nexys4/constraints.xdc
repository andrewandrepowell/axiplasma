set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports raw_clock]
#create_clock -period 10.000 -name clock -waveform {0.000 5.000} -add [get_ports raw_clock]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports raw_nreset]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {gpio_input[0]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {gpio_input[1]}]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {gpio_input[2]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {gpio_input[3]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {gpio_input[4]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {gpio_input[5]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {gpio_input[6]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {gpio_input[7]}]
set_property -dict {PACKAGE_PIN T8 IOSTANDARD LVCMOS18} [get_ports {gpio_input[8]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS18} [get_ports {gpio_input[9]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {gpio_input[10]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {gpio_input[11]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {gpio_input[12]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {gpio_input[13]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {gpio_input[14]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {gpio_input[15]}]

set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {gpio_output[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {gpio_output[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {gpio_output[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {gpio_output[3]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {gpio_output[4]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {gpio_output[5]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {gpio_output[6]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {gpio_output[7]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {gpio_output[8]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {gpio_output[9]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {gpio_output[10]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {gpio_output[11]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {gpio_output[12]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {gpio_output[13]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {gpio_output[14]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {gpio_output[15]}]

set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports uart_rx]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports uart_tx]

create_clock -period 20.000 -name VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0 -waveform {0.000 10.000}
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0] -min -add_delay 2.000 [get_ports {gpio_input[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0] -max -add_delay 2.000 [get_ports {gpio_input[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0] -min -add_delay 2.000 [get_ports raw_nreset]
set_input_delay -clock [get_clocks VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0] -max -add_delay 2.000 [get_ports raw_nreset]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0] -min -add_delay 0.000 [get_ports {gpio_output[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out1_ip_block_design_clk_wiz_0_0] -max -add_delay 0.000 [get_ports {gpio_output[*]}]

create_clock -period 104166.672 -name virtual_uart_baud_clock -waveform {10.000 52093.328}
set_input_delay -clock [get_clocks virtual_uart_baud_clock] -min -add_delay 2.000 [get_ports uart_rx]
set_input_delay -clock [get_clocks virtual_uart_baud_clock] -max -add_delay 2.000 [get_ports uart_rx]
set_output_delay -clock [get_clocks virtual_uart_baud_clock] -min -add_delay 2.000 [get_ports uart_tx]
set_output_delay -clock [get_clocks virtual_uart_baud_clock] -max -add_delay 2.000 [get_ports uart_tx]

set_false_path -from [get_clocks aclk_clk_wiz_0] -to [get_clocks ddr_aclk_clk_wiz_0]
set_false_path -from [get_clocks ddr_aclk_clk_wiz_0] -to [get_clocks aclk_clk_wiz_0]
set_false_path -from [get_clocks oserdes_clk] -to [get_clocks oserdes_clkdiv]
set_false_path -from [get_clocks oserdes_clk_1] -to [get_clocks oserdes_clkdiv_1]
set_false_path -from [get_clocks oserdes_clk_2] -to [get_clocks oserdes_clkdiv_2]
set_false_path -from [get_clocks oserdes_clk_3] -to [get_clocks oserdes_clkdiv_3]

#set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]
