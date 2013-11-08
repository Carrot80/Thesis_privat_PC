function PerformICAFull (Path, data_resampled) 

    cfg         = [];
    cfg.method  = 'runica'; % this is the default and uses the implementation from EEGLAB
    cfg.channel = {'MEG'};
    comp_ica = ft_componentanalysis(cfg, data_resampled)

    FileICA = strcat (Path.Preprocessing, '\', 'comp_ica') ;
    save (FileICA, 'comp_ica')

    % prepare the layout
    cfg_lay         = [];
    cfg_lay.grad    = comp_ica.grad;
    lay             = ft_prepare_layout(cfg_lay);

    % plot the components for visual inspection
    figure
    cfg             = [];
    cfg.component   = [1:40];       % specify the component(s) that should be plotted
    cfg.layout      = lay; % specify the layout file that should be used for plotting
    cfg.comment     = 'ICA - all channels/trials';
    ft_topoplotIC(cfg, comp_ica)
    
    PathTopoplotICA = strcat (Path.Preprocessing, '\', 'comp_ica') ;
    saveas (gca, PathTopoplotICA, 'fig')
    
end