
% import and segment MRI 


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
