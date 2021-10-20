# OSG_EGGS_CRUMBS

Scripts and configuration files used to get the following running on Open-Science-Grid:

- quetzal-CoalTL
- quetzal-EGGS
- quetzal-CRUMBS

# Input

The following input files are defined by the user and should be placed in the `input_files` folder:

- `suitability.tif`: the suitability geotiff file for representing the landscape:
  - NA for representing ocean cells
  - 0 for representing continental cells of null suitability and infinite friction
  - ]0,1] values for intermediate suitability and frictions
- `EGG.conf`: configuration file for the quetzal-EGG used - unknown parameter values will be rewritten by the ABC pipeline
- `sample.csv`: file mapping sampled gene copies IDS to their latitude longitude sampling points
- `imap.txt`: IMAP file from BPP mapping individuals to putative populations for computing summary statistics

# Configuration:

- Prior distributions for the demographic scenario are set in the `src/DAG/A.condor` file.
- Number of simulations is set in the `src/DAG/generate_DAG.sh` file.
-
