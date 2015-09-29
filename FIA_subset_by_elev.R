##Title: FIA_subset.R
#Author: Tony Chang
#Date:09.29.2015
#Abstract: Subsetting the PIAL dataset

require(rgdal)
require(raster)
require(dismo)
require(sqldf) #this is the sql library for R
require(data.table)
require(bit64)
require(Hmisc)
require(xtable)
filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\wbp_bbox_all_trees_classified_linked.csv'
FIA_subset = fread(filename, sep = ",", showProgress=T) 

#query where there is at least one whitebark pine and look at elevation, repeat with sub-alpine fir
pial_fs = sqldf(sprintf("SELECT * FROM FIA_subset WHERE PIAL_TOTAL > 0"))
#using 2 sd away from the mean of PIAL to determine the lower range of the distribution
elev_lim = mean(pial_fs$ELEV)-sd(pial_fs$ELEV)
hi_elev_fs = sqldf(sprintf("SELECT * FROM FIA_subset WHERE ELEV > %s",elev_lim))
hi_n = dim(hi_elev_fs)[1]
lo_elev_fs = sqldf(sprintf("SELECT * FROM FIA_subset WHERE ELEV <= %s",elev_lim))
lo_n = dim(lo_elev_fs)[1]

filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\all_trees_classified_linked_subset_HI.csv'
write.table(hi_elev_fs, file =sprintf('%s', filename), sep = ',', row.names = FALSE)
filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\all_trees_classified_linked_subset_LO.csv'
write.table(lo_elev_fs, file =sprintf('%s', filename), sep = ',', row.names = FALSE)