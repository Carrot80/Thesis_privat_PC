%% prepare head model, Forward Modell and Leadfield Matrix:


function kh_PrepHeadModell (PathVolume, Segmentation, MRIRealignResliced, PathDataInput, MEGDataFile, PathPreprocessing, DataAll, RemovedChannels, PathMRI, PatientName)

    FileSegmentation            = strcat( PathVolume, '\', Segmentation, '.mat');
    load( FileSegmentation );
 
    cfg_headmodell          = [];
    cfg_headmodell.method   = 'singleshell';
    vol_resliced            = ft_prepare_headmodel(cfg_headmodell, mri_realign_resliced_segmentedmri); % oder hdm = ft_prepare_singleshell(cfg, segmentedmri);??
    vol_resliced            = ft_convert_units(vol_resliced, 'cm');
    
    ResultVolResliced       = strcat( PathVolume, '\', 'vol_resliced', '.mat' );
    save( ResultVolResliced, 'vol_resliced' );
    
    MEGFilePath             = strcat(PathDataInput, '\', MEGDataFile);
    sens                    = ft_read_sens( MEGFilePath );
    sens_cm                 = ft_convert_units( sens, 'cm' ); %schauen, ob nicht eh schon in cm dargestellt
    hs                      = ft_read_headshape( MEGFilePath ); %get headshape points
    hs_cm                   = ft_convert_units( hs, 'cm' );
    
    figure
    ft_plot_vol(vol_resliced);
    hold on
    ft_plot_headshape(hs_cm) 
    plot_hs                 = strcat( PathVolume, '\', 'headshape' );
    print('-dpng',plot_hs);
    
    ft_plot_sens ( sens_cm, 'style', '*b', 'label', 'label');    
    plot_sens               = strcat( PathVolume, '\', 'SensorPos' );
    print( '-dpng',plot_sens );
         
    FileDataAll             = strcat ( PathPreprocessing, '\', 'DataAll', '.mat' );
    load ( FileDataAll );
    FileRemovedChannels     = strcat ( PathPreprocessing, '\', 'RemovedChannels', '.mat' );
    load ( FileRemovedChannels );
    
    FileTemplateGrid        = strcat ( 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_grid', '.mat' ) ;
    load ( FileTemplateGrid ) ;
   
    File_mri_realign_resliced = strcat(PathVolume, '\', 'mri_realign_resliced.mat');
    load (File_mri_realign_resliced);
    
    
    cfg_grid_warped                 = [];
    cfg_grid_warped.grid.warpmni    = 'yes';
    cfg_grid_warped.grid.template   = template_grid;
    cfg_grid_warped.grid.nonlinear  = 'yes'; % use non-linear normalization
    cfg_grid_warped.mri             = mri_realign_resliced;
    cfg_grid_warped.vol             = vol_resliced;
    cfg_grid_warped.channel         = ['MEG', RemovedChannels];  % user specific an welcher Stelle, bereits bei template grid?
    cfg_grid_warped.grad            = dataAll.grad;
    cfg_grid_warped.grid.resolution = 1.0;   % use a 3-D grid with a 0.5 cm resolution (Margit's Empfehlung)

    [grid_warped]                   = ft_prepare_leadfield ( cfg_grid_warped );
    
    ResultGridWarped       = strcat( PathVolume, '\', 'grid_warped', '.mat' );
    save( ResultGridWarped, 'grid_warped' );
    
    % make a figure of the single subject headmodel, and grid positions
    figure;
    ft_plot_vol(vol_resliced, 'edgecolor', 'none'); alpha 0.4;
    ft_plot_mesh(grid_warped.pos(grid_warped.inside,:));
    plot_grid_warped         = strcat( PathVolume, '\', 'plot_grid_warped' );
    print('-dpng',plot_grid_warped);
              
    
%     cfg_grid.grad            = dataAll.grad;
%     cfg_grid.vol             = vol_resliced;
%     cfg_grid.reducerank      = 2;
%     cfg_grid.channel         = ['MEG', RemovedChannels];  % user specific
%     cfg_grid.grid.resolution = 0.6;   % use a 3-D grid with a 0.5 cm resolution (Margit's Empfehlung)
%     [grid_resliced]          = ft_prepare_leadfield ( cfg_grid );
% 
%     ResultGridResliced       = strcat( PathVolume, '\', 'grid_resliced', '.mat' );
%     save( ResultGridResliced, 'grid_resliced' );
    
 

end
