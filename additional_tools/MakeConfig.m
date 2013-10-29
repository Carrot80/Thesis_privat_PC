% evtl. umbenennen in FrequencyConfig

function [Config] = MakeConfig()

    Config                              = [];

    Config.Frequency.Alpha.lower        = 8;
    Config.Frequency.Alpha.upper        = 13;
    Config.Frequency.Alpha.string       = '8_13Hz';
    Config.Frequency.Alpha.foilim       = [8 13]; 
    Config.Frequency.Alpha.tapsmofrq    = []; % braucht man erst ab 30 Hz
    Config.Frequency.Alpha.frequency    = 10;
    Config.Frequency.Alpha.method       = 'mtmfft'; %  i.e. 'mtmconvol' (multitaper)
    Config.Frequency.Alpha.taper        = 'hanning'; %The option 'hanning' ensures that only one taper will be applied thereby not introducing an artificial frequency smoothing (which is sometimes desired).
    Config.Frequency.Alpha.output       = 'powandcsd'; % 'pow'

    Config.Frequency.Beta.lower         = 13;
    Config.Frequency.Beta.upper         = 25;
    Config.Frequency.Beta.string        = '13_25Hz';
    Config.Frequency.Beta.foilim        = [13 25];
    Config.Frequency.Beta.tapsmofrq     = [];  
    Config.Frequency.Beta.frequency     = 19;
    Config.Frequency.Beta.method       = 'mtmfft';
    Config.Frequency.Beta.taper        = []; 
    Config.Frequency.Beta.output       = 'powandcsd'; 


    Config.Frequency.Theta.lower         = 4;
    Config.Frequency.Theta.upper         = 8;
    Config.Frequency.Theta.string        = '4_8Hz';
    Config.Frequency.Theta.foilim        = [4 8];
    Config.Frequency.Theta.tapsmofrq     = [];  
    Config.Frequency.Theta.frequency     = 6;
    Config.Frequency.Theta.method       = 'mtmfft'; 
    Config.Frequency.Theta.taper        = 'hanning';  
    Config.Frequency.Theta.output       = 'powandcsd'; 

    Config.Frequency.Gamma.lower         = 25;
    Config.Frequency.Gamma.upper         = 45;
    Config.Frequency.Gamma.string        = '25_45Hz';
    Config.Frequency.Gamma.foi           = 35;
    Config.Frequency.Gamma.tapsmofrq     = 10;  %
    Config.Frequency.Gamma.frequency     = 35;
    Config.Frequency.Gamma.method       = 'mtmfft'; 
    Config.Frequency.Gamma.taper        = [];  
    Config.Frequency.Gamma.output       = 'powandcsd'; 


end