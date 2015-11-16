# WBP_competitor_climate_analysis

Respository to home dataset for the whitebark pine (Pinus albicaulis) climate and competitor interaction analysis within the Greater Yellowstone Ecosystem. 

The code within this reposisitory requires the aquisition of the FIA datasets found at 
http://apps.fs.fed.us/fiadb-downloads/datamart.html


### Update: 11.16.2015 by @tchang

Add new code for querying the FIA dataset in FIA_rSQL_v2.R. The major changes include usage of several addition tables and the latest release of the PLOT.CSV and TREE.CSV tables that include 2015 measurements. Total plots from the latest wbp_bbox_all_trees_classified_linked.csv file are n = 2150. The major changes in the query involve the requirement to have COND_STATUS_CD (from the COND.CSV table) to be equal to 1, which means the plots must come from a forested region (2 means non-forested and others typically imply a water body). Additionally, because some sub/micro plots are placed in partial conditions (i.e. half on a forested plot and half on a non-forested plot), then calculations relating to TPA (Trees Per Acre) and BA (Basal Area) are not the most accurate expansions of tree count within an area. This is adjusted for through application of the SUBPROP_UNADJ and MICRPROP_UNADJ adjustment factor values from the COND.CSV table. Finally, to relate the adjustment factors to a single plot (some plots have multiple adjustment factors depending on the year of measurement), we use the END_INVYR field from the POP_EVAL_GRP.CSV to note the latest year that the plot was completed in and take adjustment factor from that corresponding year. 

### Update: 09.30.2015 by @tchang

Agreement from the group on performing the full range of the sampling in order to account for environmental variability that could impact PIAL abundance.

Additional consideration for the sampling year (INVYR) and considering only live trees (STATUSCD = 1) to limit analysis to only live trees. This change has reduced to total trees in all plots to from 83666 total trees to 56471 live trees (27195 dead). Number of plots has reduced to 2191 due to removal of plots with only dead trees.   

### Update: 09.29.2015 by @tchang

Moving forward with analysis to a limited subset of the n = 2379, to be exclusive to the PIAL sub-alpine zone. Subsetting was performed by querying all plots with at least one PIAL present and determining the mean ($\mu = 9026.993'$) and standard deviation ($\sigma = 795.3836'$) of the elevation of those plots. Then the original dataset was re-queried to be in an elevation one standard deviation below the mean = 8234 ($\mu - \sd$)ft.  

### Update: 09.28.2015 by @tchang

Added scatter plots and correlations (Spearman and Pearson) for all pairwise classes of PIAL versus ABAL and PIEN. 

Elevational divisions were created as follows

DIV1 : ELEV > 10000

DIV2 : 8800 < ELEV < 9500

DIV3 : ELEV < 8500

Please check the "plots" folder for associated output


