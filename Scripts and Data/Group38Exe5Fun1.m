% Data analysis 2021 - Koniotakis Emmanouil 8616

% Create simple linear regression model given dependent variable Y and
% independent variable X. X and Y are vectors. Return RMSE and the 
% standard deviation of the error.

function [RMSE, std_e, regressionModel] = Group38Exe5Fun1(X, Y)
    % Create simple linear regression model using as the independent
    % variable X the wave_cases and as the dependant variable the
    % wave_deaths.
    regressionModel = fitlm(X, Y);
    % Find [b0, b1] 2x1 matrix
    b_coeff = regressionModel.Coefficients.Estimate;
    % Coefficients of b coefficients
    X2 = [ones(length(X),1) X]; 
    % y_pred = b0 + b1x
    y_pred = X2*b_coeff; 
    % Find RMSE
    RMSE = regressionModel.RMSE;
    % Find the estimation residuals
    residuals = regressionModel.Residuals.Raw;
    % Find the standard deviation of the residuals for each yi|x
    std_e = residuals./RMSE;       
end

