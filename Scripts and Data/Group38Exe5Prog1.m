% Data analysis 2021 - Koniotakis Emmanouil 8616

% Investigate whether we can predict daily deaths based on the daily cases
% on a country's first wave, using simple linear regression models.
% Consider y(t) the daily new deaths on day t and x(t-time_d) the daily 
% cases from which the daily deaths are predicted. 
% 1) Test gof for the different values of time_d and find the value for which
% which the model performs best.
% 2) Perform a diagnostic test for every value of time_d.

clear all

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Use same country set as in Exercise 4
test_country = {'Czechia', 'France', 'Greece', 'Germany', 'Austria', 'Switzerland'};

% Number of countries
num = length(test_country);

% Initialize min RMSE and standard deviation of error vector for the gof 
% test and time delay for min RMSE vector
minRMSE = zeros(num,1);
% min_e_std = zeros(l1, num);
mintd = zeros(num,1);

% Find time delay that gives maximum cross correlation between cases and
% deaths.
for i=1:num
% Get country row
[row,~] = find(strcmp(cases(:,'Country').Variables, test_country{i}) == 1);

% Get country data as vectors skipping the first 3 columns that contain
% the country, the continent and the population. Thus, we know that the
% days begin from column 4 and end at column 351.    
temp_cases = (cases(row,4:end).Variables)';
temp_deaths = (deaths(row,4:end).Variables)';

% Fix data problems based on country
[temp_cases, temp_deaths, ~] = Group38Exe2Fun2(temp_cases, temp_deaths, test_country{i}, 0);

% Data cleanup
[temp_cases, temp_deaths] = Group38Exe1Fun1(temp_cases, temp_deaths);

% Find first wave for deaths
wave_num = 1;
[temp_deaths, first_day_deaths, last_day_deaths] = Group38Exe1Fun2(temp_deaths, wave_num);
wave_deaths = temp_deaths(1:(last_day_deaths - first_day_deaths + 1));

% Length of first wave for deaths.
l1 = length(wave_deaths);

% In the case of finding the first wave for cases, given the problem 
% description, we will consider x(t) the wave of cases and y(t+time_d) the
% wave of deaths. Thus we need to find the normal first day of the start
% of the death wave, to find the first non zero death case. For negative 
% values of time_d that go before the first death, we will simply create
% the death wave using zero padding, since we know that the deaths prior
% to the first death, will be by definition 0. Since we are researching the
% first wave, there is no restriction when having positive time_d values 
% beyond the normal end of the first wave in deaths.
[~, first_day_cases, ~] = Group38Exe1Fun2(temp_cases, wave_num);

% Time delay values
time_d = -20:1:0;

% Afterwards for every possible value of time delay we are testing, we
% will create a displaced death wave, that has the same length as the 
% case wave using the first_day_deaths are the start of the death wave
% for time delay = 0.
% Initialize RMSE and error vectors
RMSE = zeros(length(time_d),1);
std_e = zeros(length(time_d),l1);

% Find difference in days between normal first day of cases and normal
% first day of deaths. Obviously, first_day_deaths > first_day_cases.
dif = first_day_deaths - first_day_cases;

% Get RMSE for the various time delays
for j = 1:length(time_d)
    delay = time_d(j);
    dif2 = dif - abs(delay);
    if dif2 < 0
    wave_cases = [zeros(abs(dif2), 1); temp_cases(first_day_cases:(last_day_deaths - dif - abs(dif2)))];
    else
        % dif2 >= 0 
        wave_cases = temp_cases((first_day_deaths - abs(delay)):(last_day_deaths - abs(delay)));
    end
% Create simple linear regression model and return RMSE and std_e.    
[RMSE(j), std_e(j,:)] = Group38Exe5Fun1(wave_cases, wave_deaths);    
end

% Get min RMSE achieved and standar deviation of error for diagnostic plot
[minRMSE(i), I] = min(RMSE);
min_std_e = std_e(I,:);
% Get time delay value for which it was achieved
mintd(i) = time_d(I);

% Print diagnostic plot
Group38Exe5Fun2(wave_deaths, min_std_e, test_country{i})

% Print results
fprintf('Country: %s, Min RMSE: %2.2f, Best time delay: %d days, Time delay range tested: [%d, %d] (in days)\n', test_country{i}, minRMSE(i), mintd(i), time_d(1), time_d(end))
end

%% Remarks
% 1) Reviewing the diagnostic plots we can see that most countries show
% similar adaptation patterns. More specifically, we can see that for low
% values in deaths the standard error starts with negative values and rises 
% as the deaths rise. Also, we can see that there seems to be smaller errors
% at the start when max(death value) rises, as shown in cases of
% Switzerland, France and Germany. This is probably due to the fact that
% the data in these countries are of much higher quality, since the 
% pandemic 'revealed' itself more accurately there. 

% 2) Continuing from (1), there are some outliers on all graphs, as 
% well as a non stable variance in the standard errors.

% 3) Continuing from (1) and (2) and from the Exercises we can conclude that
% the quality of the data is affecting the results we are receiving, since
% there seems to be a linear relation between daily cases and daily deaths
% with some time delay.

% 4) Continuing from (3), the linear model used shows promise in regards
% to predicting the daily deaths from the daily cases, but further tests
% must be performed.

% 5) As expected the results are almost identical to those of Exe4, which
% had the opposite wave used for displacement and that's why they have 
% opposite values when sign is concerned, but almost identical absolute
% values. This is to be expected, since both approaches utilize the
% covariance of the data, which is not done in the approach of Exe3, for 
% which we can say with even more certainty now that it is clearly worse.
