
function kh_FreqAnalysis (ConfigFile, Data, Path)

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
     
     FreqAll            = ft_freqanalysis( cfgFreq, Data.DataAll );
     FreqPre            = ft_freqanalysis( cfgFreq, Data.DataPre );
     FreqPost           = ft_freqanalysis( cfgFreq, Data.DataPst );
     
     
     FreqAnalysis = struct ('FreqAll', FreqAll, 'FreqPre', FreqPre, 'FreqPost', FreqPost)
     
     ResultFreqAnalysis      = strcat( PathFreqAnalysis, '\', 'FreqAnalysis', '_', ConfigFile.string, '.mat' );
     save( ResultFreqAnalysis, 'FreqAnalysis' );
     
end