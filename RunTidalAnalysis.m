% Run Tidal Analysis on Sea Level Data to obtain NTR

%% Set Variables
% time
% slevel
% LAT

%% Interpolate to hourly resolution
dv = datevec(time); 
datesih = dv;
% transform minutes and seconds to ones
datesih(:,5:6) = zeros;
hd = datenum(datesih);

% unique values
hdu = unique(hd); % hourly dates unique
[timeu,uis]  = unique(time);
sl         = slevel(uis);    
sl_h        = interp1(datenum(timeu),sl,hdu);

%     hr_int = [hdu,sl_h];


%% De-trend water levels
% Take a 30-day moving average with 1-hour timestep
% remove that from the data

% Using movmean
% 30 days * 24 hours/day

mov30avg = movmean(sl_h, 30*24, 'omitnan'); % 1-hour time-step bc movmean calculates along neighboring elements
                                       % we already have hourly data so each timestep is 1 hour
DTsl = sl_h - mov30avg;  

time_hr = hdu;

%% Remove nans before running tidal analysis
% in order to have the same size for the input and output
ntest = find(isnan(DTsl); % check if it has nans
time_hr(isnan(DTsl)) = [];
DTsl(isnan(DTsl)) = [];


%% Tidal Analysis
% Save results as files
% Not in a matrix bc that takes up too much space.

cd 'C:\Users\am612589\OneDrive - University of Central Florida\DataCode_Inc\TidalResults'

clearvars -except time_hr DTsl LAT names

% load time_hr
% load DTsl
% load LAT

% Pre-allocate space and name headers
TidalResults = {};
TidalResults{1,1} = 'Time';
TidalResults{1,2} = 'DTsl';
TidalResults{1,3} = 'Water Level' ;
TidalResults{1,4} = 'Tidal Prediction';
TidalResults{1,5} = 'NTR' ;
TidalResults{1,6} = 'Complete Date Range';

tic 
[Pred, Coef, Theo_time, icomp_years, WL, uyears, tgGAPS] = tide_calculation_vgaps(time_hr,DTsl,LAT); 

%% Compute Surge by removing tides
NTR = WL- Pred;

% Save
TidalResults{2,1} = time_hr;
TidalResults{2,2} = DTsl;
TidalResults{2,3} = WL;
TidalResults{2,4} = Pred;
TidalResults{2,5} = NTR;

dv_time = datevec(time_hr); % ensuring to use the hrly time after removing nans
TIME = datetime(dv_time);

%% Generate dates to fill mos & years of date range
startDate = datetime(year(TIME(1)), 1, 1, 0,0,0); % Generate starting on first month of the 1st yr of available data,  
                                                 % set to 1st day of month (to have a complete month)

endDate = datetime(year(TIME(end)), 12, 31, 23, 0, 0); % End of full year: full month (12/31), full hours in day (0-23)

completeDateRange = (startDate:hours(1):endDate)';

TidalResults{2,6} = completeDateRange;
toc