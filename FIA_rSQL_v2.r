##############################################################################################################################
#Title: FIA_rSQL_v2.R
#Version: 4.0
#Author: Tony Chang
#Date: 11/16/2015, Modified Date 03/04/2016
#Abstract:  
#			Version 1
#			Querying through the FIA dataset on using the sqldf library in R version 3.2.0 
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
#
#			Version 2
#			11/16/2015 changes: Additional queries to consider the condition of sub-plot/micro-plot laying in exclusively 
#			forest or non-forest land. Adjustments to the TPA were made by proportion of sub/micro plot on forest.
#
#     03/04/2016 changed: Rounded all BA_M2HA values to least significant digit (0.01)
##############################################################################################################################

require(sqldf) #this is the sql library for R
require(data.table) #need this library to load the csv much faster as the datafiles are >1.0 GB
require(bit64)

#Define working directory where the FIA data is stored locally
wd = "E:\\FIA\\"

#Create a list of the column you want to reduce csv load time
plot_scols = c("CN", "PLOT", "LAT", "LON", "ELEV", "MANUAL", "DESIGNCD", "STATECD", "INVYR", "MEASYEAR") 
tree_scols = c("CN", "PLT_CN", "PLOT", "SPCD", "TREE", "DIA", "HT", "DIAHTCD", "TPA_UNADJ", "STATUSCD", "CONDID") 
cond_scols = c("PLT_CN","CONDID", "COND_STATUS_CD", "MICRPROP_UNADJ","SUBPPROP_UNADJ","MACRPROP_UNADJ","CONDPROP_UNADJ", "COND_NONSAMPLE_REASN_CD") 
pop_stratum_assgn_scols = c("PLT_CN", "STRATUM_CN")

#Load files
cond = fread(paste(wd,"COND.CSV", sep=""), select = cond_scols, showProgress=T)
plot = fread(paste(wd,"PLOT.CSV", sep=""), select = plot_scols, showProgress=T)
tree = fread(paste(wd,"TREE.CSV", sep=""), select = tree_scols, showProgress=T)
pop_plot_stratum_assgn = fread(paste(wd,"POP_PLOT_STRATUM_ASSGN.CSV", sep=""), select = pop_stratum_assgn_scols, showProgress=T)
pop_stratum = fread(paste(wd,"POP_STRATUM.CSV", sep=""), showProgress=T)
pop_estn_unit = fread(paste(wd,"POP_ESTN_UNIT.CSV", sep=""), showProgress=T)
pop_eval = fread(paste(wd,"POP_EVAL.CSV", sep=""), showProgress=T)
pop_eval_typ = fread(paste(wd,"POP_EVAL_TYP.CSV", sep=""), showProgress=T)
pop_eval_grp = fread(paste(wd,"POP_EVAL_GRP.CSV", sep=""), showProgress=T)

#get the species and state code for each tree
spcds = fread(paste(wd,"REF_SPECIES.CSV", sep=""), showProgress=T)
statecds = fread(paste(wd,"STATE.CSV", sep=""), showProgress=T)

plot = sqldf(sprintf("SELECT * FROM plot JOIN statecds ON plot.STATECD = statecds.STATE_CD "))
#total load time should be about ~6 min

######################################################################################################
######################################################################################################
######################################################################################################

#perform the qa early in the analysis and set bounding box
#reduce the plot geographic domain to increase query speeds. 

qa_conditions = '((DESIGNCD = 1 AND MANUAL < 1) OR (MANUAL >=1))'

xmax = -108.263
xmin = -112.436
ymin = 42.252
ymax = 46.182
#specify the bounds for the FIA data

bbox = sprintf('(LAT>=%s AND LAT<=%s AND LON>=%s AND LON<=%s)',ymin, ymax, xmin, xmax)
plot_qa = sqldf(sprintf("SELECT * FROM plot WHERE %s AND %s", qa_conditions, bbox))

#reduce the conditions domain to only include COND_STATUS_CD 1 or 2 
#forested and non-forested land FIADB User guide P2_6-0-1_final.pdf pg. 74
#note: there are non-unique PLT_CN in the CONDITIONS table
cond_qa = sqldf("SELECT * FROM cond c WHERE c.COND_STATUS_CD = 1 OR c.COND_STATUS_CD = 2")

plot_qa_2 = sqldf("SELECT pq.*, 
	cq.COND_STATUS_CD, cq.CONDID, cq.MICRPROP_UNADJ, cq.SUBPPROP_UNADJ, cq.MACRPROP_UNADJ, cq.CONDPROP_UNADJ, cq.COND_NONSAMPLE_REASN_CD 
	FROM plot_qa pq, cond_qa cq WHERE pq.CN = cq.PLT_CN")  #GROUP BY pq.CN")

#find duplicates
#dup = duplicated(plot_qa_2$CN) #yes there are duplicates that vary by the COND_STATUS_CD, 1 or 2

#almost there...
#now get plots that are within the EVAL_GRP

grps_to_match = c("montana", "idaho", "wyoming") #areas to match up
grps_query = paste(grps_to_match, collapse="|")
grps = unique(grep(grps_query,pop_eval_grp$EVAL_GRP_DESCR, ignore.case=TRUE)) #make sure no redundant

eval_grps = data.frame(EVAL_GRP = pop_eval_grp$EVAL_GRP[grps]) #codes for all the groups desired

#subset pop_eval_grp and pop_eval_typ to just these eval_grps and "EXPVOL" and other tables individually because R runs out of memory

pop_eval_grp_pre = sqldf("SELECT peg.*, pe.LOCATION_NM, pe.REPORT_YEAR_NM, pe.START_INVYR, pe.END_INVYR, pe.EVAL_DESCR FROM pop_eval_grp peg, pop_eval pe 
	WHERE peg.CN = pe.EVAL_GRP_CN")

#here we want to group on CN
pop_eval_grp_sub = sqldf("SELECT pegp.* 
	FROM pop_eval_grp_pre pegp 
	JOIN eval_grps eval ON pegp.EVAL_GRP = eval.EVAL_GRP
	GROUP BY pegp.CN")
	
pop_eval_typ_sub = sqldf("SELECT pet.*, pegs.EVAL_GRP, pegs.EVAL_GRP_DESCR, pegs.START_INVYR, pegs.END_INVYR 
	FROM pop_eval_typ pet, pop_eval_grp_sub pegs 
	WHERE pet.EVAL_TYP = 'EXPVOL' AND pet.EVAL_GRP_CN = pegs.CN")

pop_estn_unit_sub = sqldf("SELECT peu.*, pets.EVAL_GRP, pets.EVAL_GRP_DESCR, pets.START_INVYR, pets.END_INVYR  
	FROM pop_estn_unit peu, pop_eval_typ_sub pets, pop_eval pev 
	WHERE peu.EVAL_CN = pev.CN AND pev.CN = pets.EVAL_CN")

pop_plot_stratum_assgn_sub = sqldf("SELECT ppsa.*, peus.EVALID, peus.EVAL_GRP_DESCR, peus.START_INVYR, peus.END_INVYR, psm.EXPNS, psm.ADJ_FACTOR_MICR, psm.ADJ_FACTOR_SUBP, psm.ADJ_FACTOR_MACR 
	FROM pop_plot_stratum_assgn ppsa, pop_stratum psm, pop_estn_unit_sub peus 
	WHERE ppsa.STRATUM_CN = psm.CN AND peus.CN = psm.ESTN_UNIT_CN")

plot_query = sqldf("SELECT pq2.*, ppsas.EVALID, ppsas.START_INVYR, ppsas.END_INVYR, ppsas.EVAL_GRP_DESCR, ppsas.STRATUM_CN, ppsas.EXPNS, ppsas.ADJ_FACTOR_MICR, ppsas.ADJ_FACTOR_SUBP, ppsas.ADJ_FACTOR_MACR FROM plot_qa_2 pq2, pop_plot_stratum_assgn_sub ppsas WHERE ppsas.PLT_CN = pq2.CN") #GROUP BY pq2.CN")

#select by the most current year grouped by the CN
plot_query_2 = sqldf("SELECT *, MAX(END_INVYR) FROM plot_query GROUP BY CN, CONDID") #should select by the most current inventory year and differentiate different CONDID

# 7343 plots are not duplicated out of 8132 (789 have multiple CONDID)

#counting the plots that are status code 1 vs 2 to know what plots are non-timberland
#sqldf("select count(CN) FROM plot_query_2 group by COND_STATUS_CD")
#  count(CN)
#1      2654
#2      4689
#This sums up to the total plot_query_2
#lets plot the lat and lon

p_cd1 = sqldf("SELECT * FROM plot_query_2 WHERE COND_STATUS_CD =1")
p_cd2 = sqldf("SELECT * FROM plot_query_2 WHERE COND_STATUS_CD =2")
plot(p_cd1$LON, p_cd1$LAT, pch='o', col ='green', xlim = c(xmin, xmax), ylim = c(ymin, ymax), ann = FALSE)
par(new=TRUE)
plot(p_cd2$LON, p_cd2$LAT, pch='x', col ='red', xlim = c(xmin, xmax), ylim = c(ymin, ymax), ann = FALSE)
title(xlab = 'LON (dd)')
title(ylab = 'LAT (dd)')

#looks great.
#now link this to our trees

######################################################################################################
######################################################################################################
######################################################################################################

#now the plots have been selected. We move to the next phase of determining the tree adjustments
#STATUSCD = 1 means live tree(2 means dead)
#DIA >= 1.0 means that we want at least 1 in DBH
#DIAHTCD =1 means the DIA was measured at breast height (not root collar)

tree_qa = sqldf("SELECT * FROM tree t WHERE t.STATUSCD = 1 AND t.DIA >= 1.0 AND t.DIAHTCD =1")

#join the tree_qa table to plots
select_trees = sqldf("SELECT * FROM tree_qa t JOIN plot_query_2 p ON (t.PLT_CN = p.CN AND t.CONDID = p.CONDID)")[-c(1)] #remove column one because CN is redundant

#how many non-forest plot trees are there?
#non_forest_trees =  sqldf('SELECT * FROM select_trees WHERE COND_STATUS_CD =2') #183 so let's remove these as recommended
select_trees_forested = sqldf('SELECT * FROM select_trees WHERE COND_STATUS_CD =1') 

#now all we need to do with each of these trees is use the SUBPROP_UNADJ and MICRPROP_UNADJ values to multiply by the each TPA_UNADJ
#to get the adjusted TPA for each stand

#To check on the various TPA_UNADJ that exist and the counts of them we cna see below
#sqldf('SELECT TPA_UNADJ,COUNT(PLT_CN) FROM select_trees GROUP BY TPA_UNADJ')
#   TPA_UNADJ COUNT(PLT_CN)
#1   6.018046         25448
#2   6.018050         21005
#3   8.024060          2218
#4  12.036090           530
#5  24.072190             8
#6  74.965280          2595
#7  74.965282          4114
#8  99.953710           276
#9 149.930560            36

#most of our plots fit the standard plot specifications by the TPA results of 74.9625282 and 6.018046
#this gives us 56230 trees, with 2622 coming from a different condition code

unique_trees = sqldf(sprintf("SELECT DISTINCT SPCD from select_trees "))
t_list = sqldf(sprintf("SELECT GENUS, SPECIES, COMMON_NAME, spcds.SPCD FROM spcds JOIN unique_trees ON spcds.SPCD = unique_trees.SPCD"))
#this gives us 12 tree species

#using the previous code from FIA_rSQL.R version 1, 
#although we should additionally add the other metrics #i.e conversion of units 
#so lets build an array of the columns we would like
#perhaps we can have a TPA_ADJ by multiplying the TPA_UNADJ by the appropriate condition proportion given the DBH
#this means a trees per acre unadjusted will be reduced by the proportion of the plot that is within a specific condition
#of forested versus non-forested. That is, if we have count 30 tress on a plot total where 
#half of it is forested then we multiply the total count by ~6 trees per acre, then we multiply by 0.5.
#if it is measured on a microplot scale then we multiply the total by ~74 trees per acre and multiply by 0.5.

query_select = "PLT_CN, MANUAL, CONDID, COND_STATUS_CD, STATECD, STATE_NAME, MEASYEAR, INVYR, START_INVYR, END_INVYR, LAT, LON, 
		ELEV, ELEV * 0.3048 as 'ELEV_M', SPCD, DIA, DIA * 2.54 as 'DBH_CM', HT, HT * 0.3048 as 'HT_M', 
		TPA_UNADJ,  MICRPROP_UNADJ,  
		CASE WHEN SUBPPROP_UNADJ IS NULL THEN MICRPROP_UNADJ ELSE SUBPPROP_UNADJ END AS SUBPPROP_UNADJ
		,CASE WHEN DIA <= 4.9 THEN TPA_UNADJ*MICRPROP_UNADJ ELSE TPA_UNADJ*SUBPPROP_UNADJ END AS TPA_ADJ"

#for some reason there are NA in our SUBPPROP trees		
#joined and filtered trees table		
sub_tree_fj = sqldf(sprintf("SELECT %s FROM select_trees_forested",query_select)) 

tree_fj = sqldf("SELECT *, DIA*DIA *  0.005454154 * TPA_UNADJ as 'BA_ACRE_UNADJ', DIA*DIA * 0.005454154 * TPA_ADJ as 'BA_ACRE' FROM sub_tree_fj") #add basal area

#now we just need to sum up the values for each tree within a plot by size class and we should have the desired query.
#note: we will need to adjust TPA to integer value for a Zero-inflated Poisson distribution

#tree_fj = sqldf("SELECT *, DIA*DIA *  0.005454154 * TPA_UNADJ as 'BA_ACRE', TPA_UNADJ/0.404686 as 'TPH', DIA*DIA *  0.005454154 * TPA_UNADJ/0.404686 as 'BA_HECTARE' FROM sub_tree_fj")
#tree_fj = sqldf("SELECT *, DIA*DIA *  0.005454154 * TPA_UNADJ as 'BA_UNADJ_ACRE', DIA*DIA *  0.005454154 * TPA_ADJ as 'BA_ADJ_ACRE' FROM sub_tree_fj")
		
nrows = dim(t_list)[1]
spcd_list = character(nrows)
names_list = character(nrows) #going to make a list with 8 elements
sql_cmd = character(nrows)
db_name = 'tree_fj'
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
  temp_sql_cmd[4] = paste('ROUND(SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN BA_ACRE END) * 0.2296,2)  AS ',names_list[i],'_BA_M2HA', sep="")
  temp_sql_cmd[5] = paste('(sqrt(SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN (DBH_CM*DBH_CM) END)
                          /COUNT(CASE WHEN SPCD = ',spcd_list[i],' THEN PLT_CN END)))  
                           AS ',names_list[i],'_QMD_CM', sep="")
  temp_sql_cmd[6] = paste('CAST(ROUND(SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN TPA_ADJ END) * 2.47105) AS INT) AS ',names_list[i],'_TPH', sep="")
  temp_sql_cmd[7] = paste('POWER((sqrt(SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN (DBH_CM*DBH_CM) END)
                          /COUNT(CASE WHEN SPCD = ',spcd_list[i],' THEN PLT_CN END))/25.4),1.605) * 
                          SUM(CASE WHEN SPCD = ',spcd_list[i],' THEN TPA_ADJ END) * 2.47105 AS ',names_list[i],'_SDI', sep="")
  for (j in 1:length(class))
  { 
    #implement another for loop for each class type
    #adding an if statement so we can count up the BA_M2HA for all within the size class
      sumry_first = paste('COUNT(CASE WHEN SPCD = ',spcd_list[i],' AND', class[j],'THEN PLT_CN END) AS ',names_list[i],'_CLASS',j, sep="") #repeat this for all iterations
      sumry_second = paste('ROUND(SUM(CASE WHEN SPCD = ',spcd_list[i],' AND', class[j],'THEN BA_ACRE END) * 0.2296, 2)  AS ',names_list[i],'_CLASS',j, '_BA_M2HA', sep="") #repeat this for all iterations
	  sumry_third = paste('CAST(ROUND(SUM(CASE WHEN SPCD = ',spcd_list[i],' AND', class[j],' THEN TPA_ADJ END) * 2.47105) as INT) AS ',names_list[i],'_CLASS',j,'_TPH', sep="")
      temp_sql_cmd[j+n_metrics] = paste(sumry_first, sumry_second, sumry_third, sep=', ')    
  }
  sql_cmd[i] = paste(temp_sql_cmd, collapse=', ') #collapse the temporary array as a single string element for the sql_cmd
}
#lets write the pivot table as a single string to put into our sqldf command for reuse later
sql_cmd_final = paste(sql_cmd, collapse=', ')

class_trees = sqldf(sprintf("SELECT PLT_CN, STATE_NAME, INVYR, MEASYEAR, LAT, LON, ELEV, ELEV_M, COUNT(PLT_CN) AS ALL_TREES_TOTAL, ROUND(SUM(BA_ACRE) * 0.2296,2) AS ALL_TREES_BA_M2HA, %s FROM %s GROUP BY PLT_CN",sql_cmd_final,db_name)) #query and create the pivot table
class_trees[is.na(class_trees)] = as.numeric(0.0) #replace all the NA values with 0

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
#update: with new queries, total count of plots is 2173 now @t.chang 2015.11.16

filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\wbp_bbox_all_trees_classified.csv'
write.table(out, file = sprintf('%s', filename), sep = ',', row.names = FALSE)


