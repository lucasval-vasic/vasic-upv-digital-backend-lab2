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

# Scan enable
define_test_signal -function shift_enable -name scan_enable -active high scan_enable -lec_value 0 -default_shift_enable -test_only

# Test Mode
define_test_signal -function test_mode -name scan_mode -active high scan_mode -lec_value 0 -test_only

# Reset
define_test_signal -function async_set_reset -name aclr -active low aclr -lec_value no_value -shared_input -scan_shift

# Scan Clock
define_test_clock -name clock clock

# Scan chains
define_scan_chain -name scan_chain_0 -sdi scan_in -sdo scan_out -shared_output -shared_input
