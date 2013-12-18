

function ForAllPat ()
    
    PatientFolder = 'C:\Kirsten\DatenDoktorarbeit\Patienten\'
    PatientList = dir( PatientFolder );
    VolunteerFolder = 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\';
    VolunteerList = dir( VolunteerFolder );
    
    for i = 1 : size (VolunteerList)
        if ( 0 == strcmp( VolunteerList(i,1).name, '.') && 0 == strcmp( VolunteerList(i,1).name, '..'))
            Main_Preprocessing ( strcat(VolunteerFolder, VolunteerList(i,1).name), VolunteerList(i,1).name  ) ;
        end
    end
end

%%

function [Path, PatientName] = Main_Preprocessing  ( PatientPath, PatientName)

 % Reject all other but zzz_sc_Strobl
        if ( 0 == strcmp (PatientPath, 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\zzz_ka_Kellermann'))
            return;
        end
        
        Path                     = [];
        Path.DataInput           = strcat ( PatientPath, '\MEG\01_Input_noise_reduced')                 ;
        Path.Preprocessing       = strcat ( PatientPath, '\MEG\02_PreProcessing')                       ;   
  
        CheckDataQuality_BIU (Path, PatientName)  
        TrialDefinition (Path, PatientName)
        RejectArtifacts (Path, 'Data1_95Hz')
end
  

function RejectArtifacts (Path, Data)

        RemoveJumps (Path, Data) 
        RejectBadTrials (Path, Data)       % hier weitermachen, siehe https://wiki.cimec.unitn.it/tiki-index.php?page=ArtifactRejection 
        kh_ComponentAnalysisFull (Path, Data)

%         ComponentAnalysisPart (Path, 'Data_bp1_95_nojumps_vis_rej')
        RejectComponent (Path, 'Comp_ica', 'data_pb1_95nojumps')



end

