% Compute monthly percentiles of NTR Data
% Create time vector to fill gaps in the GESLA data
% (GESLA data has gaps for example where it jumps from yr 1870 to 1885 without NaNs)

% Create time vector with all years (column 1) & all months (column 2)​

% Include start to end year, 12 months per year (despite data gaps)​
 
% Ex: 1846-2021: 175yrs * 12months = size 2100 (w NaNs where gaps)​

% Find position for each month of each year

% Ex: For year 1846 month 1, calculate percentile IF meets criteria​
 
%                                                 ELSE = NaN   


%% Key West Example
% Load Data

% Load NTR 
load NTR_kw
% Load Time
load time_kw

original_time = time_kw;
original_NTR = NTR_kw;

startDate = datetime(year(original_time(1)), 1, 1, 0,0,0); % Generate starting on first month of the 1st yr of available data,  
                                                           % set to 1st day of month (to have a complete month)

endDate = datetime(year(original_time(end)), 12, 31, 23,0,0); % End of full year: full month (12/31), full hours in day (0-23)

completeDateRange = (startDate:hours(1):endDate)';

completeData = table(completeDateRange, 'VariableNames', {'Date'});
data_table = table(original_time, original_NTR, 'VariableNames', {'Date', 'NTR'});
test_combine = outerjoin(completeData, data_table, 'Keys', 'Date');

% Plot to check if it works...
% original with NaNs inserted
figure(); plot(test_combine.Date_data_table, test_combine.NTR); 

figure(); plot(test_combine.Date_completeData, test_combine.NTR); 

%% Re-calculate percentile...
DatesAll = test_combine.Date_completeData;
dvAllDates = datevec(DatesAll);

yrsB = unique(year(DatesAll));
mos = unique(month(DatesAll));

Nyr = length(yrsB);

allNTR = table2array(test_combine(:,3)); % Column 3 is NTR

% For each year
for ii = 1:Nyr
    % Find positions for each year in our generated vector of dates
    V{ii} = find(dvAllDates(:,1) == yrsB(ii));   % V subsets data by one year
    
    % Subset Monthly
    % For each year, find the index of each month
    for M = 1:12
        m_ind{M, ii} = find(dvAllDates(V{ii},2) == mos(M)); % Month in rows, yrs in columns 
         
        %% Take percentiles 
        %  when >= 75% of data in a calendar month
        Ldata = length(allNTR(V{ii}(m_ind{M,ii}))); % length of data in month
        Lval = length(find(~isnan(allNTR(V{ii}(m_ind{M,ii}))))); % length of available values in month data
         
        lnan = length(find(isnan(allNTR(V{ii}(m_ind{M,ii}))))); % length of nans

        if Lval >= 0.75*Ldata          %  when >= 75% of data in a month
            p99(M,ii) = prctile(allNTR(V{ii}(m_ind{M,ii})), 99); 
        else         
            p99(M,ii) = NaN;
        end
    end
end
    
% Reshape percentile to plot 
plot_p99 = reshape(p99brest, [12*Nyr,1]);

%% Create monthly time vector to plot percentiles
t_monthly = (startDate + 15-1):calmonths(1):endDate; % center of month (15th day)













​