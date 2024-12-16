# clocks
set CLK_FREQ 100.0
set CLK_PERIOD [expr 1e3/$CLK_FREQ]
create_clock -name clk -add -period $CLK_PERIOD [get_ports clock]

# inputs
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports data[*]]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports wrreq]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports rdreq]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports aclr]

set_load 0.1 [get_ports data[*]]
set_load 0.1 [get_ports wrreq]
set_load 0.1 [get_ports rdreq]
set_load 0.1 [get_ports aclr]
set_load 0.1 [get_ports clock]

set_driving_cell -lib_cell BUFX4 -library slow_1v0 -pin Y data[*]
set_driving_cell -lib_cell BUFX4 -library slow_1v0 -pin Y wrreq
set_driving_cell -lib_cell BUFX4 -library slow_1v0 -pin Y rdreq
set_driving_cell -lib_cell BUFX4 -library slow_1v0 -pin Y aclr
set_driving_cell -lib_cell BUFX4 -library slow_1v0 -pin Y clock

set_input_transition 1.3 [get_ports data[*]]
set_input_transition 1.3 [get_ports wrreq]
set_input_transition 1.3 [get_ports rdreq]
set_input_transition 1.3 [get_ports aclr]
set_input_transition 1.3 [get_ports clock]


# outputs
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports q[*]]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports full]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports empty]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports usedw]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports almost_full]

set_load 0.1 [get_ports q[*]]
set_load 0.1 [get_ports full]
set_load 0.1 [get_ports empty]
set_load 0.1 [get_ports usedw]
set_load 0.1 [get_ports almost_full]


set_propagated_clock [all_clocks]
set_clock_uncertainty -hold 0.1 [all_clocks]
set_clock_uncertainty -setup 0.1 [all_clocks]
