%%
    function TrialDefinition (Path, PatientName)    
    
    FilePreProc = strcat (Path.Preprocessing, '\', 'Data1_95Hz.mat') ;
    
    if exist (FilePreProc, 'file')
        return
    end
    
    fileName  = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    HeartBeatCleaned = strcat( Path.Preprocessing, 'hb_n_c,rfhp0.1Hz') ;
    
    
    if exist('hb_n_c,rfhp0.1Hz', 'file')
       fileName = HeartBeatCleaned
    end
    
    % define trials:
    hdr                     = ft_read_header(fileName) ;
    cfg_preproc.dataset     = fileName ;
    cfg_preproc.channel     = 'MEG' ;
    [Data]                  = ft_definetrial(cfg_preproc) ;
    
    % preprocessing
    cfg_preproc.channel     = 'MEG' ;
    cfg_preproc.continuous  = 'yes' ;
    cfg_preproc.bpfilter    = 'yes' ;
    cfg_preproc.bpfreq      = [1 95] ;
    cfg_preproc.bsfilter    = 'yes' ;
    cfg_preproc.bsfreq      = [50 100] ;
    Data1_95Hz              = ft_preprocessing(Data) ;
    
    PathData = strcat (Path.Preprocessing, '\', 'Data1_95Hz') ;
    save (PathData, 'Data1_95Hz') ;
  

    end
    




