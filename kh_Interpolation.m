%% Interpolation of Source to match template mri dimension

function kh_Interpolation(PathSourceAnalysis, SourceFileName, PathTemplateMRI, TemplateMRI)

 % load Data
    SourceFile = strcat( PathSourceAnalysis, '\', SourceFileName, '.mat');
    source_trials = load( SourceFile );
    source_trials = source_trials.(SourceFileName);
    
   load( strcat( PathTemplateMRI, '\', TemplateMRI, '.mat'));
     

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
    
    IntFileName                     = strcat( PathSourceAnalysis, '\', SourceFileName, '_int.mat');
    save( IntFileName, 'source_trials_int' );



end
