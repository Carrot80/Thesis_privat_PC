% Plot statistics

function  kh_PlotStatistics( PathStatistics, ResultStatsLeft, ResultStatsRight, ResultStatsCombined, ResultStatsBoth, Result_NoROIs, PathMRI, MRINorm  )
    
        
        load( strcat( PathStatistics, '\', 'Stats_allRois_left', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_allRois_right', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_allRois_both_hem', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_allRois_combined_hem', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_NoROIs', '.mat' ));
        
        load( strcat( PathMRI, '\', MRINorm, '.mat' ))        ; % evtl. nicht das templateMRI nehmen, sondern zu besseren Darstellungszwecken das normalisierte individuelle Gehirn
        
        % interpolate stats to template mri in order to plot it:
        cfg_int                         = [];
        cfg_int.parameter               = {'prob'; 'stat'}; % z.B. 'prob', 'stat', 'posclusterslabelmat'
        Stats_allRois_left_int            = ft_sourceinterpolate(cfg_int, Stats_allRois_left, mri_realign_resliced_norm');
        Stats_allRois_right_int           = ft_sourceinterpolate(cfg_int, Stats_allRois_right, mri_realign_resliced_norm');
        Stats_allRois_both_hem_int        = ft_sourceinterpolate(cfg_int, Stats_allRois_both_hem, mri_realign_resliced_norm');
        Stats_allRois_combined_hem_int    = ft_sourceinterpolate(cfg_int, Stats_allRois_combined_hem, mri_realign_resliced_norm');
        Stats_NoROIs_int                  = ft_sourceinterpolate(cfg_int, Stats_NoROIs, mri_realign_resliced_norm');
        
        Sign_ResultStats_NoROIs_int      = Stats_NoROIs_int;
        lowerlim                         = Stats_NoROIs.critval(1);
        upperlim                         = Stats_NoROIs.critval(2);
        Sign_ResultStats_NoROIs_int.mask =((Sign_ResultStats_NoROIs_int.stat<=lowerlim | Sign_ResultStats_NoROIs_int.stat >= upperlim));
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.anaparameter    = 'anatomy'; 
        cfg_plot.maskparameter   = 'mask';  % mask seems to be right % see also opacitymap and opacitylim
%         cfg_plot.opacitymap      = 'vdown'; % 'rampup' (only pos. values); 'rampdown' (only neg. values), 'vdown' (both pos. and neg. values)
%         cfg_plot.opacitylim      = [-2.5 2.5];  % [min max]; 'zeromax' (values from zero to max will be plotted), 'minzero' , 'maxabs' ;
%         cfg_plot.funcolorlim     = [-2.5 2.5];
        cfg_plot.coordsys        = 'spm';
        ft_sourceplot(cfg_plot, Sign_ResultStats_NoROIs_int);
        
        title('no ROIs');
        sourceplot_noROIs          = strcat(PathStatistics, '\', 'Stats_noROIs');
        print('-dpng', sourceplot_noROIs);
        
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'rampup';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; % sind das die signifikanten Werte? (rechts nur Nullen)
        cfg_plot.coordsys        = 'spm';
        
        ft_sourceplot(cfg_plot, Stats_allRois_left_int);
        title('all ROIs left hemisphere');
        sourceplot_left          = strcat(PathStatistics, '\', 'Stats_allROIs_left');
        print('-dpng', sourceplot_left);
        
        ft_sourceplot(cfg_plot, Stats_allRois_right_int);
        title('all ROIs right hemisphere');
        sourceplot_right        = strcat(PathStatistics, '\', 'Stats_allROIs_right');
        print('-dpng', sourceplot_right);     
        
        
        sign_Stats_allROIs_both_hem_int       = Stats_allRois_both_hem_int;
        sign_Stats_allROIs_both_hem_int.mask  =((sign_Stats_allROIs_both_hem_int.stat<=lowerlim | sign_Stats_allROIs_both_hem_int.stat >= upperlim));
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'rampup';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; 
        cfg_plot.coordsys        = 'spm';
        
        ft_sourceplot(cfg_plot, sign_Stats_allROIs_both_hem_int); 
        title('all ROIs both hemispheres');
        sourceplot_both_hem        = strcat(PathStatistics, '\', 'Stats_allROIs_both_hem');
        print('-dpng', sourceplot_both_hem);  
        
        
        sign_Stats_allROIs_combined_hem_int      = Stats_allRois_combined_hem_int;
        sign_Stats_allROIs_combined_hem_int.mask =((sign_Stats_allROIs_combined_hem_int.stat<=lowerlim | sign_Stats_allROIs_combined_hem_int.stat >= upperlim));
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'rampup';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; 
        cfg_plot.coordsys        = 'spm';

        ft_sourceplot(cfg_plot, sign_Stats_allROIs_combined_hem_int);
        title('all ROIs combined hemispheres');
        sourceplot_combined_hem        = strcat(PathStatistics, '\', 'Stats_allROIs_combined_hem');
        print('-dpng', sourceplot_combined_hem);  
        
    
            
end  
    
