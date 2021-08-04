# self_other_longitudinal
Code used to analyze fMRI data in study development of neural correlates of self- and other-referential processing across adolescence. This data includes a longitudinal sample of young to mid-adolescents participating for three years in annual measurements, and cross-sectional data of an independent group of young adults. 
Scripts run in combination with packages mentioned in manuscript; SPM 12, generalized PPI (version 13.1) and marsbar, version 0.44.

Directory preprocessing_and_analyses contains main code used to run analyes. Function soconnect_mri_input_main_MT_longitudinal.m is used to set the directories, subjects to be analyzed and the numbers of the scans to be used, as well as which steps to perform (i.e. various preprocessing steps, first-level analysis, gPPI). This function calls soconnect_mri_pipeline_main_MT_longitudinal.m which runs the various preprocessing and analyses steps, by calling other functions and SPM batches.

Two functions are run outside of the main pipeline: soconnect_motion_calculation_longitudinal_MT.m calculates absolute motion (>3mm) and framewise displacement. 
soconnect_roi_analyzer_MT_lt.m calculates signal changes in ROIs using marsbar.

Moreover, various scripts are included serving as ‘filler scripts’ to fill in relevant information in SPM batches to perform second level analyses. These are:
-	soconnect_lt_twoflex_anova.m and soconnect_lt_twoflex_anova_gppi.m to fill in batch ‘soconnect_lt_twoflex_anova_subinter.mat’ to run two-way flexible factorial anova on the longitudinal data for whole-brain activity and connectivity analyses respectively. 
-	Similarly, soconnect_lt_twoflex_group_anova and soconnect_lt_twoflex_group_anova_gppi.m are scripts to fill in batch ‘soconnect_lt_twoflex_anova_group.mat’ to run mixed flexible factorial anova on the cross-sectional data (adolescents vs adults) for whole-brain activity and connectivity analyses respectively. 
-	Last, two scripts were used to fill in batch ‘soconnect_imCalc_averagecontrast.mat’ to create average contrast images over waves for activity (soconnect_ImCalc_average_contrast_image.m) and connectivity (soconnect_ImCalc_average_contrast_image_gppi.m).

