
function kh_FreqAnalysis (ConfigFile, Data, Path)

% evtl. noch Abbildungen erstellen

   % make frequency directory if not exists yet:
    DirFreqName = strcat (Path.FreqAnalysis, '\', ConfigFile.name);
    [state] = mkdirIfNecessary( DirFreqName );


    % Check, if data is already avaliable
     FileName = strcat(DirFreqName, '\', 'FreqAnalysis', '_', ConfigFile.string, '.mat');
         
        if exist( FileName, 'file' )
            return;
        end

% load files:
     
     FileData            = strcat ( Path.DataTimeOfInterest, '\', Data, '.mat' );
     load ( FileData );

     % Calculating FFT and cross spectral density matrix:
  
     cfgFreq            = []                    ;
     cfgFreq.method     = ConfigFile.method     ;
     cfgFreq.output     = ConfigFile.output     ; 
     cfgFreq.taper      = ConfigFile.taper      ;
     cfgFreq.tapsmofrq  = ConfigFile.tapsmofrq  ;   % braucht man erst ab 30 Hz
     cfgFreq.foilim     = ConfigFile.foilim     ;
     cfgFreq.rawtrial   = 'yes';
     cfgFreq.keeptrials = 'yes';
         
        % if tapsmofrq is empty: remove field
     if isempty( cfgFreq.tapsmofrq) == 1 ;
         cfgFreq = rmfield(cfgFreq, 'tapsmofrq') ;
     end
     
      % if taper is empty: remove field
     if isempty( cfgFreq.taper) == 1 ;
         cfgFreq = rmfield(cfgFreq, 'taper') ;
     end   
     
       % if taper is empty: remove field
     if isempty( cfgFreq.foilim) == 1 ;
         cfgFreq = rmfield(cfgFreq, 'foilim') ;
     end   
        
     FreqAll            = ft_freqanalysis( cfgFreq, Data.DataAll );
     FreqPre            = ft_freqanalysis( cfgFreq, Data.DataPre );
     FreqPost           = ft_freqanalysis( cfgFreq, Data.DataPst );
       
     FreqAnalysis = struct ('FreqAll', FreqAll, 'FreqPre', FreqPre, 'FreqPost', FreqPost)
     
     ResultFreqAnalysis      = strcat( DirFreqName, '\', 'FreqAnalysis', '_', ConfigFile.string, '.mat' );
     save( ResultFreqAnalysis, 'FreqAnalysis' );
     
end