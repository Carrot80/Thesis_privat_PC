% perform PCA :


function PerformPCAFull (Path, data_resampled) 
    cfg         = [];
    cfg.method  = 'pca'; % this is the default and uses the implementation from EEGLAB
    cfg.channel = {'MEG'};
    comp_pca = ft_componentanalysis(cfg, data_resampled)
    
    FilePCA = strcat (Path.Preprocessing, '\', 'comp_pca') ;
    save (FileICA, 'comp_pca')
    
    % prepare the layout 
    cfg_lay_pca         = [];
    cfg_lay_pca.grad    = comp_pca.grad;
    lay_pca             = ft_prepare_layout(cfg_lay_pca);
     
    % plot the components for visual inspection
    figure
    cfg             = [];
    cfg.component   = [1:40];       % specify the component(s) that should be plotted
    cfg.layout      = lay_pca; % specify the layout file that should be used for plotting
    cfg.comment     = 'no';
    ft_topoplotIC(cfg, comp_pca)
    
    PathTopoplotPCA = strcat (Path.Preprocessing, '\', 'comp_pca') ;
    saveas (gca, PathTopoplotPCA, 'fig')

    %view the time course of the component: stürzt ab (evtl. debuggen!!
    figure(2)
    cfg           = [] ;
    cfg.layout    = lay_pca ; % specify the layout file that should be used for plotting
    cfg.component = [1:10]; % components to be plotted
    ft_databrowser(cfg, comp_pca)
    
end