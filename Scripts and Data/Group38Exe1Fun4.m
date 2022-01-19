% Data analysis 2021 - Koniotakis Emmanouil 8616


% This is a void function that sorts gof of distributions on cases and 
% deaths based on p-values and RMSE and print the results.

function Group38Exe1Fun4(distribution, p_cases, RMSE_cases, p_deaths, RMSE_deaths)
dist_num = length(distribution);

[~,I1] = maxk(p_cases,dist_num);
fprintf('The best distributions performing the gof test using p values on cases are shown in sequence:\n')
for i=1:dist_num
   fprintf('%d) %s, p: %d, ',i ,distribution{I1(i)}, p_cases(I1(i))) 
end
fprintf('\n')

% Sort gof of distributions on deaths based on p-values
[~,I3] = maxk(p_deaths,dist_num);
fprintf('\nThe best distributions performing the gof test using p values on deaths are shown in sequence:\n')
for i=1:dist_num
   fprintf('%d) %s, p: %d, ',i ,distribution{I3(i)}, p_deaths(I3(i))) 
end
fprintf('\n')

% Sort gof of distributions on cases based on RMSE values
[~,I2] = mink(RMSE_cases,dist_num);
fprintf('\nThe best distributions performing the gof test using RMSE values on cases are shown in sequence:\n')
for i=1:dist_num
   fprintf('%d) %s, RMSE: %2.2f, ',i ,distribution{I2(i)}, RMSE_cases(I2(i))) 
end
fprintf('\n')

% Sort gof of distributions on deaths based on RMSE values
[~,I4] = mink(RMSE_deaths,dist_num);
fprintf('\nThe best distributions performing the gof test using RMSE values on deaths are shown in sequence:\n')
for i=1:dist_num
   fprintf('%d) %s, RMSE: %2.2f, ',i ,distribution{I4(i)}, RMSE_deaths(I4(i))) 
end
fprintf('\n')

end