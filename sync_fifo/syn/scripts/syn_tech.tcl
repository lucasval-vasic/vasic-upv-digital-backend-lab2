####################################################################################################
## Synthesizing to gates
####################################################################################################

set_db / .syn_map_effort $MAP_OPT_EFF
syn_map

puts "Runtime & Memory after 'syn_map'"
time_info MAPPED

write_snapshot -outdir $REPORTS_PATH -tag map
report_summary -directory $REPORTS_PATH
report_dp > $REPORTS_PATH/map/${BLOCK_NAME}_datapath.rpt

write_do_lec -revised_design fv_map -logfile ${LOG_PATH}/rtl2intermediate.lec.log > ${OUTPUTS_PATH}/rtl2intermediate.lec.do
