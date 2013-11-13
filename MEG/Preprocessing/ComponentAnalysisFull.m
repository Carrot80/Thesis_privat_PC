
%% Component analysis:

function kh_ComponentAnalysisFull (Path, Data)

    FileCompICAFull = strcat (Path.Preprocessing, '\', 'comp_ica.mat') ;
    FileCompPCAFull = strcat (Path.Preprocessing, '\', 'comp_pca.mat') ;
    
    if exist (FileCompICAFull, 'file') && exist (FileCompPCAFull, 'file')
        
%         PlotPCA (Path, FileCompPCAFull)
%         PlotICA (Path, FileCompICAFull)

    return
        
    end

    FilePreProc = strcat (Path.Preprocessing, '\', Data) ;
    load (FilePreProc)

    
    %% downsample data , otherwise ICA decomposition will take too long
    
    cfg            = [] ;
    cfg.resamplefs = 300 ;
    cfg.detrend    = 'yes' ;
    data_resampled = ft_resampledata(cfg, Data) ;
 
   
    %% perform the component analysis (i.e., decompose the data)
    
    PerformICAFull (Path, data_resampled)
    PerformPCAFull (Path, data_resampled)
    

    
end
