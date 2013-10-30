% statistics

function kh_Statistics( PathSourceAnalysis, Source_Pre, Source_Pst, PathStatistics )

% neue Funktion einbauen, die Source interpoliert auf template mni (dieses
% einlesen und downsamplen, damit nicht zu viele redundante Werte, dann auf


% noch zu erledigen:
% - Prüfe innerhalb deiner Funktion als erstes, ob die Dateien vorhanden sind und lade dann die Variablen. 

    Source_Pre        = strcat( PathSourceAnalysis, '\', Source_Pre, '.mat');
    Source_PreStim    = load( Source_Pre );
    Source_PreStim    = Source_PreStim.source_trials_int; 
    
    Source_Pst        = strcat( PathSourceAnalysis, '\', Source_Pst, '.mat');
    Source_PstStim    = load( Source_Pst );
    Source_PstStim    = Source_PstStim.source_trials_int;
    
    cfg_stats                     = [];
    cfg_stats.dim                 = Source_PreStim.dim;
    cfg_stats.method              = 'analytic';                 % significance probability can only be calculated by means of the so-called Monte Carlo method. 
    cfg_stats.statistic           = 'indepsamplesT';            % 'indepsamplesT', 'depsamplesT', 'actvsblT', % müsste eigentlich dependent sein, funktioniert aber nicht
    cfg_stats.clusteralpha        =  0.05 ;                     % All samples are selected whose t-value is larger than some threshold as specified in cfg.clusteralpha. 
    cfg_stats.parameter           = 'pow';
    cfg_stats.clusterthreshold    = 'nonparametric_common'  ;      %'nonparametric_individual': computes a threshold per voxel; nonparametric_common: uses the same
                                                                % threshold for all voxels  
    cfg_stats.clusterstatistic    = 'maxsum';                   %  how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
%                                                                option 'wcm' refers to 'weighted cluster mass',  a statistic that combines cluster size and
%                                                                intensity;  see Hayasaka & Nichols (2004) NeuroImage for details
    cfg_stats.correctm            = 'cluster';                    % correction of multiple comparisons:  'no', 'max', 'cluster', 'bonferoni', 'holms', or 'fdr' 
    cfg_stats.numrandomization    = 500     ;                      %  1000, oder 'all'
    cfg_stats.alpha               = 0.05; 
    cfg_stats.tail                = 0;                            % two-sided test
    cfg_stats.correcttail         = 'alpha';
    cfg_stats.design(1,:)         = [1:length(Source_PreStim.trial) 1:length(Source_PstStim.trial)];
    cfg_stats.design(2,:)         = [ones(1,length(Source_PreStim.trial)) ones(1,length(Source_PstStim.trial))*2];
    cfg_stats.ivar                = 2;                            % row of design matrix that contains independent variable (the conditions)
    cfg_stats.inputcoord          = 'mni';  
    
    cfg_stats.atlas               = 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateAtlas\ROI_MNI_V4.nii' ; 
    cfg_stats.roi                 = {'Precentral_L';'Precentral_R';'Frontal_Sup_L';'Frontal_Sup_R';'Frontal_Sup_Orb_L';'Frontal_Sup_Orb_R';'Frontal_Mid_L';'Frontal_Mid_R';'Frontal_Mid_Orb_L';'Frontal_Mid_Orb_R';'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R';'Frontal_Inf_Orb_L';'Frontal_Inf_Orb_R';'Rolandic_Oper_L';'Rolandic_Oper_R';'Supp_Motor_Area_L';'Supp_Motor_Area_R';'Olfactory_L';'Olfactory_R';'Frontal_Sup_Medial_L';'Frontal_Sup_Medial_R';'Frontal_Med_Orb_L';'Frontal_Med_Orb_R';'Rectus_L';'Rectus_R';'Insula_L';'Insula_R';'Cingulum_Ant_L';'Cingulum_Ant_R';'Cingulum_Mid_L';'Cingulum_Mid_R';'Cingulum_Post_L';'Cingulum_Post_R';'Hippocampus_L';'Hippocampus_R';'ParaHippocampal_L';'ParaHippocampal_R';'Amygdala_L';'Amygdala_R';'Calcarine_L';'Calcarine_R';'Cuneus_L';'Cuneus_R';'Lingual_L';'Lingual_R';'Occipital_Sup_L';'Occipital_Sup_R';'Occipital_Mid_L';'Occipital_Mid_R';'Occipital_Inf_L';'Occipital_Inf_R';'Fusiform_L';'Fusiform_R';'Postcentral_L';'Postcentral_R';'Parietal_Sup_L';'Parietal_Sup_R';'Parietal_Inf_L';'Parietal_Inf_R';'SupraMarginal_L';'SupraMarginal_R';'Angular_L';'Angular_R';'Precuneus_L';'Precuneus_R';'Paracentral_Lobule_L';'Paracentral_Lobule_R';'Caudate_L';'Caudate_R';'Putamen_L';'Putamen_R';'Pallidum_L';'Pallidum_R';'Thalamus_L';'Thalamus_R';'Heschl_L';'Heschl_R';'Temporal_Sup_L';'Temporal_Sup_R';'Temporal_Pole_Sup_L';'Temporal_Pole_Sup_R';'Temporal_Mid_L';'Temporal_Mid_R';'Temporal_Pole_Mid_L';'Temporal_Pole_Mid_R';'Temporal_Inf_L';'Temporal_Inf_R';'Cerebelum_Crus1_L';'Cerebelum_Crus1_R';'Cerebelum_Crus2_L';'Cerebelum_Crus2_R';'Cerebelum_3_L';'Cerebelum_3_R';'Cerebelum_4_5_L';'Cerebelum_4_5_R';'Cerebelum_6_L';'Cerebelum_6_R';'Cerebelum_7b_L';'Cerebelum_7b_R';'Cerebelum_8_L';'Cerebelum_8_R';'Cerebelum_9_L';'Cerebelum_9_R';'Cerebelum_10_L';'Cerebelum_10_R';'Vermis_1_2';'Vermis_3';'Vermis_4_5';'Vermis_6';'Vermis_7';'Vermis_8';'Vermis_9';'Vermis_10'};
    Stats_NoROIs                  = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.roi                 = {'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R'; 'SupraMarginal_L';'SupraMarginal_R'; ...
                                         'Angular_L';'Angular_R'; 'Temporal_Sup_L'; 'Temporal_Sup_R'; 'Temporal_Pole_Sup_L'; 'Temporal_Pole_Sup_R'; 'Temporal_Mid_L'; 'Temporal_Mid_R'; 'Temporal_Pole_Mid_L'; 'Temporal_Pole_Mid_R'; 'Temporal_Inf_L'; 'Temporal_Inf_R'; };
    
    cfg_stats.hemisphere          = 'left' ; %   'left' 'right', 'both', 'combined', specifying this is required when averaging over regions 
    Stats_allRois_left            = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.hemisphere          = 'right' ; 
    Stats_allRois_right             = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.hemisphere          = 'both' ; 
    Stats_allRois_both_hem          = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.hemisphere          = 'combined' ; 
    Stats_allRois_combined_hem      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    FileName_NoROIs = strcat( PathStatistics, '\', 'Stats_NoROIs', '.mat' );
    save( FileName_NoROIs, 'Stats_NoROIs' )
    
    FileName_allRois_left = strcat( PathStatistics, '\', 'Stats_allRois_left', '.mat' );
    save( FileName_allRois_left, 'Stats_allRois_left' )
  
    FileName_allRois_right = strcat( PathStatistics, '\', 'Stats_allRois_right', '.mat' );
    save( FileName_allRois_right, 'Stats_allRois_right' )
    
    FileName_allRois_both_hem = strcat( PathStatistics, '\', 'Stats_allRois_both_hem', '.mat' );
    save( FileName_allRois_both_hem, 'Stats_allRois_both_hem' )
    
    FileName_allRois_combined_hem = strcat( PathStatistics, '\', 'Stats_allRois_combined_hem', '.mat' );
    save( FileName_allRois_combined_hem, 'Stats_allRois_combined_hem' )
        
end


