%% Loop Simulations for all TGs (send)

% Create simulations shuffling the YEARS in the time vector randomly ~1000x,
%        (do not change order of months within the year. keep seasonality)
%                         fit the harmonic
%                         Compute Correlations
%                         Obtain range of correlation values based on the random data
%                         Compare to actual correlation value


clear 

addpath 'D:\OneDrive - University of Central Florida\DataCode_Inc'

% Load Input Data
load oTG_ResMSL    % MSL results for overlapping TGs (between datasets)
load Res99_OLS     % NTR: GESLA monthly 99th percentile of NTR (921 TGs)

% Load TG names
load OnamesMSL
load OnamesNTR

% Remove arrecife
OnamesMSL(20) = [];
OnamesNTR(20) = [];

Window = 5; % Window size for Harmonic Fit (years)

% Number of shuffles (simulations)
numShuffles = 50;
% For each tide gauge
tic
for tg = 1

    % Time vectors
    timeMSL{tg} = oTG_ResMSL.(OnamesMSL{tg}).TIME; % time of input: monthly MSL data  
    timeNTR99{tg} = Res99_OLS.(OnamesNTR{tg}).TIME; % time of input: NTR monthly 99th percentile
    
    %% Align time vectors
    [time_overlap{tg}, iMSL_ot{tg}, iNTR_ot{tg}] = intersect(timeMSL{tg}, timeNTR99{tg}); % overlapping time,  index in MSL that overlaps, time index in NTR that overlaps
    
    % Data vectors aligned in time
    NTR99_aligned{tg}  = Res99_OLS.(OnamesNTR{tg}).MSL(iNTR_ot{tg}); % .MSL actually means the input TS (NTR 99p monthly TS)
    
    % Extract year components
    time_vector{tg} = time_overlap{tg};
    years{tg} = fix(time_vector{tg});
    
    % Determine the unique years
    unique_years{tg} = unique(years{tg}); 
    
    % Find out the shortest length of TS we are correlating (after truncating the non-aligning years)
    % len_yrs(tg) = length(unique_years{tg})
    
    % Pre-allocate matrix for index of shuffled years
    ind{tg} = [];
    
    % Shuffle the unique years for n number of shuffles (simulations)
    for n = 1:numShuffles
        shuffled_years{tg}(:,n) = unique_years{tg}(randperm(length(unique_years{tg})));
    
        % Create index for each shuffled year
        for y = 1:length(unique_years{tg})
            ii = find(years{tg} == shuffled_years{tg}(y,n));
    
            ind{tg} = cat(1,ind{tg},ii);
        end
    end
    
    ri{tg} = reshape(ind{tg},[length(time_vector{tg}),numShuffles]);
    
    %% Fit Harmonic to each simulation
    for n = 1:numShuffles
        % Clarify variable names
        %shuffled_time_vectors{tg}(:,n) = time_vector{tg}(ri{tg}(:,n));
        shuffled_data_vector{tg}(:,n) = NTR99_aligned{tg}(ri{tg}(:,n));
    
        [ResSim_NTR99{n}] = GetMovingWindow_Monthly(shuffled_data_vector{tg}(:,n), time_vector{tg}, Window); % Using OLS
                            % In GetMovingWindow_Monthly.m code, comment out line 132 (to not caluclate ____.Monthly)
                           
        %ResSim_NTR99{n}.ShuffledTIME = shuffled_time_vectors{tg}(:,n); % show the shuffled time vector

        %save(['D:\OneDrive - University of Central Florida\DataCode_Inc\2_StormSurgeOLS\Res_Sim99\', OnamesMSL{tg} '.mat'], 'ResSim_NTR99');

        %save(['D:\TestSave\', OnamesMSL{tg} '.mat'], 'ResSim_NTR99');
        
        %save(['D:\Test2\', OnamesMSL{tg} '.mat'], 'ResSim_NTR99');
        
    end
%     clear NTR99_aligned 
%     clear shuffled_data_vector 
end
toc