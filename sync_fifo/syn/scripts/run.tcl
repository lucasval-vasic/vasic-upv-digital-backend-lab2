puts "Hostname : [info hostname]"

##############################################################################
## Preset global variables and attributes
##############################################################################

set BLOCK_NAME sync_fifo
set GEN_EFF medium
set MAP_OPT_EFF medium
set DO_INSERT_SCAN false

set DATE [clock format [clock seconds] -format "%b%d-%T"] 
set OUTPUTS_PATH ../out
set REPORTS_PATH ../rep
set LOG_PATH ../log

set LIB_PATH {/home/lvalent/training/vasic_upv/lab1_dev/lib/slow.lib}
set LEF_PATH {/home/lvalent/training/vasic_upv/lab1_dev/lef/gsclib045_tech.lef /home/lvalent/training/vasic_upv/lab1_dev/lef/gsclib045_macro.lef}

set_db / .information_level 7 

if {![file exists ${LOG_PATH}]} {
  file mkdir ${LOG_PATH}
  puts "Creating directory ${LOG_PATH}"
}


if {![file exists ${OUTPUTS_PATH}]} {
  file mkdir ${OUTPUTS_PATH}
  puts "Creating directory ${OUTPUTS_PATH}"
}

if {![file exists ${REPORTS_PATH}]} {
  file mkdir ${REPORTS_PATH}
  puts "Creating directory ${REPORTS_PATH}"
}

###############################################################
## Library setup
###############################################################

set_db / .library $LIB_PATH
set_db / .lef_library $LEF_PATH

##set_db / .lp_insert_clock_gating true 

####################################################################
## Load Design
####################################################################


read_hdl -language v2001 "../../rtl/${BLOCK_NAME}.v"
elaborate $BLOCK_NAME
puts "Runtime & Memory after 'read_hdl'"
time_info Elaboration

check_design
check_design -unresolved

####################################################################
## Constraints Setup
####################################################################

read_sdc ../../tcons/${BLOCK_NAME}.sdc
puts "The number of exceptions is [llength [vfind "design:$BLOCK_NAME" -exception *]]"


####################################################################################################
## Scan definition
####################################################################################################
if $DO_INSERT_SCAN {
  source ../scripts/scan_define.tcl
}

define_cost_group -name I2C
path_group -from [all_inputs] -to [all_registers] -group I2C -name I2C
define_cost_group -name C2C
path_group -from [all_registers] -to [all_registers] -group C2C -name C2C
define_cost_group -name C2O
path_group -from [all_registers] -to [all_outputs] -group C2O -name C2O
define_cost_group -name I2O
path_group -from [all_inputs] -to [all_outputs] -group I2O -name I2O

####################################################################################################
## Synthesizing to generic 
####################################################################################################
source ../scripts/syn_generic.tcl

if $DO_INSERT_SCAN {
  redirect $REPORTS_PATH/dft_preview_check_dft_rules_post_cgic.rep {check_dft_rules}
  redirect $REPORTS_PATH/dft_preview_regs_initial.rep {report_scan_registers}
  redirect $REPORTS_PATH/dft_preview_setup_initial.rep {report_scan_setup}
  redirect $REPORTS_PATH/dft_preview_check_design_multidriven.rep {check_design -multiple_driver}
  redirect $REPORTS_PATH/dft_preview_advance_dft_violations.rep {report_dft_violations -tristate -xsource -xsource_by_instance}
}

####################################################################################################
## Synthesizing to gates
####################################################################################################
source ../scripts/syn_tech.tcl

####################################################################################################
## Insert scan
####################################################################################################
if $DO_INSERT_SCAN {
  source ../scripts/scan_insert.tcl
}
#######################################################################################################
## Optimize Netlist
#######################################################################################################
source ../scripts/optimize.tcl

#######################################################################################################
## Write outputs
#######################################################################################################
source ../scripts/write_outputs.tcl

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

quit
