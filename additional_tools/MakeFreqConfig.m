

function [FreqConfig] = MakeFreqConfig()

    FreqConfig                    = [];

    FreqConfig.Alpha.lower        = 8;
    FreqConfig.Alpha.upper        = 13;
    FreqConfig.Alpha.string       = '8_13Hz';
    FreqConfig.Alpha.name         = 'Alpha';
    FreqConfig.Alpha.foilim       = [8 13]; 
    FreqConfig.Alpha.tapsmofrq    = []; % braucht man erst ab 30 Hz
    FreqConfig.Alpha.frequency    = 10;
    FreqConfig.Alpha.method       = 'mtmfft'; %  i.e. 'mtmconvol' (multitaper)
    FreqConfig.Alpha.taper        = 'hanning'; %The option 'hanning' ensures that only one taper will be applied thereby not introducing an artificial frequency smoothing (which is sometimes desired).
    FreqConfig.Alpha.output       = 'powandcsd'; % 'pow'

    FreqConfig.Beta.lower         = 13;
    FreqConfig.Beta.upper         = 25;
    FreqConfig.Beta.string        = '13_25Hz';
    FreqConfig.Beta.name         = 'Beta';
    FreqConfig.Beta.foilim        = [13 25];
    FreqConfig.Beta.tapsmofrq     = [];  
    FreqConfig.Beta.frequency     = 19;
    FreqConfig.Beta.method       = 'mtmfft';
    FreqConfig.Beta.taper        = 'hanning'; 
    FreqConfig.Beta.output       = 'powandcsd'; 


    FreqConfig.Theta.lower         = 4;
    FreqConfig.Theta.upper         = 8;
    FreqConfig.Theta.string        = '4_8Hz';
    FreqConfig.Theta.name          = 'Theta';
    FreqConfig.Theta.foilim        = [4 8];
    FreqConfig.Theta.tapsmofrq     = [];  
    FreqConfig.Theta.frequency     = 6;
    FreqConfig.Theta.method       = 'mtmfft'; 
    FreqConfig.Theta.taper        = 'hanning';  
    FreqConfig.Theta.output       = 'powandcsd'; 

    FreqConfig.Gamma.lower         = 25;
    FreqConfig.Gamma.upper         = 45;
    FreqConfig.Gamma.string        = '25_45Hz';
    FreqConfig.Gamma.name          = 'Gamma';
%     FreqConfig.Gamma.foi           = 35;
    FreqConfig.Gamma.foilim        = [25 45];
    FreqConfig.Gamma.tapsmofrq     = [];  %
    FreqConfig.Gamma.frequency     = 35;
    FreqConfig.Gamma.method       = 'mtmfft'; 
    FreqConfig.Gamma.taper        = 'hanning';  
    FreqConfig.Gamma.output       = 'powandcsd'; 


end