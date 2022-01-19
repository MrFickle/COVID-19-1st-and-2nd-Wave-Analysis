% Data analysis 2021 - Koniotakis Emmanouil 8616
clear all

% In this exercise, we will choose manually 11 European countries and
% perform the gof test using RMSE values on each country
% with the best distribution for cases and the best distribution for 
% deaths, as found in exercise 1. Afterwards, we are going to sort the
% performance based on the countries. For the above demands we will be 
% using functions that were built for the 1st exercise.

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Choose countries
test_country = {'Greece', 'France', 'Italy', 'Spain', 'Germany', 'Sweden',...
    'United_Kingdom', 'Belgium', 'Austria', 'Switzerland', 'Czechia'};

% Get total number of possible cases and deaths
n = width(cases)-3;
% Get total number of countries
m = length(test_country);
% Initialize cases vector for every country. Each column represents a
% country.
test_cases = zeros(n, m);
% Initialize deaths vector for each country. Each column represents a
% country.
test_deaths = zeros(n, m);

% Initialize continent cell and population vector
test_continent = cell(1,m);
test_pop = zeros(m,1);

% Initialize RMSE values for each continent
total_RMSE_cases = zeros(m,1);
total_RMSE_deaths = zeros(m,1);

% Initialize mean values to normalize RMSE
mu_cases = zeros(m,1);
mu_deaths = zeros(m,1);

% Initialize normalized RMSE with mean 
norm_RMSE_cases = zeros(m,1);
norm_RMSE_deaths = zeros(m,1);


% Get country row and then get cases and deaths
for i=1:m
    [row,~] = find(strcmp(cases(:,'Country').Variables, test_country{i}) == 1);
    test_cases(:,i) = (cases(row,4:end).Variables)';
    test_deaths(:,i) = (deaths(row,4:end).Variables)';
    
    % Fix data inaccuracies for smoother testing
    [temp_cases, temp_deaths] = Group38Exe2Fun2(test_cases(:,i), test_deaths(:,i), test_country{i}, 0);
    
    temp = cases(row,2).Variables;
    test_continent{i} = temp{1};
    test_pop(i) = cases(row,3).Variables;
    
    % Plot the histograms for cases and deaths on every country
    % Print country's name, continent and population
    fprintf('Continent: %s \nCountry: %s \nPopulation: %d \n',test_continent{i}, test_country{i}, test_pop(i))
    
    % Cleanup data
    [temp_cases, temp_deaths] = Group38Exe1Fun1(temp_cases, temp_deaths);
    
    % Histogram params
    dif = width(cases) - length(temp_cases);
    days = 1:length(temp_cases);
    first_day = cases(row,days(1)+3+dif).Properties.VariableNames;
    final_day = cases(row,days(end)+dif).Properties.VariableNames;    
   
    % Find first wave for new cases
    wave_num = 1;
    [wave_cases, first_day_cases, last_day_cases] = Group38Exe1Fun2(temp_cases, wave_num);
    % Find first wave for new deaths
    [wave_deaths, first_day_deaths, last_day_deaths] = Group38Exe1Fun2(temp_deaths, wave_num);
    
    % Define best distributions for cases and deaths
    dist_cases = {'Loglogistic'};
    dist_deaths = {'Lognormal'};

    % Perform gof for cases
    [~, total_RMSE_cases(i)] = Group38Exe1Fun3(wave_cases(1:(last_day_cases - first_day_cases + 1),1), 'Cases', dist_cases, test_country{i});
    
    % Perform gof for deaths
    [~, total_RMSE_deaths(i)] = Group38Exe1Fun3(wave_deaths(1:(last_day_deaths - first_day_deaths + 1),1), 'Deaths', dist_deaths, test_country{i});
    
    % Get mean
    mu_cases(i) = mean(wave_cases);
    mu_deaths(i) = mean(wave_deaths);
    
    % Get normalized RMSE using mean
    norm_RMSE_cases(i) = total_RMSE_cases(i)/mu_cases(i);
    norm_RMSE_deaths(i) = total_RMSE_deaths(i)/mu_deaths(i);
end

% Print countries in descending order in terms of performing better
% in the gof tests using the RMSE/mean values using different
% distributions for cases and deaths. 
Group38Exe2Fun1([], norm_RMSE_cases, [], norm_RMSE_deaths, test_country, dist_cases, dist_deaths)

%% Remarks
% 1) The best parametric distribution used for cases and deaths that was
% found in Exe1 seems to adapt better to most countries than the original
% country it was tested on. Specifically, Czechia, which was the country
% used in Exe1, ranks at 10/11 on cases and at 9/11 on deaths in terms
% of performance compared to the other countries used.

% 2) The metric for performance, meaning the gof test, was chosen to be
% RMSE/mean for simplicity. Other approaches could firstly include
% normalization of cases and deaths in the range of [0,1] and calculating
% the RMSE there for every country and then compare the values.

% 3) Continuing from (2), we see that in the terms of daily cases, the 
% RMSE/mean values are in the range[0.47, 2.17], with the top 3 countries
% scoring in the range [0.47, 0.99]. Thus, we can easily say that the 
% distribution chosen performs rather well on the daily cases, which can
% also be confirmed visually by the corresponding graphs.

% 4) Continuing from (3), we see that in the terms of daily deaths, the 
% RMSE/mean values are in the range[0.41, 2.66], with the top 3 countries
% scoring in the range [0.41, 0.52]. Thus, we can easily say that the 
% distribution chosen performs rather well on the daily cases, which can
% also be confirmed visually by the corresponding graphs.

% 5) Combining (2) and (3), we can see that in terms of distribution
% adaptation compared to the daily cases, the daily deaths are better at 
% the top performance countries but deteriorate as we go to the worst
% performance countries.

% 6) With regards to (5), as obvious as it is, the adaptation performance
% heavily depends on the quality of the data used. Thus, the performance
% could be improved by various methods, like the following:
% a) Improving the data values used for every country seperately, either 
% manually or by using better algorithms for cleaning, normalizing and 
% replacing values, etc, than the one built here.

% b) Improving the algorithm built that finds the waves for better accuracy, 
% or creating the waves manually for each country.
