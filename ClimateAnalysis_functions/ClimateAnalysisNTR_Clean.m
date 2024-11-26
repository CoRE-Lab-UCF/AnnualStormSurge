% Clean version of Climate Index Analysis for NTR data

clear; close all; clc

% For each climate index, check the 5 strongest years of both its positive and negative phase.
% Apply the Harmonic analysis to the NTR monthly 99th percentile during these years
% Compare the output: amplitude value in (+) positive phase of Climate Index and in (-) negative phase of Climate Index

% Not all TGs have data during the strongest years of a climate index...
% Align time of Climate Index w TG time frame

%% Load Data
% Change Data to corresponding NTR metric


%% Load Climate Index 
% Input: Climate Index Annual Average
% ClimInd = ;
%%%%%%%%%%%%%%%%%%%%%%%%%%  ENSO 3
% load n3_Ann_Avg
% load ENSO3yrs
%%%%%%%%%%%%%%%%%%%%%%%%%%% NAO
% load NAOdata
% load NAO_Ann_Avg
%%%%%%%%%%%%%%%%%%%%%%%%%%% AMO
% load AMOdata
% load AMO_Ann_Avg
%%%%%%%%%%%%%%%%%%%%%%%%%%% PDO
% load PDOdata
% load PDO_Ann_Avg

%%%%%%%%%%%%%%%%%%%%%%%%%% SAM
load SAMannavg
load SAMyrs

%% Change these inputs accordingly (metric, CI)
% Clarify Variable Names for Function
inputData = NTRmetric;     % Non-tidal residual (monthly 99th percentile for this study)
inputTime = t_monthly580'; % Corresponding monthly time vector 

Ann_Avg_CI = SAMannavg;    % Annual Average of Climate Index
yrsCI = SAMyrs;            % Years of Climate Index

%% Pre-processing
% Align Time to TG record
[first12,last12,YRSCI,Ann_Avg_nan2,time10,NTR10] = pre_process_index_NTR(names, inputData, inputTime, yrsCI, Ann_Avg_CI); % names: list of TG sites

%% Find Strongest Years of Climate Index
[yrs5CI_pos, yrs5CI_neg, no_overlap, YRSov, yrsTG,iCI] = find_strongest_yrs_CI_NTR(names,YRSCI,first12, last12, Ann_Avg_nan2, NTR10, time10);

% Remove NaNs
yrs5CI_pos(no_overlap,:)     = [];
yrs5CI_neg(no_overlap,:) = [];
% Remove TGs that don't overlap timeframes
time10(no_overlap) = [];
NTR10 = rmfield(NTR10,names(no_overlap));

%% Subset NTR during Climate Index 5 Strongest Yrs
% (Positive Phase of Climate Index)
% Save for each TG
NTR5_CI = [];
names = fieldnames(NTR10); % Update names list after eliminating TGs

for tg = 1: size(yrs5CI_pos,1) % through tide gauges

    NTR_y = [];

    % top 5 Climate Index years for each tg 
    year_tg = yrs5CI_pos(tg,:);

    a = year(time10{tg}); % all years with >10 data months/yr

    for ii = 1: length(year_tg)      % For each of the 5 strongest years 

        fa = find(a== year_tg(ii));
        % format time for function
        dvtime = datevec(time10{tg});
        TIMEdec = dvtime(:,1) + (dvtime(:,2)/12) - 1/24;
        NTR_y = cat(1,NTR_y,[TIMEdec(fa), NTR10.(names{tg})(fa)]); % concatenate the results as a timeseries

    end

    NTR5_CI.(names{tg}) = NTR_y;

end

%% Run Harmonic Analysis on Climate Index (Pos Phase)
% Create Time Vector
% The harmonic needs a time vector. The 5 strongest years are not truly chronological so just
% use some 5-year period for the timestep to reference
% Let's use the first 5 years
TIME = TIMEdec(1:5*12);  % keep in mind this time doesn't matter 
Window = 5

for i = 1:length(names); 
    x = NTR5_CI.(names{i})(:,2); % NTR Values during the 5 strongest yrs of input Climate Index  
    
    %Window = 5;
    [res_CI] = NTR_GetMovingWindow_Monthly(x,TIME,Window);  % Moving Harmonic Analysis Using OLS 
    res_MSL_CIpos.(names{i}) = res_CI;                      % save results to a struct  
end

%% Negative Phase of Climate Index
clear year_tg
clear fa
NTR5_CIneg = [];

for tg = 1: size(yrs5CI_neg,1) % through tide gauges

    NTR_yneg = [];

    % top 5 Climate Index years for each tg 
    year_tg = yrs5CI_neg(tg,:);

    a = year(time10{tg}); % all years with >10 data months/yr

    for ii = 1: length(year_tg);      % For each of the 5 strongest years 

        fa = find(a== year_tg(ii));
        % format time for function
        dvtime = datevec(time10{tg});
        TIMEdec = dvtime(:,1) + (dvtime(:,2)/12) - 1/24;
        NTR_yneg = cat(1,NTR_yneg,[TIMEdec(fa), NTR10.(names{tg})(fa)]); % concatenate the results as a timeseries

    end

    NTR5_CIneg.(names{tg}) = NTR_yneg;

end

%% Run Harmonic Analysis on Climate Index (Neg Phase)
clear res_CI
% Create Time Vector
TIME = TIMEdec(1:5*12);  % keep in mind this time doesn't matter 

for i = 1:length(names); 
    x = NTR5_CIneg.(names{i})(:,2); % NTR Values during the 5 strongest yrs of input Climate Index  
    
    Window = 5;
    [res_CI] = NTR_GetMovingWindow_Monthly(x,TIME,Window);  % Moving Harmonic Analysis
    res_MSL_CIneg.(names{i}) = res_CI;                     % save results to a struct  
end

%% Compute diff b/t + & - phase of Climate Index
for k = 1:length(names)
    CI_diff(k) =  res_MSL_CIpos.(names{k}).AmpPha(3) - res_MSL_CIneg.(names{k}).AmpPha(3);
    CI_norm_diff(k) = CI_diff(k)/ (nanmean(normby.(names{k}).AmpPha(:,3))); % normalize the difference by the TG's mean amplitude
end

%% Significance of amp diff
% Compute the significance of the amplitude difference during the Positive Phase vs. the Negative Phase
% Check if the standard error bars overlap

amp5_pos = zeros([3, length(names)]); % Pre-allocate for CI amp, & Standard Errors
amp5_neg = nan([3,length(names)]); 

for tg = 1:length(names)
    amp5_pos(1:3 , tg) = [res_MSL_CIpos.(names{tg}).AmpPha(3); 
                             res_MSL_CIpos.(names{tg}).AmpPha(3) + res_MSL_CIpos.(names{tg}).Monthly(end,8);
                             res_MSL_CIpos.(names{tg}).AmpPha(3) - res_MSL_CIpos.(names{tg}).Monthly(end,8);] ;

    amp5_neg(1:3 , tg) = [res_MSL_CIneg.(names{tg}).AmpPha(3); 
                             res_MSL_CIneg.(names{tg}).AmpPha(3) + res_MSL_CIneg.(names{tg}).Monthly(end,8);
                             res_MSL_CIneg.(names{tg}).AmpPha(3) - res_MSL_CIneg.(names{tg}).Monthly(end,8);] ;

    if amp5_pos(1,tg) > amp5_neg(1, tg) % If El Niño amp > La Niña amp
        sig(tg) = amp5_pos(3,tg) > amp5_neg(2,tg); % Compare the bottom errorbar of El Niño to the top errorbar of La Niña
    else 
        sig(tg) = amp5_neg(3,tg) > amp5_pos(2,tg); 
     
    end
end
sum(sig ==1); % how many are significant.. 


