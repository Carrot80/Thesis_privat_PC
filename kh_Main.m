
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
      
        [Config, PathExt] = SelectTimeWindowOfInterest(); % evtl. hier oben FreqConfig integrieren, separat abspeichern
        
        
        
        % Reject all other patients but Illek
        if ( 0 == strcmp (PatientPath, 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\zzz_si_Illek'))
            return;
        end
        
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
        
        

        kh_RedefineTrials (Config, Path)       
        kh_VolumeSegment (PatientName, Path)
        kh_PrepHeadModell ('MRI_realignment', 'n_c,rfhp0.1Hz', 'Data', 'RemovedChannels', PatientName, Path)
        [FreqConfig] = MakeFreqConfig()
        kh_FreqAnalysis(FreqConfig.Beta, 'Data', Path)
        kh_FreqAnalysis(FreqConfig.Alpha, 'Data', Path)
        kh_FreqAnalysis(FreqConfig.Theta, 'Data', Path)
        kh_FreqAnalysis(FreqConfig.Gamma, 'Data', Path)
        
        kh_SourceAnalysis (FreqConfig.Beta, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.Alpha, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.Theta, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.Gamma, 'Data', 'MRI_realignment', 'Volume', Path)
         
        
        
        
%         kh_Interpolation (PathSourceAnalysis, 'trial_sourcePre_13_25Hz', PathTemplateMRI, 'template_mri')
%         kh_Interpolation (PathSourceAnalysis, 'trial_sourcePost_13_25Hz', PathTemplateMRI, 'template_mri')
%         kh_Statistics( PathSourceAnalysis,  'trial_sourcePre_13_25Hz_int', 'trial_sourcePost_13_25Hz_int', PathStatistics)
%         kh_PlotStatistics(PathStatistics, 'Stats_allRois_left', 'Stats_allRois_right', 'Stats_allRois_combined_hem', 'Stats_allRois_both_hem', 'Stats_NoROIs', PathMRI, 'mri_realign_resliced_norm')
%         [LI] = kh_LateralityIndex (PathStatistics, ResultStats_left, ResultStats_right, PathLI)

      
end

%% 

function [Config, PathExt] = SelectTimeWindowOfInterest()

    Config.Pre          = [];                                           
    Config.Pre.toilim   = [-0.5 0];
    Config.Post         = [];
    Config.Post.toilim  = [0.3 0.8]; 

    Config.TimeWindow_ms = [];
    Config.TimeWindow_ms = (Config.Post.toilim*1000);
    Config.TimeWindow_string =  strcat(num2str(Config.TimeWindow_ms(1)), '_', num2str(Config.TimeWindow_ms(2)), 'ms');

    % PathExt = strcat( '\', num2str( Config.TimeWindow_ms(1)), '_', num2str( Config.TimeWindow_ms(2)), 'ms'); 
    PathExt = Config.TimeWindow_string;

end


