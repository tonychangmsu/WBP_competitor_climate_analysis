#Title: Full_model.md
##Author: Tony Chang, Katie Ireland
##Date: 09.30.2015

####Abstract:
Full model of climate/species interaction for determining live PIAL abundances
$$
\begin{equation}

PIAL_BA_M2HA = INVYR + TMIN_1_1980_2010 + PPT_9_1980_2010 + TMAX_7_1980_2010 + VPD_3_1980_2010 + AET_7_1980_2010 + PET_8_1980_2010 + 
SOILM_6_1980_2010 + SAND_L1 + ROCKVOL_L1 + PACK_4_1980_2010 + VPD_8_1980_2010 + AWC100 + 
ABLA_BA_M2HA + PIEN_BA_M2HA + PSME_BA_M2HA + PICO_BA_M2HA +
(ABLA_BA_M2HA x SOILM_6_1980_2010) + (ABLA_BA_M2HA x SAND_L1) + (ABLA_BA_M2HA x ROCKVOL_L1) + (ABLA_BA_M2HA x PACK_4_1980_2010) + (ABLA_BA_M2HA x VPD_8_1980_2010) + 
(PIEN_BA_M2HA x SOILM_6_1980_2010) + (PIEN_BA_M2HA x SAND_L1) + (PIEN_BA_M2HA x ROCKVOL_L1) + (PIEN_BA_M2HA x PACK_4_1980_2010) + (PIEN_BA_M2HA x VPD_8_1980_2010) + 
(PSME_BA_M2HA x SOILM_6_1980_2010) + (PSME_BA_M2HA x SAND_L1) + (PSME_BA_M2HA x ROCKVOL_L1) + (PSME_BA_M2HA x PACK_4_1980_2010) + (PSME_BA_M2HA x VPD_8_1980_2010) + 
(PICO_BA_M2HA x SOILM_6_1980_2010) + (PICO_BA_M2HA x SAND_L1) + (PICO_BA_M2HA x ROCKVOL_L1) + (PICO_BA_M2HA x PACK_4_1980_2010) + (PICO_BA_M2HA x VPD_8_1980_2010) + 
(PIFL_BA_M2HA+PIPU_BA_M2HA+POTR_BA_M2HA) + ((PIFL_BA_M2HA+PIPU_BA_M2HA+POTR_BA_M2HA) x AWC100)

\end{equation}
$$
###################################################
Total number of variables in the full model considering all competitors is: 	39 variables

###Addition as of 09.30.2015 @tchang and @kgutzwiller
###Due to interest of differing size classes and the advantages of built in SAS functions that is accepted by the literature, four models may be considered using only size classes. This would further allow consideration of intraspecific species competition

# for PIAL_CLASSN
where N is 1 through 4
$$
\begin{equation}

PIAL_CLASSN = INVYR + TMIN_1_1980_2010 + PPT_9_1980_2010 + TMAX_7_1980_2010 + VPD_3_1980_2010 + AET_7_1980_2010 + PET_8_1980_2010 + 
SOILM_6_1980_2010 + SAND_L1 + ROCKVOL_L1 + PACK_4_1980_2010 + VPD_8_1980_2010 + AWC100 + 
(PIAL_TOTAL-PIAL_CLASSN) + ABLA_TOTAL + PIEN_TOTAL + PSME_TOTAL + PICO_TOTAL +
(ABLA_TOTAL x SOILM_6_1980_2010) + (ABLA_TOTAL x SAND_L1) + (ABLA_TOTAL x ROCKVOL_L1) + (ABLA_TOTAL x PACK_4_1980_2010) + (ABLA_TOTAL x VPD_8_1980_2010) + 
(PIEN_TOTAL x SOILM_6_1980_2010) + (PIEN_TOTAL x SAND_L1) + (PIEN_TOTAL x ROCKVOL_L1) + (PIEN_TOTAL x PACK_4_1980_2010) + (PIEN_TOTAL x VPD_8_1980_2010) + 
(PSME_TOTAL x SOILM_6_1980_2010) + (PSME_TOTAL x SAND_L1) + (PSME_TOTAL x ROCKVOL_L1) + (PSME_TOTAL x PACK_4_1980_2010) + (PSME_TOTAL x VPD_8_1980_2010) + 
(PICO_TOTAL x SOILM_6_1980_2010) + (PICO_TOTAL x SAND_L1) + (PICO_TOTAL x ROCKVOL_L1) + (PICO_TOTAL x PACK_4_1980_2010) + (PICO_TOTAL x VPD_8_1980_2010) + 
(PIFL_TOTAL+PIPU_TOTAL+POTR_TOTAL) + ((PIFL_TOTAL+PIPU_TOTAL+POTR_TOTAL) x AWC100)

\end{equation}
$$