% Pre-process Climate Index (for NTR study)
% For each TG, drop yrs of Climate Index data where [NTR _ ] input data < 10 months

function [first12,last12,YRSCI,Ann_Avg_nan2,time10, NTR10] = pre_process_index_NTR(names, inputData, inputTime, yrsCI, Ann_Avg_CI)

%%%%%%%%%% Inputs:

%           inputData = Data (Water Level: NTR _, or MSL, etc.)
%           inputTime = Time vector corresponding with input data
%           yrsCI = Years of Climate Index
%           Ann_Avg_CI = Annual Average Climate Index
 
%%%%%%%%%% Outputs: 

%           first12 = first 12 months containing data 
%           last12 = last 12 months containing data
%           YRSCI = structure for the yrs of the Climate Index associated with each TG
%           Ann_Avg_nan2 = structure of the Climate Index values during the years w >= 10 months of data
%           data10 [time10, NTR10] = timeseries data (TIME,[NTR __]) after removing the yrs w <10 months 


% copy input data [NTR __ monthly metric] to drop years (& be able to access full data later)
for i = 1:length(names)

    %data10.(names{i}) = [inputTime{i}, inputData.(names{i})]; % copy [input] data to drop years (& be able to access full data later)
    time10{i} = inputTime{i}; 
    NTR10.(names{i}) = inputData.(names{i}); % simplify name of [input] variable

    years{i} = year(inputTime{i}); % Years of input TG data [NTR __]

    % Find where there are more than 2 NaN months per year
    u_yrs{i} = unique(years{i}); % For each tg, List the unique years
    for u = 1:numel(u_yrs{i})
        iyr = u_yrs{i}(u); % For each yr
        nan_count_per_year{i}(u) = sum(isnan(NTR10.(names{i})  (years{i} == u_yrs{i}(u)) )) ;      
    end

    fnan{i} = find(nan_count_per_year{i} > 2); % Find where num of NaNs exceed our threshold
    
    % change positions to years
    yrsXX{i} = u_yrs{i}(fnan{i});
    % Pre-allocate space for indexing
    fn_yrs = []; % index for the years we need to drop in TG data
    iDCyrs = []; % index in Climate index for the yrs we need to drop 
    for n = 1:length(fnan{i}) 
        % In the TG data, find the index of years we need to drop
        temp{i} = find(years{i} == yrsXX{i}(n)); % Find index for each year that has more than 2 NaNs
        fn_yrs = cat(1,fn_yrs,temp{i});          % Concatenate the indices for each tg and each yr 

        % In the climate index, find the index for the same (corresponding) yrs
        Ctemp{i} = find(yrsCI == yrsXX{i}(n));
        iDCyrs = cat(1, iDCyrs, Ctemp{i});

    end

    % Drop the years
     %data10.(names{i})(fn_yrs, :) = []; % Now this is the data (TIME,[NTR __} ) after removing the years w <10 months
     time10{i}(fn_yrs) = []; % time data after removing the years w <10 months
     NTR10.(names{i})(fn_yrs) = [];  % [NTR __] data after removing the years w <10 months
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% El Niño         
     YRSCI.(names{i}) = yrsCI; % Create a structure for the yrs of the Climate Index associated with each TG
     YRSCI.(names{i})(iDCyrs) = []; % Drop the necessary years
     Ann_Avg_nan2.(names{i}) = Ann_Avg_CI; % Create a structure for the Climate Index values during the years w >= 10 months of data
     Ann_Avg_nan2.(names{i})(iDCyrs) = [];  % Drop the same years we dropped 

    % Make sure the first/last years we use have the full 12 months
    u12{i} = unique(year(time10{i}(1:12))); % Check if first 12 months are in the same year
    L(i) = length(u12{i});           % # of yrs displayed in first 12 months
  
    if L(i) == 2                     % If the first 12 months occurs b/t 2 years... 
        first12(i) = u12{i}(2);      % Consider the 2nd year (with full months) to be the first where we scan for the climate Index 
    else
        first12(i) = u12{i};
    end

    ulast{i} = unique(year(time10{i}(end-12+1:end)));
    Llast(i) = length(ulast{i});
    
    last12(i) = ulast{i}(1);   % Consider the yr with full months to be the last year we check          
end


end
