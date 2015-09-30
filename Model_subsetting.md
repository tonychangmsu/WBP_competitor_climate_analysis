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

##### For PIAL

1)	TMIN_1

2)	PPT_9

3)	TMAX_7

4)	VPD_3

5)	PACK_4

6)	AET_7

7)	PET_8

##### For PICO

8)	SAND_L1

9)     VPD_8

10)   SOILM_6

11)	ROCKVOL_L1

##### Additional consideration (from 09.29.2015)

12)    AWC100
	
Biotic effects:

13)	PICO_BA_TOTAL

14)	OTHER_BA_TOTAL = ALL_BA_TOTAL - PICO_BA_TOTAL - PIAL_BA_TOTAL
	
Interactions:

15)	PICO_BA_TOTAL * SAND_L1

16)	PICO_BA_TOTAL * VPD_8

17)    PICO_BA_TOTAL * SOILM_6

18)    PICO_BA_TOTAL * ROCKVOL_L1

19)	OTHER_BA_TOTAL * AWC100

Subset (high elevation model)
$$
/equation
{
PIAL_BA_TOTAL = TMIN_1 x_{1} + PPT_9 x_{2} + TMAX_7 x_{3} + VPD_3 x_{4} + PACK_4 x_{5} + AET_7 x_{6} + PET_8 x_{7} + SAND_L1 x_{8} + VPD_8 x_{9} + SOILM_6 x_{10} + ROCKVOL_L1 x_{11} + AWC x_{12} + PICO_BA_TOTAL x_{13} +  OTHER_BA_TOTAL x_{14} + (PICO_BA_TOTAL * SAND_L1) x_{15} + (PICO_BA_TOTAL * VPD_8) x_{16} + (PICO_BA_TOTAL * SOILM_6) x_{17} + (PICO_BA_TOTAL * ROCKVOL_L1) x_{18} + (OTHER_BA_TOTAL * AWC100) * x_{19}
}
$$

############################################################################################
############################################################################################
############################################################################################

##### Update 09.30.2015 9:24pm @tchang

## Second stage for lower elevation group competitors assuming PICO is the major competitor

####Abstract:

Less than the original division: 

Elevation division = mean(data$ELEV) - sd(data$ELEV) = 8234

N = 2355 - 876 = 1503

Abiotic effects:

##### For PIAL

1)	TMIN_1

2)	PPT_9

3)	TMAX_7

4)	VPD_3

5)	PACK_4

6)	AET_7

7)	PET_8

##### For PICO

8)	SAND_L1

9)  VPD_8

10) SOILM_6

11)	ROCKVOL_L1

##### Additional consideration (from 09.29.2015)

12) AWC100
	
Biotic effects:

13)	PICO_BA_TOTAL

14)	OTHER_BA_TOTAL = ALL_BA_TOTAL - PICO_BA_TOTAL - PIAL_BA_TOTAL
	
Interactions:

15)	PICO_BA_TOTAL * SAND_L1

16)	PICO_BA_TOTAL * VPD_8

17) PICO_BA_TOTAL * SOILM_6

18) PICO_BA_TOTAL * ROCKVOL_L1

19)	OTHER_BA_TOTAL * AWC100

Subset (low elevation model)
$$
/equation
{
PIAL_BA_TOTAL = TMIN_1 x_{1} + PPT_9 x_{2} + TMAX_7 x_{3} + VPD_3 x_{4} + PACK_4 x_{5} + AET_7 x_{6} + PET_8 x_{7} + SAND_L1 x_{8} + VPD_8 x_{9} + SOILM_6 x_{10} + ROCKVOL_L1 x_{11} + AWC x_{12} + PICO_BA_TOTAL x_{13} +  OTHER_BA_TOTAL x_{14} + (PICO_BA_TOTAL * SAND_L1) x_{15} + (PICO_BA_TOTAL * VPD_8) x_{16} + (PICO_BA_TOTAL * SOILM_6) x_{17} + (PICO_BA_TOTAL * ROCKVOL_L1) x_{18} + (OTHER_BA_TOTAL * AWC100) * x_{19}
}
$$

############################################################################################
############################################################################################
############################################################################################
