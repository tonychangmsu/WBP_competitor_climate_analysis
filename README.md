# WBP_competitor_climate_analysis

Respository to home dataset for the whitebark pine (Pinus albicaulis) climate and competitor interaction analysis within the Greater Yellowstone Ecosystem. 

The code within this reposisitory requires the aquisition of the FIA datasets found at 
http://apps.fs.fed.us/fiadb-downloads/datamart.html

### Update: 09.28.2015 by @tchang

Added scatter plots and correlations (Spearman and Pearson) for all pairwise classes of PIAL versus ABAL and PIEN. 

Elevational divisions were created as follows

DIV1 : ELEV > 10000

DIV2 : 8800 < ELEV < 9500

DIV3 : ELEV < 8500

Please check the "plots" folder for associated output

### Update: 09.29.2015 by @tchang

Moving forward with analysis to a limited subset of the n = 2379, to be exclusive to the PIAL sub-alpine zone. Subsetting was performed by querying all plots with at least one PIAL present and determining the mean ($\mu = 9026.993'$) and standard deviation ($\sigma = 795.3836'$) of the elevation of those plots. Then the original dataset was re-queried to be in an elevation one standard deviation below the mean = 8234 ($\mu - \sd$)ft.  
