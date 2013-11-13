%% Interpolation of Source to match template mri dimension

function kh_Interpolation(ConfigFile, SourceFileName, TemplateMRI, Path)

  % make frequency directory if not exists yet:
    DirFreqName = strcat (Path.Interpolation, '\', ConfigFile.name);
    [state] = mkdirIfNecessary( DirFreqName );
    
    % Check, if data is already avaliable
     IntFileName = strcat(DirFreqName, '\', SourceFileName, '_', ConfigFile.string, '_int.mat');
         
        if exist( IntFileName, 'file' )
            return;
        end
                
        fprintf('starting with interpolation of %s freqency band \n', ConfigFile.name);
        str = strcat (SourceFileName, '_', ConfigFile.string, '.mat');
        fprintf('loading %s ...\n', str );

 % load Data
 
    SourceFile = strcat( Path.SourceAnalysis, '\', ConfigFile.name, '\', SourceFileName, '_', ConfigFile.string, '.mat');
    source_trials = load( SourceFile );
    source_trials = source_trials.(SourceFileName);
    
   load( strcat( Path.TemplateMRI, '\', TemplateMRI, '.mat'));
     

   %% set config for interpolation
    
    cfg_i            = [];  
    cfg_i.parameter  = 'trial.pow';
    cfg_i.downsample = 1;  % evtl. besser downsamplen

    % create trials variable for loop
    trials.trial = struct('pow',cell(1,length(source_trials.trial)));
    
    for i=1:length(source_trials.trial)
        source_trials_int           = [];
        source_trials.trial(1,1)    = source_trials.trial(1,i);
        source_trials_int           = ft_sourceinterpolate(cfg_i, source_trials, template_mri);
        trials.trial(1,i).pow       = source_trials_int.trial.pow;
    end
          
    source_trials_int.trial         = trials.trial;
    
    fprintf('saving %s ...\n', strcat (SourceFileName, '_', ConfigFile.string, '_int', '.mat') );
    save( IntFileName, 'source_trials_int' );



end
