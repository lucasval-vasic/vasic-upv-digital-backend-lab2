
####################################################################################################
## Synthesizing to generic 
####################################################################################################

#set_db design:$BLOCK_NAME .retime true 

set_db / .syn_generic_effort $GEN_EFF
syn_generic

puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC

report_dp > $REPORTS_PATH/generic/${BLOCK_NAME}_datapath.rpt
write_snapshot -outdir $REPORTS_PATH -tag generic
report_summary -directory $REPORTS_PATH

write_hdl  > ${OUTPUTS_PATH}/${BLOCK_NAME}_intermediate.vg
