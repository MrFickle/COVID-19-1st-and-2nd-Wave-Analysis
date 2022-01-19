% Data analysis 2021 - Koniotakis Emmanouil 8616

% Create multiple linear regression model given dependent variable Y and
% independent matrix X. Y is a vector and each column of X is a variable
% vector. Return RMSE and the standard deviation of the error.

function [RMSE, std_e, b_coeff, R2, AdjR2] = Group38Exe6Fun1(X, Y)
    % Coefficients of b coefficients
    X2 = [ones(length(X),1) X];

    % Afterwards you find the coefficients bi for ascending i by using regression
    b_coeff = regress(Y, X2);

    % Then you can create predictions
    y_pred = X2*b_coeff;

    % Find the residuals using definition
    residuals = Y - y_pred;
    
    % Find the RMSE using definition to calculate the std(residuals)
    RMSE = sqrt(1/(length(X)-length(b_coeff)) * (sum(residuals.^2)));
    
    % Find the std(residuals) from definition for each yi|x
    std_e = residuals./RMSE;
    
    % Find the coefficient of determination
    SStot = sum((Y - mean(Y)).^2);
    SSres = sum(residuals.^2);
    R2 = 1 - SSres/SStot;
    
    % Return adjusted coefficient of determination
    AdjR2 = 1 - (1-R2)*(length(Y) - 1)/(length(Y) - size(X,2) - 1);
end