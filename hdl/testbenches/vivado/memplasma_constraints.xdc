# Clock constraints.
create_clock -period 20.000 -name clock [get_ports aclk]
# Input delay constraints.
set_input_delay -clock [get_clocks clock] 2.000 [get_ports aresetn]
set_input_delay -clock [get_clocks clock] 2.000 [get_ports intr_in]
set_input_delay -clock [get_clocks clock] 2.000 [get_ports mem_in_data]
set_input_delay -clock [get_clocks clock] 2.000 [get_ports mem_in_valid]
set_input_delay -clock [get_clocks clock] 2.000 [get_ports mem_out_ready]
# Output delay constraints.
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_in_address]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_in_enable]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_in_ready]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_out_address]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_out_data]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_out_strobe]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_out_enable]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports mem_out_valid]
set_output_delay -clock [get_clocks clock] 2.000 [get_ports debug_cpu_pause]

#set_property DONT_TOUCH true [get_nets -regexp address_next.*]
#set_property DONT_TOUCH true [get_nets -regexp cpu_read_data.*]
#set_property DONT_TOUCH true [get_nets -regexp cpu_write_data.*]
#set_property DONT_TOUCH true [get_nets -regexp cpu_strobe_next.*]
#set_property DONT_TOUCH true [get_nets -regexp debug_cpu_pause.*]

#set_property DONT_TOUCH true [get_nets -regexp mem_in_data.*]