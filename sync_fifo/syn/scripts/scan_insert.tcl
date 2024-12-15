set_db dft_identify_internal_test_clocks no_cgic_hier

## Run the DFT rule checks
redirect -tee $REPORTS_PATH/dft_insert_check_dft_rules_preinsert.rep {check_dft_rules}

report_dft_violations -tristate -xsource -xsource_by_instance -clock -abstract -async  -race -shiftreg > $REPORTS_PATH/dft_insert_advance_dft_violations.rep

# in 21.10 version, by default it is true
set_db dft_add_test_compression_new_flow false

connect_scan_chains

redirect $REPORTS_PATH/dft_insert_report_scan_chains.rep {report_scan_chains $BLOCK_NAME}

#analyze_scan_compressibility -library $USE_VERILOG_SIM_MODELS -decompressor broadcast -mask wide1 -ratios "10 20 30 40 50" -compression_method compress_scan_chains

redirect -tee $REPORTS_PATH/dft_insert_report_dft_setup.rep {report_scan_setup}

# Scan compression enable
define_test_signal TODO -name TODO -active high -function compression_enable -lec_value no_value
# Scan mask enable
define_test_signal TODO -name TODO -active high -function mask_enable -lec_value no_value
# Scan mask load
define_test_signal TODO -name TODO -active high -function mask_load -lec_value no_value
# Scan mask clk
define_test_clock -function compressor_clock -name TODO TODO

# In the following compress_scan_chains command, include the -decompressor option with the xor value 
# to build an XOR-based spreader network in addition to the broadcast-based decompression logic.  
compress_scan_chains -ratio $SCAN_COMPRESS_RATIO \
    -compression_enable TODO  \
    -compressor xor \
    -mask wide1 \
    -mask_enable TODO \
    -mask_clock TODO \
    -mask_load TODO \
    -write_timing_constraints $OUTPUTS_DIR/$BLOCK_NAME_compression_constr_out.tcl \
    $BLOCK_NAME

redirect $REPORTS_DIR/dft_insert_report_dft_chains_w_comp.rep {report dft_chains $BLOCK_NAME}
