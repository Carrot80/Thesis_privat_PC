%% zuerst HeartBeat bereinigen, überprüfen, dann filtern, dann jumps und muskeln bereinigen, dann ica, dann visuell

 fileName='C:\MEG\Daten\Kontrollen\Illek_Stefan\zzz_si\la_seMEG40\1INYC4~U\1\mitRauschreduktion\c,rfhp0.1Hz'
 % find clean periods with no high-frequency-noise:
    % finding good periods for every channels. based on fft run with a % window of 2s sliding in steps of 0.5s. 
    % gives for every channel collumns% of beginning and end times of clean periods.
    cleanPeriodsAllChans=findCleanPeriods(fileName);
    
    % deciding which time points are realy clean. strictest is when for a given% time point there 
    % is no bad channel. for this the third argument% (chanNumThr) has to be 1. the default is 20, 
    % that is if 20 channels or more are% noisy at a sertain a time point it is considered as bad.
    cleanPeriods=sumGoodPeriods(fileName,cleanPeriodsAllChans,[]);
    

% removing too short good periods, less than 5s long 
    notTooShort=find((cleanPeriods(2,:)-cleanPeriods(1,:))>=5);cleanPeriods=cleanPeriods(:,notTooShort);
    save cleanPeriods cleanPeriods
    for segi=1:size(cleanPeriods,2)    
        p=pdf4D(fileName);    
        cleanCoefs = createCleanFile(p, fileName,...        
            'byLF',512 ,'Method','Adaptive',...        
            'xClean',[4,5,6],...       
            'CleanPartOnly',[cleanPeriods(1,segi) cleanPeriods(2,segi)],...
            'outFile','temp2',...       
            'noQuestions',1,...        
            'byFFT',0,...        
            'HeartBeat',[],... % for automatic HB cleaning change 0 to [] 
             'maskTrigBits', 512);    
         if exist('temp1','file')        
             !rm temp1   
         end
         !mv temp2 temp1    
         fileName='temp1';    %close all    
         display(['done segment ',num2str(segi)]);
    end
    eval(['!mv temp1 per_',fileNameOrig]);
    p=pdf4D(fileNameOrig);
    hdr=get(p,'header');
    lat=[1 hdr.epoch_data{1,1}.pts_in_epoch];
    chi=channel_index(p,'MEG','name');
    orig=mean(read_data_block(p,lat,chi),1);
    p=pdf4D(['per_',fileNameOrig]);
    clean=mean(read_data_block(p,lat,chi),1);
    figure;plot(orig,'r');
    hold on;
    plot(clean,'g');
    title('AVERAGED CHANNELS')
    legend ('OLD','NEW')
    
    
    
    % clean Heartbeat:

    fileName='C:\MEG\Daten\Kontrollen\Illek_Stefan\zzz_si\la_seMEG40\1INYC4~U\1\mitRauschreduktion\c,rfhp0.1Hz'
    p = pdf4D(fileName);
    
    chi = channel_index(p, 'meg');
    data = read_data_block(p, [], chi);
    tMEG = (0:size(data,2)-1)/1017.25;
    figure(2)
    plot(tMEG,mean(data))
 
    cleanCoefs = createCleanFile(p, fileName,'byLF',0, 'HeartBeat',[]) % oder:
    cleanCoefs = createCleanFile(p, fileName,'byLF',0,'HeartBeat',[],'CleanPartOnly',[0 30]); % siehe clean periods

    save cleanCoefs cleanCoefs

     
    cleanpdf=pdf4D('hb_c,rfhp0.1Hz');
    data2=read_data_block(cleanpdf, [],chi);
    tMEGClean = (0:size(data2,2)-1)/1017.25;
    
    figure
    plot(tMEG,mean(data),'b')
    hold on
    plot(tMEGClean,mean(data2),'r')
   
    
    %   Calculate the power spectrum: (evtl. separat abspeichern)

        data = read_data_block(p, [], chi);
        [data1PSD, freq] = allSpectra(data,samplingRate,1,'FFT');
        [data2PSD, freq] = allSpectra(data2,samplingRate,1,'FFT');
        figure;plot (freq(1,1:120),data1PSD(1,1:120),'r')
        hold on;
        plot (freq(1,1:120),data2PSD(1,1:120),'b')
        xlabel ('Frequency Hz');
        ylabel('SQRT(PSD), T/sqrt(Hz)');
        title('Mean PSD for A245');

        cfg         = []
        cfg.dataset = 'hb_c,rfhp0.1Hz';
        ft_qualitycheck(cfg) 

