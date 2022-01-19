% Data analysis 2021 - Koniotakis Emmanouil 8616

% We assume that the course of the wave is similar for the cases and
% deaths, but we expect that the death wave comes after the case wave.
% Thus, we want to find the time delay between the 2 waves that gives the
% maximum Pearson cross correlation coefficient corr(X,Y) = sxy/(sxsy),
% where X stands for the cases and Y for the deaths.



clear all

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Choose as countries the one used at Exe1 and 5 of which were used at
% Exe2 and 3.
test_country = {'Czechia', 'France', 'Greece', 'Germany', 'Austria', 'Switzerland'};

% Number of countries
num = length(test_country);

% Initialize max correlation vector and time delay for max correlation
% vector
maxcor = zeros(num,1);
maxtd = zeros(num,1);

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

% Initial length
% l1 = length(temp_cases);

% Fix data problems based on country
[temp_cases, temp_deaths, ~] = Group38Exe2Fun2(temp_cases, temp_deaths, test_country{i}, 0);

% Data cleanup
[temp_cases, temp_deaths] = Group38Exe1Fun1(temp_cases, temp_deaths);

% Find first wave for cases
wave_num = 1;
[temp_cases, first_day_cases, last_day_cases] = Group38Exe1Fun2(temp_cases, wave_num);
wave_cases = temp_cases(1:(last_day_cases - first_day_cases + 1));

% Length of first wave for cases.
l1 = length(wave_cases);

% In the case of finding the first wave for deaths, given the problem 
% description, we will consider x(t) the wave of cases and y(t+time_d) the
% wave of deaths. Thus we need to find the normal first day of the start
% of the death wave, to find the first non zero death case. For negative 
% values of time_d that go before the first death, we will simply create
% the death wave using zero padding, since we know that the deaths prior
% to the first death, will be by definition 0. Since we are researching the
% first wave, there is no restriction when having positive time_d values 
% beyond the normal end of the first wave in deaths.
[~, first_day_deaths, ~] = Group38Exe1Fun2(temp_deaths, wave_num);

% Time delay values
time_d = -20:1:20;

% Afterwards for every possible value of time delay we are testing, we
% will create a displaced death wave, that has the same length as the 
% case wave using the first_day_deaths are the start of the death wave
% for time delay = 0.
pearson = zeros(length(time_d),1);

% Get correlations for the various time delays
for j = 1:length(time_d)
   delay = time_d(j);
   if delay < 0
      wave_deaths = [zeros(abs(delay),1) ; temp_deaths(first_day_cases:(last_day_cases - abs(delay)))];
   else
      % delay >= 0
      wave_deaths = temp_deaths((first_day_cases + delay):(last_day_cases + delay));
   end
   % Find correlation
   pearson(j) = corr(wave_cases, wave_deaths);  
end

% Get max correlation achieved
[maxcor(i), I] = max(pearson);
% Get time delay value for which it was achieved
maxtd(i) = time_d(I);

% Print results
fprintf('Country: %s, Best correlation: %2.2f, Best time delay: %d days, Time delay range tested: [%d, %d] (in days)\n', test_country{i}, maxcor(i), maxtd(i), time_d(1), time_d(end))
end


%% Remarks
% 1) As it should be expected, the time delays here are all positive
% values, which is a logical result.

% 2) The best correlations achieved are in the range [0.51, 0.91].

% 3) The time delays for which best correlation was achieved, are in the
% range of [6, 13] days. 

% 4) This test's performance to find the time delay is clearly better than 
% the one used in Exe3, since: 
% a) It does not utilize a parametric approach, which was by no means 
% perfect with the data given as shown in Exe3. 
% b) It uses all the data given, instead of searching for a local maxima
% like in Exe3.

% 5) The difference between countries in time delays could be due to a 
% number of factors, such as:
% a) Bad quality data
% b) A practical issue: countries that were hit hard on the first wave 
% could have had problems problems with medical equipment availability
% and thus deaths appeared sooner that it would theoretically be expected.
% c) Another practical issue: bad testing protocols where new cases should 
% have been found sooner and thus resulting in shorter time delays. 


