
  function kh_display_and_print(PatientPath, PatientName)

    PathFluency = strcat (PatientPath, '\', '\fMRI\nifti\Fluency\') ; 
    PathVG = strcat (PatientPath, '\', '\fMRI\nifti\Verbgeneration\') ; 
    PathMRI = strcat (PatientPath, '\', '\MRI\') ;

    DirFilesFluency = dir(fullfile(PathFluency, '*.nii'));
    DirPathVG = dir(fullfile(PathVG, '*.nii'));
    DirPathMRI = dir(fullfile(PathMRI, '*.nii'));  

      
for i= 1:numel(DirFilesFluency)
    files{i,1} = DirFilesFluency(i,1).name ;
end  
    
%     for a = 1:10:numel(dir(fullfile(PathFluency, '*.nii')))
%         spm_check_registration(char(f{a:min(a+9,numel(f))}));
%         spm_print;
% 
%     end 
    
    for a = 1:10:numel(files)
        spm_check_registration(char(files{a:min(a+9,numel(files))})); % herausfinden, was f bedeutet
        spm_print;

    end 
      
  
  end
