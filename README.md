#Lab 2 - Logical synthesis and Design for Test

##Introduction
On this lab we will get acquainted with the logical synthesis tool from Cadence: Genus.

During the lab you will get familiar with the different steps in the synthesis task and then will insert scan chains into a design.

##Genus start
As we did on the first lab we will source the config_cadence.sh script to set up the paths for Cadence flow:

```console
> source config_cadence.sh
```

Now we can ensure that Genus works by invoking it:

```console
> genus
```

## Synthesis flow scripts
Unlike what we did on lab 1 where we spent most of the time issuing individual commands here we will use a complete flow of scripts to run synthesis on the designs.

The first task of the lab is to examine and get familiar with these files. Start by opening run.tcl script and read it through. You will find references to familiar stages like map to generic gates, map to technology gates, optimization, timing verification. For each of these tasks a separate script will be executed. This is done to simplify the main script.

Now start checking out each of the separate scripts. Notice how they are very generic scripts that could be run across many designs simply adjusting some TCL variables.


## Initial synthesis

Now we will run out first synthesis. Make sure you're in the sync_fifo/syn/run directory and call up Genus with the run.tcl script:

```console
> genus -files ../scripts/run.tcl
```

After some screens of text output the synthesis process should complete without errors. Now it's time to review the files written out by Genus to the out/ and rep/ directories. You will find things like the intermediate and final synthesis netlist, and different reports about timing, area, gate in each of the different synthesis stages.


## Synthesis reports
Now that our initial synthesis run has completed we will examine the multiple report files written out by Genus. Notice how many reports repeat from synthesis state to synthesis stage. This may be useful when debugging some area or timing issue. For now we will concentrate on the reports from final stage, after all the mapping and optimizations have been completed.

Check out the final_gates.rpt. Notice how it describes the total gate count, plus counter per gate type and includes an estimation of leakage power.

Now check out final_qor.rpt. Notice how it describes the TNS and WNS slacks, plus the area figures.

Then check out final_timing.rpt which has a similar structure to Tempus reports from Lab 1. Here the paths with worst timing are analyzed.

Finally check out final.rpt. This is a summary table of different metrics across the synthesis stages. It may be useful to see how each of the stages contributes to the final figures.

### Retiming
In order to apply retiming to a design we will need to push timing into violations. Do so by increasing the clock frequency like you did for Lab 1 so synthesis shows a small violation as worst path. Make a backup copy of the /rep folder so you can compare the runs.
Now add this command on top of syn_generic.tcl script:

```commandline
set_db design:$BLOCK_NAME .retime true
```

Rerun synthesis and notice how the tool takes a longer time as Genus is performing retiming. Search the logfile for "retime" and notice how it describes the WNS retiming will attempt to correct.

### Effort level
By default effort levels are all set to medium:
```commandline
set GEN_EFF medium
set MAP_OPT_EFF medium
```
Experiment setting it to high for both GEN_EFF and MAP_OPT_EFF when over-constraining the clock frequency and notice the effect on area and timing.

### DFT insertion
In order to insert scan into the design we need to manually edit the RTL code and introduce the dedicated scan controls, inputs and outputs. Since the design isn't too large we can do with a single scan chain. Larger designs will require many scan chains.

Now set DO_INSERT_SCAN to true in syn.tcl, so the calls to scan_define.tcl and scan_insert.tcl are executed. Add the appropriate scan control port names in scan_define.tcl. Look for the TODO comments.

Then we will need to create a separate set of timing constraints fort scan mode. Make sure to add a set_case_analysis in both the functional and scan constraints file where you set scan_mode and scan_enable to the correct value.

### Scan compression