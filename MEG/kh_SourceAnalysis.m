% Source Analysis:  Contrast activity to another interval


function kh_SourceAnalysis ( ConfigFile, Data, MRI, Volume, Path )

   
    % make frequency directory if not exists yet:
    DirFreqName = strcat (Path.SourceAnalysis, '\', ConfigFile.name);
    [state] = mkdirIfNecessary( DirFreqName );


    % Check, if data is already avaliable
     FileName = strcat(DirFreqName, '\', 'trial_sourcePost', '_', ConfigFile.string, '.mat');
         
        if exist( FileName, 'file' )
            return;
        end
                
        str = fprintf('starting source localization of %s freqency band ...\n', ConfigFile.name);
        
        
    % load Files:
     FileGrid               = strcat ( Path.Volume, '\', Volume, '.mat' );
     load ( FileGrid );
     FileFreqAnalysis       = strcat ( Path.FreqAnalysis, '\', ConfigFile.name, '\', 'FreqAnalysis', '_', ConfigFile.string, '.mat' );
     load ( FileFreqAnalysis );

    % compute common spatial filter %
    
    cfg_source                     = [];
    cfg_source.method              = 'dics';
    cfg_source.frequency           = ConfigFile.frequency;
    cfg_source.grid                = Volume.grid_warped;
    cfg_source.vol                 = Volume.vol_resliced;
    cfg_source.dics.projectnoise   = 'yes';
    cfg_source.dics.lambda         = '5%';
    cfg_source.dics.keepfilter     = 'yes';
    cfg_source.dics.realfilter     = 'yes';
    sourceAll                      = ft_sourceanalysis(cfg_source, FreqAnalysis.FreqAll);
    
    ResultSourceAll            = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'sourceAll', '_', ConfigFile.string, '.mat' );
    save( ResultSourceAll, 'sourceAll' ); 
     
   

    % By placing this pre-computed filter inside cfg.grid.filter, it can now be
    % applied to each condition separately:
    
    cfg_source.grid.filter          = sourceAll.avg.filter;
    cfg_source.keeptrials           = 'yes'; 
    cfg_source.rawtrial             = 'yes';
    trial_sourcePre                 = ft_sourceanalysis(cfg_source, FreqAnalysis.FreqPre); 
    
%   load templte grid and replace pos and dim with template_grid
    FileTemplateGrid        = strcat ( 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_grid', '.mat' ) ;
    load ( FileTemplateGrid ) ;   
    
    trial_sourcePre.pos         = template_grid.pos;
    trial_sourcePre.dim         = template_grid.dim;
    
    ResultSourcePre             = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'trial_sourcePre', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePre, 'trial_sourcePre' ); 
    
    clear trial_sourcePre
    
    trial_sourcePost     = ft_sourceanalysis(cfg_source, FreqAnalysis.FreqPost);
    trial_sourcePost.pos = template_grid.pos
    trial_sourcePost.dim = template_grid.dim
    
    ResultSourcePost           = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'trial_sourcePost', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePost, 'trial_sourcePost' );  
    
    clear trial_sourcePost


    % compute the contrast of (post-pre)/pre. In this operation we ...
    % assume that the noise bias is the same for the pre- and post-stimulus ...
    % interval and it will thus be removed

    % zum Plotten auch noch mal Variable ohne Keeptrials erstellen:
        
    cfg_source.grid.filter          = sourceAll.avg.filter;
    cfg_source.keeptrials           = 'no'; 
    cfg_source.rawtrial             = 'no';
    avg_sourcePre                   = ft_sourceanalysis( cfg_source, FreqAnalysis.FreqPre ); 
    avg_sourcePost                  = ft_sourceanalysis( cfg_source, FreqAnalysis.FreqPost );
        
    sourceDiff                      = avg_sourcePost;
    sourceDiff.avg.pow              = ( avg_sourcePost.avg.pow - avg_sourcePre.avg.pow ) ./ avg_sourcePre.avg.pow;

    ResultSourcePreAVG            = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'avg_sourcePre', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePreAVG, 'avg_sourcePre' ); 
    ResultSourcePostAVG            = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'avg_sourcePost', '_', ConfigFile.string, '.mat' );
    save( ResultSourcePostAVG, 'avg_sourcePost' ); 


    %  interpolate the source to the MRI
    File_MRI_realignment = strcat( Path.Volume, '\', MRI, '.mat' );
    load( File_MRI_realignment, 'MRI_realignment' )
 

    cfg_int            = [];
    cfg_int.downsample = 1;
    cfg_int.parameter  = 'avg.pow';
    sourceDiffInt  = ft_sourceinterpolate(cfg_int, sourceDiff, MRI_realignment.mri_realign_resliced);

    % Now plot the power ratios: 
 
    cfg_slice               = [];
    cfg_slice.method        = 'slice';
    cfg_slice.funparameter  = 'avg.pow';
    cfg_slice.maskparameter = cfg_slice.funparameter;
%     cfg_slice.funcolorlim   = [-1.2 1.2];
%     cfg_slice.opacitylim    = [-1.2 1.2]; 
    cfg_slice.opacitymap    = 'rampup';  
    ft_sourceplot_invisible(cfg_slice, sourceDiffInt);
    title ( ConfigFile.name )
    plot_slice              = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'avg_slice', '_', ConfigFile.string );
    print( '-dpng', plot_slice );

    
    cfg_ortho                = [];
    cfg_ortho.method         = 'ortho';
    cfg_ortho.interactive    = 'no';
    cfg_ortho.funparameter   = 'avg.pow';
    cfg_ortho.maskparameter  = cfg_ortho.funparameter;
%     cfg_ortho.funcolorlim    = [-0.6 0.6];
%     cfg_ortho.opacitylim     = [-0.6 0.6];  
    cfg_ortho.opacitymap     = 'rampup';  
    ft_sourceplot_invisible(cfg_ortho, sourceDiffInt);
    title ( ConfigFile.name )
    
    plot_ortho               = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', 'avg_ortho', '_', ConfigFile.string );
    saveas(gcf,plot_ortho,'fig') 
    


end


