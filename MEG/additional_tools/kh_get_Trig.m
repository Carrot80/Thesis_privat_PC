function [trl] = kh_get_Trig(cfg)

% m-file ms_trialfun_trig von Margit, etwas verändert:

% Input:
% cfg.dataset='c,rfhp0.1Hz';
% cfg.channel = 'TRIGGER';
cfg.trialdef.eventtype  = 'TRIGGER'
cfg.trialdef.eventvalue = 4224
cfg.trialdef.prestim    = 1.0
cfg.trialdef.poststim   = 1.5

% read trigger/response channel from data

cfg_raw         = [];
cfg_raw.dataset = cfg.dataset;
cfg_raw.channel = cfg.trialdef.eventtype;
data_raw = ft_preprocessing(cfg_raw);

% get important variables

nSamp_pre = round(data_raw.hdr.Fs * cfg.trialdef.prestim);
nSamp_pst = round(data_raw.hdr.Fs * cfg.trialdef.poststim);

% Output
% ------
% trl - [nTrials x 3] matrix
%   1st column: sample of trial-begin
%   2nd column: sample of trial-end
%   3rd column: offset between trigger and trial-begin in samples (sample trial - sample trigger)

trg = bitand(data_raw.trial{1}, cfg.trialdef.eventvalue);
trg_samp = find(diff(trg) == cfg.trialdef.eventvalue) + 1;
nTrl = length(trg_samp);
trl = zeros(nTrl, 3);

for t = 1:nTrl
    trl(t,1) = trg_samp(t)-nSamp_pre;
    trl(t,2) = trg_samp(t)+nSamp_pst;
    trl(t,3) = nSamp_pre.*(-1);
end

% ----------------------------------------------------------------------
% erstelle Variable "trl", die 3 Spalten enthält: prästimulusintervall,
% triggeronset und poststimulusintervall

%trl_test=zeros([length(triggers), 3]);
%trl_test(:,1)=triggers(1,:)-nSamp_pre
%trl_test(:,2)=triggers+nSamp_pst
%trl_test(:,3)=nSamp_pre.*(-1)




