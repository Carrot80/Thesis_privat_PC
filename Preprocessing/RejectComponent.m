function kh_RejectComponent (Path, Comp, Data)

 PathFilePreProc = strcat (Path.Preprocessing, '\', Data) ;
    load (PathFilePreProc)

    % run the ICA in the original data (Skript Maor):
    cfg                 = [];
    cfg.topo            = comp.topo;
    cfg.topolabel       = comp.topolabel;
    comp_orig           = componentanalysis(cfg, datacln);
    

    % set the bad comps as the value for cfgrc.component (Skript Yuval):
    cfgrc                           = [];
    cfgrc.component                 = [1 2 3]; % change
    cfgrc.feedback                  = 'no';
    data_HB_1_95_nojumps_sum_pca    = ft_rejectcomponent(cfgrc, compMOG_pca, data_HB_pb1_95nojumps);
   

    cfg                                 = [];
    cfg.method                          = 'summary'; %trial
    cfg.channel                         = 'MEG';
    cfg.alim                            =  1e-12;
    data_HB_1_95_nojumps_sum_pca_visual = ft_rejectvisual(cfg, data_HB_1_95_nojumps_sum_pca);

    cfg                                 = [];
    cfg.method                          =  'summary'; %trial
    cfg.channel                         = 'MEG';
    cfg.alim                            = 1e-12;
    data_HB_1_95_nojumps_sum_pca_visual = ft_rejectvisual(cfg, data_HB_pb1_95nojumps_sum);

    % um durch Gesamtdaten zu browsen, siehe auch Yuval Course 4
    cfg=[];
    cfg.layout=lay;
    cfg.channel = 1:5;
    cfg.continuous='yes';
    ft_databrowser(cfg,data_HB_1_95_nojumps_sum_pca);

    
    %%
    % um sich Trials anzusehen
    cfg = [];
    cfg.channel = 'MEG';
    % open the browser and page through the trials
    artf=ft_databrowser(cfg,data_HB_1_95_nojumps_sum_pca);

    %unklar, ob partial rejection funktioniert,da trials gestückelt werden
    cfg.artfctdef.reject='partial'
    cfg.artfctdef.xxx.artifact=artf.artfctdef.visual.artifact
    data_HB_1_95_nojumps_sum_pca_rejvis=ft_rejectartifact(cfg,data_HB_1_95_nojumps_sum_pca)




end