#################################
### Write outputs
#################################

write_snapshot -outdir $REPORTS_PATH -tag final
report_summary -directory ${REPORTS_PATH}
report_power > ${REPORTS_PATH}/final_power.rpt
write_hdl  > ${OUTPUTS_PATH}/${BLOCK_NAME}.vg
write_sdc > ${OUTPUTS_PATH}/${BLOCK_NAME}_m.sdc

write_do_lec -golden_design fv_map -revised_design ${OUTPUTS_PATH}/${BLOCK_NAME}_m.v -logfile  ${LOG_PATH}/intermediate2final.lec.log > ${OUTPUTS_PATH}/intermediate2final.lec.do
write_do_lec -revised_design ${OUTPUTS_PATH}/${BLOCK_NAME}_m.v -logfile ${LOG_PATH}/rtl2final.lec.log > ${OUTPUTS_PATH}/rtl2final.lec.do

if $DO_SCAN_COMPRESSION {
  set compression_option "-compression"
} else {
  set compression_option ""
}

if $DO_INSERT_SCAN {
  write_dft_atpg -directory $OUTPUTS_PATH $compression_option -run_from_directory -library \
    "/eda/xfab/XKIT/x_all/cadence/XFAB_Digital_Power_RefKit-cadence/v1_3_1/pdk/xh018/diglibs/D_CELLS_JIHD/v4_1/verilog/v4_1_0/D_CELLS_JIHD.v \
    /eda/xfab/XKIT/x_all/cadence/XFAB_Digital_Power_RefKit-cadence/v1_3_1/pdk/xh018/diglibs/D_CELLS_JIHD/v4_1/verilog/v4_1_0/VLG_PRIMITIVES.v " \
}
