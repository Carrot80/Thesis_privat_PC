
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
      
        [Config, PathExt] = SelectTimeWindowOfInterest(); % evtl. in FreqConfig integrieren
            
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
        kh_FreqAnalysis(FreqConfig.LowGamma, 'Data', Path)
        
        kh_SourceAnalysis (FreqConfig.Beta, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.Alpha, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.Theta, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.Gamma, 'Data', 'MRI_realignment', 'Volume', Path)
        kh_SourceAnalysis (FreqConfig.LowGamma, 'Data', 'MRI_realignment', 'Volume', Path)
         
        kh_Interpolation (FreqConfig.Beta, 'trial_sourcePre', 'template_mri', Path)
        kh_Interpolation (FreqConfig.Beta, 'trial_sourcePost', 'template_mri', Path)
        kh_Interpolation (FreqConfig.Alpha, 'trial_sourcePre', 'template_mri', Path)
        kh_Interpolation (FreqConfig.Alpha, 'trial_sourcePost', 'template_mri', Path)       
        kh_Interpolation (FreqConfig.Theta, 'trial_sourcePre', 'template_mri', Path)
        kh_Interpolation (FreqConfig.Theta, 'trial_sourcePost', 'template_mri', Path)    
        kh_Interpolation (FreqConfig.Gamma, 'trial_sourcePre', 'template_mri', Path)
        kh_Interpolation (FreqConfig.Gamma, 'trial_sourcePost', 'template_mri', Path)  
        kh_Interpolation (FreqConfig.LowGamma, 'trial_sourcePre', 'template_mri', Path)
        kh_Interpolation (FreqConfig.LowGamma, 'trial_sourcePost', 'template_mri', Path)  
        
         
        % statistics: erstellt automatisch Abbildungen, evtl. noch Info in
        % Configfile, ob er Abbildung erstellen soll oder nicht:
        
        kh_Statistics( FreqConfig.Beta, 'trial_sourcePre', 'trial_sourcePost', Path) 
        kh_Statistics( FreqConfig.Alpha, 'trial_sourcePre', 'trial_sourcePost', Path)
        kh_Statistics( FreqConfig.Theta, 'trial_sourcePre', 'trial_sourcePost', Path)
        kh_Statistics( FreqConfig.Gamma, 'trial_sourcePre', 'trial_sourcePost', Path)
        kh_Statistics( FreqConfig.LowGamma, 'trial_sourcePre', 'trial_sourcePost', Path)

        
        kh_LateralityIndex (FreqConfig.Beta, 'Stats_allRois_left', 'Stats_allRois_right', Path)
        kh_LateralityIndex (FreqConfig.Beta, 'Stats_Broca_left', 'Stats_Broca_right', Path)                    
        kh_LateralityIndex (FreqConfig.Beta, 'Stats_Wernicke_left', 'Stats_Wernicke_right', Path)        
        kh_LateralityIndex (FreqConfig.Beta, 'Stats_TemporalLobe_left', 'Stats_TemporalLobe_right', Path)
        kh_LateralityIndex (FreqConfig.Alpha, 'Stats_allRois_left', 'Stats_allRois_right', Path)
        kh_LateralityIndex (FreqConfig.Alpha, 'Stats_Broca_left', 'Stats_Broca_right', Path)                    
        kh_LateralityIndex (FreqConfig.Alpha, 'Stats_Wernicke_left', 'Stats_Wernicke_right', Path)        
        kh_LateralityIndex (FreqConfig.Alpha, 'Stats_TemporalLobe_left', 'Stats_TemporalLobe_right', Path)
        kh_LateralityIndex (FreqConfig.Theta, 'Stats_allRois_left', 'Stats_allRois_right', Path)
        kh_LateralityIndex (FreqConfig.Theta, 'Stats_Broca_left', 'Stats_Broca_right', Path)                    
        kh_LateralityIndex (FreqConfig.Theta, 'Stats_Wernicke_left', 'Stats_Wernicke_right', Path)        
        kh_LateralityIndex (FreqConfig.Theta, 'Stats_TemporalLobe_left', 'Stats_TemporalLobe_right', Path)
        kh_LateralityIndex (FreqConfig.Gamma, 'Stats_allRois_left', 'Stats_allRois_right', Path)
        kh_LateralityIndex (FreqConfig.Gamma, 'Stats_Broca_left', 'Stats_Broca_right', Path)                    
        kh_LateralityIndex (FreqConfig.Gamma, 'Stats_Wernicke_left', 'Stats_Wernicke_right', Path)        
        kh_LateralityIndex (FreqConfig.Gamma, 'Stats_TemporalLobe_left', 'Stats_TemporalLobe_right', Path)
        kh_LateralityIndex (FreqConfig.LowGamma, 'Stats_allRois_left', 'Stats_allRois_right', Path)
        kh_LateralityIndex (FreqConfig.LowGamma, 'Stats_Broca_left', 'Stats_Broca_right', Path)                    
        kh_LateralityIndex (FreqConfig.LowGamma, 'Stats_Wernicke_left', 'Stats_Wernicke_right', Path)        
        kh_LateralityIndex (FreqConfig.LowGamma, 'Stats_TemporalLobe_left', 'Stats_TemporalLobe_right', Path)

      
end

