% Data analysis 2021 - Koniotakis Emmanouil 8616

% This function performs gof p-test and calculates the RMSE for 5 different 
% parametric distributions separately for cases and deaths and returns
% the p and RMSE values, as well as plotting the fitted distributions on
% the respective initial histograms.


% cases must be a vector. type = 'Cases' / 'Deaths'
function [p_values, RMSE] = Group38Exe1Fun3(cases, type, distribution, country)
% Create days vector
days = (1:1:length(cases))';
               
% Create 5 parametric distributions using the day of the first wave as a
% random variable and check for gof using chi^2 p-test and RMSE. Basically
% see how well the distribution fits on the original histogram.
l = length(distribution);

% Initialize relative frequency values for pdfs
cases_par_y = zeros(length(days), l);

% total cases
total_cases = sum(cases);

% Find gof using chi2 distribution
p_values = zeros(l,1);
        
for i=1:1:l
% Get pdf
cases_par_pd = fitdist(days, distribution{i}, 'Frequency', cases);
% Find y values from pdf
cases_par_y(:,i) = pdf(cases_par_pd, days);
% Convert relative frequency, to frequency
cases_par_y(:,i) = cases_par_y(:,i) * total_cases;
% Get p values
[~,p_values(i)] = chi2gof(days, 'CDF', cases_par_pd, 'Frequency', cases);
end


% Calculate RMSE
RMSE = zeros(l,1);
for i=1:1:l
    RMSE(i) = sqrt((1/(length(cases))) * sum((cases_par_y(:,i) - cases).^2));
end

% Cases plot
figure()
bar(cases,sqrt(length(cases))/5)
title(sprintf('Daily New %s of Covid19 in %s', type, country))
ylabel(sprintf('Number of %s', type))
xlabel(sprintf('Day number')) 
legend(sprintf('%s/day', type))
hold on

% Create 5 colors
color = {'r' , 'g' , 'm', 'y', 'k'};

for i=1:1:l
plot(days, cases_par_y(:,i), 'LineWidth', 2, 'Color', color{mod(i,5)+1})
legend([sprintf('%s/day', type) distribution])
end
hold off

end

