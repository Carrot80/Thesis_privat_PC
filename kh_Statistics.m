% statistics

function kh_Statistics( ConfigFile, Source_Pre, Source_Pst, Path )

  % make frequency directory if not exists yet:
    DirFreqName = strcat (Path.Statistics, '\', ConfigFile.name);
    [state] = mkdirIfNecessary( DirFreqName );
    
    % Check, if data is already avaliable
%      StatsFileName = strcat( DirFreqName, '\', 'Stats_Broca_combined_hem', '.mat' )
%         if exist( StatsFileName, 'file' )
%             return;
%         end
                
  fprintf('starting with statistics of %s freqency band \n', ConfigFile.name);


% loading Data

  fprintf('loading source data ...\n' );


    FileSource_Pre    = strcat( Path.Interpolation, '\', ConfigFile.name, '\', Source_Pre, '_', ConfigFile.string, '_int', '.mat');
    Source_PreStim    = load( FileSource_Pre );
    Source_PreStim    = Source_PreStim.source_trials_int; 
    
    FileSource_Pst    = strcat( Path.Interpolation, '\', ConfigFile.name, '\', Source_Pst, '_', ConfigFile.string, '_int', '.mat');
    Source_PstStim    = load( FileSource_Pst );
    Source_PstStim    = Source_PstStim.source_trials_int;
    
    
    %% set config:
    
        cfg_stats                     = [];
        cfg_stats.dim                 = Source_PreStim.dim;
        cfg_stats.method              = 'analytic';                         % significance probability can only be calculated by means of the so-called Monte Carlo method. 
        cfg_stats.statistic           = 'indepsamplesT';                    % 'indepsamplesT', 'depsamplesT', 'actvsblT', % müsste eigentlich dependent sein, funktioniert aber nicht
        cfg_stats.clusteralpha        =  0.05 ;                             % All samples are selected whose t-value is larger than some threshold as specified in cfg.clusteralpha. 
        cfg_stats.parameter           = 'pow';
        cfg_stats.clusterthreshold    = 'nonparametric_common'  ;           %'nonparametric_individual': computes a threshold per voxel; nonparametric_common: uses the same
                                                                            % threshold for all voxels  
    %     cfg_stats.clusterstatistic    = 'maxsum';                         %  how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
    %                                                                       option 'wcm' refers to 'weighted cluster mass',  a statistic that combines cluster size and
    %                                                                       intensity;  see Hayasaka & Nichols (2004) NeuroImage for details
        cfg_stats.correctm            = 'cluster';                          % correction of multiple comparisons:  'no', 'max', 'cluster', 'bonferoni', 'holms', or 'fdr' 
    %     cfg_stats.numrandomization    = 500     ;                         %  1000, oder 'all'
        cfg_stats.alpha               = 0.05; 
        cfg_stats.tail                = 0;                                  % two-sided test
        cfg_stats.correcttail         = 'alpha';
        cfg_stats.design(1,:)         = [1:length(Source_PreStim.trial) 1:length(Source_PstStim.trial)];
        cfg_stats.design(2,:)         = [ones(1,length(Source_PreStim.trial)) ones(1,length(Source_PstStim.trial))*2];
        cfg_stats.ivar                = 2;                                  % row of design matrix that contains independent variable (the conditions)
        cfg_stats.inputcoord          = 'mni';  
        cfg_stats.atlas               = 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateAtlas\ROI_MNI_V4.nii' ; 
    
    %% compute stats for complete atlas: (for plotting, to have nice borders )
    
      % Check, if data is already avaliable
        fn_Stats_NoROIs = strcat( DirFreqName, '\', 'Stats_NoROIs', '.mat' );
     
        if ~exist( fn_Stats_NoROIs, 'file' ) 
    
                cfg_stats.roi                 = {'Precentral_L';'Precentral_R';'Frontal_Sup_L';'Frontal_Sup_R';'Frontal_Sup_Orb_L';'Frontal_Sup_Orb_R';'Frontal_Mid_L';'Frontal_Mid_R';'Frontal_Mid_Orb_L';'Frontal_Mid_Orb_R';'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R';'Frontal_Inf_Orb_L';'Frontal_Inf_Orb_R';'Rolandic_Oper_L';'Rolandic_Oper_R';'Supp_Motor_Area_L';'Supp_Motor_Area_R';'Olfactory_L';'Olfactory_R';'Frontal_Sup_Medial_L';'Frontal_Sup_Medial_R';'Frontal_Med_Orb_L';'Frontal_Med_Orb_R';'Rectus_L';'Rectus_R';'Insula_L';'Insula_R';'Cingulum_Ant_L';'Cingulum_Ant_R';'Cingulum_Mid_L';'Cingulum_Mid_R';'Cingulum_Post_L';'Cingulum_Post_R';'Hippocampus_L';'Hippocampus_R';'ParaHippocampal_L';'ParaHippocampal_R';'Amygdala_L';'Amygdala_R';'Calcarine_L';'Calcarine_R';'Cuneus_L';'Cuneus_R';'Lingual_L';'Lingual_R';'Occipital_Sup_L';'Occipital_Sup_R';'Occipital_Mid_L';'Occipital_Mid_R';'Occipital_Inf_L';'Occipital_Inf_R';'Fusiform_L';'Fusiform_R';'Postcentral_L';'Postcentral_R';'Parietal_Sup_L';'Parietal_Sup_R';'Parietal_Inf_L';'Parietal_Inf_R';'SupraMarginal_L';'SupraMarginal_R';'Angular_L';'Angular_R';'Precuneus_L';'Precuneus_R';'Paracentral_Lobule_L';'Paracentral_Lobule_R';'Caudate_L';'Caudate_R';'Putamen_L';'Putamen_R';'Pallidum_L';'Pallidum_R';'Thalamus_L';'Thalamus_R';'Heschl_L';'Heschl_R';'Temporal_Sup_L';'Temporal_Sup_R';'Temporal_Pole_Sup_L';'Temporal_Pole_Sup_R';'Temporal_Mid_L';'Temporal_Mid_R';'Temporal_Pole_Mid_L';'Temporal_Pole_Mid_R';'Temporal_Inf_L';'Temporal_Inf_R';'Cerebelum_Crus1_L';'Cerebelum_Crus1_R';'Cerebelum_Crus2_L';'Cerebelum_Crus2_R';'Cerebelum_3_L';'Cerebelum_3_R';'Cerebelum_4_5_L';'Cerebelum_4_5_R';'Cerebelum_6_L';'Cerebelum_6_R';'Cerebelum_7b_L';'Cerebelum_7b_R';'Cerebelum_8_L';'Cerebelum_8_R';'Cerebelum_9_L';'Cerebelum_9_R';'Cerebelum_10_L';'Cerebelum_10_R';'Vermis_1_2';'Vermis_3';'Vermis_4_5';'Vermis_6';'Vermis_7';'Vermis_8';'Vermis_9';'Vermis_10'};
                Stats_NoROIs                  = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
                Stats_NoROIs.name             = 'Stats_NoROIs'; % redundant, da auch in kh_PlotStatistics definiert 
                save( fn_Stats_NoROIs, 'Stats_NoROIs' )
                kh_PlotStatistics (ConfigFile, fn_Stats_NoROIs, 'Stats_NoROIs', Path)
        else
    
                kh_PlotStatistics (ConfigFile, fn_Stats_NoROIs, 'Stats_NoROIs', Path) % evtl. andere Plot-Funktion schreiben
    
        end
    
    %% Stats for all ROIs: 
    
    cfg_stats.roi                       = {'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R'; 'SupraMarginal_L';'SupraMarginal_R'; ...
                                         'Angular_L';'Angular_R'; 'Temporal_Sup_L'; 'Temporal_Sup_R'; 'Temporal_Pole_Sup_L'; 'Temporal_Pole_Sup_R'; 'Temporal_Mid_L'; 'Temporal_Mid_R'; 'Temporal_Pole_Mid_L'; 'Temporal_Pole_Mid_R'; 'Temporal_Inf_L'; 'Temporal_Inf_R'; };
    
    
    % Check, if data is already avaliable
        fn_Stats_allROIs_left           = strcat( DirFreqName, '\', 'Stats_allRois_left', '.mat' );
        fn_Stats_allROIs_right          = strcat( DirFreqName, '\', 'Stats_allRois_right', '.mat' );
        fn_Stats_allROIs_both_hem       = strcat( DirFreqName, '\', 'Stats_allRois_both_hem', '.mat' );
        fn_Stats_allROIs_combined_hem   = strcat( DirFreqName, '\', 'Stats_allRois_combined_hem', '.mat' );
         
        
     if ~exist( fn_Stats_allROIs_left, 'file' ) 
                
            cfg_stats.hemisphere          = 'left' ; %   'left' 'right', 'both', 'combined', specifying this is required when averaging over regions 
            Stats_allRois_left            = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_allRois_left.name       = 'Stats_allRois_left';
            save( fn_Stats_allROIs_left, 'Stats_allRois_left' )     
     end
     
     if ~exist( fn_Stats_allROIs_right, 'file' ) 
         
            cfg_stats.hemisphere          = 'right' ; 
            Stats_allRois_right           = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_allRois_right.name      = 'Stats_allRois_right';
            save( fn_Stats_allROIs_right, 'Stats_allRois_right' )      
     end       
            
     if ~exist( fn_Stats_allROIs_both_hem, 'file' ) 
    
            cfg_stats.hemisphere          = 'both' ; 
            Stats_allRois_both_hem        = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_allRois_both_hem.name   = 'Stats_allRois_both_hem';
            save( fn_Stats_allROIs_both_hem, 'Stats_allRois_both_hem' )
            kh_PlotStatistics (ConfigFile, fn_Stats_allROIs_both_hem, 'Stats_allRois_both_hem', Path)
            
     else
         kh_PlotStatistics (ConfigFile, fn_Stats_allROIs_both_hem, 'Stats_allRois_both_hem', Path)
         
     end      
            
      if ~exist( fn_Stats_allROIs_combined_hem, 'file' )         

            cfg_stats.hemisphere            = 'combined' ; 
            Stats_allRois_combined_hem      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_allRois_combined_hem.name = 'Stats_allRois_combined_hem';
            save( fn_Stats_allROIs_combined_hem, 'Stats_allRois_combined_hem' )
            kh_PlotStatistics (ConfigFile, fn_Stats_allROIs_combined_hem, 'Stats_allRois_combined_hem', Path)
            
      else
          kh_PlotStatistics (ConfigFile, fn_Stats_allROIs_combined_hem, 'Stats_allRois_combined_hem', Path)
          
      end
                    
         
  
    
    %% Statistics for Broca:
    
    cfg_stats.roi                   = {'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R'};
    
    % Check, if data is already avaliable
        fn_Stats_Broca_left         = strcat( DirFreqName, '\', 'Stats_Broca_left', '.mat' );
        fn_Stats_Broca_right        = strcat( DirFreqName, '\', 'Stats_Broca_right', '.mat' );
        fn_Stats_Broca_both_hem     = strcat( DirFreqName, '\', 'Stats_Broca_both_hem', '.mat' );
        fn_Stats_Broca_combined_hem = strcat( DirFreqName, '\', 'Stats_Broca_combined_hem', '.mat' );
    
        if ~exist( fn_Stats_Broca_left, 'file' ) 
            
            cfg_stats.hemisphere          = 'left' ; %   'left' 'right', 'both', 'combined', specifying this is required when averaging over regions 
            Stats_Broca_left              = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Broca_left.name         = 'Stats_Broca_left';
            save( fn_Stats_Broca_left, 'Stats_Broca_left' )

        end
        
        if ~exist( fn_Stats_Broca_right, 'file' ) 
            
            cfg_stats.hemisphere          = 'right' ; 
            Stats_Broca_right             = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Broca_right.name        = 'Stats_Broca_right';
            save( fn_Stats_Broca_right, 'Stats_Broca_right' )
        end
        
        if ~exist( fn_Stats_Broca_both_hem, 'file' ) 
            
            cfg_stats.hemisphere          = 'both' ; 
            Stats_Broca_both_hem          = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Broca_both_hem.name     = 'Stats_Broca_both_hem';
            save( fn_Stats_Broca_both_hem, 'Stats_Broca_both_hem' )
            kh_PlotStatistics (ConfigFile, fn_Stats_Broca_both_hem, 'Stats_Broca_both_hem', Path)
            
        else
            kh_PlotStatistics (ConfigFile, fn_Stats_Broca_both_hem, 'Stats_Broca_both_hem', Path)
            
        end
        
        if ~exist( fn_Stats_Broca_combined_hem, 'file' ) 
            
            cfg_stats.hemisphere          = 'combined' ; 
            Stats_Broca_combined_hem      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Broca_combined_hem.name = 'Stats_Broca_combined_hem';
            save( fn_Stats_Broca_combined_hem, 'Stats_Broca_combined_hem' )
            kh_PlotStatistics (ConfigFile, fn_Stats_Broca_combined_hem, 'Stats_Broca_combined_hem', Path)
            
        else
            kh_PlotStatistics (ConfigFile, fn_Stats_Broca_combined_hem, 'Stats_Broca_combined_hem', Path)
            
        end
        
  
    
    
    %% Statistics for Wernicke:
    
    cfg_stats.roi                       = {'SupraMarginal_L';'SupraMarginal_R'; 'Angular_L';'Angular_R'; 'Temporal_Sup_L'; 'Temporal_Sup_R'};
    
      % Check, if data is already avaliable
         fn_Stats_Wernicke_left         = strcat( DirFreqName, '\', 'Stats_Wernicke_left', '.mat' );
         fn_Stats_Wernicke_right        = strcat( DirFreqName, '\', 'Stats_Wernicke_right', '.mat' );
         fn_Stats_Wernicke_both_hem     = strcat( DirFreqName, '\', 'Stats_Wernicke_both_hem', '.mat' );
         fn_Stats_Wernicke_combined_hem = strcat( DirFreqName, '\', 'Stats_Wernicke_combined_hem', '.mat' );
         
         if ~exist( fn_Stats_Wernicke_left, 'file' )     
             
            cfg_stats.hemisphere          = 'left' ; %   'left' 'right', 'both', 'combined', specifying this is required when averaging over regions 
            Stats_Wernicke_left           = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Wernicke_left.name      = 'Stats_Wernicke_left';
            save( fn_Stats_Wernicke_left, 'Stats_Wernicke_left' )            
         end
         
         if ~exist( fn_Stats_Wernicke_right, 'file' )  
             
            cfg_stats.hemisphere          = 'right' ; 
            Stats_Wernicke_right          = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Wernicke_right.name     = 'Stats_Wernicke_right';
            save( fn_Stats_Wernicke_right, 'Stats_Wernicke_right' )
              
         end
         
         if ~exist( fn_Stats_Wernicke_both_hem, 'file' )     
             
            cfg_stats.hemisphere          = 'both' ; 
            Stats_Wernicke_both_hem       = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Wernicke_both_hem.name  = 'Stats_Wernicke_both_hem';
            save( fn_Stats_Wernicke_both_hem, 'Stats_Wernicke_both_hem' )
            kh_PlotStatistics (ConfigFile, fn_Stats_Wernicke_both_hem, 'Stats_Wernicke_both_hem', Path)
             
         else
             kh_PlotStatistics (ConfigFile, fn_Stats_Wernicke_both_hem, 'Stats_Wernicke_both_hem', Path)
             
         end
         
         
         if ~exist( fn_Stats_Wernicke_combined_hem, 'file' )   
            cfg_stats.hemisphere             = 'combined' ; 
            Stats_Wernicke_combined_hem      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
            Stats_Wernicke_combined_hem.name = 'Stats_Wernicke_combined_hem';
            save( fn_Stats_Wernicke_combined_hem, 'Stats_Wernicke_combined_hem' )
            kh_PlotStatistics (ConfigFile, fn_Stats_Wernicke_combined_hem, 'Stats_Wernicke_combined_hem', Path)
            
         else
            kh_PlotStatistics (ConfigFile, fn_Stats_Wernicke_combined_hem, 'Stats_Wernicke_combined_hem', Path)
            
         end 
    
    
    %% Statistics for Temporal Lobe:
     
     cfg_stats.roi                          = {'Temporal_Sup_L'; 'Temporal_Sup_R'; 'Temporal_Pole_Sup_L'; 'Temporal_Pole_Sup_R'; 'Temporal_Mid_L'; 'Temporal_Mid_R'; 'Temporal_Pole_Mid_L'; 'Temporal_Pole_Mid_R'; 'Temporal_Inf_L'; 'Temporal_Inf_R'; };
   
     % Check, if data is already avaliable
         fn_Stats_TemporalLobe_left         = strcat( DirFreqName, '\', 'Stats_TemporalLobe_left', '.mat' );
         fn_Stats_TemporalLobe_right        = strcat( DirFreqName, '\', 'Stats_TemporalLobe_right', '.mat' );
         fn_Stats_TemporalLobe_both_hem     = strcat( DirFreqName, '\', 'Stats_TemporalLobe_both_hem', '.mat' );
         fn_Stats_TemporalLobe_combined_hem = strcat( DirFreqName, '\', 'Stats_TemporalLobe_combined_hem', '.mat' );
   
         if ~exist( fn_Stats_TemporalLobe_left, 'file' )   
             
             cfg_stats.hemisphere          = 'left' ; %   'left' 'right', 'both', 'combined', specifying this is required when averaging over regions 
             Stats_TemporalLobe_left       = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
             Stats_TemporalLobe_left.name  = 'Stats_TemporalLobe_left';
             save( fn_Stats_TemporalLobe_left, 'Stats_TemporalLobe_left' )          
         end
         
         if ~exist( fn_Stats_TemporalLobe_right, 'file' )   
             
             cfg_stats.hemisphere          = 'right' ; 
             Stats_TemporalLobe_right      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
             Stats_TemporalLobe_right.name = 'Stats_TemporalLobe_right';
             save( fn_Stats_TemporalLobe_right, 'Stats_TemporalLobe_right' )         
         end
         
         
         if ~exist( fn_Stats_TemporalLobe_both_hem, 'file' )  
             
              cfg_stats.hemisphere             = 'both' ; 
              Stats_TemporalLobe_both_hem      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
              Stats_TemporalLobe_both_hem.name = 'Stats_TemporalLobe_both_hem';
              save( fn_Stats_TemporalLobe_both_hem, 'Stats_TemporalLobe_both_hem' )
              kh_PlotStatistics (ConfigFile, fn_Stats_TemporalLobe_both_hem, 'Stats_TemporalLobe_both_hem', Path)
              
         else
              kh_PlotStatistics (ConfigFile, fn_Stats_TemporalLobe_both_hem, 'Stats_TemporalLobe_both_hem', Path)
              
         end
         
         if ~exist( fn_Stats_TemporalLobe_combined_hem, 'file' )   
             
             cfg_stats.hemisphere                   = 'combined' ; 
             Stats_TemporalLobe_combined_hem        = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
             Stats_TemporalLobe_combined_hem.name   = 'Stats_TemporalLobe_combined_hem';
             save( fn_Stats_TemporalLobe_combined_hem, 'Stats_TemporalLobe_combined_hem' )
             kh_PlotStatistics (ConfigFile, fn_Stats_TemporalLobe_combined_hem, 'Stats_TemporalLobe_combined_hem', Path)
             
         else
             kh_PlotStatistics (ConfigFile, fn_Stats_TemporalLobe_combined_hem, 'Stats_TemporalLobe_combined_hem', Path)
             
         end         
    
        
end


