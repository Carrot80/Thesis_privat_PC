  
function PlotPCA (Path, FileCompPCAFull)

load (FileCompPCAFull)

 % prepare the layout 
    cfg_lay_pca         = [];
    cfg_lay_pca.grad    = comp_pca.grad;
    lay_pca             = ft_prepare_layout(cfg_lay_pca);
     
    % plot the components for visual inspection
  

    %view the time course of the component: stürzt ab (evtl. debuggen!!
    figure(2)
    cfg           = [] ;
    cfg.layout    = lay_pca ; % specify the layout file that should be used for plotting
    cfg.component = [1:5]; % components to be plotted
    ft_databrowser(cfg, comp_pca)
    
    
    
end