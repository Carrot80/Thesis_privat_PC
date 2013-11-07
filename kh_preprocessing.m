

function ForAllPat ()
    
    PatientFolder = 'C:\Kirsten\DatenDoktorarbeit\Patienten\'
    PatientList = dir( PatientFolder );
    VolunteerFolder = 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\';
    VolunteerList = dir( VolunteerFolder );
    
    for i = 1 : size (VolunteerList)
        if ( 0 == strcmp( VolunteerList(i,1).name, '.') && 0 == strcmp( VolunteerList(i,1).name, '..'))
            analysis2( strcat(VolunteerFolder, VolunteerList(i,1).name), VolunteerList(i,1).name  ) ;
        end
    end
end

%%

function [Path, PatientName] = analysis2  ( PatientPath, PatientName)

 % Reject all other but zzz_sc_Strobl
        if ( 0 == strcmp (PatientPath, 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\zzz_ka_Kellermann'))
            return;
        end
        
        [Config, PathExt] = SelectTimeWindowOfInterest(); % evtl. in FreqConfig integrieren
        
        Path                     = [];
        Path.DataInput           = strcat ( PatientPath, '\MEG\01_Input_noise_reduced')                 ;
        Path.Preprocessing       = strcat ( PatientPath, '\MEG\02_PreProcessing')                       ;
        Path.DataTimeOfInterest  = strcat ( PatientPath, '\MEG\03_DataTimeOfInterest', '\', PathExt)    ;
        Path.Volume              = strcat ( PatientPath, '\MEG\04_Volume')                              ;
        Path.FreqAnalysis        = strcat ( PatientPath, '\MEG\05_FreqAnalysis', '\', PathExt)          ;
        Path.SourceAnalysis      = strcat ( PatientPath, '\MEG\06_SourceAnalysis', '\', PathExt)        ;
        Path.Interpolation       = strcat ( PatientPath, '\MEG\07_Interpolation', '\', PathExt)         ;  
        Path.Statistics          = strcat ( PatientPath, '\MEG\08_Statistics', '\', PathExt)            ;
        Path.LI                  = strcat ( PatientPath, '\MEG\09_LateralityIndices', '\', PathExt)     ;
        
        Path.TemplateMRI         = 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateMRI';
        Path.MRI                 = strcat ( PatientPath, '\MRI');
        
        Path_cellarray = struct2cell(Path);
        for i=1:length(Path_cellarray)
            mkdirIfNecessary( char(Path_cellarray(i) ));
        end
  
        PreProcessing (Path, PatientName)
        kh_ComponentAnalysisFull (Path)
        kh_ComponentAnalysisPart (Path)
        kh_RejectComponent (Path)

end
  

%%
    function PreProcessing (Path, PatientName)    
    
%     CheckDataQuality_BIU (Path)


%% 

    FilePreProc = strcat (Path.Preprocessing, '\', 'Data_bp1_95_nojumps_vis_rej.mat') ;
    
    if exist (FilePreProc, 'file')
        return
    end
    
    fileName  = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    HeartBeatCleaned = strcat( Path.Preprocessing, 'hb_n_c,rfhp0.1Hz') ;
    
    
    if exist('hb_n_c,rfhp0.1Hz', 'file')
       fileName = HeartBeatCleaned
    end
    
    % define trials:
    hdr                     = ft_read_header(fileName) ;
    cfg_preproc.dataset     = fileName ;
    cfg_preproc.channel     = 'MEG' ;
    [Data]                  = ft_definetrial(cfg_preproc) ;
    
    % preprocessing
    cfg_preproc.channel     = 'MEG' ;
    cfg_preproc.continuous  = 'yes' ;
    cfg_preproc.bpfilter    = 'yes' ;
    cfg_preproc.bpfreq      = [1 95] ;
    cfg_preproc.bsfilter    = 'yes' ;
    cfg_preproc.bsfreq      = [50 100] ;
    Data_bp1_95             = ft_preprocessing(Data) ;
    PathData = strcat (Path.Preprocessing, '\', 'Data_bp1_95') ;
    save (PathData, 'Data_bp1_95') ;
  
    %% Jumps in data:
    
    % It is very important to remove all jump and muscle artifacts before running your ICA, 
    % otherwise they may change the results you get. To remove artifacts on the example dataset, use:
    % jump:
 
    % channel selection, cutoff and padding:
    cfg_jump.trl        = Data.trl;
    cfg_jump.datafile   = fileName;
    cfg_jump.headerfile = fileName;
    cfg_jump.continuous = 'yes'; 
    cfg_jump.artfctdef.zvalue.channel    = 'MEG';
    cfg_jump.artfctdef.zvalue.cutoff     = 20;
    cfg_jump.artfctdef.zvalue.trlpadding = 0;
    cfg_jump.artfctdef.zvalue.artpadding = 0;
    cfg_jump.artfctdef.zvalue.fltpadding = 0;
 
    % algorithmic parameters
    cfg_jump.artfctdef.zvalue.cumulative    = 'yes';
    cfg_jump.artfctdef.zvalue.medianfilter  = 'yes';
    cfg_jump.artfctdef.zvalue.medianfiltord = 9 ;
    cfg_jump.artfctdef.zvalue.absdiff       = 'yes';
 
    % make the process interactive
    cfg_jump.artfctdef.zvalue.interactive = 'no';
 
    [cfg_jump_output, artifact_jump]      = ft_artifact_zvalue(cfg_jump);
    PathJumps                             = strcat (Path.Preprocessing, '\', 'Jumps_RawData') ;
    save (PathJumps, 'artifact_jump', 'cfg_jump_output') ;
    
    cfg_jump                         = [] ; 
    cfg_jump.artfctdef.reject        = 'complete'; % use 'partial' if you want to do partial artifact rejection
    cfg_jump.artfctdef.jump.artifact = artifact_jump ;
    %cfg.artfctdef.muscle.artifact = artifact_muscle;
    Data_bp1_95nojumps = ft_rejectartifact(cfg_jump, Data_bp1_95) ;
    PathDataNoJumps                  = strcat (Path.Preprocessing, '\', 'Data_bp1_95nojumps') ;
    save (PathDataNoJumps, 'Data_bp1_95nojumps') ;


    %% reject manually 

    %rejectvisual summary
    cfg         = [];
    cfg.method  = 'summary';
    cfg.channel = 'MEG';
    cfg.alim    = 1e-12;
    % reject all bad trials/channels manually :
    [Data_bp1_95_nojumps_vis_rej,trlsel,chansel] = ft_rejectvisual(cfg, Data_bp1_95nojumps);
    
    RemovedChannels = find (chansel == 0) ;
%     RemovedChannels_string = num2cell (RemovedChannels)
% %     cell2str
%     char(RemovedChannels)
%     RemovedChannels_strcat = strcat ('A', RemovedChannels_string)
%     RemovedTrials = find (trlsel == 0 ) ;
    
%   RemovedChannels = num2cell( RemovedChannels) ;
    Data_bp1_95_nojumps_vis_rej.trlsel          = trlsel ;
    Data_bp1_95_nojumps_vis_rej.chansel         = chansel ;
    Data_bp1_95_nojumps_vis_rej.RemovedChannels = RemovedChannels ;
    Data_bp1_95_nojumps_vis_rej.RemovedTrials   = RemovedTrials ;

    PathData = strcat (Path.Preprocessing, '\', 'Data_bp1_95_nojumps_vis_rej') ;
    save (PathData, 'Data_bp1_95_nojumps_vis_rej')

    end
    

%% Component analysis:

function kh_ComponentAnalysisFull (Path)

    FileCompFull = strcat (Path.Preprocessing, '\', 'comp_ica.mat') ;
    
    if exist (FileCompFull, 'file')
        return
    end

    FilePreProc = strcat (Path.Preprocessing, '\', 'Data_bp1_95_nojumps_vis_rej') ;
    load (FilePreProc)

    
    %% downsample data , otherwise ICA decomposition will take too long
    cfg            = [] ;
    cfg.resamplefs = 300 ;
    cfg.detrend    = 'no' ;
    data_resampled = ft_resampledata(cfg, Data_bp1_95_nojumps_vis_rej) ;
 
    %% perform the independent component analysis (i.e., decompose the data)
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
    cfg.comment     = 'no';
    ft_topoplotIC(cfg, comp_ica)
    title ('Components ICA')
    PathTopoplotICA = strcat (Path.Preprocessing, '\', 'comp_ica') ;
    saveas (gca, PathTopoplotICA, 'fig')
    
    %% perform PCA :
    cfg         = [];
    cfg.method  = 'pca'; % this is the default and uses the implementation from EEGLAB
    cfg.channel = {'MEG'};
    comp_pca = ft_componentanalysis(cfg, data_resampled)
    
    FilePCA = strcat (Path.Preprocessing, '\', 'comp_pca') ;
    save (FileICA, 'comp_pca')
    
    % prepare the layout % debuggen !!
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
    title ('Components PCA')
    
    PathTopoplotPCA = strcat (Path.Preprocessing, '\', 'comp_pca') ;
    saveas (gca, PathTopoplotPCA, 'fig')

    %view the time course of the component: stürzt ab, evtl. zu große
    %Datenmenge (evtl. debuggen!!
    figure(2)
    cfg           = [] ;
    cfg.layout    = lay_pca ; % specify the layout file that should be used for plotting
    cfg.channel = comp_pca.label{1:5}; % components to be plotted
    ft_databrowser(cfg, comp_pca)

    
end



%% schauen, dass man sich Rohdaten anschauen kann, um Blinzelartefakte etc zu erkennen

function kh_ComponentAnalysisPart (Path)
    
    fileName  = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    FilePreProc = strcat (Path.Preprocessing, '\', 'Data_bp1_95_nojumps_vis_rej') ;
    load (FilePreProc)
    
    findBadChans(fileName); % geht nur ab Beginn des Datensatzes bis beliebig
    tracePlot_BIU(1,10, fileName); % für variable Zeiten


%%  BIU:

    startt                  = 1 ;
    endt                    = 100 ;
    cfg                     = [] ;
    cfg.dataset             = fileName ;
    cfg.trialdef.beginning  = startt ;
    cfg.trialdef.end        = endt ;
    cfg.trialfun            = 'trialfun_raw' ; % the other usefull trialfun we have are trialfun_beg and trialfun_BIU
    cfg1                    = ft_definetrial(cfg) ;

    cfg1.channel            = Data_bp1_95_nojumps_vis_rej.label ;
    cfg1.continuous         = 'yes' ;
    cfg1.bpfilter           = 'yes' ;
    cfg1.bpfreq             = [1 95] ;
    cfg1.bsfilter           = 'yes' ;
    cfg1.bsfreq             = [50 100] ;
    cfg1.demean             = 'no' ; % old version was: cfg1.blc='yes';
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

%% reject component:

function kh_RejectComponent (Path)

    FilePreProc = strcat (Path.Preprocessing, '\', 'Data_bp1_95_nojumps_vis_rej') ;
    load (FilePreProc)

    % run the ICA in the original data (Skript Maor):
    cfg                 = [];
    cfg.topo            = comp.topo;
    cfg.topolabel       = comp.topolabel;
    comp_orig           = componentanalysis(cfg, datacln);
    

    % set the bad comps as the value for cfgrc.component (Skript Yuval):
    cfgrc                           = [];
    cfgrc.component                 = [1 2 3]; % change
    cfgrc.feedback                  = 'no';
    data_HB_1_95_nojumps_sum_pca    = ft_rejectcomponent(cfgrc, compMOG_pca, data_HB_pb1_95nojumps_sum);
   

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

