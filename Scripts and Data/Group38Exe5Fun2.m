% Data analysis 2021 - Koniotakis Emmanouil 8616

% Create diagnostic plot of country where simple linear regression was
% performed for the prediction of the daily deaths.

function Group38Exe5Fun2(Y, std_e, country)
    % Diagnostic Plot
    figure;
    % Plot the standard deviation of the residuals for each yi|x
    scatter(Y,std_e);
    hold on;
    % Plot the 95% CI upper limit for the std(residuals)
    plot(xlim,[1.96 1.96]);
    hold on;
    % Plot a line in the middle of the graph
    plot(xlim,[0 0]);
    hold on;
    % Plot the 95% CI lower limit for the std(residuals)
    plot(xlim,[-1.96 -1.96]);
    title(sprintf('Diagnostic Plot of Linear Regression in %s', country));
    xlabel("Daily deaths")
    ylabel("Standard Error");
end