function create_templateGrid () 

% evtl. realignment und reslicing mit template mri machen? 
% NOTE: the path to the template file is user-specific
template = ft_read_mri('C:\Kirsten\Programme\Fieldtrip\fieldtrip-20130929\external\spm8\templates/T1.nii');
template.coordsys = 'spm'; % so that FieldTrip knows how to interpret the coordinate system

% segment the template brain and construct a volume conduction model (i.e. head model): this is needed
% for the inside/outside detection of voxels.
cfg          = [];
template_seg = ft_volumesegment(cfg, template);

PathTemplateGrid = strcat ('C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_seg', '.mat');
save (PathTemplateGrid, 'template_seg')
 
cfg          = [];
cfg.method   = 'singleshell';
template_vol = ft_prepare_headmodel(cfg, template_seg);
template_vol = ft_convert_units(template_vol, 'cm'); % Convert the vol to cm, since the grid will also be expressed in cm

PathTemplateGrid = strcat ('C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_vol', '.mat');
save (PathTemplateGrid, 'template_vol')

% construct the dipole grid in the template brain coordinates
% the source units are in cm
% the negative inwardshift means an outward shift of the brain surface for inside/outside detection
cfg = [];
cfg.grid.xgrid  = -20:1:20; % 1=1cm = Grid resolution
cfg.grid.ygrid  = -20:1:20; % 1=1cm = Grid resolution
cfg.grid.zgrid  = -20:1:20; % 1=1cm = Grid resolution
% cfg.grid.resolution = 0.6;
cfg.grid.unit   = 'cm';
cfg.grid.tight  = 'yes';

cfg.inwardshift = -1.5;
cfg.vol        = template_vol;
template_grid  = ft_prepare_sourcemodel(cfg);
 
PathTemplateGrid = strcat ('C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\', 'template_grid', '.mat');
save (PathTemplateGrid, 'template_grid')

% make a figure with the template head model and dipole grid
figure
hold on
ft_plot_vol(template_vol, 'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
ft_plot_mesh(template_grid.pos(template_grid.inside,:));
plot_mesh = strcat('C:\Kirsten\DatenDoktorarbeit\Alle\TemplateGrid', '\','template_vol_mesh');
print( '-dpng', plot_mesh);

end
