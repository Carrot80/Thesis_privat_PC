%% prepare head model, Forward Modell and Leadfield Matrix:


function kh_PrepHeadModell (Segmentation, MEGRawFile, DataFile, RemovedChannels, PatientName, Path)

  % Check, if data is already avaliable
     FileName = strcat(Path.Volume, '\', 'Volume', '.mat');
         
        if exist( FileName, 'file' )
            return;
        end
        

    FileSegmentation            = strcat( Path.Volume, '\', Segmentation, '.mat');
    load( FileSegmentation );
 
    cfg_headmodell          = [];
    cfg_headmodell.method   = 'singleshell';
    vol_resliced            = ft_prepare_headmodel(cfg_headmodell, MRI_realignment.mri_realign_resliced_segmentedmri); % oder hdm = ft_prepare_singleshell(cfg, segmentedmri);??
    vol_resliced            = ft_convert_units(vol_resliced, 'cm');
    
    MEGFilePath             = strcat(Path.DataInput, '\', MEGRawFile);
    sens                    = ft_read_sens( MEGFilePath );
    sens_cm                 = ft_convert_units( sens, 'cm' ); %schauen, ob nicht eh schon in cm dargestellt
    hs                      = ft_read_headshape( MEGFilePath ); %get headshape points
    hs_cm                   = ft_convert_units( hs, 'cm' );
    
    figure
    ft_plot_vol(vol_resliced);
    hold on
    ft_plot_headshape(hs_cm) 
    plot_hs                 = strcat( Path.Volume, '\', 'headshape' );
    print('-dpng',plot_hs);
    
    ft_plot_sens ( sens_cm, 'style', '*b', 'label', 'label');    
    plot_sens               = strcat( Path.Volume, '\', 'SensorPos' );
    print( '-dpng',plot_sens );
         
    FileDataAll             = strcat ( Path.DataTimeOfInterest, '\', DataFile, '.mat' );
    load ( FileDataAll );
    FileRemovedChannels     = strcat ( Path.Preprocessing, '\', 'RemovedChannels', '.mat' );
    load ( FileRemovedChannels );
    
    FileTemplateGrid        = strcat ( 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_grid', '.mat' ) ;
    load ( FileTemplateGrid ) ;  
    
    cfg_grid_warped                 = [];
    cfg_grid_warped.grid.warpmni    = 'yes';
    cfg_grid_warped.grid.template   = template_grid;
    cfg_grid_warped.grid.nonlinear  = 'yes'; % use non-linear normalization
    cfg_grid_warped.mri             = MRI_realignment.mri_realign_resliced;
    cfg_grid_warped.vol             = vol_resliced;
    cfg_grid_warped.channel         = ['MEG', RemovedChannels];  % user specific an welcher Stelle, bereits bei template grid?
    cfg_grid_warped.grad            = Data.DataAll.grad;
    cfg_grid_warped.grid.resolution = 1.0;   % use a 3-D grid with a 0.5 cm resolution (Margit's Empfehlung)

    [grid_warped]                   = ft_prepare_leadfield ( cfg_grid_warped );
    
    
    % make a figure of the single subject headmodel, and grid positions
    figure;
    ft_plot_vol(vol_resliced, 'edgecolor', 'none'); alpha 0.4;
    ft_plot_mesh(grid_warped.pos(grid_warped.inside,:));
    plot_grid_warped         = strcat( Path.Volume, '\', 'plot_grid_warped' );
    print('-dpng',plot_grid_warped);
   
    Volume = struct('vol_resliced', vol_resliced, 'grid_warped', grid_warped)
   
    ResultVolume       = strcat( Path.Volume, '\', 'Volume', '.mat' );
    save( ResultVolume, 'Volume' );

end
