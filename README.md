#Lab 2 - Logical synthesis and Design for Test

##Introduction
On this lab we will get acquainted with the logical synthesis tool from Cadence: Genus.

During the lab you will get familiar with the different steps in the synthesis task and then will insert scan chains into a design.

The lab includes files for the sync_fifo design, for the 0.18um X-Fab process. You will need to add the tcons files from Lab 1. If you complete all the lab you can also synthesize the async_fifo design, or port the design to the 0.35um AMS process.

##Genus start
As we did on the first lab we will source the config_cadence.sh script to set up the paths for Cadence flow:

```console
> source config_cadence.sh
```

Now we can ensure that Genus works by invoking it:

```console
> genus
```

##Synthesis flow scripts
Unlike what we did on lab 1 where we spent most of the time issuing individual commands here we will use a complete flow of scripts to run synthesis on the designs.

The first task of the lab is to examine and get familiar with these files. Start by opening run.tcl script and read it through. You will find references to familiar stages like map to generic gates, map to technology gates, optimization, timing verification. For each of these tasks a separate script will be executed. This is done to simplify the main script.

Now start checking out each of the separate scripts. Notice how they are very generic scripts that could be run across many designs simply adjusting some TCL variables.


##Initial synthesis

Now we will run out first synthesis. Make sure you're in the $BLOCK_NAME/syn/run directory and call up Genus with the run.tcl script:

```console
> genus -files ../scripts/run.tcl
```

After some screens of text output the synthesis process should complete without errors. Now it's time to review the files written out by Genus to the out/ and rep/ directories. You will find things like the intermediate and final synthesis netlist, and different reports about timing, area, gate in each of the different synthesis stages.


##Synthesis reports
Now that our initial synthesis run has completed we will examine the multiple report files written out by Genus. Notice how many reports repeat from synthesis state to synthesis stage. This may be useful when debugging some area or timing issue. For now we will concentrate on the reports from final stage, after all the mapping and optimizations have been completed.

Check out the final_gates.rpt. Notice how it describes the total gate count, plus counter per gate type and includes an estimation of leakage power.

On report_power.rpt you will find an estimate of the complete power figure consumed by the design and the breakdown into static and dynamic power.

Now check out final_qor.rpt. Notice how it describes the TNS and WNS slacks, plus the area figures.

Then check out final_timing.rpt which has a similar structure to Tempus reports from Lab 1. Here the paths with worst timing are analyzed.

Finally check out final.rpt. This is a summary table of different metrics across the synthesis stages. It may be useful to see how each of the stages contributes to the final figures.

##Restoring design
During each of the synthesis stages a snapshot is stored in the rep folder, named STAGE_BLOCK_NAME.db, where STAGE is each of the synthesis stages. We can quickly restore any of these checkpoints with the read_db command:

```commandline
read_db ../rep/STAGE_BLOCK_NAME.db
```

Restore the snapshot for the final stage, we will use it to query the design database.

##Design database. get_db, set_db

On Cadence tools the design information is stored in an internal database that we can query with the get_db, set_db commands.

get_db is used to read data from the database. There are two ways to access objects using get_db:
1. get_db object_type pattern
2. get_db object .attribute
Wildcards can be used for attribute names.
   
- The following example retrieves the current value of the library attribute on the root directory:
```commandline
:> get_db / .library
```
- The following example assumes you are already at the root of the design hierarchy, so the object specification is omitted:
```commandline
genus:> get_db library
```
- The following example returns the area of all flip flops. get_db is nestable.:
```commandline
genus:> get_db [get_db lib_cells *DFF*] .area
```
- The following example lists all root-level attributes starting with lp (related to low power implementation). It lists the attributes along with their values:
```commandline
genus:> get_db / .lp*
```

set_db is used to write data into the database. There are two ways to modify values of objects using set_db:

1. set_db object(s) .chain value
2. set_db object(s) .attribute value

-The following example sets the information_level attribute, which controls the verbosity of the tools, to the value of 5 and assumes the current directory for the path:
```commandline
genus:> set_db information_level 5
```
-The following locks the technology library search path to /home/Test/foo by locking the lib_search_path attribute. For the rest of the session, the lib_search_path attribute becomes read-only.:
```commandline
genus:> set_db -lock lib_search_path /home/Test/foo
```
-The following example shows how to set preserve attribute for instance a/b
```commandline
genus:> set_db inst:a/b .preserve true
```
-The following example shows how to set preserve attribute for all instances
```commandline
genus:> set_db [get_db insts] .preserve true
```
-The following example shows how to set max_fanout attribute for all input ports
```commandline
genus:> set_db [get_ports -filter direction==in] .max_fanout 10
```
-The following example shows how to set preserve attribute for the nets of the instance a/b
```commandline
genus: set_db inst:a/b .pins.net.preserve true
```

##Effort level
By default effort levels are all set to medium:
```commandline
set GEN_EFF medium
set MAP_OPT_EFF medium
```
Experiment setting it to high for both GEN_EFF and MAP_OPT_EFF when over-constraining the clock frequency and notice the effect on area and timing.

##Retiming
In order to apply retiming to a design we will need to push timing into violations. Do so by increasing the clock frequency like you did for Lab 1 so synthesis shows a small violation as worst path. Make a backup copy of the /rep folder so you can compare the runs.
Now add this command on top of syn_generic.tcl script:

```commandline
set_db design:$BLOCK_NAME .retime true
```

Rerun synthesis and notice how the tool takes a longer time as Genus is performing retiming. Search the logfile for "retime" and notice how it describes the WNS retiming will attempt to correct.

##DFT insertion
In order to insert scan into the design we need to manually edit the RTL code and introduce the dedicated scan controls, inputs and outputs. Since the design isn't too large we can do with a single scan chain. Larger designs will require many scan chains.

Now set DO_INSERT_SCAN to true in syn.tcl, so the calls to scan_define.tcl and scan_insert.tcl are executed. Add the appropriate scan control port names in scan_define.tcl. Look for the TODO comments.

Then we will need to create a separate set of timing constraints fort scan mode. Make sure to add a set_case_analysis in both the functional and scan constraints file where you set scan_mode and scan_enable to the correct value.

After all the required edits you can rerun the synthesis and inspect the rep/dft* reports. Notice there are 2 sets of reports: dft_preview* and dft_insert*. The first ones belong to the scan rules check before scan is inserted, and the second ones are the rules checks after scan chain insertion. Also the list of flops belonging to scan chains is reported. Make a note of the chain length.

##Run ATPG
After the scan insertion Genus will produce a complete setup for the Automated Test Pattern Generation task (ATPG). We can easily invoke Modus, the Cadence ATPG tool to check the testability of the design and get some coverage figures.

Simply go to the out/ directory and invoke Modus:

```commandline
modus -f runmodus.atpg.tcl
```

Check out the out/modus.log file and notice the different Modus commands compiled by Genus.

##Scan compression
In oder to add scan compression we need to add a few more extra ports to the Verilog code: scan_compr_enable, scan_mask_enable, scan_mask_load and scan_mask_clk. The first port enables the scan compressor. The mask controls allow masking, this is, disabling some of the paths going through the compressor

Then we need to enable insertion of scan compression with the DO_SCAN_COMPRESSION switch on run.tcl.

We also need to set the compression ratio at the top of scan_define.tcl. Values between 20 and 30 are usual.1

Finally we need to add the names for the newly added ports in the scan_define.tcl script.

After re-running the synthesis and ensuring that the compressor was properly inserted (check out the rep/dft_insert_report_dft_chains_w_comp.rep report and check that the compressed chain length matches the original chain size divided by the compression ratio), re-run Modus. You will that there are 2 ATPG vector generation stages, the first for FULLSCAN and the second one for COMPRESSION, which increases coverage with a reduced pattern count.

##Other suggestions

- adding observation/control flops