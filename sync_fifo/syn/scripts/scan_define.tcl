###############################################################################
## Scan definitions
###############################################################################

set SCAN_COMPRESS_RATIO 10

# define scan style, configuration
set_db dft_scan_style muxed_scan

set_db dft_prefix DFT_
set_db dft_identify_top_level_test_clocks false
set_db dft_identify_test_signals false

set_db [get_db designs $BLOCK_NAME] .dft_scan_map_mode tdrc_pass
set_db [get_db designs $BLOCK_NAME] .dft_connect_shift_enable_during_mapping tie_off
set_db [get_db designs $BLOCK_NAME] .dft_connect_scan_data_pins_during_mapping loopback
set_db [get_db designs $BLOCK_NAME] .dft_scan_output_preference non_inverted
set_db [get_db designs $BLOCK_NAME] .dft_lockup_element_type preferred_level_sensitive
set_db [get_db designs $BLOCK_NAME] .dft_mix_clock_edges_in_scan_chains true

### Scan signals definition

### TODO add appropriate port names for scan controls, inputs, outputs
# Scan enable
define_test_signal -function shift_enable -name TODO -active high TODO -lec_value 0 -default_shift_enable -test_only

# Test Mode
define_test_signal -function test_mode -name TODO -active high TODO -lec_value 0 -test_only

# Reset
define_test_signal -function async_set_reset -name TODO -active low TODO -lec_value no_value -shared_input -scan_shift

# Scan Clock
define_test_clock -name TODO TODO

# Scan chains
define_scan_chain -name scan_chain_0 -sdi TODO -sdo TODO -shared_output -shared_input
