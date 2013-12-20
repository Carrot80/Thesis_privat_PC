
<<<<<<< HEAD

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
=======
function ImageCheckMain  

    PatientFolder = 'L:\kirsten_thesis\data\patients\';
    ControlsFolder = 'L:\kirsten_thesis\data\controls\'
    
    ImageCheck (PatientFolder)
    ImageCheck (ControlsFolder)
    
end

function ImageCheck (MainFolder)
    
    List = dir( MainFolder );
    
    
    for i = 1 : size (List)
        if ( 0 == strcmp( List(i,1).name, '.') && 0 == strcmp( List(i,1).name, '..') )
            SubjectPath = strcat(MainFolder, List(i,1).name) ;
            SubjectName = List(i,1).name  ;
            
            kh_display_and_print( SubjectPath, strcat (SubjectPath, '\fMRI\nifti\Fluency\')  );
            kh_display_and_print( SubjectPath, strcat (SubjectPath, '\fMRI\nifti\Verbgeneration\')  );
            kh_display_and_print( SubjectPath, strcat (SubjectPath, '\MRI\')  );
>>>>>>> fMRTDicomImport
        end
    end
    
end


<<<<<<< HEAD
  function kh_display_and_print_Fluency(PatientPath, PatientName)

    PathFluency     = strcat (PatientPath, '\fMRI\nifti\Fluency\') ; 
    DirFilesFluency = dir(fullfile(PathFluency, '*.nii')); 
    dir_files       = dir(fullfile(PathFluency,'*.nii' ));
    
    if exist (strcat(PathFluency, 'ImageCheck.ps'), 'file')
       return
    end
    
=======
  function kh_display_and_print(SubjectPath, TaskPath)

    DirFilesTask = dir(fullfile(TaskPath, '*.nii')); 
    dir_files       = dir(fullfile(TaskPath,'*.nii' ));
    
    if exist (strcat(TaskPath, 'ImageCheck.ps'), 'file')
       return
    end
    
    fprintf('printing to %s \n', TaskPath);
    
>>>>>>> fMRTDicomImport
    for i= 1:length(dir_files)
        files{i} = dir_files(i).name
    end
    
    files = files'
       
    for i=1:length(files)
<<<<<<< HEAD
        f{i} = [ strcat(PathFluency) files{i,1}]
=======
        f{i} = [ strcat(TaskPath) files{i,1}]
>>>>>>> fMRTDicomImport
    end
    
    f=f'
    
<<<<<<< HEAD
    fileName = [PathFluency, 'ImageCheck']
=======
    fileName = [TaskPath, 'ImageCheck']
>>>>>>> fMRTDicomImport
    for i=1:10:numel(f)
        spm_check_registration(char(f{i:min(i+9,numel(f))}));
        spm_print(fileName);
    end
    
<<<<<<< HEAD
  

  end
  
  function kh_display_and_print_Verbgeneration( PatientPath, PatientName  )
  
   PathVG = strcat (PatientPath, '\fMRI\nifti\Verbgeneration\') ; 
    PathMRI = strcat (PatientPath, '\MRI\') ;
    DirPathVG = dir(fullfile(PathVG, '*.nii'));
    DirPathMRI = dir(fullfile(PathMRI, '*.nii'));  
  
  
  % hier weitermachen
  end
  
=======
 end
  
>>>>>>> fMRTDicomImport
