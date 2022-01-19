% Data analysis 2021 - Koniotakis Emmanouil 8616

% Estimate time delay between peak in cases and peak in deaths, considering
% that the peak in deaths comes after the peak in cases. 
% 1) Create a function that will estimate the peak in cases/deaths for the
% first wave for a specific country using the best distribution found in
% the previous exercises. The date of the peak must also be found.
% 2) Consider the same countries as used in exercise 2 and call the above
% function for each country, find the time delay between peaks of cases
% and deaths and calculate the 95% parametric and bootstrap confidence 
% interval for the mean(time delay) and check whether time delay = 14
% is feasible in that confidence interval.

clear all

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Choose countries
test_country = {'Greece', 'France', 'Italy', 'Spain', 'Germany', 'Sweden',...
     'United_Kingdom', 'Belgium', 'Austria', 'Switzerland', 'Czechia'};
% test_country = {'Greece', 'France', 'Italy', 'Spain', 'Germany',...
%     'United_Kingdom', 'Belgium', 'Austria', 'Switzerland', 'Czechia'}
% test_country = 'Czechia';

% Number of countries
num = length(test_country);

% Initialize time delay and peaks, peak dates, peak days for cases/deaths
time_d = zeros(num,1);
peak_value = zeros(num,2);
peak_date = cell(num,2);
peak_day = zeros(num,2);

% Get time delay for every country
for i=1:num
% Get country row
[row,~] = find(strcmp(cases(:,'Country').Variables, test_country{i}) == 1);

% Get country data as vectors skipping the first 3 columns that contain
% the country, the continent and the population. Thus, we know that the
% days begin from column 4 and end at column 351.    
temp_cases = (cases(row,4:end).Variables)';
temp_deaths = (deaths(row,4:end).Variables)';

% Initial length
l1 = length(temp_cases);

% Fix data problems based on country
[temp_cases, temp_deaths, l1] = Group38Exe2Fun2(temp_cases, temp_deaths, test_country{i}, l1);

% Remove empty cases before the start of the first wave and replace NaN
% values. We know that this function, chops the starting part of the 
% cases vectors. Thus, the difference in length between the two instances
% of temp_cases must be logged.
[temp_cases, temp_deaths] = Group38Exe1Fun1(temp_cases, temp_deaths);

% Second length
l2 = length(temp_cases);

% Difference in length
dif = l1 - l2;

% Now we are in the position to find the first wave, where we will use
% the dif value as a date offset for the peak.
% Find first wave for new cases
wave_num = 1;
[temp_cases, first_day_cases, last_day_cases] = Group38Exe1Fun2(temp_cases, wave_num);
% Find first wave for new deaths
[temp_deaths, first_day_deaths, last_day_deaths] = Group38Exe1Fun2(temp_deaths, wave_num);

% Offset for cases
dif_cases = dif + first_day_cases;
% Offset for deaths
dif_deaths = dif + first_day_deaths;

% Now we are in the position to create a pdf from the first wave.
wave_cases = temp_cases(1:(last_day_cases - first_day_cases + 1));
wave_deaths = temp_deaths(1:(last_day_deaths - first_day_deaths + 1));

% Get estimated peak value, peak day and peak date for cases.
dist_cases = 'Loglogistic';
[peak_value(i,1), peak_day(i,1), peak_date{i,1}] = Group38Exe3Fun1(wave_cases, dist_cases, cases(row,:), dif_cases);

% Get estimated peak value, peak day and peak date for deaths.
dist_deaths = 'Lognormal';
[peak_value(i,2), peak_day(i,2), peak_date{i,2}] = Group38Exe3Fun1(wave_deaths, dist_deaths, deaths(row,:), dif_deaths);

% Get time delay between peak in cases and deaths
time_d(i) = peak_day(i,2) - peak_day(i,1);
end

% Print time delay for every country in descending order
[~,I] = maxk(time_d,num);
fprintf('Time delay (in days) between peak in cases and deaths\n')
for i=1:num
   fprintf('%d) %s: %d \n', i, test_country{I(i)}, time_d(I(i))); 
end

% Find 95% parametric and bootstrap confidence interval for mean time delay  
% using the sample created above and also perform test hypothesis for 
% mean time delay = 14.
mean_test = 14;
alpha = 0.05;
[h,p,ci] = Group38Exe3Fun2(time_d, alpha, mean_test);

% 95% parametric confidence interval
fprintf('\nThe 95%s parametric confidence interval for the mean of the time delay between peak in cases and deaths is [%2.2f, %2.2f].\n','%', ci(1,1), ci(1,2))

% Parametric test hypothesis
fprintf('p-value (for H:mean = %2.2f) = %1.5f, thus the test hypothesis is rejected. \n',mean_test,p(1));

% 95% bootstrap confidence interval
fprintf('\nThe 95%s bootstrap confidence interval for the mean of the time delay between peak in cases and deaths is [%2.2f, %2.2f].\n','%', ci(2,1), ci(2,2))

% Bootstrap test hypothesis
fprintf('p-value (for H:mean = %2.2f) = %1.5f, thus the test hypothesis is rejected. \n',mean_test,p(2));


%% Remarks
% 1) The time delay of 14 days does not fall into either of the confidence 
% intervals, even when countries with only positive values were tested, as
% expected, since the highest positive value is 10 days.

% 2) As it can be seen from the results, some countries have negative
% values in time delays. This is due to the way the peaks are chosen 
% which throws off the algorithm when spikes occur.

% 3) For better results, the following methods could be used:
% a) Improving the data values used for every country seperately, either 
% manually or by using better algorithms for cleaning, normalizing and 
% replacing values, etc, than the one built here.
% b) Improving the algorithm built that finds the waves for better accuracy, 
% or creating the waves manually for each country.
% c) Choose different countries. Here Sweden and the United Kingdom display
% negative values.
% d) Using a different test for finding the peak, like the one used in
% Group38Exe1Fun2, which finds the waves, where the approach used was to
% find the peak in the moving mean of the day tested and its previous 4,
% thus using a 5-day moving mean as the values being tested for peaks. 
% This was used to resolve the issues created due to spikes. In addition,
% as implemented in Group38Exe1Fun2, in order for a local maxima to be
% considered a peak, another condition was used that required that local
% maxima to remain the highest local maxima for N consecutive days. 



