% Fit Harmonic Analysis to NTR percentile

% Load Data

% Time (monthly time vector)
load t_monthly_brest % monthly time vector of NTR percentiles in Brest
% Data (monthly percentile of NTR)
load plot_p99 % monthly 99th percentile of storm surge

%% Moving Window: 5 yrs
Window = 5

% Convert time format to fit tool
dv_time = datevec(t_monthly_brest);
TIME = dv_time(:,1) + (dv_time(:,2)/12) - 1/24; 
%        year     +       month    - day(24 hrs)

%% 99p
[TotalPreMSL] = GetMovingWindow_Monthly(plot_p99.brest_3_fra_refmar, TIME, Window); % Using OLS estimation
Result99pNTR = TotalPreMSL;