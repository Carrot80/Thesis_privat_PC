 function RejectBadTrials (Path, data)
    
 % https://wiki.cimec.unitn.it/tiki-index.php?page=ArtifactRejection
 % Reject 4 noisiest trials
    
    PathDataNoJumps                  = strcat (Path.Preprocessing, '\', data, '_', 'nojumps', '.mat') ;
    load (PathDataNoJumps)
    
    %rejectvisual summary
    cfg         = [];
    cfg.method  = 'summary';
    cfg.channel = 'MEG';
    cfg.alim    = 1e-12;
    % reject all bad trials/channels manually :
    [Data_vis_rej,trlsel,chansel] = ft_rejectvisual(cfg, data);
    
    RemovedChannels = find (chansel == 0) ;
%     RemovedChannels = find (Data_bp1_95_nojumps_vis_rej.chansel == 0) ;
%     RemovedChannels_string = num2cell (RemovedChannels)
%     RemovedChannels_strcat = strcat ('A', RemovedChannels_string)
%     RemovedTrials = find (trlsel == 0 ) ;
    
%   RemovedChannels = num2cell( RemovedChannels) ;
    Data_bp1_95_nojumps_vis_rej.trlsel          = trlsel ;
    Data_bp1_95_nojumps_vis_rej.chansel         = chansel ;
    Data_bp1_95_nojumps_vis_rej.RemovedChannels = RemovedChannels ;
    Data_bp1_95_nojumps_vis_rej.RemovedTrials   = RemovedTrials ;

    PathData = strcat (Path.Preprocessing, '\', data , 'vis_rej') ;
    save (PathData, 'Data_vis_rej', 'trlsel', 'chansel')

    end
    