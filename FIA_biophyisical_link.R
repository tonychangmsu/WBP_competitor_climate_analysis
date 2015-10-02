#Title: FIA_biophyisical_link.R
#Author: Tony Chang
#Date:09.17.2015
#Abstract: Merge the extracted point data with the collection of biophysical data

##############install required packages##############
#install.packages('rgdal')
#install.packages('raster')
#install.packages('dismo')

require(rgdal)
require(raster)
require(dismo)
require(data.table)
require(bit64)
filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\wbp_bbox_all_trees_classified.csv'
FIA_subset = fread(filename, sep = ",", showProgress=T) 

#define the points of interest to extract from raster
fia_xy = cbind(FIA_subset$LON, FIA_subset$LAT)
fia_s = SpatialPoints(fia_xy)
projection(fia_s) = CRS("+proj=longlat +ellps=WGS84")

rasterpath = 'E:\\Soil'
rasterlist = list.files(path = rasterpath, pattern = '*.tif$')
nlist = length(rasterlist)

#define the bounding box
xmax = -108.263
xmin = -112.436
ymin = 42.252
ymax = 46.182

x = c(xmin, xmax)
y = c(ymin, ymax)
xy = cbind(x,y)
s = SpatialPoints(xy)
projection(s) = CRS("+proj=longlat +ellps=WGS84")

for (i in 1:nlist){
  rasterfile = paste(rasterpath,'\\',rasterlist[i], sep = '')
  data = raster(rasterfile)
  projection(data) = CRS("+proj=longlat +ellps=WGS84")
  
  data_clip = crop(data, s) #crop the data
  #since the name of the files use the conus_gcs72_L#_VARNAME.tif template, we can just get the variable name from filename
  extracted_values = extract(data_clip, fia_s, method='simple')
  
  varname = substr(rasterlist[i],13,nchar(rasterlist[i])-4) #get the name of the variable 
  
  FIA_subset[,paste(varname)] = extracted_values #add the extracted points
}

#new added 09.23.2015 @tchang
#adding rock volume layer
for (i in 1:11){
  varname = paste('ROCKVOL_L',i, sep='')
  rasterfile = paste('E:\\Land_Facet\\CONUS_SOIL\\',varname, '.tif',sep ='')
  data = raster(rasterfile)
  data_clip = crop(data,s)
  extracted_values = extract(data_clip, fia_s, method ='simple')
  FIA_subset[,paste(varname)] = extracted_values
}

#now get the climate variables
climate_folder = 'E:\\PRISM\\30yearnormals\\'
varlist = c('tmin', 'tmax', 'ppt', 'aet', 'pet', 'pack', 'soilm', 'vpd')
year = c(1980,2010)
month = seq(1,12)


for (i in 1:length(year)){
  for (j in 1:length(varlist)){
    for (k in 1:length(month)){
      rasterfile = paste(climate_folder,varlist[j],"\\", varlist[j],"_",year[i]-30,"_",year[i],"_",month[k],".tif",sep="")      
      data = raster(rasterfile)
      projection(data) = CRS("+proj=longlat +ellps=WGS84")
      data_clip = crop(data, s) #crop the data
      extracted_values = extract(data_clip, fia_s, method='simple')
      cname = toupper(paste(varlist[j],"_",month[k],"_",year[i]-30,"_",year[i],sep=""))
      FIA_subset[,paste(cname)] = extracted_values #add the extracted points
    }
  }
}

#finally consider landform metrics from Theobald dataset
lf_name = "E:\\Land_Facet\\ergo_geog_ProjectRaster.tif"
lf_data = raster(lf_name)
data_clip = crop(lf_data,s)
extracted_values = extract(data_clip, fia_s, method='simple')
cname = 'ERGO_GEOG'
FIA_subset[,paste(cname)] = extracted_values
#FIA_subset[,paste(cname)] = as.character(extracted_values) #don't save as characters

#write out the dataset
out = na.omit(FIA_subset)
#post-hoc change at site PLT_CN = 5379587010690 and 11795987010690, sees that the fuzzing landed the point into a water body. 
out = out[-19]
out = out[-2113] 
#last check
dim(out)
filename = 'E:\\Data_requests\\adhikari_08252015\\github_out\\wbp_bbox_all_trees_classified_linked.csv'
write.table(out, file =sprintf('%s', filename), sep = ',', row.names = FALSE)
