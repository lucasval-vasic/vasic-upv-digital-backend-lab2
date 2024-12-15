#######################################################################################################
## Optimize Netlist
#######################################################################################################

set_db / .syn_opt_effort $MAP_OPT_EFF
syn_opt
write_snapshot -outdir $REPORTS_PATH -tag syn_opt
report_summary -directory $REPORTS_PATH

puts "Runtime & Memory after 'syn_opt'"
time_info OPT
