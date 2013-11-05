

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
        if ( 0 == strcmp (PatientPath, 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\zzz_sf_Fakhry'))
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

end
  

%%
    function PreProcessing (Path, PatientName)    
        
% clean heartbeat:

    fileName        = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    p               = pdf4D(fileName) ;
    
    % look at the mean MEG:
    chi             = channel_index( p, {'MEG'} ) ;
    data            = read_data_block( p, [], chi ) ;
    samplingRate    = get( p,'dr' ) ;
    tMEG            = ( 0:size(data,2)-1 )/samplingRate ;
    plot(tMEG,mean(data))
    PathPlot        = strcat(Path.Preprocessing, '\', 'MeanMEG') ;
    NameTitle       = strcat ('Mean MEG', {' '}, '-', {' '}, PatientName)
    title (NameTitle) ;
    print('-dpng', PathPlot) ;
    
  
%     cleanCoefs = createCleanFile(p, fileName, 'byLF',0, 'HeartBeat',[]) ;
    cleanCoefs      = createCleanFile(p, fileName, 'HeartBeat',[]) ; 
    PathPlot        = strcat(Path.Preprocessing, '\', 'MeanMEG') ;
    print ('-dpng', PathPlot) ;
    
    tList = listErrorInHB(cleanCoefs) ;
    
    FileName_cleanCoefs = strcat (Path.Preprocessing, 'cleanCoefs') ;
    save (FileName_cleanCoefs, 'cleanCoefs', 'tList') 
    
    % auch noch tList speichern

     
    cleanpdf=pdf4D('hb_c,rfhp0.1Hz') ;
    data2=read_data_block(cleanpdf, [],chi) ;
    tMEGClean = (0:size(data2,2)-1)/1017.25 ;
    
    figure
    plot(tMEG,mean(data),'b')
    hold on
    plot(tMEGClean,mean(data2),'r')
    
    % find clean periods with no high-frequency-noise:
    % finding good periods for every channels. based on fft run with a % window of 2s sliding in steps of 0.5s. 
    % gives for every channel collumns% of beginning and end times of clean periods.
    cleanPeriodsAllChans=findCleanPeriods(fileName);
    
    % deciding which time points are realy clean. strictest is when for a given% time point there 
    % is no bad channel. for this the third argument% (chanNumThr) has to be 1. the default is 20, 
    % that is if 20 channels or more are% noisy at a sertain a time point it is considered as bad.
    cleanPeriods=sumGoodPeriods(fileName,cleanPeriodsAllChans,[]);
    
   % MEG von ILLEK ist sauber
    
%   Calculate the power spectrum:
   
[data1PSD, freq] = allSpectra(data,1017.25,1,'FFT');
[data2PSD, freq] = allSpectra(data2,1017.25,1,'FFT');
figure;plot (freq(1,1:120),data1PSD(1,1:120),'r')
hold on;
plot (freq(1,1:120),data2PSD(1,1:120),'b')
xlabel ('Frequency Hz');
ylabel('SQRT(PSD), T/sqrt(Hz)');
title('Mean PSD for A245');

cfg         = []
cfg.dataset = 'hb_c,rfhp0.1Hz';
ft_qualitycheck(cfg) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Fieldtrip: define trial and preprocessing
    
        hdr = ft_read_header('C:\Kirsten\DatenDoktorarbeit\Kontrollen\zzz_si_Illek\MEG\01_Input_noise_reduced\hb_c,rfhp0.1Hz');
        cfg.dataset='C:\MEG\Daten\Kontrollen\Illek_Stefan\zzz_si\la_seMEG40\1INYC4~U\1\mitRauschreduktion\hb_c,rfhp0.1Hz';
        cfg.channel = 'TRIGGER';
        [cfg] = ft_definetrial(cfg)
    
        % preprocessing
            cfg.channel='MEG';
            cfg.continuous='yes';
            cfg.bpfilter='yes'
            cfg.bpfreq=[1 95]
            cfg.bsfilter='yes'
            cfg.bsfreq=[50 100]
            data_HB_bp1_95=ft_preprocessing(cfg);
           
% It is very important to remove all jump and muscle artifacts before running your ICA, 
% otherwise they may change the results you get. To remove artifacts on the example dataset, use:
% jump:
 
% channel selection, cutoff and padding

cfg.trl        = trl;
cfg.datafile   = 'hb_c,rfhp0.1Hz';
cfg.headerfile = 'hb_c,rfhp0.1Hz';
cfg.continuous = 'yes'; 
cfg.artfctdef.zvalue.channel    = 'MEG';
cfg.artfctdef.zvalue.cutoff     = 20;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;
 
% algorithmic parameters
cfg.artfctdef.zvalue.cumulative    = 'yes';
cfg.artfctdef.zvalue.medianfilter  = 'yes';
cfg.artfctdef.zvalue.medianfiltord = 9;
cfg.artfctdef.zvalue.absdiff       = 'yes';
 
% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';
 
[cfg, artifact_jump] = ft_artifact_zvalue(cfg);

cfg=[]; 
cfg.artfctdef.reject = 'complete'; % use 'partial' if you want to do partial artifact rejection
cfg.artfctdef.jump.artifact = artifact_jump;
%cfg.artfctdef.muscle.artifact = artifact_muscle;
data_HB_pb1_95nojumps = ft_rejectartifact(cfg,data_HB_bp1_95);

%         data_HB_pb1_95nojumps = ft_rejectartifact(cfg,data_HB_bp1_95);
%         detected  14 jump artifacts
%         rejected    7 trials completely
%         rejected    0 trials partially
%         resulting 179 trials
%         the input is raw data with 248 channels and 186 trials
%         selecting 0 trials
%         the call to "ft_redefinetrial" took 1 seconds
%         the call to "ft_rejectartifact" took 1 seconds



cfg = [];
cfg.channel = 'MEG';
% open the browser and page through the trials
artf=ft_databrowser([],data_HB_pb1_95nojumps);   

%% schauen, dass man sich Rohdaten anschauen kann, um Blinzelartefakte etc zu erkennen

findBadChans('hb_c,rfhp0.1Hz'); % geht nur ab Beginn des Datensatzes bis beliebig
tracePlot_BIU(1700,1800,'hb_c,rfhp0.1Hz'); % für variable Zeiten


%% reject manually

%rejectvisual summary
cfg=[];
cfg.method='summary';
cfg.channel='MEG';
cfg.alim=1e-12;
data_HB_pb1_95nojumps_sum=ft_rejectvisual(cfg, data_HB_pb1_95nojumps); % reject all bad trials/channels manually
save fieldtrip_cleaning

%% Componentenanalyse:

% evtl. herausfinden, wie man aus den Daten jumps entfernen kann über die
% tList
% versuchen, fieldtrip-daten ähnlich zu plotten wie mean(MEG)

%     tMEG = (0:size(data,2)-1)/1017.25;
%     figure(2)
%     plot(tMEG,mean(data))

data_no_artifacts = data_HB_pb1_95nojumps_sum; %save the original data for later use
cfg            = [];
cfg.resamplefs = 300;
cfg.detrend    = 'no';
dummy          = ft_resampledata(cfg, data_no_artifacts);
save dummy dummy

% perform the independent component analysis (i.e., decompose the data)
cfg        = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
cfg.channel = {'MEG'};
comp = ft_componentanalysis(cfg, dummy)
save comp comp

% prepare the layout
cfg = [];
cfg.grad = dummy.grad;
lay = ft_prepare_layout(cfg);


% plot the components for visual inspection
figure
cfg = [];
cfg.component = [1:40];       % specify the component(s) that should be plotted
cfg.layout    = lay; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)

%view the time course of the component:
figure(2)
cfg = [];
cfg.layout = lay; % specify the layout file that should be used for plotting
cfg.viewmode = 'component'
ft_databrowser(cfg, comp)


% Skript von Maor:

% run the ICA in the original data
cfg = [];
cfg.topo = comp.topo;
cfg.topolabel = comp.topolabel;
comp_orig = componentanalysis(cfg, datacln);


%%  Yuval:

startt=1;
endt=100;
cfg=[];
cfg.dataset='hb_c,rfhp0.1Hz';
cfg.trialdef.beginning=startt;
cfg.trialdef.end=endt;
cfg.trialfun='trialfun_raw'; % the other usefull trialfun we have are trialfun_beg and trialfun_BIU
cfg1=ft_definetrial(cfg);
cfg1.channel='MEG';
cfg1.continuous='yes';
cfg1.bpfilter='yes'
cfg1.bpfreq=[1 95]
cfg1.bsfilter='yes'
cfg1.bsfreq=[50 100]
cfg1.demean='yes';% old version was: cfg1.blc='yes';
MOG=ft_preprocessing(cfg1);
% lets view the raw data for one channel
cfgb=[];
cfgb.layout=lay;
cfgb.continuous='yes';
cfgb.event.type='';
cfgb.event.sample=1;
cfgb.blocksize=3;
cfgb.channel='A248';
comppic=ft_databrowser(cfgb,MOG);

% ICA
cfgp=[];
cfgc.method='runica';
compMOG_runica    = ft_componentanalysis(cfgc, MOG);

% PCA zum Vergleich
cfgp=[];
cfgc.method  ='pca';
compMOG_pca  = ft_componentanalysis(cfgc, MOG);

% see the components and find the HB and MOG artifact
% remember the numbers of the bad components and close the data browser

% plot the components for visual inspection
figure
cfg3 = [];
cfg3.component = [1:10];       % specify the component(s) that should be plotted
cfg3.layout    = lay; % specify the layout file that should be used for plotting
cfg3.comment   = 'no';
ft_topoplotIC(cfg3, compMOG_pca)

cfgb=[];
cfgb.layout=lay;
%cfgb.channel = {comp.label{1:5}};
cfg.component = [1:5];
cfgb.continuous='yes';
cfgb.event.type='';
cfgb.event.sample=1;
cfgb.blocksize=3;
comppic=ft_databrowser(cfgb,compMOG_pca);



% set the bad comps as the value for cfgrc.component.
cfgrc = [];
cfgrc.component = [1 2 3]; % change
cfgrc.feedback='no';
data_HB_1_95_nojumps_sum_pca = ft_rejectcomponent(cfgrc, compMOG_pca, data_HB_pb1_95nojumps_sum);
save CleanData data_HB_1_95_nojumps_sum_pca

cfg=[];
cfg.method='summary'; %trial
cfg.channel='MEG';
cfg.alim=1e-12;
data_HB_1_95_nojumps_sum_pca_visual=ft_rejectvisual(cfg, data_HB_1_95_nojumps_sum_pca);

cfg=[];
cfg.method='summary'; %trial
cfg.channel='MEG';
cfg.alim=1e-12;
data_HB_1_95_nojumps_sum_pca_visual=ft_rejectvisual(cfg, data_HB_pb1_95nojumps_sum);

% um durch Gesamtdaten zu browsen, siehe auch Yuval Course 4
cfg=[];
cfg.layout=lay;
cfg.channel = 1:5;
cfg.continuous='yes';
ft_databrowser(cfg,data_HB_1_95_nojumps_sum_pca);

% um sich Trials anzusehen
cfg = [];
cfg.channel = 'MEG';
% open the browser and page through the trials
artf=ft_databrowser([],data_HB_1_95_nojumps_sum_pca);

%unklar, ob partial rejection funktioniert,da trials gestückelt werden
cfg.artfctdef.reject='partial'
cfg.artfctdef.xxx.artifact=artf.artfctdef.visual.artifact
data_HB_1_95_nojumps_sum_pca_rejvis=ft_rejectartifact(cfg,data_HB_1_95_nojumps_sum_pca)

CleanData = data_HB_1_95_nojumps_sum_pca_rejvis

save CleanData data_HB_1_95_nojumps_sum_pca_rejvis data_HB_1_95_nojumps_sum_pca

end

