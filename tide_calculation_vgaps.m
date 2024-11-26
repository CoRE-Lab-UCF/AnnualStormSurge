%% Calculating predicted tides

function [Pred, Coef, Theo_time, icomp_years, WL, uyears, tgGAPS]= tide_calculation_vgaps(time,sl,lat)

% remove nans at the beginning and end
fnan1   = find(isnan(sl)== 0,1,'first');
fnane   = find(isnan(sl)== 0,1,'last');
sl      = sl(fnan1:fnane,:);
time    = time(fnan1:fnane,:);

tg = [time, sl];

% on a yearly basis
dates   = datevec(time);
uyears  = unique(dates(:,1));

% Save results
Pred       = [];
Coef       = {};

icomp_years      = []; % years with less than 70% of data
Theo_time        = [];
WL               = [];
tgGAPS           = [];

for i= 1:length(uyears)
    
    %% Data completion 
    
    % find data within the i year
    iy  = find(dates(:,1)== uyears(i));
    
    if isempty(iy)== 1
        Coef{i} = nan;
        icomp_years  = cat(1,icomp_years,years(i));
        continue
    end
        
    % year including 369 days
    % time if year was complete
    yeariini = datenum([uyears(i) 1 1 0 0 0]);
    yearifin = yeariini + 369;
    
    comyear = yeariini: datenum([0 0 0 1 0 0]): yearifin;
        
    % Data within the i year (369 days)
    tgicomp = tg(iy,:);
    
    datef   = tg(iy(1),1)+369;
    f       = find(tg(:,1)<= datef,1,'last');
    tgi     = tg(iy(1):f,:);      
    
    %% Year completion
    
    ylength = length(comyear);
        
    tgi_no_nan = tgicomp;
    tgi_no_nan(isnan(tgi_no_nan(:,2)),:) = [];
    
    theo_timei = tgi_no_nan(:,1);
        
    wllength = size(tgi_no_nan,1);
    
    if (wllength/ylength)< .70 % if not enough data
        
        icomp_years  = cat(1,icomp_years,uyears(i));
        tgGAPS       = nan(size(tgicomp,1),1);
        Pred         = cat(1,Pred,tgGAPS);
        Theo_time    = cat(1,Theo_time,tgicomp(:,1));
        WL           = cat(1,WL,tgGAPS);
        
    else
        
        %% Short term constituents only
        coef      = ut_solv(tgi(:,1),tgi(:,2),[],lat,'auto','white',RunTimeDisp='nnn');
       
        %---Remove the seasonality from tides (we want to conserve seasonality)
        indx_SA=strcmp(coef.name,'SA');
        indx_SSA=strcmp(coef.name, 'SSA');

        coef.A(indx_SA)=0; coef.A(indx_SSA)=0; 
        coef.A_ci(indx_SA)=0; coef.A_ci(indx_SSA)=0; 
        coef.g(indx_SA)=0; coef.g(indx_SSA)=0; 
        coef.g_ci(indx_SA)=0; coef.g_ci(indx_SSA)=0; 

        [utide,~] = ut_reconstr(theo_timei,coef);
        
        Pred         = cat(1,Pred,utide);
        Theo_time    = cat(1,Theo_time,theo_timei);
        WL           = cat(1,WL,tgi_no_nan(:,2));
        Coef{i}      = coef;
        
                
    end
    
end




    

    
    














