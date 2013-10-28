
function template_mri()
    template_mri    = ft_read_mri('C:\Kirsten\Programme\Fieldtrip\fieldtrip-20131021\external\spm8\templates\T1.nii');
    
    PathTemplateMRI = strcat ('C:\Kirsten\DatenDoktorarbeit\Alle\TemplateMRI', '\', 'template_mri');
    save (PathTemplateMRI, 'template_mri');
    
end