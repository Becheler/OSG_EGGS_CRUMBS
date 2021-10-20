# What does this do:

Perform a spatially explicit ABC analysis, running on Open-Science-Grid and using the
following simulation resources:

- quetzal-CoalTL
- quetzal-EGGS
- quetzal-CRUMBS
- decrypt

# User input

The following input files are defined by the user and should be placed in the `input_files` folder:

- `suitability.tif`: the suitability geotiff file for representing the landscape:
  - NA for representing ocean cells
  - 0 for representing continental cells of null suitability and infinite friction
  - ]0,1] values for intermediate suitability and frictions
- `EGG.conf`: configuration file for the quetzal-EGG used - unknown parameter values will be rewritten by the ABC pipeline
- `sample.csv`: file mapping sampled gene copies IDS to their latitude longitude sampling points
- `imap.txt`: IMAP file from BPP mapping individuals to putative populations for computing summary statistics

# User configuration

- Prior distributions for the demographic scenario are set in the `src/DAG/A.condor` file.
- Number of simulations is set in the `src/DAG/generate_DAG.sh` file.
- The pipeline Directed Acyclic Graph is generated with `sh src/DAG/generate_DAG.sh > workflow.dag`
- The worklow is submitted with `condor_submit_dag workflow.dag`
- Assess the advancement of simulations with `condor_watch_q`
- Once the simulations are done, retrieve:
  - summary statistics: `sh src/post-analysis/get_sumstats.sh`
  - parameters table: `sh src/post-analysis/get_param_table.sh`
