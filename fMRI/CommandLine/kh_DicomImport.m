
function ForAllPat
    
    PatientFolder = 'L:\kirsten_thesis\data\patients\'
    PatientList = dir( PatientFolder );
      
    for i = 1 : size (PatientList)
        if ( 0 == strcmp( PatientList(i,1).name, '.') && 0 == strcmp( PatientList(i,1).name, '..') && 0 == strcmp( PatientList(i,1).name, 'Pat_09_13031ck') && 0 == strcmp( PatientList(i,1).name, 'Pat_09_13031ck'))
            ReadDicoms( strcat(PatientFolder, PatientList(i,1).name), PatientList(i,1).name  );
        end
    end
end

function ReadDicoms (PatientPath, PatientName)


       
    Path.RawData = strcat(PatientPath,'\', 'fMRI\', 'RawData');
    Path.Nifti_Fluency = strcat (PatientPath, '\', 'fMRI\nifti\Fluency\')
    Path.Nifti_VG = strcat (PatientPath, '\', 'fMRI\nifti\Verbgeneration\')
    
    % if files already exist, return
  
      if 2 < length(dir(Path.Nifti_VG)) && 2 < length(dir(Path.Nifti_Fluency)) % if nifti files exist in VG and Fluency dir, then don't do anything
            return
       
   
      elseif 2 < length(dir(Path.Nifti_VG)) && 2 == length(dir(Path.Nifti_Fluency))  % if nifti files exist only for VG, then import dicoms for Fluency
          
                    DicomImportFluency(Path, PatientPath, PatientName) 
            
      elseif 2 == length(dir(Path.Nifti_VG)) && 2 < length(dir(Path.Nifti_Fluency)) % if nifti files exist only for Flueny, then import dicoms for VG
          
                    DicomImportVG(Path, PatientPath, PatientName)
                    
      elseif 2 == length(dir(Path.Nifti_VG)) && 2 == length(dir(Path.Nifti_Fluency)) % import both if folders are empty
          
                    DicomImportFluency(Path, PatientPath, PatientName) 
                    DicomImportVG(Path, PatientPath, PatientName)
      
                        
      end   
end 


      
function DicomImportFluency(Path, PatientPath, PatientName) 

    DirRawData = dir(Path.RawData)
    
    
    % Fluency:

    
    DirFluency = DirRawData(4,1).name
    Path.RawData_Fluency = strcat(Path.RawData, '\', DirFluency,'\');
    
    
      if 2 == length(dir(Path.RawData_Fluency)) 
            return
      end  
    
    cd (strcat(Path.RawData, '\', DirFluency));
      
    files = spm_select('List', Path.RawData_Fluency, 'R.*') ;
    hdr = spm_dicom_headers(files) ;
    spm_dicom_convert(hdr, 'all','flat' ,'nii') ;

    movefile(strcat (Path.RawData_Fluency, 'f*.nii') ,strcat (PatientPath, '\', 'fMRI\nifti\Fluency\'))   ; 



end
    
  

function DicomImportVG(Path, PatientPath, PatientName)

    % Folder with Verbgeneration dicoms:
    
    DirRawData = dir(Path.RawData) ;
    DirVerbgen = DirRawData(3,1).name ;
    Path.RawData_VG = strcat(Path.RawData, '\', DirVerbgen,'\');
    
     if 2 == length(dir(Path.RawData_VG)) 
            return
     end  

    cd (strcat(Path.RawData, '\', DirVerbgen)); 
    
    fprintf('reading files from %s \n', PatientName);
    
    files = spm_select('List', Path.RawData_VG, 'R.*') ;
    hdr = spm_dicom_headers(files) ;
    spm_dicom_convert(hdr, 'all','flat' ,'nii') ;

    movefile( strcat(Path.RawData_VG, 'f*.nii') ,strcat (PatientPath, '\', 'fMRI\nifti\Verbgeneration\')); 


    
end
