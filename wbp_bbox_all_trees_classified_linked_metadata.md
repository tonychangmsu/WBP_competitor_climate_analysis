### Title: wbp_bbox_all_trees_classified_linked_08272015_metadata.txt
### Author: Tony Chang
### Institution: Montana State University Department of Ecology
### Date: 09-21-2015
'''
This file describes the attribute fields of the wbp_bbox_all_trees_classified_linked_08272015.csv 
file for reference and analysis. All response variables in this file were derived from the FIA
dataset (http://apps.fs.fed.us/fiadb-downloads/datamart.html)
using FIA_rSQL_v2_1.R script that will be posted on Github shortly for reproducibility. 

This selection of response variables are bounded by the defined GYE bounding box of 

xmax = -108.263
xmin = -112.436
ymin = 42.252
ymax = 46.182

in decimal degrees | WGS84 projection. 

FIA data was filtered for MANUAL code 1 as defined as follows from the National Core
Field Guide | Version 5.1 (http://www.fia.fs.fed.us/library/field-guides-methods-proc/) |
due to limited sampling using the MANUAL CODE = 1 in Wyoming | an additional filter of 
MANUAL <1.0 and DESIGNCD=1 was also utilized to increase sample size.
=======================================================================================
9/15/2015 changes: Changed the filtering parameters to use MANUAL <1.0 and DESIGNCD=1 as suggested from Jim Menlove USGS Ecologist/Analyst at the RMRS.
9/30/2015 changes: Changed the filtering parameters for trees to include only trees where STATUSCD = 1 to only consider live trees
Also integrated into the query are two additional variables | Basal Area and Stand Density Index defined as BA = 0.005454 * (DIA/2) when TREE.DIAHTCD =1

=======================================================================================
Data was further filtered for community analysis to only include competitors that 
co-occured where at least 1 Pinus albicaulis (whitebark pine) tree was found present. This does not include the FIA SEEDLING dataset. This was scheme was used to address the specific analysis of species/abiotic competitive interaction with Pinus albicaulis.

Counts of trees class definitions are as follows   
CLASS1 = ' DIA > 1 AND DIA <= 4 '
CLASS2 = ' DIA > 4 AND DIA <= 8 '
CLASS3 = ' DIA > 8 AND DIA <= 12 '
CLASS4 = ' DIA > 12 '

where DIA is the diameter at breast height measured in inches. 

Climate data were extracted for 30 year normals per month from the 30 arc-second spatial 
resolution PRISM climate dataset (http://www.prism.oregonstate.edu/) for two time periods
1) 1950-1980 normals and 2)1980-2010 normals
Water balance variables were derived in house using the Dingman 2002 model
(http://s3-eu-west-1.amazonaws.com/files.figshare.com/1779409/Text_S1.pdf)
and used in Chang et al 2014.  
(http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0111669)
All climate data was linked to FIA plot data found within the cells using 
FIA_climate_merge.py script. 

*_NOTE: FIA PLOTS HAVE NOT BEEN SCREENED FOR DATA LAT/LON FUZZING!_*

The FIADB includes coordinates for every plot location in the database | whether it is forested or
not | but these are not the precise locations of the plot centers. In an amendment to the Food Security
Act of 1985 (reference 7 USC 2276 § 1770) | Congress directed FIA to ensure the privacy of private
landowners. Exact plot coordinates could be used in conjunction with other publicly available data
to link plot data to specific landowners | in violation of requirements set by Congress. In addition to
the issue of private landowner privacy | the FIA program had concerns about plot integrity and
vandalism of plot locations on public lands. A revised policy has been implemented and methods
for making approximate coordinates available for all plots have been developed. These methods are
collectively known as “fuzzing and swapping” (Lister et al 2005).
In the past | FIA provided approximate coordinates for its periodic data in the FIADB. These
coordinates were within 1.0 mile of the exact plot location (this is called fuzzing). However |
because some private individuals own extensive amounts of land in certain counties | the data could
still be linked to these owners. In order to maintain the privacy requirements specified in the
amendments to the Food Security Act of 1985 | up to 20 percent of the private plot coordinates are
swapped with another similar private plot within the same county (this is called swapping). This
method creates sufficient uncertainty at the scale of the individual landowner such that privacy
requirements are met. It also ensures that county summaries and any breakdowns by categories |
such as ownership class | will be the same as when using the true plot locations. This is because only
the coordinates of the plot are swapped – all the other plot characteristics remain the same. The only
difference will occur when users want to subdivide a county using a polygon. Even then | results
will be similar because swapped plots are chosen to be similar based on attributes such as forest
type | stand-size class | latitude | and longitude (each FIA work unit has chosen its own attributes for
defining similarity).

For plot data collected under the current plot design | plot numbers are reassigned to sever the link to
other coordinates stored in the FIADB prior to the change in the law. Private plots are also swapped
using the method described above; remeasured plots are swapped independent of the periodic data.
All plot coordinates are fuzzed | but less than before – within 0.5 mile for most plots and up to 1.0
mile on a small subset of them. This was done to make it difficult to locate the plot on the ground |
while maintaining a good correlation between the plot data and map-based characteristics.

USDA Forest Service Gen. Tech. Rep. RMRS-GTR-245. 2010. pp 8-9

=======================================================================================
## STATSGO database (soils)

Information regarding abiotic soils factors were gathered from the STATSGO USDA NRCS webpage
http://www.nrcs.usda.gov/wps/portal/nrcs/detail/soils/survey/geo/?cid=nrcs142p2_053629

metadata for all units and attribute found at 
http://www.nrcs.usda.gov/wps/portal/nrcs/detail/soils/survey/geo/?cid=nrcs142p2_053631

and at

http://www.soilinfo.psu.edu/index.cgi?soil_data&conus&data_cov&mapunit

Standard layer depth are as follows (http://www.soilinfo.psu.edu/index.cgi?soil_data&conus&data_cov&texture&methods)
| Standard Layer | Thickness (cm) | Depth to Top of Layer (cm) | Depth to Bottom of Layer |
|----------------|----------------|----------------------------|--------------------------|
|1                |5                |0                         |5                         |
|2                |5                |5                         |10                        |
|3                |10               |10                        |20                        |
|4                |10               |20                        |30                        |
|5                |10               |30                        |40                        |
|6                |20               |40                        |60                        |
|7                |20               |60                        |80                        |
|8                |20               |80                        |100                       |
|9                |50               |100                       |150                       |
|10               |50               |150                       |200                       |
|11               |50               |200                       |250                       |

=====================================================================================
## Basal area and Stand Density Index calculations:

Basal Area: 
1. For each tree in the plot: BA = 0.005454 * (DIA)^2  where DIA would come from the TREE table and only use where TREE.DIAHTCD = 1 (which mean tree diameter was measured at DBH)

2. To see how much BA/acre is represented by each tree:  BA * TREE.TPA_UNADJ

3. Then | sum the BA/acre of all the trees on the plot to get plot-level BA in ft2/acre

4. Multiply by 0.2296 to convert to m2/ha

Stand Density Index:
The formula | in metric units is:
SDI =TPH x (QMD/25.4)^1.605

TPH = tree per hectare

QMD = quadratic mean diameter (cm) = sqrt(sum(dbh^2)/n) 

where n is the number of trees

For reference see
http://oak.snr.missouri.edu/forestry_functions/qmd.php
========================================================================================
========================================================================================
Units for each field are noted as follows:
========================================================================================
# Plot information 
* PLT_CN : 13-14 digit plot identification code
* STATE_NAME : Name of US State
* INVYR : Year when the plot inventory was taken
* LAT : North Latitude WGS84 degree
* LON : West Longitude WGS84 degree
* ELEV : Elevation in Feet
* ELEV_M : Elevation in Meter

=======================================================================================
# Tree data (response data)
* tree_abbreviation_TOTAL : Total count of specific tree species at plot
* tree_abbreviation_AVG_DBH_CM : Mean DBH of all specific tree species at plot (centimeters)
* tree_abbreviation_STDEV_DBH_CM : Standard deviation DBH of all specific tree species at plot (centimeters)
* tree_abbreviation_BA_M2HA : Basal areas of all specific tree species at plot (meters squared per hectare)
* tree_abbreviation_QMD_CM : Quadratic mean diameter of all specific tree species at plot (cm)
* tree_abbreviation_TPH : Trees per hectare for all specific tree species at plot (tree/hectare)
* tree_abbreviation_SDI : Stand Density Index for all specific tree species at plot (unitless)
* tree_abbreviation_CLASS1 : Count of CLASS1 trees at plot
* tree_abbreviation_CLASS2 : Count of CLASS2 trees at plot
* tree_abbreviation_CLASS3 : Count of CLASS3 trees at plot
* tree_abbreviation_CLASS4 : Count of CLASS4 trees at plot
* tree_abbreviation_CLASS1_BA_M2HA : Basal areas of CLASS1 trees at plot (meters squared per hectare)
* tree_abbreviation_CLASS2_BA_M2HA : Basal areas of CLASS2 trees at plot (meters squared per hectare)
* tree_abbreviation_CLASS3_BA_M2HA : Basal areas of CLASS3 trees at plot (meters squared per hectare)
* tree_abbreviation_CLASS4_BA_M2HA : Basal areas of CLASS4 trees at plot (meters squared per hectare)

tree_abbreviations represent the following list

          GENUS      SPECIES           COMMON_NAME SPCD tree_abbreviation
1.        Pinus   albicaulis        whitebark pine  101 PIAL
2.        Abies   lasiocarpa         subalpine fir   19 ABLA
3.        Pinus     contorta        lodgepole pine  108 PICO
4.        Picea  engelmannii      Engelmann spruce   93 PIEN
5.        Pinus     flexilis           limber pine  113 PIFL
6.        Pinus    ponderosa        ponderosa pine  122 PIPO
7.        Picea      pungens           blue spruce   96 PIPU
8.      Populus angustifolia narrowleaf cottonwood  749 POAN
9.      Populus  balsamifera      black cottonwood  747 POBA
10.     Populus    deltoides     plains cottonwood  745 PODE
11.     Populus  tremuloides         quaking aspen  746 POTR
12. Pseudotsuga    menziesii           Douglas-fir  202 PSME

Note: tree_abbreviation = ALL_TREES refers to the sum of the 12 listed species

=======================================================================================
# Climate data (predictor data)
* TMIN1-12_startyear_endyear : 30 year normal minimum temperatures in C 
* TMAX1-12_startyear_endyear : 30 year normal maximum temperatures in C
* PPT1-12_startyear_endyear : 30 year normal precipitation in mm
* AET1-12_startyear_endyear : 30 year normal actual evapotranspiration in mm
* PET1-12_startyear_endyear : 30 year normal potential evapotranspiration in mm
* PACK1-12_startyear_endyear : 30 year normal snow water equivalent in mm
* SOILM1-12_startyear_endyear : 30 year normal soil moisture in mm
* VPD1-12_startyear_endyear : 30 year normal vapor pressure deficit in kPa

=======================================================================================
# Soils data (STATSGO predictor data)
* AWC : Available water holding capacity (inches/inch)
* BD : Mean bulk density 
* CLAY : Percent clay content in denoted layer (% of soil < 2mm in size)
* PERM : Permeability rate (inches/hour) 
* ROCKDEPTHM : Depth to bedrock (Meter)
* SAND : Percent sand in content denoted layer (% of soil < 2mm in size)
* SILT : Percent silt in content denoted layer (% of soil < 2mm in size)
* ROCKVOL : Percent unattached particles 2 mm or larger in diameter that are strongly cemented or more resistant to rupture

=======================================================================================
* ERGO_GEOG : Land facet metric classification from David Theobald 

Labeling as follows:
VALUE | LABEL
11 | MOUNTAIN_DIVIDE
12 | PEAK_RIDGE
13 | CLIFF
20 | UPPER_SLOPE_FLAT
21 | UPPER_SLOPE_COOL
22 | UPPER_SLOPE_WARM
30 | LOWER_SLOPE_FLAT
31 | LOWER_SLOPE
33 | LOWER_SLOPE_WARM
41 | VALLEY
42 | VALLEY_NARROW

##### Please send questions regarding this data to Tony Chang or Arjun Adhikari at
##### tony.chang@msu.montana.edu  | arjun.adhikari@montana.edu
