

function ImageCheck  

    PatientFolder = 'L:\kirsten_thesis\data\patients\';
    PatientList = dir( PatientFolder );
    
    for i = 1 : size (PatientList)
        if ( 0 == strcmp( PatientList(i,1).name, '.') && 0 == strcmp( PatientList(i,1).name, '..') )
            PatientPath = strcat(PatientFolder, PatientList(i,1).name) ;
            PatientName = PatientList(i,1).name  ;
            
            kh_display_and_print_Fluency( PatientPath, PatientName  );
            kh_display_and_print_Verbgeneration( PatientPath, PatientName  );
            kh_display_and_print_MRI( PatientPath, PatientName  );
        end
    end
    
    PatientFolder = 'L:\kirsten_thesis\data\contols\';
    PatientList = dir( PatientFolder );
    
    for i = 1 : size (PatientList)
        if ( 0 == strcmp( PatientList(i,1).name, '.') && 0 == strcmp( PatientList(i,1).name, '..') )
            PatientPath = strcat(PatientFolder, PatientList(i,1).name) ;
            PatientName = PatientList(i,1).name  ;
            
            kh_display_and_print_Fluency( PatientPath, PatientName  );
            kh_display_and_print_Verbgeneration( PatientPath, PatientName  );
            kh_display_and_print_MRI( PatientPath, PatientName  );
        end
    end
    
end


  function kh_display_and_print_Fluency(PatientPath, PatientName)

    PathFluency     = strcat (PatientPath, '\fMRI\nifti\Fluency\') ; 
    DirFilesFluency = dir(fullfile(PathFluency, '*.nii')); 
    dir_files       = dir(fullfile(PathFluency,'*.nii' ));
    
    if exist (strcat(PathFluency, 'ImageCheck.ps'), 'file')
       return
    end
    
    for i= 1:length(dir_files)
        files{i} = dir_files(i).name
    end
    
    files = files'
       
    for i=1:length(files)
        f{i} = [ strcat(PathFluency) files{i,1}]
    end
    
    f=f'
    
    fileName = [PathFluency, 'ImageCheck']
    for i=1:10:numel(f)
        spm_check_registration(char(f{i:min(i+9,numel(f))}));
        spm_print(fileName);
    end
    
  

  end
  
  function kh_display_and_print_Verbgeneration( PatientPath, PatientName  )
  
   PathVG = strcat (PatientPath, '\fMRI\nifti\Verbgeneration\') ; 
    PathMRI = strcat (PatientPath, '\MRI\') ;
    DirPathVG = dir(fullfile(PathVG, '*.nii'));
    DirPathMRI = dir(fullfile(PathMRI, '*.nii'));  
  
  
  % hier weitermachen
  end
  
