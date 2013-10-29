% Source Analysis:  Contrast activity to another interval


function kh_SourceAnalysis ( ConfigFile, PathPreprocessing, DataAll, DataPre, DataPost, PathVolume, Grid, Vol, PathFreqAnalysis, PathSourceAnalysis, mri_realign_resliced)

     % load files:
     
     FileDataAll            = strcat ( PathPreprocessing, '\', DataAll, '.mat' );
     load ( FileDataAll );
     FileDataPre            = strcat ( PathPreprocessing, '\', DataPre, '.mat' );
     load ( FileDataPre );
     FileDataPost           = strcat ( PathPreprocessing, '\', DataPost, '.mat' );
     load ( FileDataPost );
     FileGrid               = strcat ( PathVolume, '\', Grid, '.mat' );
     load ( FileGrid );
     FileVol                = strcat ( PathVolume, '\', Vol, '.mat' );
     load ( FileVol );

     % Calculating FFT and cross spectral density matrix:
     
     cfgFreq            = []                    ;
     cfgFreq.method     = ConfigFile.method     ;
     cfgFreq.output     = ConfigFile.output     ; 
     cfgFreq.taper      = ConfigFile.taper      ;
%      cfgFreq.tapsmofrq  = ConfigFile.tapsmofrq; % braucht man erst ab 30 Hz
     cfgFreq.foilim     = ConfigFile.foilim     ;
     cfgFreq.rawtrial   = 'yes';
     cfgFreq.keeptrials = 'yes';
     FreqAll            = ft_freqanalysis( cfgFreq, dataAll );
     FreqPre            = ft_freqanalysis( cfgFreq, dataPre );
     FreqPost           = ft_freqanalysis( cfgFreq, dataPost );
     
     ResultFreqAll      = strcat( PathFreqAnalysis, '\', 'FreqAll', '_', ConfigFile.string, '.mat' );
     save( ResultFreqAll, FreqAll );
     ResultFreqPre      = strcat( PathFreqAnalysis, '\', 'FreqPre', '_', ConfigFile.string, '.mat' );
     save( ResultFreqPre, 'FreqPre' );    
     ResultFreqPost     = strcat( PathFreqAnalysis, '\', 'FreqPost', '_', ConfigFile.string, '.mat' );
     save( ResultFreqPost, 'FreqPost' ); 
    
     clear dataAll dataPre dataPost cfgFreq

    % compute common spatial filter %
    
    cfg_source                     = [];
    cfg_source.method              = 'dics';
    cfg_source.frequency           = ConfigFile.frequency;
    cfg_source.grid                = grid_warped;
    cfg_source.vol                 = vol_resliced;
    cfg_source.dics.projectnoise   = 'yes';
    cfg_source.dics.lambda         = '5%';
    cfg_source.dics.keepfilter     = 'yes';
    cfg_source.dics.realfilter     = 'yes';
    sourceAll                      = ft_sourceanalysis(cfg_source, FreqAll);
    
    ResultSourceAll            = strcat( PathSourceAnalysis, '\', 'sourceAll', '_', ConfigFile.string, '.mat' );
    save( ResultSourceAll, 'sourceAll' ); 
     
   

    % By placing this pre-computed filter inside cfg.grid.filter, it can now be
    % applied to each condition separately:
    
    cfg_source.grid.filter          = sourceAll.avg.filter;
    cfg_source.keeptrials           = 'yes'; 
    cfg_source.rawtrial             = 'yes';
    trial_sourcePre                 = ft_sourceanalysis(cfg_source, freqPre); 
    
%   load templte grid and replace pos and dim with template_grid
    FileTemplateGrid        = strcat ( 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_grid', '.mat' ) ;
    load ( FileTemplateGrid ) ;   
    
    trial_sourcePre.pos         = template_grid.pos;
    trial_sourcePre.dim         = template_grid.dim;
    
    ResultSourcePre             = strcat( PathSourceAnalysis, '\', 'trial_sourcePre', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePre, 'trial_sourcePre' ); 
    
    clear trial_sourcePre
    
    trial_sourcePost     = ft_sourceanalysis(cfg_source, freqPost);
    trial_sourcePost.pos = template_grid.pos
    trial_sourcePost.dim = template_grid.dim
    
    ResultSourcePost           = strcat( PathSourceAnalysis, '\', 'trial_sourcePost', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePost, 'trial_sourcePost' );  
    
    clear trial_sourcePost


    % compute the contrast of (post-pre)/pre. In this operation we ...
    % assume that the noise bias is the same for the pre- and post-stimulus ...
    % interval and it will thus be removed

    % zum Plotten auch noch mal Variable ohne Keeptrials erstellen:
        
    cfg_source.grid.filter          = sourceAll.avg.filter;
    cfg_source.keeptrials           = 'no'; 
    cfg_source.rawtrial             = 'no';
    avg_sourcePre                   = ft_sourceanalysis( cfg_source, freqPre ); 
    avg_sourcePost                  = ft_sourceanalysis( cfg_source, freqPost );
        
    sourceDiff                      = avg_sourcePost;
    sourceDiff.avg.pow              = ( avg_sourcePost.avg.pow - avg_sourcePre.avg.pow ) ./ avg_sourcePre.avg.pow;

    ResultSourcePreAVG            = strcat( PathSourceAnalysis, '\', 'avg_sourcePre', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePreAVG, 'avg_sourcePre' ); 
    ResultSourcePostAVG            = strcat( PathSourceAnalysis, '\', 'avg_sourcePost', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePostAVG, 'avg_sourcePost' ); 


    %  interpolate the source to the MRI
    File_mri_realign_resliced = strcat( PathVolume, '\', 'mri_realign_resliced', '.mat' );
    load( File_mri_realign_resliced, 'mri_realign_resliced' )

    cfg_int            = [];
    cfg_int.downsample = 1;
    cfg_int.parameter  = 'avg.pow';
    sourceDiffInt  = ft_sourceinterpolate(cfg_int, sourceDiff, mri_realign_resliced);

    % Now plot the power ratios: 

    cfg_ortho                = [];
    cfg_ortho.method         = 'ortho';
    cfg_ortho.interactive    = 'yes';
    cfg_ortho.funparameter   = 'avg.pow';
    cfg_ortho.maskparameter  = cfg_ortho.funparameter;
%     cfg_ortho.funcolorlim    = [-0.6 0.6];
%     cfg_ortho.opacitylim     = [-0.6 0.6];  
    cfg_ortho.opacitymap     = 'rampup';  
    ft_sourceplot(cfg_ortho, sourceDiffInt);
    plot_ortho               = strcat( PathSourceAnalysis, '\', 'avg_ortho', '_', ConfigFile.string );
    print('-dpng', plot_ortho );

    figure
    cfg_slice               = [];
    cfg_slice.method        = 'slice';
    cfg_slice.funparameter  = 'avg.pow';
    cfg_slice.maskparameter = cfg_slice.funparameter;
    cfg_slice.funcolorlim   = [-1.2 1.2];
    cfg_slice.opacitylim    = [-1.2 1.2]; 
    cfg_slice.opacitymap    = 'rampup';  
    ft_sourceplot(cfg_slice, sourceDiffInt);

    plot_slice              = strcat( PathSourceAnalysis, '\', 'avg_slice', '_', ConfigFile.string );
    print( '-dpng', plot_slice );


end


