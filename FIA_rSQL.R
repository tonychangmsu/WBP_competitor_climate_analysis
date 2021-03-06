##############################################################################################################################
#Title: FIA_rSQL.R
#Version: 4.0
#Author: Tony Chang
#Date: 09/30/2015
#Abstract:  Querying through the FIA dataset on using the sqldf library in R version 3.2.0 
#           look at the methods to understand the many .csv files and the codes/meaning
#           http://www.fia.fs.fed.us/library/field-guides-methods-proc/
#          
#           All the CSV datafile can be downloaded at http://apps.fs.fed.us/fiadb-downloads/datamart.html 
#           at the bottom of the webpage. The ones necessary for this tutorial are TREE.CSV and PLOT.CSV

#           The REF_SPECIES.CSV can be found provided by TCHANG or found on page 226-235 of the Appendix F from the FIA Manual
#           http://www2.latech.edu/~strimbu/Teaching/FOR425/Species_Code_FIA.pdf

#           9/15/2015 changes: Changed the filtering parameters to use MANUAL <1.0 and DESIGNCD=1 as suggested from Jim Menlove 
#           USGS Ecologist/Analyst at the RMRS.
#           Also integrated into the query are two additional variables, Basal Area and Stand Density Index
#           defined as BA = 0.005454 * (DIA/2) when TREE.DIAHTCD =1
#         
#           9/30/2015 changes: Consideration for the year and trees that are only alive during the sampling process
##############################################################################################################################

#######LOADING LIBRARIES##############
#install.packages("data.table") #uncomment these to install packages
#install.packages("sqldf")
#note that the 'sqldf' library requires the R version 3.2.0

require(sqldf) #this is the sql library for R
require(data.table) #need this library to load the csv much faster as the datafiles are >1.0 GB

#######LOADING DATA##############
plotfile = "E:\\FIA\\PLOT.csv"
plot_cols = colnames(read.csv(file = plotfile, nrows = 1)) #get the column names within plots to look up
plot_scols = c("CN", "PLOT", "LAT", "LON", "ELEV", "MANUAL", "DESIGNCD", "STATECD", "INVYR") #and create a list of the column you want to reduce csv load time
plot = fread(plotfile, sep = ",", select = plot_scols, showProgress=T) 
#fread is from the data.table library, it is much faster than read.csv or read.table, but be patient as these files are very big

treefile = "E:\\FIA\\TREE.CSV"
tree_cols = colnames(read.csv(file = treefile, nrows = 1)) #get the column names within trees
tree_scols = c('CN', 'PLT_CN', 'PLOT', 'SPCD', 'TREE', 'DIA', 'HT', 'DIAHTCD', 'TPA_UNADJ', 'STATUSCD') #and create a list of the column you want to reduce csv load time
trees = fread(treefile, sep = ",", select = tree_scols, showProgress=T)

#require this later for Basal area calculations
filename = "E:\\FIA\\POP_STRATUM.CSV"
pop_cols = colnames(read.csv(file = filename, nrows = 1)) #get the column names within plots to look up
pop_scols = c("CN", "EXPNS") #and create a list of the column you want to reduce csv load time
pop = fread(filename, sep = ",", select = pop_scols, showProgress=T) 

#get the species code for each tree
spcdfile = "E:\\FIA\\REF_SPECIES.CSV"
spcds = fread(spcdfile, sep = ',')

#get the state codes
statefile = "E:\\FIA\\STATE.CSV"
statecds = fread(statefile, sep=',')

#Join STATECD to STATENAME
plots = sqldf(sprintf("SELECT * FROM plot JOIN statecds ON plot.STATECD = statecds.STATE_CD "))

############SUBSETTING##################################
#perform the qa early in the analysis and set bounding box
qa_conditions = '((DESIGNCD = 1 AND MANUAL < 1) OR (MANUAL >=1))'

xmax = -108.263
xmin = -112.436
ymin = 42.252
ymax = 46.182
#specify the bounds for the FIA data

bbox = sprintf('(LAT>=%s AND LAT<=%s AND LON>=%s AND LON<=%s)',ymin, ymax, xmin, xmax)

plots_qa = sqldf(sprintf("SELECT * FROM plots WHERE %s AND %s", qa_conditions, bbox))
###########QUERYING##############
#now we want all the trees including within the bounding box with a DIAHTCD = 1 (meaning the tree diameter was measured for DBH) and statuscd = 1
trees_req_cols = sprintf("trees.PLT_CN, trees.SPCD, trees.STATUSCD, trees.DIA, trees.DIA * 2.54 as 'DBH_CM', trees.HT, trees.HT * 0.3048 as 'HT_M', trees.DIA*trees.DIA *  0.005454154 * trees.TPA_UNADJ as 'BA_ACRE', trees.TPA_UNADJ")
plots_req_cols = sprintf("plots_qa.INVYR, plots_qa.LAT, plots_qa.LON, plots_qa.ELEV, plots_qa.ELEV * 0.3048 as 'ELEV_M' , plots_qa.STATE_NAME")
all_trees_bbox = sqldf(sprintf("SELECT %s, %s FROM trees, plots_qa WHERE (trees.PLT_CN = plots_qa.CN AND trees.DIA !='NA' AND trees.DIAHTCD =1 AND trees.STATUSCD =1)", trees_req_cols, plots_req_cols))
all_trees_bbox_wdead = sqldf(sprintf("SELECT %s, %s FROM trees, plots_qa WHERE (trees.PLT_CN = plots_qa.CN AND trees.DIA !='NA' AND trees.DIAHTCD =1)", trees_req_cols, plots_req_cols))
n_dead = dim(all_trees_bbox)[1]-dim(all_trees_bbox_wdead)[1]
#all trees = 83666, live only = 56471, dead = 27195

#need two groupby, 1)groupby CN 2)groupby spcd, then count by size classes...
select_trees = sqldf(sprintf("SELECT PLT_CN, SPCD, COUNT(SPCD) as 'TREE_TOTAL_COUNT', AVG(DIA) as 'MEAN_DBH', sqrt(variance(DIA)) as 'STDEV_DBH', SUM(TPA_UNADJ) as 'TOTAL_TPA' from all_trees_bbox WHERE (DIA > 0 AND STATUSCD = 1) GROUP BY PLT_CN, SPCD"))
#get only live trees
select_trees_all =sqldf(sprintf("SELECT PLT_CN, SPCD, COUNT(SPCD) as 'TREE_TOTAL_COUNT', AVG(DIA) as 'MEAN_DBH', sqrt(variance(DIA)) as 'STDEV_DBH', SUM(TPA_UNADJ) as 'TOTAL_TPA' from all_trees_bbox WHERE DIA > 0 GROUP BY PLT_CN, SPCD"))
#lets look at summing up th tpa_unadj column

plots_tpa = sqldf(sprintf("SELECT trees.PLT_CN, COUNT(trees.PLT_CN) as 'TREE_COUNT', SUM(trees.TPA_UNADJ) as SUM_TPA FROM trees, plots_qa WHERE (trees.DIAHTCD =1 AND trees.PLT_CN = plots_qa.CN) GROUP BY trees.PLT_CN"))
#this will be useful in linking the data for the Plot level TOTAL TPA, add it to plots_qa
plots_qa_tpa = sqldf(sprintf("SELECT plots_qa.*, plots_tpa.SUM_TPA, plots_tpa.SUM_TPA * 2.47105 AS TPH, plots_tpa.TREE_COUNT FROM plots_qa, plots_tpa WHERE plots_qa.CN = plots_tpa.PLT_CN"))

#okay so now one solution is just to get a list of all the unique species from which we'd like to build columns from
unique_trees = sqldf(sprintf("SELECT DISTINCT SPCD from select_trees "))
t_list = sqldf(sprintf("SELECT GENUS, SPECIES, COMMON_NAME, spcds.SPCD FROM spcds JOIN unique_trees ON spcds.SPCD = unique_trees.SPCD"))
#if we include all the plots then we get 17 tree species. #we may be only interested in the trees that exist with WBP however.

####################################################
############new 10.06.2015##########################
####################################################
#abstract: subsetted plots are using a variable plot sized due to lack of standardization (i.e MANUALCD !=1)
#          this creates disagreement in plot size and representaion of the small sized class tree counts. 
#          therefore, upon analysis of CLASS1 trees with predictor variables, a non-uniform plot size is not being account for (108 plots out of 2216). 
#          to create a more uniform dataset for statistical analysis, variable sized plots were removed (loss of 378 wbp tree counts from 37 plots (with WBP) all in WY except for one in MT ).
#          this must note that inference for CLASS1 tree is a sample population derived from a subplot scale (6.8 ft radius (FIA MANUAL pg. 1-11))
#          whereas all other CLASS tree model represent a sample population derived from a plot scale (24 ft radius subpplot (FIA MANUAL pg. 1-11))
######################################################################################

# attempting to remove variable sized subplots to attain a more uniform subset of sample plots
# however, small plots for sub 5" trees measured at 6.8' radius microplot are still prevalent and must be dealt with separately using the 
# TPA adjustments (see below). 
# generate map and table of variable sized plots and representative diameters
# remove variable sized plots from all_trees_bbox
# reclassify trees by CLASS1 <=4.9
# and CLASS 2 > 4.9 AND <= 8
# relink subset

dT = sqldf("SELECT PLT_CN, TPA_UNADJ, LAT, LON, ELEV FROM all_trees_bbox GROUP BY PLT_CN")
dis_TPA = sqldf("SELECT TPA_UNADJ, LAT, LON, ELEV, COUNT(TPA_UNADJ) as counts_TPA FROM dT GROUP BY TPA_UNADJ")
var_TPA = c(8.024060,12.036090, 24.072190 ,99.953710, 149.930560)
var_trees = sqldf("SELECT * FROM all_trees_bbox WHERE (TPA_UNADJ = 8.024060 OR TPA_UNADJ = 12.036090 OR TPA_UNADJ = 24.072190 OR TPA_UNADJ = 99.953710 OR TPA_UNADJ = 149.930560)")
wbp_var = sqldf("SELECT * FROM var_trees WHERE SPCD = 101")
elev_var = sqldf("SELECT * FROM wbp_var GROUP by PLT_CN")
var_TPA_plts = sqldf("SELECT * FROM dT WHERE (TPA_UNADJ = 8.024060 OR TPA_UNADJ = 12.036090 OR TPA_UNADJ = 24.072190 OR TPA_UNADJ = 99.953710 OR TPA_UNADJ = 149.930560)")
std_TPA_plts = sqldf("SELECT * FROM dT WHERE NOT(TPA_UNADJ = 8.024060 OR TPA_UNADJ = 12.036090 OR TPA_UNADJ = 24.072190 OR TPA_UNADJ = 99.953710 OR TPA_UNADJ = 149.930560)")
sm_plt_trees = sqldf("SELECT * FROM all_trees_bbox WHERE (TPA_UNADJ = 74.965282 OR TPA_UNADJ = 74.965280)")
lg_plt_trees = sqldf("SELECT * FROM all_trees_bbox WHERE (TPA_UNADJ = 6.018046 OR TPA_UNADJ = 6.018050)")
sm_plts = sqldf("SELECT * FROM sm_plt_trees GROUP BY PLT_CN")
lg_plts = sqldf("SELECT * FROM lg_plt_trees GROUP BY PLT_CN")

### we need a standard measure of trees per standard plot size. Where standard plot size is 6.018046 acres. Therefore, to get an estimate of 
### tree count per standard plot we divide by the 6.018046 acres and round up to nearest integer
### assuming that the counts of trees can be extrapolated (especially those of small diameter)
### to the larger plot. @t.chang 10/26/2015
### note: this is adjustment assumes analogous scaling to using a 
### response variable such as basal area or tree per acre, which have been used routinely in silviculture/forestry (Avery and Burkhart 2002).  

sm_lg = sqldf("SELECT lg_plts.* FROM lg_plts, sm_plts WHERE lg_plts.PLT_CN = sm_plts.PLT_CN")
plot(std_TPA_plts$LON, std_TPA_plts$LAT, pch = 'o', col = 'green', xlim = c(xmin, xmax), ylim = c(ymin, ymax), ann = FALSE)
par(new=TRUE)
plot(var_TPA_plts$LON, var_TPA_plts$LAT, pch = 'x', col = 'red', xlim = c(xmin, xmax), ylim = c(ymin, ymax), ann = FALSE)
title(xlab = 'LON (dd)')
title(ylab = 'LAT (dd)')

#plot(sm_lg$LON, sm_lg$LAT, pch = 2, cex = 0.5, xlim = c(xmin, xmax), ylim = c(ymin, ymax))
par(new=FALSE)

#hist(all_trees_bbox$TPA_UNADJ)# view histogram to see how many variable sized plots exist

#so subset all_trees_bbox to only include plots where the TPA_UNADJ = 6.018046 or 6.018050 or 74.965282 or 74.965280
all_trees_bbox$TPA_UNADJ = round(all_trees_bbox$TPA_UNADJ ,5) #round this to the nearest 5th decimal
all_trees_bbox_filter = sqldf("SELECT * FROM all_trees_bbox WHERE (TPA_UNADJ = 74.96528 OR TPA_UNADJ = 6.01805)")

############whitebark pine queries##################
######this is changed to just allow all trees######
#if so, then we need to query for the whitebark pine and the coexisting trees...
#now query to find where species is the latin name
#wbp_code = sqldf("SELECT SPCD FROM spcds WHERE SPECIES = 'albicaulis' AND GENUS = 'Pinus'") #this queries for the species albicaulis
#now query where tree is equal to this species code
#wbp = sqldf(sprintf("SELECT * FROM all_trees_bbox WHERE SPCD = %s",wbp_code))
#wbp_counts = sqldf("SELECT PLT_CN, COUNT (PLT_CN) as wbp_occurances FROM wbp GROUP BY PLT_CN")
# group by the PLT_CN to get all the treed sub-plots within PLOT
#from here we can join this with the 'plots' variable that has the topographic information 
#now join to the plots that match
#wbp_plots = sqldf("SELECT * FROM wbp_counts, plots_qa_tpa WHERE wbp_counts.PLT_CN=plots_qa_tpa.CN")
#unique_trees_wbp = sqldf(sprintf("SELECT DISTINCT select_trees.SPCD from select_trees, wbp_plots WHERE select_trees.PLT_CN = wbp_plots.PLT_CN"))
#t_list_wbp = sqldf(sprintf("SELECT GENUS, SPECIES, COMMON_NAME, spcds.SPCD FROM spcds JOIN unique_trees_wbp ON spcds.SPCD = unique_trees_wbp.SPCD"))
#There are only 9 species of trees that may coexist in a plot where WBP is present.
#I believe it is a good idea to only use these species for the search. This I will add to the metadata 

nrows = dim(t_list)[1]
spcd_list = character(nrows)
names_list = character(nrows) #going to make a list with 8 elements
sql_cmd = character(nrows)
db_name = 'all_trees_bbox_filter'
n_metrics = 7
class = c(' DIA <= 4.9 ',' DIA > 4.9 AND DIA <= 8 ',' DIA > 8 AND DIA <= 12 ',' DIA > 12 ')
for (i in 1:nrows) #implement a for loop from 1 to the total number of rows (nrows)
{
  g = substr(t_list$GENUS[i],1,2) #get the first 2 letters of the genus for the substring function
  s = substr(t_list$SPECIES[i],1,2) #get the first 2 letters of the string
  names_list[i] = toupper(paste(g,s, sep ="")) #concatenate the two variables and make them upper case then put into the names_list
  spcd_list[i] = t_list$SPCD[i] #fill spcd_list array with codes of species to create query
  temp_sql_cmd = character(length(class)+n_metrics) #generate a temporary array to store sql commands for each class of tree
  temp_sql_cmd[1] = paste('COUNT(CASE WHEN SPCD = ',spcd_list[i],' THEN PLT_CN END) AS ',names_list[i],'_TOTAL', sep="") #repeat this for all iterations
  #now generate a summary of the average DBH and standard deviation of all the trees in cm 
  temp_sql_cmd[2] = paste('AVG(CASE WHEN SPCD = ',spcd_list[i],' THEN DBH_CM END) AS ',names_list[i],'_AVG_DBH_CM', sep="")
  temp_sql_cmd[3] = paste('sqrt(VARIANCE(CASE WHEN SPCD = ',spcd_list[i],' THEN DBH_CM END)) AS ',names_list[i],'_STDEV_DBH_CM', sep="")
  temp_sql_cmd[4] = paste('SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN BA_ACRE END) * 0.2296  AS ',names_list[i],'_BA_M2HA', sep="")
  temp_sql_cmd[5] = paste('(sqrt(SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN (DBH_CM*DBH_CM) END)
                          /COUNT(CASE WHEN SPCD = ',spcd_list[i],' THEN PLT_CN END)))  
                           AS ',names_list[i],'_QMD_CM', sep="")
  temp_sql_cmd[6] = paste('SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN TPA_UNADJ END) * 2.47105 AS ',names_list[i],'_TPH', sep="")
  temp_sql_cmd[7] = paste('POWER((sqrt(SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN (DBH_CM*DBH_CM) END)
                          /COUNT(CASE WHEN SPCD = ',spcd_list[i],' THEN PLT_CN END))/25.4),1.605) * 
                          SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN TPA_UNADJ END) * 2.47105 AS ',names_list[i],'_SDI', sep="")
  for (j in 1:length(class))
  { 
    #implement another for loop for each class type
    #adding an if statement so we can count up the BA_M2HA for all within the size class
      sumry_first = paste('COUNT(CASE WHEN SPCD = ',spcd_list[i],' AND', class[j],'THEN PLT_CN END) AS ',names_list[i],'_CLASS',j, sep="") #repeat this for all iterations
      sumry_second = paste('SUM(CASE WHEN SPCD = ',spcd_list[i],' AND', class[j],'THEN BA_ACRE END) * 0.2296  AS ',names_list[i],'_CLASS',j, '_BA_M2HA', sep="") #repeat this for all iterations
      temp_sql_cmd[j+n_metrics] = paste(sumry_first, sumry_second, sep=', ')    
  }
  sql_cmd[i] = paste(temp_sql_cmd, collapse=', ') #collapse the temporary array as a single string element for the sql_cmd
}
#lets write the pivot table as a single string to put into our sqldf command for reuse later
sql_cmd_final = paste(sql_cmd, collapse=', ') #collapse all the string elements to a single string for the query

class_trees = sqldf(sprintf("SELECT PLT_CN, STATE_NAME, INVYR, LAT, LON, ELEV, ELEV_M, COUNT(PLT_CN) AS ALL_TREES_TOTAL, SUM(BA_ACRE) * 0.2296 AS ALL_TREES_BA_M2HA, %s FROM %s GROUP BY PLT_CN",sql_cmd_final,db_name)) #query and create the pivot table
class_trees[is.na(class_trees)] = as.numeric(0.0) #replace all the NA values with 0
#make sure all the columns are numeric
ncols = dim(class_trees)[2]
class_trees[,3:ncols] = as.numeric(unlist(class_trees[,3:ncols]))
class_trees[,1] = as.numeric(unlist(class_trees[,1])) #added this to allow sorting of the PLT_CNs

#last check before adding the abiotic are removal of off PLT_CNs where values of abiotic variables seemed strange
#PLT_CN 
bad_cns = c(5379587010690,11795987010690)
#bad_cns = c(5379587010690,11795987010690,37275577010690,2322590010690,5429042010690,4721383010690,40389476010690)
#find the bad CNs and plot the points and look at the environmental variables
v = c()
for (i in 1:length(bad_cns)){
  v = c(v,sprintf("PLT_CN != %s",bad_cns[i])) 
}
query = paste(v, collapse=' AND ')
out = sqldf(sprintf("SELECT * FROM class_trees WHERE %s", query))
#total number of samples with removal of dead trees drops down to 2216 from the original sample size of 2355
filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\wbp_bbox_all_trees_classified.csv'
write.table(out, file =sprintf('%s', filename), sep = ',', row.names = FALSE)

#####################################################################
###########################STOP######################################
#####################################################################
