%% Find Strongest Years of Climate Index
% For each climate index, check the 5 strongest years in both the positive and negative phase.

function [yrs5CI_pos,yrs5CI_neg,no_overlap,YRSov,yrsTG,iCI] = find_strongest_yrs_CI_NTR(names,YRSCI,first12, last12, Ann_Avg_nan2, NTR10, time10)

%%%%%%%%%%%%% Inputs:

%               names = names of TG sites (for looping)
%  The following inputs are obtained from outputs of the function pre_process_indexNTR.m:
%               first12 = first 12 months containing data (of each TG site)
%               last12 = last 12 months containing data (of each TG site)
%               Ann_Avg_nan2 = structure of the Climate Index values during the years w >= 10 months of TG data 
%                                   *(dropped years with >2 nan of TG data)
%                                   **(this is before dropping yrs that don't overlap w CI & TG)
%               YRSCI = structure for the yrs of the Climate Index associated with "Ann_Avg_nan2" for each TG
%               data10 = timeseries data (TIME,MSL) after removing the yrs w <10 months 

%%%%%%%%%%%%% Outputs:

%               yrs5CI_pos = 5 strongest years of the Climate Index's positive phase
%               yrs5CI_neg =                                          negative
%               no_overlap = tide gauges where the Climate Index data & [input] data do not overlap records


% Pre-allocate index for beginning and end of time
beg = zeros([length(names) 1]); % what time we begin to check
fin = zeros([length(names) 1]); % what time we stop checking

no_overlap = [];

% For each tide gauge, take the Annual Maximum during the allotted time period
% bc we are comparing against the CLIMATE INDEX Annual Value
for tg = 1:length(names) % for each tg

    yrsTG.(names{tg}) = unique(year(time10{tg})); % list of yrs for each TG
    
    % Calculate the length of overlapping years
    % Find index in Climate TS 
    [iCI{tg}, loc_CI{tg}] = ismember(yrsTG.(names{tg}), YRSCI.(names{tg})); % find index in CLIMATE INDEX TS
% end

    % If TG and Climate Index overlap for less than 30 years
    if sum(iCI{tg}) < 30    
        no_overlap = cat(1,no_overlap,tg);
        pos5years(tg, 1:5) = NaN(1,5);
        neg5yrs(tg, 1:5) = NaN(1,5);
    else
%     end
        % Only consider the overlapping years
        YRSov.(names{tg}) = YRSCI.(names{tg})(loc_CI{tg}(find(iCI{tg} == 1))); % time: yrs overlapping
        Ann_Avg_ov.(names{tg}) = Ann_Avg_nan2.(names{tg})(loc_CI{tg}(find(iCI{tg} == 1))); % data: CI Ann Avg during overlapping yrs excluding yrs w >2 Nans of TG data
        
%     end
% end
        % Set index to begin & end scanning Climate Mode for the top 5
        % Begin scanning at first yr where TG and CI overlap    
        if first12(tg) <= YRSCI.(names{tg})(1); % If tg starts earlier than climate index record,
            beg(tg) = 1;              % Begin at 1st yr of climate index record
        else        % If TG starts after the 1st yr of climate index record
            beg(tg) = find(YRSov.(names{tg}) == first12(tg)); % begin at the 1st yr of tg record where it overlaps w CI 
%             a{tg} = find(YRSov.(names{tg}) >= first12(tg)); % begin at the 1st yr of tg record
%             beg(tg) = a{tg}(1);                             % the first yr above the 1st yr (incase the )
        end
        % Finish scanning CI until the last yr of TG [input] record
        fin(tg) = find(YRSov.(names{tg}) == last12(tg));
        
%         if last12(tg) == 2021; % the downloaded TG data ends in 2021
%             fin(tg) = find(YRSov.(names{tg}) == 2021);   % Finish checking until this time period
%         else                   % If the TG record ends before 2021...
%             b{tg} = find(YRSov.(names{tg}) == last12(tg)); % Finish scanning climate index until the last yr of TG [NTR] record
%             fin(tg) = b{tg}(1);
   
        % For each tide gauge, take the top 5 Annual Maximum of the Climate Index
        % during the allotted time period (time of TG MSL record)

        [nPos(tg,1:5), iNp(tg,1:5)] = maxk(Ann_Avg_ov.(names{tg})(beg(tg):fin(tg)),5); % This index is based off the shortened TS...
        % Align the index properly (iNp refers to the shortened section of the TS)
        yrs_tg = YRSov.(names{tg})(beg(tg):fin(tg));
        pos5years(tg, 1:5) = yrs_tg(iNp(tg,:));

        %% Also find Negative Phase years (by taking minimum)
        [nNeg(tg,1:5), iNneg(tg,1:5)] = mink(Ann_Avg_ov.(names{tg})(beg(tg):fin(tg)),5);
        % Align index properly
        neg5yrs(tg,1:5) = yrs_tg(iNneg(tg,:));

    end

        % Sort the years in ascending order
        yrs5CI_pos = sort(pos5years, 2); % sort along 2nd dimension (rows)
        yrs5CI_neg = sort(neg5yrs,2);
end

