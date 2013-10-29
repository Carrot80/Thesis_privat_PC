
function kh_alpha ()
%% Alpha: 
% wichtig: cfg.rawtrial= 'yes', um trials für sourcestatistics zu erhalten,
% evtl. auch cfg.keeptrials = 'yes'; siehe ft_sourcesanalysis

        cfg = [];
        cfg.method    = 'mtmfft';
        cfg.taper   = 'hanning';
        cfg.output    = 'powandcsd'; 
        cfg.tapsmofrq = 2;
        cfg.foilim    = [10 10];
        cfg.keeptrials = 'yes'
        cfg.rawtrial = 'yes'
        freqAll_8_12Hz_test = ft_freqanalysis(cfg, dataAll);
        save freqAll_8_12Hz freqAll_8_12Hz 

        cfg = [];
        cfg.method    = 'mtmfft';
        cfg.output    = 'powandcsd';
        cfg.tapsmofrq = 2;
        cfg.foilim    = [10 10];
        cfg.keeptrials = 'yes'
        cfg.rawtrial = 'yes'
        freqPre_8_12Hz = ft_freqanalysis(cfg, dataPre);
        save freqPre_8_12Hz freqPre_8_12Hz

        cfg = [];
        cfg.method    = 'mtmfft';
        cfg.output    = 'powandcsd';
        cfg.tapsmofrq = 2;
        cfg.foilim    = [10 10];
        cfg.keeptrials = 'yes'
        cfg.rawtrial = 'yes'
        freqPost_8_12Hz = ft_freqanalysis(cfg, dataPost);
        save freqPost_8_12Hz freqPost_8_12Hz

        % compute common spatial filter % hier kein cfg.rawtrials = 'yes'
        cfg              = [];
        cfg.method       = 'dics';
        cfg.frequency    = 10
        cfg.grid         = grid_resliced;
        cfg.vol          = vol_resliced;
        cfg.dics.projectnoise = 'yes';
        cfg.dics.lambda       = '5%';
        cfg.dics.keepfilter   = 'yes';
        cfg.dics.realfilter   = 'yes';

        sourceAll_Alpha = ft_sourceanalysis(cfg, freqAll_8_12Hz);
        save sourceAll_Alpha sourceAll_Alpha


        % By placing this pre-computed filter inside cfg.grid.filter, it can now be
        % applied to each condition separately:
        cfg.keeptrials = 'yes' % unklar, ob sinnvoll, da Speicherprobleme
        cfg.rawtrial = 'yes'
        cfg.grid.filter = sourceAll_Alpha.avg.filter;
        sourcePre_alpha  = ft_sourceanalysis(cfg, freqPre_8_12Hz );
        sourcePost_alpha = ft_sourceanalysis(cfg, freqPost_8_12Hz);

        save sourcePre_alpha sourcePre_alpha  % kann Variable nicht speichern, da zu groß
        save sourcePost_alpha sourcePost_alpha % kann Variable nicht speichern, da zu groß
        
        % evtl. einfacherer Weg, um Statistik zu erhalten: noch
        % ausprobieren
%         cfg=[]
%         cfg.method       = 'dics';
%         cfg.frequency    = 10
%         cfg.grid         = grid_resliced;
%         cfg.vol          = vol_resliced;
%         cfg.dics.projectnoise = 'yes';
%         cfg.dics.lambda       = '5%';
%         cfg.dics.keepfilter   = 'yes';
%         cfg.dics.realfilter   = 'yes';
%         cfg.permutation = 'yes'
%         cfg.numpermutation = 'all'
%         [source] = ft_sourceanalysis(cfg, freqPre_8_12Hz, freqPost_8_12Hz)

        % compute the contrast of (post-pre)/pre. In this operation we ...
        % assume that the noise bias is the same for the pre- and post-stimulus ...
        % interval and it will thus be removed

        sourceDiff_Alpha = sourcePost_alpha;
        sourceDiff_Alpha.avg.pow = (sourcePost_con.avg.pow - sourcePre_con.avg.pow) ./ sourcePre_con.avg.pow;

        %  interpolate the source to the MRI
        cfg            = [];
        cfg.downsample = 1;
        cfg.parameter  = 'avg.pow';
        sourceDiff_Int_Alpha  = ft_sourceinterpolate(cfg, sourceDiff_Alpha , mri_realign_resliced);

        save sourceDiff_Int_Alpha sourceDiff_Int_Alpha


        % Now plot the power ratios: 
        figure
        cfg = [];
        cfg.method        = 'ortho';
        cfg.interactive   = 'yes';
        cfg.funparameter  = 'avg.pow';
        cfg.maskparameter = cfg.funparameter;
        cfg.funcolorlim   = [-1.2 1.2];
        cfg.opacitylim    = [-1.2 1.2];  
        cfg.opacitymap    = 'rampup';  
        ft_sourceplot(cfg, sourceDiff_Int_Alpha);
        % Ergebnis: Alpha-Aktivierung über rechten Sensoren



        figure
        cfg = [];
        cfg.method        = 'slice';
        cfg.funparameter  = 'avg.pow';
        cfg.maskparameter = cfg.funparameter;
        cfg.funcolorlim   = [-1.2 1.2];
        cfg.opacitylim    = [-1.2 1.2]; 
        cfg.opacitymap    = 'rampup';  
        ft_sourceplot(cfg, sourceDiff_Int_Alpha);

        % Normalisiere source:
        cfg = [];
        cfg.coordsys      = 'SPM';
        cfg.nonlinear     = 'no';
        sourceDiff_Int_Alpha_Norm = ft_volumenormalise(cfg, sourceDiff_Int_Alpha);


        % Darstellung auf Oberfläche: funktioniert nicht

        [sourceDiff_Int_Alpha_Norm_cm] = ft_convert_units(sourceDiff_Int_Alpha_Norm, 'cm')
        figure
        cfg = [];
        cfg.method         = 'surface';
        cfg.funparameter   = 'avg.pow';
        cfg.maskparameter  = cfg.funparameter;
        cfg.funcolorlim    = [-0.5 0]; % evtl. ändern
        cfg.funcolormap    = 'jet';
        cfg.opacitylim     = [-0.5 0]; % evtl. ändern
        cfg.opacitymap     = 'rampup';  
        cfg.projmethod     = 'nearest'; 
        cfg.surffile       = 'surface_l4_both.mat'; % evtl. ändern
        cfg.surfdownsample = 10; % evtl. ändern
        ft_sourceplot(cfg, sourceDiff_Int_Alpha_Norm_cm);
        view ([180 0])

        figure
        cfg = [];
        cfg.method        = 'slice';
        cfg.funparameter  = 'avg.pow';
        cfg.maskparameter = cfg.funparameter;
        cfg.funcolorlim   = [-1.2 1.2];
        cfg.opacitylim    = [-1.2 1.2]; 
        cfg.opacitymap    = 'rampup';  
        ft_sourceplot(cfg, sourceDiff_Int_Alpha_Norm);

end
