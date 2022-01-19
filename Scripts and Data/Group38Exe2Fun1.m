% Data analysis 2021 - Koniotakis Emmanouil 8616

% Print countries in descending order in terms of performing better
% in the gof tests using p values and RMSE values using different
% distributions for cases and deaths. 

function Group38Exe2Fun1(p_cases, norm_RMSE_cases, p_deaths, norm_RMSE_deaths, country, dist_cases, dist_deaths)
% Get number of countries
l = length(country);

% Country performance based on gof test on cases 
% p values
if isempty(p_cases) == 0
[~,I] = maxk(p_cases,l);
fprintf('Using the %s distribution to perform the gof test using p values on cases, the countries that adapted better are shown in sequence:\n', dist_cases{1})
for i=1:l
   fprintf('%d) %s ',i ,country{I(i)}) 
end
fprintf('\n\n')
end

% RMSE values
[~,I] = mink(norm_RMSE_cases,l);
fprintf('Using the %s distribution to perform the gof test using RMSE/mean values on cases, the countries that adapted better are shown in sequence:\n', dist_cases{1})
for i=1:l
   fprintf('%d) %s, RMSE/mean: %2.2f \n ',i ,country{I(i)}, norm_RMSE_cases(I(i))) 
end
fprintf('\n\n')

% Country performance based on gof test on deaths
% p values
if isempty(p_deaths) == 0
[~,I] = maxk(p_deaths,l);
fprintf('Using the %s distribution to perform the gof test using p values on cases, the countries that adapted better are shown in sequence:\n', dist_deaths{1})
for i=1:l
   fprintf('%d) %s ',i ,country{I(i)}) 
end
fprintf('\n\n')
end

% RMSE values
[~,I] = mink(norm_RMSE_deaths,l);
fprintf('Using the %s distribution to perform the gof test using RMSE/mean values on deaths, the countries that adapted better are shown in sequence:\n', dist_deaths{1})
for i=1:l
   fprintf('%d) %s, RMSE/mean: %2.2f \n',i ,country{I(i)}, norm_RMSE_deaths(I(i))) 
end
fprintf('\n\n')
end