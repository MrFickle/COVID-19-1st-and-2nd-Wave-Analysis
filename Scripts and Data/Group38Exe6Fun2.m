% Data analysis 2021 - Koniotakis Emmanouil 8616

% Given dependent variable Y and independent matrix X, where Y is a vector
% and each column of X is a variable vector. After performing PCA on X
% create a multiple linear regression model and return the RMSE and the
% standard deviation of the error.

function [RMSE, std_e, b_coeff, R2, AdjR2] = Group38Exe6Fun2(X, Y)
    % Perform PCA analysis on X matrix
    [coeffs, scores, eigenvalues,~,~,mu] = pca(X);
    
    % Scree plot
%     figure()
%     plot(1:length(eigenvalues), eigenvalues, 'Marker', '+')
%     title('Scree Plot')
%     ylabel('eigenvalue')
%     xlabel('index')
%     xticks(1:length(eigenvalues))
    
    % Keep highest 2 principal components without denormalizing them, since
    % we don't need the original vectors for plotting
    X2 = [ones(length(scores(:,1:2)),1) scores(:,1:2)];
    
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