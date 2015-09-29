#Variable selection and subsetting
##Author: Tony Chang
##Date: 09.29.2015

####Abstract:

AH: 	"Subset the data such that we can explore the relationships of the predictor variables and basal area for 
		PIAL within the exclusive sub-alpine region in order to explore how important main and interactions are
		with limited impact from lower elevation climate/competition"

Division: Elevation division = mean(data$ELEV) - sd(data$ELEV) = 8234

N = 876

Abiotic effects:

##### For PIAL (from Chang et al 2014)

1)	TMIN_1

2)	PPT_9

3)	TMAX_7

4)	VPD_3

5)	PACK_4

6)	AET_7

7)	PET_8

##### For ABLA (from Piekielek et al 2015)

8)	SAND_L1

9)     VPD_8

10)   SOILM_6

11)	ROCKVOL_L1

##### Additional consideration (from 09.29.2015)

12)    AWC100
	
Biotic effects:

13)	ABLA_BA_TOTAL

14)	OTHER_BA_TOTAL = ALL_BA_TOTAL - ABLA_BA_TOTAL - PIAL_BA_TOTAL
	
Interactions:

15)	ABLA_BA_TOTAL * SAND_L1

16)	ABLA_BA_TOTAL * VPD_8

17)    ABLA_BA_TOTAL * SOILM_6

18)    ABLA_BA_TOTAL * ROCKVOL_L1

19)	OTHER_BA_TOTAL * WHC_100

Subset (high elevation model)
$$
/equation
{
PIAL_BA_TOTAL = TMIN_1 x_{1} + PPT_9 x_{2} + TMAX_7 x_{3} + VPD_3 x_{4} + PACK_4 x_{5} + AET_7 x_{6} + PET_8 x_{7} + SAND_L1 x_{8} + VPD_8 x_{9} + SOILM_6 x_{10} + ROCKVOL_L1 x_{11} + AWC x_{12} + ABLA_BA_TOTAL x_{13} +  OTHER_BA_TOTAL x_{14} + (ABLA_BA_TOTAL * SAND_L1) x_{15} + (ABLA_BA_TOTAL * VPD_8) x_{16} + (ABLA_BA_TOTAL * SOILM_6) x_{17} + (ABLA_BA_TOTAL * ROCKVOL_L1) x_{18} + (OTHER_BA_TOTAL * WHC_100) * x_{19}
}
$$