
function ForAllPat
    
    PatientFolder = 'C:\Kirsten\DatenDoktorarbeit\Patienten\'
    PatientList = dir( PatientFolder );
    VolunteerFolder = 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\';
    VolunteerList = dir( VolunteerFolder );
    
    for i = 1 : size (VolunteerList)
        if ( 0 == strcmp( VolunteerList(i,1).name, '.') && 0 == strcmp( VolunteerList(i,1).name, '..'))
            analysis( strcat(VolunteerFolder, VolunteerList(i,1).name), VolunteerList(i,1).name  );
        end
    end
end


%%  Main function

function analysis ( PatientPath, PatientName)
        PreConfig = [];                                           
        PostConfig = [];
        PathExt = {};
        [PreConfig, PostConfig, PathExt] = SelectTimeWindowOfInterest();
        % Reject all other patients but Illek
        if ( 0 == strcmp (PatientPath, 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\zzz_si_Illek'))
            return;
        end
        
        PathDataInput       = strcat ( PatientPath, '\MEG\01_Input_noise_reduced');
        PathPreprocessing   = strcat ( PatientPath, '\MEG\02_PreProcessing');
        PathFreqAnalysis    = strcat ( PatientPath, '\MEG\03_FreqAnalysis', PathExt);
        PathSourceAnalysis  = strcat ( PatientPath, '\MEG\05_SourceAnalysis', PathExt);
        PathVolume          = strcat ( PatientPath, '\MEG\04_Volume');
        PathMRI             = strcat ( PatientPath, '\MRI');
        PathStatistics      = strcat ( PatientPath,'\MEG\07_Statistics', PathExt);
        PathTemplateMRI     = 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateMRI';
        PathLI              = strcat (PatientPath, '\MEG\08_LateralityIndices', PathExt);
   %     PathInterpolation = strcat(PatientPath, '\MEG\06_Interpolation');  
        
%         kh_RedefineTrial (PreConfig, PostConfig)
%         kh_VolumeSegment (PathMRI, PatientName, PathVolume )
%         kh_PrepHeadModell (PathVolume, 'result_mri_realign_resliced_segmentedmri', 'mri_realign_resliced', PathDataInput, 'n_c,rfhp0.1Hz', PathPreprocessing, 'DataAll', 'RemovedChannels', PathMRI, PatientName)
%         kh_SourceAnalysis_beta (PathPreprocessing, 'dataAll', 'dataPre', 'dataPost', PathVolume, 'grid_warped', 'vol_resliced', PathFreqAnalysis, PathSourceAnalysis, 'mri_realign_resliced')
%         kh_Interpolation_beta (PathSourceAnalysis, 'trial_sourcePre_13_25Hz', PathTemplateMRI, 'template_mri')
%         kh_Interpolation_beta (PathSourceAnalysis, 'trial_sourcePost_13_25Hz', PathTemplateMRI, 'template_mri')
%         kh_Statistics( PathSourceAnalysis,  'trial_sourcePre_13_25Hz_int', 'trial_sourcePost_13_25Hz_int', PathStatistics)
          kh_PlotStatistics(PathStatistics, 'Stats_allRois_left', 'Stats_allRois_right', 'Stats_allRois_combined_hem', 'Stats_allRois_both_hem', 'Stats_NoROIs', PathMRI, 'mri_realign_resliced_norm')
%         [LI] = kh_Laterality_Index (PathStatistics, ResultStats_left, ResultStats_right, PathLI)


%         kh_gamma ()
%         kh_alpha ()
%         
end

%% Redefine trials:

function [PreConfig, PostConfig, PathExt] = SelectTimeWindowOfInterest()
PreConfig = [];                                           
PreConfig.toilim = [-0.5 0];
PostConfig = [];
PostConfig.toilim = [0.3 0.8]; 

PathExt = strcat( '\', num2str( PreConfig.toilim(1)), num2str( PreConfig.toilim(2))); 
PathExt = strcat(PathExt, num2str( PostConfig.toilim(1)), num2str( PostConfig.toilim(2))); 
end


function kh_RedefineTrial( PreConfig, PostConfig )


% select time window of interest                    
dataPre = ft_redefinetrial(PreConfig, CleanData);
save dataPre dataPre

dataPost = ft_redefinetrial(PostConfig, CleanData);
save dataPost dataPost

% trials sind unterschiedlich lang, deshalb alle kürzer als gewählte ...
% samples herauswerfen

maxlength_dataPost=zeros(1,length(dataPost.time))
for i=1:length(dataPost.time)
    
    maxlength_dataPost(1,i)=length(dataPost.time{1,i})
end

for i=1:length(dataPost.time)
int(1,i)=length(dataPost.time{1,i})<max(maxlength_dataPost)
end

find_int=find(int==1)

    dataPost.time(:,find_int)=[]
    dataPost.trial(:,find_int)=[]
    dataPost.sampleinfo(find_int,:)=[]
    
    

% das gleiche für data.Pre:

maxlength_dataPre=zeros(1,length(dataPre.time))
for i=1:length(dataPre.time)
    
    maxlength_dataPre(1,i)=length(dataPre.time{1,i})
end

for i=1:length(dataPre.time)
int_dataPre(1,i)=length(dataPre.time{1,i})<max(maxlength_dataPre)
end

find_int_dataPre=find(int_dataPre==1)

    dataPre.time(:,find_int_dataPre)=[]
    dataPre.trial(:,find_int_dataPre)=[]
    dataPre.sampleinfo(find_int_dataPre,:)=[]

 save dataPre dataPre
 save dataPost dataPost
 
%% compute a single data structure with both conditions, and compute the frequency domain 

dataAll = ft_appenddata([], dataPre, dataPost);
save dataAll dataAll



end

%% import and segment MRI 


function [mri_realign_resliced, mri_realign_resliced_segmentedmri] = kh_VolumeSegment (PathMRI, PatientName, PathVolume )
   
mri             = strcat ( PathMRI, '\', PatientName, '.nii' ) ;
patients_mri    = ft_read_mri(mri);

% define coordinate system:
% [mri_coord]     = ft_determine_coordsys(patients_mri) %SPM Koordinatensystem genommen

cfg_realign     = []
[mri_realigned]   = ft_volumerealign(cfg_realign, patients_mri) %evtl. auch anteriore Kommisur definieren, da dies in SPM auch gemacht wird % hier nicht gemacht

File_MRIrealigned = strcat (PathVolume, '\', 'mri_realigned', '.mat' );
save (File_MRIrealigned, 'mri_realigned');

% reslicen, um 256x256x256 voxel zu erhalten => dann funktioniert wohl Segmentierung besser:
cfg_reslice             = []
mri_realign_resliced    = ft_volumereslice(cfg_reslice, mri_realigned); 

% downsamplen auf 2x2x2mm (128x128x128)
cfg_downsample              = [];
cfg_downsample.downsample   = 2;
mri_realign_resliced        = ft_volumedownsample(cfg_downsample, mri_realign_resliced);

result_mri_realign_resliced = strcat( PathVolume, '\', 'mri_realign_resliced', '.mat' );
save( result_mri_realign_resliced, 'mri_realign_resliced' );


% normalization for later use (plot statistics):

 cfg_norm = [];
 cfg_norm.coordinates = [];   % 'spm, 'ctf' or empty for interactive (default = [])
 cfg_norm.downsample = 1;
 [mri_realign_resliced_norm] = ft_volumenormalise(cfg_norm, mri_realign_resliced)
 FILE_mri_realign_resliced_norm = strcat( PathMRI, '\', 'mri_realign_resliced_norm', '.mat' );
 save( FILE_mri_realign_resliced_norm, 'mri_realign_resliced_norm' );

% segmentation: 
cfg_segment             = [];
%cfg_segment.write      = 'no';
cfg_segment.coordsys    = 'ctf';
cfg_segment.downsample  = 2; % evtl. downsamplen, jedoch unklar, ob hinterher Probleme mit fMRT, im FT tutorial wurde downgesampled
cfg_segment.output      = {'brain','skull','scalp', 'white', 'gray'};
cfg_segment.brainsmooth = 5; % the FWHM of the gaussian kernel in voxels, (default = 5)
cfg_segment.scalpsmooth = 5; % or scalar, the FWHM of the gaussian kernel in voxels, (default = 5)
[mri_realign_resliced_segmentedmri] = ft_volumesegment(cfg_segment, mri_realign_resliced);

% visualize:
cfg_plot                    = [];
cfg_plot.funparameter       = 'brain';
cfg_plot.location           = 'center';
ft_sourceplot(cfg_plot, mri_realign_resliced_segmentedmri);
title('segmented mri - brain');
segmented_mri               = strcat( PathVolume, '\', 'segmented_mri' );
print('-dpng',segmented_mri);

seg_i                       = ft_datatype_segmentation(mri_realign_resliced_segmentedmri,'segmentationstyle','indexed');
cfg_plot                    = [];
cfg_plot.funparameter       = 'seg'; 
cfg_plot.location           = 'center';
ft_sourceplot(cfg_plot,seg_i);
title('datatype_segmentation - brain - skull - scalp');
datatype_segmentation       = strcat( PathVolume, '\', 'datatype_segmentation' );
print('-dpng', datatype_segmentation);

result_mri_realign_resliced_segmentedmri = strcat( PathVolume, '\', 'mri_realign_resliced_segmentedmri', '.mat' );
save( result_mri_realign_resliced_segmentedmri, 'mri_realign_resliced_segmentedmri' );

clear mri_realign_resliced_segmentedmri mri_realign_resliced

end

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


%% Source Analysis Beta Oscillation: 13-25 Hz: Contrast activity to another interval


function kh_SourceAnalysis_beta ( PathPreprocessing, DataAll, DataPre, DataPost, PathVolume, Grid, Vol, PathFreqAnalysis, PathSourceAnalysis, mri_realign_resliced)

     % load files:
     
     FileDataAll            = strcat ( PathPreprocessing, '\', DataAll, '.mat' );
     load ( FileDataAll );
     FileDataPre            = strcat ( PathPreprocessing, '\', DataPre, '.mat' );
     load ( FileDataPre );
     FileDataPost           = strcat ( PathPreprocessing, '\', DataPost, '.mat' );
     load ( FileDataPost );
     FileGrid               = strcat ( PathVolume, '\', Grid, '.mat' );
     load ( FileGrid );
     FileVol                = strcat ( PathVolume, '\', Vol, '.mat' );
     load ( FileVol );

     % Calculating FFT and cross spectral density matrix:
     
     cfg_beta            = [];
     cfg_beta.method     = 'mtmfft';
     cfg_beta.output     = 'powandcsd'; 
    % cfg_beta.taper     = 'hanning';
     cfg_beta.tapsmofrq  = 6; % braucht man erst ab 30 Hz
     cfg_beta.foilim     = [19 19];
     cfg_beta.rawtrial   = 'yes';
     cfg_beta.keeptrials = 'yes';
     freqAll_13_25Hz     = ft_freqanalysis( cfg_beta, dataAll );
     freqPre_13_25Hz     = ft_freqanalysis( cfg_beta, dataPre );
     freqPost_13_25Hz    = ft_freqanalysis( cfg_beta, dataPost );
     
     ResultFreqAllBeta   = strcat( PathFreqAnalysis, '\', 'freqAll_13_25Hz', '.mat' );
     save( ResultFreqAllBeta, 'freqAll_13_25Hz' );
     ResultFreqPreBeta   = strcat( PathFreqAnalysis, '\', 'freqPre_13_25Hz', '.mat' );
     save( ResultFreqPreBeta, 'freqPre_13_25Hz' );    
     ResultFreqPostBeta  = strcat( PathFreqAnalysis, '\', 'freqPost_13_25Hz', '.mat' );
     save( ResultFreqPostBeta, 'freqPost_13_25Hz' ); 
    
     clear dataAll dataPre dataPost cfg_beta

    % compute common spatial filter %
    
    cfg_source                     = [];
    cfg_source.method              = 'dics';
    cfg_source.frequency           = 19;
    cfg_source.grid                = grid_warped;
    cfg_source.vol                 = vol_resliced;
    cfg_source.dics.projectnoise   = 'yes';
    cfg_source.dics.lambda         = '5%';
    cfg_source.dics.keepfilter     = 'yes';
    cfg_source.dics.realfilter     = 'yes';
    sourceAll_beta                 = ft_sourceanalysis(cfg_source, freqAll_13_25Hz);
    
    ResultSourceAllBeta            = strcat( PathSourceAnalysis, '\', 'sourceAll_beta', '.mat' );
    save( ResultSourceAllBeta, 'sourceAll_beta' ); 
     
   

    % By placing this pre-computed filter inside cfg.grid.filter, it can now be
    % applied to each condition separately:
    
    cfg_source.grid.filter          = sourceAll_beta.avg.filter;
    cfg_source.keeptrials           = 'yes'; 
    cfg_source.rawtrial             = 'yes';
    trial_sourcePre_13_25Hz         = ft_sourceanalysis(cfg_source, freqPre_13_25Hz); 
    
%   load templte grid and replace pos and dim with template_grid
    FileTemplateGrid        = strcat ( 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_grid', '.mat' ) ;
    load ( FileTemplateGrid ) ;   
    
    trial_sourcePre_13_25Hz.pos = template_grid.pos
    trial_sourcePre_13_25Hz.dim = template_grid.dim
    
    ResultSourcePreBeta             = strcat( PathSourceAnalysis, '\', 'trial_sourcePre_13_25Hz', '.mat' );
    save( ResultSourcePreBeta, 'trial_sourcePre_13_25Hz' ); 
    
    clear trial_sourcePre_13_25Hz
    
    trial_sourcePost_13_25Hz        = ft_sourceanalysis(cfg_source, freqPost_13_25Hz);
    trial_sourcePost_13_25Hz.pos = template_grid.pos
    trial_sourcePost_13_25Hz.dim = template_grid.dim
    
    ResultSourcePostBeta            = strcat( PathSourceAnalysis, '\', 'trial_sourcePost_13_25Hz', '.mat' );
    save( ResultSourcePostBeta, 'trial_sourcePost_13_25Hz' );  
    
    clear trial_sourcePost_13_25Hz


    % compute the contrast of (post-pre)/pre. In this operation we ...
    % assume that the noise bias is the same for the pre- and post-stimulus ...
    % interval and it will thus be removed

    % zum Plotten auch noch mal Variable ohne Keeptrials erstellen:
        
    cfg_source.grid.filter          = sourceAll_beta.avg.filter;
    cfg_source.keeptrials           = 'no'; 
    cfg_source.rawtrial             = 'no';
    avg_sourcePre_13_25Hz           = ft_sourceanalysis( cfg_source, freqPre_13_25Hz ); 
    avg_sourcePost_13_25Hz          = ft_sourceanalysis( cfg_source, freqPost_13_25Hz );
        
    sourceDiff_13_25Hz              = avg_sourcePost_13_25Hz;
    sourceDiff_13_25Hz.avg.pow      = ( avg_sourcePost_13_25Hz.avg.pow - avg_sourcePre_13_25Hz.avg.pow ) ./ avg_sourcePre_13_25Hz.avg.pow;

    ResultSourcePreBetaAVG            = strcat( PathSourceAnalysis, '\', 'avg_sourcePre_13_25Hz', '.mat' );
    save( ResultSourcePreBetaAVG, 'avg_sourcePre_13_25Hz' ); 
    ResultSourcePostBetaAVG            = strcat( PathSourceAnalysis, '\', 'avg_sourcePost_13_25Hz', '.mat' );
    save( ResultSourcePostBetaAVG, 'avg_sourcePost_13_25Hz' ); 


    %  interpolate the source to the MRI
    File_mri_realign_resliced = strcat( PathVolume, '\', 'mri_realign_resliced', '.mat' );
    load( File_mri_realign_resliced, 'mri_realign_resliced' )

    cfg_int            = [];
    cfg_int.downsample = 1;
    cfg_int.parameter  = 'avg.pow';
    sourceDiffInt_beta  = ft_sourceinterpolate(cfg_int, sourceDiff_13_25Hz, mri_realign_resliced);

    % Now plot the power ratios: 

    cfg_ortho                = [];
    cfg_ortho.method         = 'ortho';
    cfg_ortho.interactive    = 'yes';
    cfg_ortho.funparameter   = 'avg.pow';
    cfg_ortho.maskparameter  = cfg_ortho.funparameter;
%     cfg_ortho.funcolorlim    = [-0.6 0.6];
%     cfg_ortho.opacitylim     = [-0.6 0.6];  
    cfg_ortho.opacitymap     = 'rampup';  
    ft_sourceplot(cfg_ortho, sourceDiffInt_beta);
    plot_ortho               = strcat( PathSourceAnalysis, '\', 'beta_avg_ortho' );
    print('-dpng', plot_ortho );

    figure
    cfg_slice               = [];
    cfg_slice.method        = 'slice';
    cfg_slice.funparameter  = 'avg.pow';
    cfg_slice.maskparameter = cfg_slice.funparameter;
    cfg_slice.funcolorlim   = [-1.2 1.2];
    cfg_slice.opacitylim    = [-1.2 1.2]; 
    cfg_slice.opacitymap    = 'rampup';  
    ft_sourceplot(cfg_slice, sourceDiffInt_beta);

    plot_slice              = strcat( PathSourceAnalysis, '\', 'beta_avg_slice' );
    print( '-dpng', plot_slice );


end


%% Interpolation of Source to match template mri dimension

function kh_Interpolation_beta(PathSourceAnalysis, SourceFileName, PathTemplateMRI, TemplateMRI)

 % load Data
    SourceFile = strcat( PathSourceAnalysis, '\', SourceFileName, '.mat');
    source_trials = load( SourceFile );
    source_trials = source_trials.(SourceFileName);
    
   load( strcat( PathTemplateMRI, '\', TemplateMRI, '.mat'));
     

   %% set config for interpolation
    
    cfg_i            = [];  
    cfg_i.parameter  = 'trial.pow';
    cfg_i.downsample = 1;  % evtl. besser downsamplen

    % create trials variable for loop
    trials.trial = struct('pow',cell(1,length(source_trials.trial)));
    
    for i=1:length(source_trials.trial)
        source_trials_int           = [];
        source_trials.trial(1,1)    = source_trials.trial(1,i);
        source_trials_int           = ft_sourceinterpolate(cfg_i, source_trials, template_mri);
        trials.trial(1,i).pow       = source_trials_int.trial.pow;
    end
          
    source_trials_int.trial         = trials.trial;
    
    IntFileName                     = strcat( PathSourceAnalysis, '\', SourceFileName, '_int.mat');
    save( IntFileName, 'source_trials_int' );



end



%% statistics

function kh_Statistics( PathSourceAnalysis, Source_Pre, Source_Pst, PathStatistics )

% neue Funktion einbauen, die Source interpoliert auf template mni (dieses
% einlesen und downsamplen, damit nicht zu viele redundante Werte, dann auf


% noch zu erledigen:
% - Prüfe innerhalb deiner Funktion als erstes, ob die Dateien vorhanden sind und lade dann die Variablen. 

    Source_Pre        = strcat( PathSourceAnalysis, '\', Source_Pre, '.mat');
    Source_PreStim    = load( Source_Pre );
    Source_PreStim    = Source_PreStim.source_trials_int; 
    
    Source_Pst        = strcat( PathSourceAnalysis, '\', Source_Pst, '.mat');
    Source_PstStim    = load( Source_Pst );
    Source_PstStim    = Source_PstStim.source_trials_int;
    
    cfg_stats                     = [];
    cfg_stats.dim                 = Source_PreStim.dim;
    cfg_stats.method              = 'analytic';                 % significance probability can only be calculated by means of the so-called Monte Carlo method. 
    cfg_stats.statistic           = 'indepsamplesT';            % 'indepsamplesT', 'depsamplesT', 'actvsblT', % müsste eigentlich dependent sein, funktioniert aber nicht
    cfg_stats.clusteralpha        =  0.05 ;                     % All samples are selected whose t-value is larger than some threshold as specified in cfg.clusteralpha. 
    cfg_stats.parameter           = 'pow';
    cfg_stats.clusterthreshold    = 'nonparametric_common'  ;      %'nonparametric_individual': computes a threshold per voxel; nonparametric_common: uses the same
                                                            % threshold for all voxels  
    cfg_stats.clusterstatistic    = 'maxsum';                %  how to combine the single samples that belong to a cluster, 'maxsum', 'maxsize', 'wcm' (default = 'maxsum')
%                                                                option 'wcm' refers to 'weighted cluster mass',  a statistic that combines cluster size and
%                                                                intensity;  see Hayasaka & Nichols (2004) NeuroImage for details
    cfg_stats.correctm            = 'cluster';                    % correction of multiple comparisons:  'no', 'max', 'cluster', 'bonferoni', 'holms', or 'fdr' 
    cfg_stats.numrandomization    = 500     ;                      %  1000, oder 'all'
    cfg_stats.alpha               = 0.05; 
    cfg_stats.tail                = 0;                            % two-sided test
    cfg_stats.correcttail         = 'alpha';
    cfg_stats.design(1,:)         = [1:length(Source_PreStim.trial) 1:length(Source_PstStim.trial)];
    cfg_stats.design(2,:)         = [ones(1,length(Source_PreStim.trial)) ones(1,length(Source_PstStim.trial))*2];
    cfg_stats.ivar                = 2;                            % row of design matrix that contains independent variable (the conditions)
    cfg_stats.inputcoord          = 'mni';  
    
    cfg_stats.atlas               = 'C:\Kirsten\DatenDoktorarbeit\Alle\TemplateAtlas\ROI_MNI_V4.nii' ; 
    cfg_stats.roi                 = {'Precentral_L';'Precentral_R';'Frontal_Sup_L';'Frontal_Sup_R';'Frontal_Sup_Orb_L';'Frontal_Sup_Orb_R';'Frontal_Mid_L';'Frontal_Mid_R';'Frontal_Mid_Orb_L';'Frontal_Mid_Orb_R';'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R';'Frontal_Inf_Orb_L';'Frontal_Inf_Orb_R';'Rolandic_Oper_L';'Rolandic_Oper_R';'Supp_Motor_Area_L';'Supp_Motor_Area_R';'Olfactory_L';'Olfactory_R';'Frontal_Sup_Medial_L';'Frontal_Sup_Medial_R';'Frontal_Med_Orb_L';'Frontal_Med_Orb_R';'Rectus_L';'Rectus_R';'Insula_L';'Insula_R';'Cingulum_Ant_L';'Cingulum_Ant_R';'Cingulum_Mid_L';'Cingulum_Mid_R';'Cingulum_Post_L';'Cingulum_Post_R';'Hippocampus_L';'Hippocampus_R';'ParaHippocampal_L';'ParaHippocampal_R';'Amygdala_L';'Amygdala_R';'Calcarine_L';'Calcarine_R';'Cuneus_L';'Cuneus_R';'Lingual_L';'Lingual_R';'Occipital_Sup_L';'Occipital_Sup_R';'Occipital_Mid_L';'Occipital_Mid_R';'Occipital_Inf_L';'Occipital_Inf_R';'Fusiform_L';'Fusiform_R';'Postcentral_L';'Postcentral_R';'Parietal_Sup_L';'Parietal_Sup_R';'Parietal_Inf_L';'Parietal_Inf_R';'SupraMarginal_L';'SupraMarginal_R';'Angular_L';'Angular_R';'Precuneus_L';'Precuneus_R';'Paracentral_Lobule_L';'Paracentral_Lobule_R';'Caudate_L';'Caudate_R';'Putamen_L';'Putamen_R';'Pallidum_L';'Pallidum_R';'Thalamus_L';'Thalamus_R';'Heschl_L';'Heschl_R';'Temporal_Sup_L';'Temporal_Sup_R';'Temporal_Pole_Sup_L';'Temporal_Pole_Sup_R';'Temporal_Mid_L';'Temporal_Mid_R';'Temporal_Pole_Mid_L';'Temporal_Pole_Mid_R';'Temporal_Inf_L';'Temporal_Inf_R';'Cerebelum_Crus1_L';'Cerebelum_Crus1_R';'Cerebelum_Crus2_L';'Cerebelum_Crus2_R';'Cerebelum_3_L';'Cerebelum_3_R';'Cerebelum_4_5_L';'Cerebelum_4_5_R';'Cerebelum_6_L';'Cerebelum_6_R';'Cerebelum_7b_L';'Cerebelum_7b_R';'Cerebelum_8_L';'Cerebelum_8_R';'Cerebelum_9_L';'Cerebelum_9_R';'Cerebelum_10_L';'Cerebelum_10_R';'Vermis_1_2';'Vermis_3';'Vermis_4_5';'Vermis_6';'Vermis_7';'Vermis_8';'Vermis_9';'Vermis_10'};
    Stats_NoROIs                  = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.roi                 = {'Frontal_Inf_Oper_L';'Frontal_Inf_Oper_R';'Frontal_Inf_Tri_L';'Frontal_Inf_Tri_R'; 'SupraMarginal_L';'SupraMarginal_R'; ...
                                         'Angular_L';'Angular_R'; 'Temporal_Sup_L'; 'Temporal_Sup_R'; 'Temporal_Pole_Sup_L'; 'Temporal_Pole_Sup_R'; 'Temporal_Mid_L'; 'Temporal_Mid_R'; 'Temporal_Pole_Mid_L'; 'Temporal_Pole_Mid_R'; 'Temporal_Inf_L'; 'Temporal_Inf_R'; };
    
    cfg_stats.hemisphere          = 'left' ; %   'left' 'right', 'both', 'combined', specifying this is required when averaging over regions 
    Stats_allRois_left            = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.hemisphere          = 'right' ; 
    Stats_allRois_right             = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.hemisphere          = 'both' ; 
    Stats_allRois_both_hem          = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    cfg_stats.hemisphere          = 'combined' ; 
    Stats_allRois_combined_hem      = ft_sourcestatistics(cfg_stats, Source_PreStim, Source_PstStim); 
    
    FileName_NoROIs = strcat( PathStatistics, '\', 'Stats_NoROIs', '.mat' );
    save( FileName_NoROIs, 'Stats_NoROIs' )
    
    FileName_allRois_left = strcat( PathStatistics, '\', 'Stats_allRois_left', '.mat' );
    save( FileName_allRois_left, 'Stats_allRois_left' )
  
    FileName_allRois_right = strcat( PathStatistics, '\', 'Stats_allRois_right', '.mat' );
    save( FileName_allRois_right, 'Stats_allRois_right' )
    
    FileName_allRois_both_hem = strcat( PathStatistics, '\', 'Stats_allRois_both_hem', '.mat' );
    save( FileName_allRois_both_hem, 'Stats_allRois_both_hem' )
    
    FileName_allRois_combined_hem = strcat( PathStatistics, '\', 'Stats_allRois_combined_hem', '.mat' );
    save( FileName_allRois_combined_hem, 'Stats_allRois_combined_hem' )
        
end




%% Plot statistics

function  kh_PlotStatistics( PathStatistics, ResultStatsLeft, ResultStatsRight, ResultStatsCombined, ResultStatsBoth, Result_NoROIs, PathMRI, MRINorm  )
    
        
        load( strcat( PathStatistics, '\', 'Stats_allRois_left', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_allRois_right', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_allRois_both_hem', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_allRois_combined_hem', '.mat' ));
        load( strcat( PathStatistics, '\', 'Stats_NoROIs', '.mat' ));
        
        load( strcat( PathMRI, '\', MRINorm, '.mat' ))        ; % evtl. nicht das templateMRI nehmen, sondern zu besseren Darstellungszwecken das normalisierte individuelle Gehirn
        
        % interpolate stats to template mri in order to plot it:
        cfg_int                         = [];
        cfg_int.parameter               = {'prob'; 'stat'}; % z.B. 'prob', 'stat', 'posclusterslabelmat'
        Stats_allRois_left_int            = ft_sourceinterpolate(cfg_int, Stats_allRois_left, mri_realign_resliced_norm');
        Stats_allRois_right_int           = ft_sourceinterpolate(cfg_int, Stats_allRois_right, mri_realign_resliced_norm');
        Stats_allRois_both_hem_int        = ft_sourceinterpolate(cfg_int, Stats_allRois_both_hem, mri_realign_resliced_norm');
        Stats_allRois_combined_hem_int    = ft_sourceinterpolate(cfg_int, Stats_allRois_combined_hem, mri_realign_resliced_norm');
        Stats_NoROIs_int                  = ft_sourceinterpolate(cfg_int, Stats_NoROIs, mri_realign_resliced_norm');
        
        Sign_ResultStats_NoROIs_int      = Stats_NoROIs_int;
        lowerlim                         = Stats_NoROIs.critval(1);
        upperlim                         = Stats_NoROIs.critval(2);
        Sign_ResultStats_NoROIs_int.mask =((Sign_ResultStats_NoROIs_int.stat<=lowerlim | Sign_ResultStats_NoROIs_int.stat >= upperlim));
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.anaparameter    = 'anatomy'; 
        cfg_plot.maskparameter   = 'mask';  % mask seems to be right % see also opacitymap and opacitylim
%         cfg_plot.opacitymap      = 'vdown'; % 'rampup' (only pos. values); 'rampdown' (only neg. values), 'vdown' (both pos. and neg. values)
%         cfg_plot.opacitylim      = [-2.5 2.5];  % [min max]; 'zeromax' (values from zero to max will be plotted), 'minzero' , 'maxabs' ;
%         cfg_plot.funcolorlim     = [-2.5 2.5];
        cfg_plot.coordsys        = 'spm';
        ft_sourceplot(cfg_plot, Sign_ResultStats_NoROIs_int);
        
        title('no ROIs');
        sourceplot_noROIs          = strcat(PathStatistics, '\', 'Stats_noROIs');
        print('-dpng', sourceplot_noROIs);
        
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'rampup';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; % sind das die signifikanten Werte? (rechts nur Nullen)
        cfg_plot.coordsys        = 'spm';
        
        ft_sourceplot(cfg_plot, Stats_allRois_left_int);
        title('all ROIs left hemisphere');
        sourceplot_left          = strcat(PathStatistics, '\', 'Stats_allROIs_left');
        print('-dpng', sourceplot_left);
        
        ft_sourceplot(cfg_plot, Stats_allRois_right_int);
        title('all ROIs right hemisphere');
        sourceplot_right        = strcat(PathStatistics, '\', 'Stats_allROIs_right');
        print('-dpng', sourceplot_right);     
        
        
        sign_Stats_allROIs_both_hem_int       = Stats_allRois_both_hem_int;
        sign_Stats_allROIs_both_hem_int.mask  =((sign_Stats_allROIs_both_hem_int.stat<=lowerlim | sign_Stats_allROIs_both_hem_int.stat >= upperlim));
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'rampup';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; 
        cfg_plot.coordsys        = 'spm';
        
        ft_sourceplot(cfg_plot, sign_Stats_allROIs_both_hem_int); 
        title('all ROIs both hemispheres');
        sourceplot_both_hem        = strcat(PathStatistics, '\', 'Stats_allROIs_both_hem');
        print('-dpng', sourceplot_both_hem);  
        
        
        sign_Stats_allROIs_combined_hem_int      = Stats_allRois_combined_hem_int;
        sign_Stats_allROIs_combined_hem_int.mask =((sign_Stats_allROIs_combined_hem_int.stat<=lowerlim | sign_Stats_allROIs_combined_hem_int.stat >= upperlim));
        
        cfg_plot                 = [];
        cfg_plot.method          = 'slice';
        cfg_plot.funparameter    = 'stat';
        cfg_plot.opacitymap      = 'rampup';
        cfg_plot.anaparameter    = 'anatomy';
        cfg_plot.maskparameter   = 'mask'; 
        cfg_plot.coordsys        = 'spm';

        ft_sourceplot(cfg_plot, sign_Stats_allROIs_combined_hem_int);
        title('all ROIs combined hemispheres');
        sourceplot_combined_hem        = strcat(PathStatistics, '\', 'Stats_allROIs_combined_hem');
        print('-dpng', sourceplot_combined_hem);  
        
    
            
end  
    
%%
function [LI_allROIs] = kh_Laterality_Index (ResultStats_left, ResultStats_right, PathLI)

  % signifikante t-Werte links :
        SignStat_left = ResultStats_left;
        sign_vert_left = find( squeeze( ResultStats_left.stat) <= ResultStats_left.critval(1));
        sign_values_left =  squeeze(ResultStats_left.stat(sign_vert_left));
        sign_values_left_abs = abs(sign_values_left)
        
        
  %  signifikante t-Werte rechts :
        SignStat_right = ResultStats_right;
        sign_vert_right = find( squeeze( ResultStats_right.stat) <= ResultStats_right.critval(1));
        sign_values_right =  squeeze(ResultStats_right.stat(sign_vert_right));
        sign_values_right_abs = abs(sign_values_right)
        
        LI_allROIs = (sum(sign_values_left_abs) - sum(sign_values_right_abs)) ./ (sum(sign_values_left_abs) + sum(sign_values_right_abs));
        File_LI_allROIs = strcat(PathLI, '\', 'LI_allROIs');
        save (File_LI_allROIs, 'LI_allROIs');
        
end

%%
function kh_gamma ()

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd'; 
cfg.tapsmofrq = 10;
cfg.foilim    = [35 35];
freqAll_25bis45Hz = ft_freqanalysis(cfg, dataAll);
save freqAll_25bis45Hz freqAll_25bis45Hz 

% Calculating the cross spectral density matrix

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 10;
cfg.foilim    = [35 35];
freqPre_25bis45Hz = ft_freqanalysis(cfg, dataPre);

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 10;
cfg.foilim    = [35 35];
freqPost_25bis45Hz = ft_freqanalysis(cfg, dataPost);


% compute common spatial filter %
cfg              = [];
cfg.method       = 'dics';
cfg.frequency    = 35
cfg.grid         = grid_resliced;
cfg.vol          = vol_resliced;
cfg.dics.projectnoise = 'yes';
cfg.dics.lambda       = '5%';
cfg.dics.keepfilter   = 'yes';
cfg.dics.realfilter   = 'yes';
sourceAll_gamma = ft_sourceanalysis(cfg, freqAll_25bis45Hz);
save sourceAll_gamma sourceAll_gamma



% By placing this pre-computed filter inside cfg.grid.filter, it can now be
% applied to each condition separately:
cfg.grid.filter = sourceAll_gamma.avg.filter;
sourcePre_25bis45Hz  = ft_sourceanalysis(cfg, freqPre_25bis45Hz);
sourcePost_25bis45Hz = ft_sourceanalysis(cfg, freqPost_25bis45Hz);

% compute the contrast of (post-pre)/pre. In this operation we ...
% assume that the noise bias is the same for the pre- and post-stimulus ...
% interval and it will thus be removed

sourceDiff_gamma = sourcePost_25bis45Hz;
sourceDiff_gamma.avg.pow = (sourcePost_25bis45Hz.avg.pow - sourcePre_25bis45Hz.avg.pow) ./ sourcePre_25bis45Hz.avg.pow;


%  interpolate the source to the MRI
cfg            = [];
cfg.downsample = 1;
cfg.parameter  = 'avg.pow';
sourceDiff_Int_gamma  = ft_sourceinterpolate(cfg, sourceDiff_gamma , mri_realign_resliced);
save sourceDiff_Int_gamma sourceDiff_Int_gamma


% Now plot the power ratios: 
figure
cfg = [];
cfg.method        = 'ortho';
cfg.interactive   = 'yes';
cfg.funparameter  = 'avg.pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [-1.2 1.2];
cfg.opacitylim    = [-1.2 1.2];  
cfg.opacitymap    = 'rampup';  
ft_sourceplot(cfg, sourceDiff_Int_gamma);
% Ergebnis: beta-Aktivierung über rechten Sensoren

figure
cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'avg.pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [-1.2 1.2];
cfg.opacitylim    = [-1.2 1.2]; 
cfg.opacitymap    = 'rampup';  
ft_sourceplot(cfg, sourceDiff_Int_gamma);

end

function kh_alpha ()
%% Alpha: 
% wichtig: cfg.rawtrial= 'yes', um trials für sourcestatistics zu erhalten,
% evtl. auch cfg.keeptrials = 'yes'; siehe ft_sourcesanalysis

        cfg = [];
        cfg.method    = 'mtmfft';
        cfg.taper   = 'hanning';
        cfg.output    = 'powandcsd'; 
        cfg.tapsmofrq = 2;
        cfg.foilim    = [10 10];
        cfg.keeptrials = 'yes'
        cfg.rawtrial = 'yes'
        freqAll_8_12Hz_test = ft_freqanalysis(cfg, dataAll);
        save freqAll_8_12Hz freqAll_8_12Hz 

        cfg = [];
        cfg.method    = 'mtmfft';
        cfg.output    = 'powandcsd';
        cfg.tapsmofrq = 2;
        cfg.foilim    = [10 10];
        cfg.keeptrials = 'yes'
        cfg.rawtrial = 'yes'
        freqPre_8_12Hz = ft_freqanalysis(cfg, dataPre);
        save freqPre_8_12Hz freqPre_8_12Hz

        cfg = [];
        cfg.method    = 'mtmfft';
        cfg.output    = 'powandcsd';
        cfg.tapsmofrq = 2;
        cfg.foilim    = [10 10];
        cfg.keeptrials = 'yes'
        cfg.rawtrial = 'yes'
        freqPost_8_12Hz = ft_freqanalysis(cfg, dataPost);
        save freqPost_8_12Hz freqPost_8_12Hz

        % compute common spatial filter % hier kein cfg.rawtrials = 'yes'
        cfg              = [];
        cfg.method       = 'dics';
        cfg.frequency    = 10
        cfg.grid         = grid_resliced;
        cfg.vol          = vol_resliced;
        cfg.dics.projectnoise = 'yes';
        cfg.dics.lambda       = '5%';
        cfg.dics.keepfilter   = 'yes';
        cfg.dics.realfilter   = 'yes';

        sourceAll_Alpha = ft_sourceanalysis(cfg, freqAll_8_12Hz);
        save sourceAll_Alpha sourceAll_Alpha


        % By placing this pre-computed filter inside cfg.grid.filter, it can now be
        % applied to each condition separately:
        cfg.keeptrials = 'yes' % unklar, ob sinnvoll, da Speicherprobleme
        cfg.rawtrial = 'yes'
        cfg.grid.filter = sourceAll_Alpha.avg.filter;
        sourcePre_alpha  = ft_sourceanalysis(cfg, freqPre_8_12Hz );
        sourcePost_alpha = ft_sourceanalysis(cfg, freqPost_8_12Hz);

        save sourcePre_alpha sourcePre_alpha  % kann Variable nicht speichern, da zu groß
        save sourcePost_alpha sourcePost_alpha % kann Variable nicht speichern, da zu groß
        
        % evtl. einfacherer Weg, um Statistik zu erhalten: noch
        % ausprobieren
%         cfg=[]
%         cfg.method       = 'dics';
%         cfg.frequency    = 10
%         cfg.grid         = grid_resliced;
%         cfg.vol          = vol_resliced;
%         cfg.dics.projectnoise = 'yes';
%         cfg.dics.lambda       = '5%';
%         cfg.dics.keepfilter   = 'yes';
%         cfg.dics.realfilter   = 'yes';
%         cfg.permutation = 'yes'
%         cfg.numpermutation = 'all'
%         [source] = ft_sourceanalysis(cfg, freqPre_8_12Hz, freqPost_8_12Hz)

        % compute the contrast of (post-pre)/pre. In this operation we ...
        % assume that the noise bias is the same for the pre- and post-stimulus ...
        % interval and it will thus be removed

        sourceDiff_Alpha = sourcePost_alpha;
        sourceDiff_Alpha.avg.pow = (sourcePost_con.avg.pow - sourcePre_con.avg.pow) ./ sourcePre_con.avg.pow;

        %  interpolate the source to the MRI
        cfg            = [];
        cfg.downsample = 1;
        cfg.parameter  = 'avg.pow';
        sourceDiff_Int_Alpha  = ft_sourceinterpolate(cfg, sourceDiff_Alpha , mri_realign_resliced);

        save sourceDiff_Int_Alpha sourceDiff_Int_Alpha


        % Now plot the power ratios: 
        figure
        cfg = [];
        cfg.method        = 'ortho';
        cfg.interactive   = 'yes';
        cfg.funparameter  = 'avg.pow';
        cfg.maskparameter = cfg.funparameter;
        cfg.funcolorlim   = [-1.2 1.2];
        cfg.opacitylim    = [-1.2 1.2];  
        cfg.opacitymap    = 'rampup';  
        ft_sourceplot(cfg, sourceDiff_Int_Alpha);
        % Ergebnis: Alpha-Aktivierung über rechten Sensoren



        figure
        cfg = [];
        cfg.method        = 'slice';
        cfg.funparameter  = 'avg.pow';
        cfg.maskparameter = cfg.funparameter;
        cfg.funcolorlim   = [-1.2 1.2];
        cfg.opacitylim    = [-1.2 1.2]; 
        cfg.opacitymap    = 'rampup';  
        ft_sourceplot(cfg, sourceDiff_Int_Alpha);

        % Normalisiere source:
        cfg = [];
        cfg.coordsys      = 'SPM';
        cfg.nonlinear     = 'no';
        sourceDiff_Int_Alpha_Norm = ft_volumenormalise(cfg, sourceDiff_Int_Alpha);


        % Darstellung auf Oberfläche: funktioniert nicht

        [sourceDiff_Int_Alpha_Norm_cm] = ft_convert_units(sourceDiff_Int_Alpha_Norm, 'cm')
        figure
        cfg = [];
        cfg.method         = 'surface';
        cfg.funparameter   = 'avg.pow';
        cfg.maskparameter  = cfg.funparameter;
        cfg.funcolorlim    = [-0.5 0]; % evtl. ändern
        cfg.funcolormap    = 'jet';
        cfg.opacitylim     = [-0.5 0]; % evtl. ändern
        cfg.opacitymap     = 'rampup';  
        cfg.projmethod     = 'nearest'; 
        cfg.surffile       = 'surface_l4_both.mat'; % evtl. ändern
        cfg.surfdownsample = 10; % evtl. ändern
        ft_sourceplot(cfg, sourceDiff_Int_Alpha_Norm_cm);
        view ([180 0])

        figure
        cfg = [];
        cfg.method        = 'slice';
        cfg.funparameter  = 'avg.pow';
        cfg.maskparameter = cfg.funparameter;
        cfg.funcolorlim   = [-1.2 1.2];
        cfg.opacitylim    = [-1.2 1.2]; 
        cfg.opacitymap    = 'rampup';  
        ft_sourceplot(cfg, sourceDiff_Int_Alpha_Norm);

end
