function ComponentAnalysisPart (Path, Data)
    
    fileName  = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    PathFilePreProc = strcat (Path.Preprocessing, '\', Data) ;
    load (PathFilePreProc)
    
    findBadChans(fileName); % geht nur ab Beginn des Datensatzes bis beliebig
    tracePlot_BIU(11,20, fileName); % für variable Zeiten


%%  BIU:

    startt                  = 1 ;
    endt                    = 100 ;
    cfg                     = [] ;
    cfg.dataset             = fileName ;
    cfg.trialdef.beginning  = startt ;
    cfg.trialdef.end        = endt ;
    cfg.trialfun            = 'trialfun_raw' ; % the other usefull trialfun we have are trialfun_beg and trialfun_BIU
    cfg1                    = ft_definetrial(cfg) ;

    cfg1.channel            = Data.label ;
    cfg1.continuous         = 'yes' ;
    cfg1.bpfilter           = 'yes' ;
    cfg1.bpfreq             = [1 95] ;
    cfg1.bsfilter           = 'yes' ;
    cfg1.bsfreq             = [50 100] ;
    cfg1.demean             = 'yes' ; % old version was: cfg1.blc='yes';
    MOG                     = ft_preprocessing(cfg1);
    
    % lets view the raw data for one channel
    cfgb                    = [] ;
    cfgb.layout             = lay ;
    cfgb.continuous         = 'yes' ;
    cfgb.event.type         = '' ;
    cfgb.event.sample       = 1 ;
    cfgb.blocksize          = 3 ;
    cfgb.channel            = 'A245';
    comppic                 = ft_databrowser(cfgb, MOG) ;

    % ICA
    cfgc                = [] ;
    cfgc.method         = 'runica';
    comp_ICA_100s       = ft_componentanalysis(cfgc, MOG);
    File_comp_ICA_100s  = strcat (Path.Preprocessing, '\', 'comp_ICA_100s') ;
    save (File_comp_ICA_100s, 'comp_ICA_100s')

    % PCA zum Vergleich
    cfgc                = [] ;
    cfgc.method         = 'pca';
    comp_PCA_100s      = ft_componentanalysis(cfgc, MOG);

    cfg_lay         = [];
    cfg_lay.grad    = comp_PCA_100s.grad;
    lay             = ft_prepare_layout(cfg_lay);
    
    % see the components and find the HB and MOG artifact
    % remember the numbers of the bad components and close the data browser

    
    % plot the components for visual inspection
    figure
    cfg3                = [];
    cfg3.component      = [1:10];       % specify the component(s) that should be plotted
    cfg3.layout         = lay; % specify the layout file that should be used for plotting
    cfg3.comment        = 'no';
    ft_topoplotIC(cfg3, comp_PCA_100s)

    % http://fieldtrip.fcdonders.nl/tutorial/layout:
    
    cfgb                = [];
    cfgb.layout         = lay;
    %cfgb.channel = {comp.label{1:5}};
    cfg.component       = [1:5];
    cfgb.continuous     = 'yes';
    cfgb.event.type     = '';
    cfgb.event.sample   = 1;
    cfgb.blocksize      = 3;
    comppic             = ft_databrowser(cfgb,compMOG_pca);

end