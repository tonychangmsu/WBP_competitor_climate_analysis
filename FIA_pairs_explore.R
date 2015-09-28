#Title: FIA_pairs_explore.R
#Author: Tony Chang
#Date:09.28.2015
#Abstract: Pairwise comparison of all the different size classes

##############install required packages##############
#install.packages('rgdal')
#install.packages('raster')
#install.packages('dismo')

require(rgdal)
require(raster)
require(dismo)
require(sqldf) #this is the sql library for R
require(data.table)
require(bit64)
require(Hmisc)
require(xtable)
filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\wbp_bbox_all_trees_classified.csv'
FIA_subset = fread(filename, sep = ",", showProgress=T) 

#This procedure should repeat for the various elevation zones

#first query all trees plots where elevation is >10000
#fs = sqldf(sprintf("SELECT * FROM FIA_subset WHERE ELEV > 10000"))
#second query all trees plots where elevation is 8800>elev>9500
#fs = sqldf(sprintf("SELECT * FROM FIA_subset WHERE ELEV > 8800 AND ELEV < 9500"))
###third query all trees plots where elevation is elev < 8500
fs = sqldf(sprintf("SELECT * FROM FIA_subset WHERE ELEV < 8500"))
n_fs = dim(fs)[1]
#get a plot of the pairwise values for whitebark pine at class 4 versus class 4 ABLA and PIEN
#from the first subset we need class 4 WBP, class 4 ABLA and class 4 PIEN
pairs(PIAL_CLASS4~ABLA_CLASS4+PIEN_CLASS4+ABLA_CLASS3+PIEN_CLASS3+ABLA_CLASS2+PIEN_CLASS2+ABLA_CLASS1+PIEN_CLASS1, data = fs, main = "Scatterplot Matrix (Below 8500' elevation)")

colnames = c("PIAL_CLASS4","ABLA_CLASS4","PIEN_CLASS4","ABLA_CLASS3","PIEN_CLASS3","ABLA_CLASS2","PIEN_CLASS2","ABLA_CLASS1","PIEN_CLASS1")
fsdata = data.frame(fs$PIAL_CLASS4,fs$ABLA_CLASS4,fs$PIEN_CLASS4,fs$ABLA_CLASS3,fs$PIEN_CLASS3,fs$ABLA_CLASS2, fs$PIEN_CLASS2,fs$ABLA_CLASS1,fs$PIEN_CLASS1)
names(fsdata) = colnames
fsdata= as.matrix(fsdata)
x = fsdata[,c(2:9)]
y = fsdata[,c(1)]

rcorr(fsdata, type = "pearson")
rcorr(fsdata, type = "spearman")
#*******************************
#repeat for class 3,2,1 of PIAL
pairs(PIAL_CLASS3~ABLA_CLASS4+PIEN_CLASS4+ABLA_CLASS3+PIEN_CLASS3+ABLA_CLASS2+PIEN_CLASS2+ABLA_CLASS1+PIEN_CLASS1, data = fs, main = "Scatterplot Matrix (Below 8500' elevation)")

colnames = c("PIAL_CLASS3","ABLA_CLASS4","PIEN_CLASS4","ABLA_CLASS3","PIEN_CLASS3","ABLA_CLASS2","PIEN_CLASS2","ABLA_CLASS1","PIEN_CLASS1")
fsdata = data.frame(fs$PIAL_CLASS3,fs$ABLA_CLASS4,fs$PIEN_CLASS4,fs$ABLA_CLASS3,fs$PIEN_CLASS3,fs$ABLA_CLASS2, fs$PIEN_CLASS2,fs$ABLA_CLASS1,fs$PIEN_CLASS1)
names(fsdata) = colnames
fsdata= as.matrix(fsdata)
x = fsdata[,c(2:9)]
y = fsdata[,c(1)]

rcorr(fsdata, type = "pearson")
rcorr(fsdata, type = "spearman")
#*******************************
#repeat for class 3,2,1 of PIAL
pairs(PIAL_CLASS2~ABLA_CLASS4+PIEN_CLASS4+ABLA_CLASS3+PIEN_CLASS3+ABLA_CLASS2+PIEN_CLASS2+ABLA_CLASS1+PIEN_CLASS1, data = fs, main = "Scatterplot Matrix (Below 8500' elevation)")

colnames = c("PIAL_CLASS2","ABLA_CLASS4","PIEN_CLASS4","ABLA_CLASS3","PIEN_CLASS3","ABLA_CLASS2","PIEN_CLASS2","ABLA_CLASS1","PIEN_CLASS1")
fsdata = data.frame(fs$PIAL_CLASS2,fs$ABLA_CLASS4,fs$PIEN_CLASS4,fs$ABLA_CLASS3,fs$PIEN_CLASS3,fs$ABLA_CLASS2, fs$PIEN_CLASS2,fs$ABLA_CLASS1,fs$PIEN_CLASS1)
names(fsdata) = colnames
fsdata= as.matrix(fsdata)
x = fsdata[,c(2:9)]
y = fsdata[,c(1)]

rcorr(fsdata, type = "pearson")
rcorr(fsdata, type = "spearman")

#*******************************
#repeat for class 3,2,1 of PIAL
pairs(PIAL_CLASS1~ABLA_CLASS4+PIEN_CLASS4+ABLA_CLASS3+PIEN_CLASS3+ABLA_CLASS2+PIEN_CLASS2+ABLA_CLASS1+PIEN_CLASS1, data = fs, main = "Scatterplot Matrix (Below 8500' elevation)")

colnames = c("PIAL_CLASS1","ABLA_CLASS4","PIEN_CLASS4","ABLA_CLASS3","PIEN_CLASS3","ABLA_CLASS2","PIEN_CLASS2","ABLA_CLASS1","PIEN_CLASS1")
fsdata = data.frame(fs$PIAL_CLASS1,fs$ABLA_CLASS4,fs$PIEN_CLASS4,fs$ABLA_CLASS3,fs$PIEN_CLASS3,fs$ABLA_CLASS2, fs$PIEN_CLASS2,fs$ABLA_CLASS1,fs$PIEN_CLASS1)
names(fsdata) = colnames
fsdata= as.matrix(fsdata)
x = fsdata[,c(2:9)]
y = fsdata[,c(1)]

rcorr(fsdata, type = "pearson")
rcorr(fsdata, type = "spearman")



#########################################################################################################################
#########################################################################################################################
#########################################################################################################################




