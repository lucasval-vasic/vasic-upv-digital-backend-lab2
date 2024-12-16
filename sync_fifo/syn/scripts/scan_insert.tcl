set_db dft_identify_internal_test_clocks no_cgic_hier

## Run the DFT rule checks
redirect -tee $REPORTS_PATH/dft_insert_check_dft_rules_preinsert.rep {check_dft_rules}

report_dft_violations -tristate -xsource -xsource_by_instance -clock -abstract -async  -race -shiftreg > $REPORTS_PATH/dft_insert_advance_dft_violations.rep

# in 21.10 version, by default it is true
#set_db dft_add_test_compression_new_flow false

connect_scan_chains

redirect $REPORTS_PATH/dft_insert_report_scan_chains.rep {report_scan_chains $BLOCK_NAME}

#analyze_scan_compressibility -library $USE_VERILOG_SIM_MODELS -decompressor broadcast -mask wide1 -ratios "10 20 30 40 50" -compression_method compress_scan_chains

redirect -tee $REPORTS_PATH/dft_insert_report_dft_setup.rep {report_scan_setup}

if $DO_SCAN_COMPRESSION {
  # Scan compression enable
  define_test_signal scan_compr_enable -name scan_compr_enable -active high -function compression_enable -lec_value no_value
  # Scan mask enable
  define_test_signal scan_mask_enable -name scan_mask_enable -active high -function mask_enable -lec_value no_value
  # Scan mask load
  define_test_signal scan_mask_load -name scan_mask_load -active high -function mask_load -lec_value no_value
  # Scan mask clk
  define_test_clock -function compressor_clock -name scan_mask_clk scan_mask_clk

  # In the following compress_scan_chains command, include the -decompressor option with the xor value 
  # to build an XOR-based spreader network in addition to the broadcast-based decompression logic.  
  compress_scan_chains -ratio $SCAN_COMPRESS_RATIO \
      -compression_enable scan_compr_enable  \
      -compressor xor \
      -mask wide1 \
      -mask_enable scan_mask_enable \
      -mask_clock scan_mask_clk \
      -mask_load scan_mask_load \
      -write_timing_constraints $OUTPUTS_PATH/${BLOCK_NAME}_compression_constr_out.tcl \
      $BLOCK_NAME

  redirect $REPORTS_PATH/dft_insert_report_dft_chains_w_comp.rep {report dft_chains $BLOCK_NAME}
}
