function  PlotICA (Path, FileCompICAFull)

load (FileCompICAFull)

 % prepare the layout
    cfg_lay         = [];
    cfg_lay.grad    = comp_ica.grad;
    lay             = ft_prepare_layout(cfg_lay);

    % plot the components for visual inspection
    figure
    cfg             = [];
    cfg.component   = [1:40];       % specify the component(s) that should be plotted
    cfg.layout      = lay; % specify the layout file that should be used for plotting
    cfg.comment     = 'no';
    ft_topoplotIC(cfg, comp_ica)
    title ('Components ICA')
    PathTopoplotICA = strcat (Path.Preprocessing, '\', 'comp_ica') ;
    saveas (gca, PathTopoplotICA, 'fig')

 % prepare the layout
    cfg_lay         = [];
    cfg_lay.grad    = comp_ica.grad;
    lay             = ft_prepare_layout(cfg_lay);

    % plot the components for visual inspection
  
    %view the time course of the component: stürzt ab (evtl. debuggen!!
    figure(2)
    cfg           = [] ;
    cfg.layout    = lay ; % specify the layout file that should be used for plotting
    cfg.component = [1:10]; % components to be plotted
    ft_databrowser(cfg, comp_ica)
    
end