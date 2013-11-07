function CheckDataQuality_BIU (Path)

% plot the mean MEG:

    fileName        = strcat ( Path.DataInput, '\',  'n_c,rfhp0.1Hz')  ;
    p               = pdf4D(fileName) ;
    chi             = channel_index( p, 'meg' ) ;
    data            = read_data_block( p, [], chi ) ;
    samplingRate    = get( p,'dr' ) ;
    tMEG            = ( 0:size(data,2)-1 )/samplingRate ;
    h = figure('visible','off'); 
    plot(tMEG,mean(data))
    PathPlot        = strcat(Path.Preprocessing, '\', 'MeanMEG') ;
    NameTitle       = strcat ('Mean MEG', {' '}, '-', {' '}, PatientName)
    title (NameTitle) ;
    print('-dpng', PathPlot) ;
    
    %    CleanMEG_BIU (fileName) % Funktion funktioniert noch nicht
    
    
    %   Calculate the power spectrum of original data
    [data1PSD, freq] = allSpectra(data, samplingRate, 1, 'FFT');
    h = figure('visible','off'); 
    plot (freq(1,1:120),data1PSD(1,1:120),'r')
    xlabel ('Frequency Hz');
    ylabel('SQRT(PSD), T/sqrt(Hz)');
    title('Mean PSD for A245');
    PathPlot2        = strcat(Path.Preprocessing, '\', 'PowerSpectrum') ;
    saveas(h, PathPlot2, 'fig')
    print('-dpng', PathPlot2) ;

    cfg         = [] ;
    cfg.dataset = fileName ;
    ft_qualitycheck(cfg) ;
    PathPlot3        = strcat(Path.Preprocessing, '\', 'QualityCheck') ;
    print('-dpng', PathPlot3) ;
    
end