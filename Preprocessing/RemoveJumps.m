  %% Jumps in data:
    % It is very important to remove all jump and muscle artifacts before running your ICA, 
    % otherwise they may change the results you get. To remove artifacts on the example dataset, use:
    % jump:
    
  function RemoveJumps (Path, Data)
  
    FileDataNoJumps    = strcat (Path.Preprocessing, '\', Data, '_', 'nojumps', '.mat') ;
    
    if exist (FileDataNoJumps, 'file')
        return
    end
    
    PathData = strcat (Path.Preprocessing, '\', Data, '.mat') ;
    
    DataFile = load (PathData)
    DataFile = DataFile.(Data)
    
    fileName  = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    HeartBeatCleaned = strcat( Path.Preprocessing, 'hb_n_c,rfhp0.1Hz') ;

    if exist('hb_n_c,rfhp0.1Hz', 'file')
       fileName = HeartBeatCleaned
    end
    
  
    % channel selection, cutoff and padding:
    cfg_jump.trl        = DataFile.cfg.trl;
    cfg_jump.datafile   = fileName;
    cfg_jump.headerfile = fileName;
    cfg_jump.continuous = 'yes'; 
    cfg_jump.artfctdef.zvalue.channel    = 'MEG';
    cfg_jump.artfctdef.zvalue.cutoff     = 20;
    cfg_jump.artfctdef.zvalue.trlpadding = 0;
    cfg_jump.artfctdef.zvalue.artpadding = 0;
    cfg_jump.artfctdef.zvalue.fltpadding = 0;
 
    % algorithmic parameters
    cfg_jump.artfctdef.zvalue.cumulative    = 'yes';
    cfg_jump.artfctdef.zvalue.medianfilter  = 'yes';
    cfg_jump.artfctdef.zvalue.medianfiltord = 9 ;
    cfg_jump.artfctdef.zvalue.absdiff       = 'yes';
 
    % make the process interactive
    cfg_jump.artfctdef.zvalue.interactive = 'no';
 
    [cfg_jump_output, artifact_jump]      = ft_artifact_zvalue(cfg_jump);
    
    PathJumps                             = strcat (Path.Preprocessing, '\', 'Jumps_RawData') ;
    save (PathJumps, 'artifact_jump', 'cfg_jump_output') ;
    
    cfg_jump                         = [] ; 
    cfg_jump.artfctdef.reject        = 'partial'; %  'complete', use 'partial' if you want to do partial artifact rejection
    cfg_jump.artfctdef.jump.artifact = artifact_jump ;
    %cfg.artfctdef.muscle.artifact = artifact_muscle;
    Data_NoJumps = ft_rejectartifact(cfg_jump, DataFile) ;
    
    save (FileDataNoJumps, 'Data_NoJumps') ;
    
  end