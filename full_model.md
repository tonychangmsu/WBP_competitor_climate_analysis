#Title: Full_model.md
###Author: Tony Chang, Katie Ireland
###Date: 09.30.2015

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

###Addition as of 09.30.2015 @tchang and @kgutzwiller, Updated at 3:03pm
###Due to interest of differing size classes and the advantages of built in SAS functions that is accepted by the literature, four models may be considered using only size classes. This would further allow consideration of intraspecific species competition

####for PIAL_CLASSN
where N is 1 through 4
$$
\begin{equation}

PIAL_CLASSN = INVYR + TMIN_1_1980_2010 + PPT_9_1980_2010 + TMAX_7_1980_2010 + VPD_3_1980_2010 + AET_7_1980_2010 + PET_8_1980_2010 + 
SOILM_6_1980_2010 + SAND_L1 + ROCKVOL_L1 + PACK_4_1980_2010 + VPD_8_1980_2010 + AWC100 + 
(PIAL_BA_M2HA-PIAL_CLASSN_BA_M2HA) + ABLA_BA_M2HA + PIEN_BA_M2HA + PSME_BA_M2HA + PICO_BA_M2HA +
(ABLA_BA_M2HA x SOILM_6_1980_2010) + (ABLA_BA_M2HA x SAND_L1) + (ABLA_BA_M2HA x ROCKVOL_L1) + (ABLA_BA_M2HA x PACK_4_1980_2010) + (ABLA_BA_M2HA x VPD_8_1980_2010) + 
(PIEN_BA_M2HA x SOILM_6_1980_2010) + (PIEN_BA_M2HA x SAND_L1) + (PIEN_BA_M2HA x ROCKVOL_L1) + (PIEN_BA_M2HA x PACK_4_1980_2010) + (PIEN_BA_M2HA x VPD_8_1980_2010) + 
(PSME_BA_M2HA x SOILM_6_1980_2010) + (PSME_BA_M2HA x SAND_L1) + (PSME_BA_M2HA x ROCKVOL_L1) + (PSME_BA_M2HA x PACK_4_1980_2010) + (PSME_BA_M2HA x VPD_8_1980_2010) + 
(PICO_BA_M2HA x SOILM_6_1980_2010) + (PICO_BA_M2HA x SAND_L1) + (PICO_BA_M2HA x ROCKVOL_L1) + (PICO_BA_M2HA x PACK_4_1980_2010) + (PICO_BA_M2HA x VPD_8_1980_2010) + 
(ALL_TREES_BA_M2HA-PIAL_BA_M2HA-ABLA_BA_M2HA-PIEN_BA_M2HA-PSME_BA_M2HA-PICO_BA_M2HA) + ((ALL_TREES_BA_M2HA-PIAL_BA_M2HA-ABLA_BA_M2HA-PIEN_BA_M2HA-PSME_BA_M2HA-PICO_BA_M2HA) x AWC100)

\end{equation}
$$

Total number of predictor variables per class count is 40 without removal from preliminary VIF analysis.