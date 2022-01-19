% Data analysis 2021 - Koniotakis Emmanouil 8616

% Conclusions are at the bottom
% Group38Exe1Prog1 version 2, using more functions
clear all

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Get the continent column
continents = cases(:,'Continent');

% Starting parameters
AEM = 8616;
Group = 38;
country_num = rem(AEM, Group)+1;

% Check whether the country given in country_num is a European country. If
% not find the closest European country to use.
test_continent = continents(country_num,1).Variables;
if ~strcmp(test_continent,'Europe')
    num1 = country_num -1;
    num2 = country_num +1;
    not_found = 1;

    while not_found
        if ~strcmp(continents(num1,1).Variables,'Europe')
            num1 = num1 -1;
            if ~strcmp(continents(num2,1).Variables,'Europe')
                num2 = num2 +1;
                % The below test is being done because as we found in 
                % Group38Exe1Prog1.m the country in the 33rd row is Croatia
                % which is not a good candidate to survey the first wave
                % of Covid19 since it hasnt passed. Thus we want to avoid
                % this country from being picked.
                if num2 == 33
                    num2 = num2+1;
                end
            else
                country_num = num2;
                %test_continent = continents(country_num,1).Variables;
                not_found = 0;
            end
        else 
            country_num = num1;
            %test_continent = continents(num1,1).Variables;
            not_found = 0;
        end
    end    
end

% Since we found the country we are going to work with, keep the cases 
% and deaths only for this country from the initial dataset. The country
% we are going to work with is Croatia.
test_cases = cases(country_num,:);
test_deaths = deaths(country_num,:);

% Keep country, continent and population values
test_country = test_cases(1,1).Variables;
test_continent = test_cases(1,2).Variables;
test_pop = test_cases(1,3).Variables;

% Remove the first three columns to keep only cases and deaths
test_cases = (test_cases(1,4:end).Variables)';
test_deaths = (test_deaths(1,4:end).Variables)';

% Print country's name, continent and population
fprintf('Continent: %s \nCountry: %s \nPopulation: %d \n',test_continent{:}, test_country{:}, test_pop) 

% Cleanup data
[test_cases, test_deaths] = Group38Exe1Fun1(test_cases, test_deaths);

% Histogram params
dif = width(cases) - length(test_cases);
days = 1:length(test_cases);
first_day = cases(country_num,days(1)+3+dif).Properties.VariableNames;
final_day = cases(country_num,days(end)+dif).Properties.VariableNames;

% Plot the histogram of cases
figure()
bar(test_cases,sqrt(length(test_cases))/5)
title(sprintf('Daily New Cases of Covid19 in %s',test_country{:}));
ylabel("Number of Cases")
xlabel(sprintf("Day number\n (Start: %s - End: %s)",first_day{:}, final_day{:}));


% Plot the histogram of deaths
figure()
bar(test_deaths,sqrt(length(test_deaths))/5)
title(sprintf('Daily New Deaths of Covid19 in %s',test_country{:}));
ylabel("Number of Deaths")
xlabel(sprintf("Day number\n (Start: %s - End: %s)",first_day{:}, final_day{:}));

% Find first wave for new cases
wave_num = 2;
[wave_cases, first_day_cases, last_day_cases] = Group38Exe1Fun2(test_cases, wave_num);
% Find first wave for new deaths
[wave_deaths, first_day_deaths, last_day_deaths] = Group38Exe1Fun2(test_deaths, wave_num);

% Define distributions to perform gof test
% distribution = {'Normal', 'Exponential', 'Logistic', 'Poisson', ... 
%     'Rayleigh', 'Kernel','Loglogistic', 'Lognormal', 'Nakagami', 'Rician', ... 
%     'Stable', 'tLocationScale', 'Weibull'};

% After performing various test, the final verdict for the chosen 5
% distributions is below.
distribution = {'Nakagami', 'Weibull', 'Rician', 'Loglogistic', 'Lognormal'};

% Perform gof for cases
[p_cases, RMSE_cases] = Group38Exe1Fun3(wave_cases(1:(last_day_cases - first_day_cases + 1),1), 'Cases', distribution, test_country{1});

% Perform gof for deaths
[p_deaths, RMSE_deaths] = Group38Exe1Fun3(wave_deaths(1:(last_day_deaths - first_day_deaths + 1),1), 'Deaths', distribution, test_country{1});

% Sort gof of distributions on cases and deaths based on p-values and the
% RMSE values and print the results.
Group38Exe1Fun4(distribution, p_cases, RMSE_cases, p_deaths, RMSE_deaths);

%% Remarks 
% 1) The best gof test on the cases based on the p value is received using
% the parametric Nakagami distribution. It must be noted though that the 
% p-values are very low for every distribution tested, in a magnitude
% below 10^-55 and thus using a 95% confidence interval level, all
% distributions would be rejected since p << 0.05.

% 2) The best gof test on the cases based on the RMSE value is received using
% the parametric Loglogistic distribution, but there is not much difference
% between each distribution on the RMSE values.

% 3) The best gof test on the deaths based on the p value is received using
% the parametric Weibull distribution. It must be noted though that the 
% p-values are quite low for every distribution tested, in a magnitude
% below 10^-4 and thus using a 95% confidence interval level, all
% distributions would be rejected since p << 0.05. In addition, the gof 
% performs much better using the deaths instead of the cases, which is 
% visibile from the fact that p_deaths >> p_cases for the same distributions.

% 4) The best gof test on the deaths based on the RMSE value is received using
% the parametric Lognormal distribution, but there is not much difference
% between each distribution on the RMSE values.

% 5) In terms of the p values the best distributions are different for
% the cases and the deaths.

% 6) In terms of the RMSE values the best distributions are the different
% for the cases and the deaths.

% 7) The attempt to use a parametric distribution to predict the 1st wave
% seems way more promising when the gof test used is the RMSE value,
% instead of the p values, which give horrible results. For this reason,
% the p values will no longer be used for gof tests moving forward, unless
% it is explicitly requested.

% 8) Given the fact that all distributions used give similar results, the
% same distribution could be used both for deaths and for the cases. Taking  
% into consideration the conclusion (7), we will ignore the p values and  
% thus, we will be using the Loglogistic distribution for the cases and the 
% Lognormal for the deaths as requested by the demands of the exercise.