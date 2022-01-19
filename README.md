# COVID-19 1st and 2nd wave analysis
 
This is a project done on a specific course taken at the Electrical and Computer Engineering department of the Aristotle University of Thessaloniki on Data Analysis.
The purpose of this project was to investigate the 1st and 2nd wave of the COVID-19 pandemic across various countries using fundamental data analysis approaches.

If you want to run the tests, place all of the scripts in the same folder and open the following in MATLAB depending on what you want to view:
1) "Group38Exe1Prog1.m": Investigate how well certain known distributions fit to the 1st wave of cases in Czechia, performing goodness of fit tests using: 
  a) p values on cases
  b) p values on deaths
  c) RMSE values on cases
  d) RMSE values on deaths

2) "Group38Exe2Prog1.m": a) Fit the Loglogistic distribution to perform the gof test using the metric RMSE/mean on cases for various countries and rank them in descending order.
                         b) Fit the Lognormal distribution to perform the gof test using the metric RMSE/mean on deaths for various countries and rank them in descending order.

3) "Group38Exe3Prog1.m": Calculate the 95% parametric and bootstrap confidence interval for the mean of the time delay between peak in cases and deaths for various countries.

4) "Group38Exe4Prog1.m": Find the time delay value between the wave of cases and deaths that gives the highest Pearson cross correlation value for various countries.


5) "Group38Exe5Prog1.m": Investigate whether we can predict daily deaths based on the daily cases on a country's first wave, using simple linear regression models. Calculate RMSE and make diagnostic plot.

6) "Group38Exe6Prog1.m": Same as Exe5 but use multiple linear regression using as independent variables the daily cases with various time delays.

7) "Group38Exe7Prog1.m":  Use the best model found from Exe6, thus the model 2, to predict the daily deaths from the daily cases. Use the first wave as a training set
and the second wave as an evaluation set. Compare the training error and evaluation error using the normalised RMSE, R^2 and the adjusted R^2.
