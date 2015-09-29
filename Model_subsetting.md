#Variable selection and subsetting
#Author: Tony Chang
#Date: 09.29.2015

####Abstract:
AH: 	"Subset the data such that we can explore the relationships of the predictor variables and basal area for 
		PIAL"

Division, elevation division = mean(data$ELEV) - sd(data$ELEV) = 8234
N = 876

Abiotic effects:

1)	TMIN_6

2)	PPT_4

3)	SOILM_6

4)	TMAX_8

5)	VPD_8

6)	PACK_4

7)	ROCKVOL_L1

8)	SAND_L1

9)	WHC_100
	
Biotic effects:

10)	ABLA_BA_TOTAL

11)	OTHER_BA_TOTAL = ALL_BA_TOTAL - ABLA_BA_TOTAL - PIAL_BA_TOTAL
	
Interactions:

12)	ABLA_BA_TOTAL * TMAX_8

13)	ABLA_BA_TOTAL * PACK_4

14)	OTHER_BA_TOTAL * WHC_100

15)	PIEN_BA_TOTAL * VPD_8
