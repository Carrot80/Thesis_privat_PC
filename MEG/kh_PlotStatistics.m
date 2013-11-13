% Plot statistics

function  kh_PlotStatistics( TimeWindow, ConfigFile, PathStatsFile, StatsFileName, Path )
    
       
        load( strcat( Path.MRI, '\', 'mri_realign_resliced_norm', '.mat' ))   ;    % evtl. nicht das templateMRI nehmen, sondern zu besseren Darstellungszwecken das normalisierte individuelle Gehirn
        StatsFileLoad = load( PathStatsFile ) ;
        StatsFile = StatsFileLoad.(StatsFileName) ;
        StatsFile.name = StatsFileName
        
        % interpolate stats to template mri in order to plot it:
        cfg_int                         = [];
        cfg_int.parameter               = {'prob'; 'stat'}; % z.B. 'prob', 'stat', 'posclusterslabelmat'
        StatsFile_int                   = ft_sourceinterpolate(cfg_int, StatsFile, mri_realign_resliced_norm');
       
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'vdown';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; 
        cfg_plot.coordsys        = 'spm';
        ft_sourceplot_invisible(cfg_plot, StatsFile_int);
        title(strcat( StatsFile.name, {' '}, ConfigFile.Name, {' '}, TimeWindow.TimeWindow_string));
        sourceplot               = strcat(Path.Statistics, '\', ConfigFile.name, '\', StatsFile.name);
        print('-dpng', sourceplot);
        
        % Plot only significant values:
        SignStatsFile_int               = StatsFile_int;
        lowerlim                        = StatsFile.critval(1);
        upperlim                        = StatsFile.critval(2);
        SignStatsFile_int.mask          = ((SignStatsFile_int.stat<=lowerlim | SignStatsFile_int.stat >= upperlim));
        
        cfg_plot_sign                 = [];
        cfg_plot_sign.method          = 'slice';
        cfg_plot_sign.funparameter    = 'stat';
        cfg_plot_sign.anaparameter    = 'anatomy'; 
        cfg_plot_sign.maskparameter   = 'mask';  % mask seems to be right % see also opacitymap and opacitylim
%         cfg_plot.opacitymap      = 'vdown'; % 'rampup' (only pos. values); 'rampdown' (only neg. values), 'vdown' (both pos. and neg. values)
%         cfg_plot.opacitylim      = [-2.5 2.5];  % [min max]; 'zeromax' (values from zero to max will be plotted), 'minzero' , 'maxabs' ;
%         cfg_plot.funcolorlim     = [-2.5 2.5];
        cfg_plot.coordsys        = 'spm';
        ft_sourceplot_invisible(cfg_plot_sign, SignStatsFile_int);
        
        title( strcat (StatsFile.name, {' '}, ConfigFile.Name, {' '}, TimeWindow.TimeWindow_string) );
        sourceplot_sign          = strcat(Path.Statistics, '\',  ConfigFile.name, '\', StatsFile.name, '_', 'sign');
        print('-dpng', sourceplot_sign);
    
        
        
end  
    
