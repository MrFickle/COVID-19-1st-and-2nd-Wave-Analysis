% Data analysis 2021 - Koniotakis Emmanouil 8616


% Use the best model found from Exe6, thus the model 2, to predict the
% daily deaths from the daily cases. Use the first wave as a training set
% and use the second wave as an evaluation set. Compare the training error
% and evaluation error using some statistic, like the rho value. In order
% to avoid confusion between the 2 waves in terms of values in cases, we
% are going to normalize the case seperately for each wave, transforming
% the original values in order to belong in the range [0,1].

clear all

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Use same country set as in Exercise 4. Switzerland was not tested due to 
% error in AdjR2 value.
test_country = {'Czechia', 'France', 'Greece', 'Germany', 'Austria'};

% Number of countries
num = length(test_country);

% Define number of waves
wave_num = 2;

for i=1:num
% Get country row
[row,~] = find(strcmp(cases(:,'Country').Variables, test_country{i}) == 1);

% Get country data as vectors skipping the first 3 columns that contain
% the country, the continent and the population. Thus, we know that the
% days begin from column 4 and end at column 351.    
temp_cases = (cases(row,4:end).Variables)';
temp_deaths = (deaths(row,4:end).Variables)';

% Fix data problems based on country
[temp_cases, temp_deaths, ~] = Group38Exe2Fun2(temp_cases, temp_deaths, test_country{i}, 0);

% Data cleanup
[temp_cases, temp_deaths] = Group38Exe1Fun1(temp_cases, temp_deaths);

% Find first and second wave for deaths
[temp_deaths, first_day_deaths, last_day_deaths] = Group38Exe1Fun2(temp_deaths, wave_num);
first_wave_deaths = temp_deaths(1:(last_day_deaths(1) - first_day_deaths(1) +1), 1);
second_wave_deaths = temp_deaths(1:(last_day_deaths(2) - first_day_deaths(2) +1), 2);

% Length of first wave for deaths.
l1 = length(first_wave_deaths);
% Length of second wave for deaths.
l2 = length(second_wave_deaths);

% In the case of finding the first wave for cases, given the problem 
% description, we will consider x(t) the wave of cases and y(t) the
% wave of deaths. Thus we need to find the normal first day of the start
% of the death wave, to find the first non zero death case. For negative 
% values of time_d that go before the first case, we will simply create
% the case wave using zero padding, since we know that the cases prior
% to the first case, will be by definition 0. Since we are researching the
% first wave, there is no restriction when having positive time_d values 
% beyond the normal end of the first wave in cases.
% In the case of finding the second wave for cases, the zero padding will
% not be required since there will be cases prior to the first day
% of the wave cases in this circumstance.
[~, first_day_cases, ~] = Group38Exe1Fun2(temp_cases, wave_num);

% Time delay values
time_d = -20:1:0;

% Afterwards for every possible value of time delay we are testing, we
% will create a displaced case wave, that has the same length as the 
% death wave using the first_day_deaths as the start of the death wave
% for time delay = 0.

% Find difference in days between normal first day of cases and normal
% first day of deaths. Obviously, first_day_deaths > first_day_cases.
dif = first_day_deaths - first_day_cases;


%% FIRST WAVE ANALYSIS

% Initialize the independent variables x(t-time_d) for the first wave, each 
% displaced case wave corresponds to a column, starting with time_d = -20.
X1 = zeros(l1, length(time_d));

% Create the independent variables x(t-time_d) for the first wave
for j = 1:length(time_d)
    delay = time_d(j);
    dif2 = dif(1) - abs(delay);
    if dif2 < 0
%     wave_cases = [zeros(abs(dif2), 1); temp_cases(first_day_cases:(last_day_deaths - dif - abs(dif2)))];
        X1(:, j) = [zeros(abs(dif2), 1); temp_cases(first_day_cases(1):(last_day_deaths(1) - dif(1) - abs(dif2)))];
    else
        % dif2 >= 0 
%         wave_cases = [temp_cases((first_day_deaths - abs(delay)):(last_day_deaths - abs(delay)))];
        X1(:, j) = temp_cases((first_day_deaths(1) - abs(delay)):(last_day_deaths(1) - abs(delay)));
    end
end

% Normalize data
maxX1 = max(X1,[],1);
X1 = X1./maxX1;
maxY1 = max(first_wave_deaths);
Y1 = first_wave_deaths/maxY1;


% Train regression model using the model 2 from Exe6
[RMSE1, std_e1, b_coeff1, R2_1, AdjR2_1] = Group38Exe6Fun1(X1, Y1);


%% SECOND WAVE ANALYSIS

% Initialize the independent variables x(t-time_d) for the second wave, each 
% displaced case wave corresponds to a column, starting with time_d = -20.
X2 = zeros(l2, length(time_d));

% Create the independent variables x(t-time_d) for the second wave
for j = 1:length(time_d)
    delay = time_d(j);
    dif2 = dif(2) - abs(delay);
    if dif2 < 0
%     wave_cases = [zeros(abs(dif2), 1); temp_cases(first_day_cases:(last_day_deaths - dif - abs(dif2)))];
        X2(:, j) = [zeros(abs(dif2), 1); temp_cases(first_day_cases(2):(last_day_deaths(2) - dif(2) - abs(dif2)))];
    else
        % dif2 >= 0 
%         wave_cases = [temp_cases((first_day_deaths - abs(delay)):(last_day_deaths - abs(delay)))];
        X2(:, j) = temp_cases((first_day_deaths(2) - abs(delay)):(last_day_deaths(2) - abs(delay)));
    end
end



% Evaluate the model created from the first wave by using it in the second 
% wave.
% Normalize data
maxX2 = max(X2,[],1);
X2 = X2./maxX2;
maxY2 = max(second_wave_deaths);
Y2 = second_wave_deaths/maxY2;

% Coefficients of b coefficients 
X_pad = [ones(length(X2),1) X2];

% Predictions
y_pred = X_pad*b_coeff1;

% Find the residuals using definition
residuals = Y2 - y_pred;

% Find the normalised RMSE using definition to calculate the std(residuals)
RMSE2 = sqrt(1/(length(X2)-length(b_coeff1)) * (sum(residuals.^2)));

% Find the std(residuals) from definition for each yi|x
std_e2 = residuals./RMSE2;

% Find the coefficient of determination
SStot = sum((Y2 - mean(Y2)).^2);
SSres = sum((Y2 - y_pred).^2);
R2_2 = 1 - SSres/SStot;

% Find the adjusted coefficient of determination
AdjR2_2 = 1 - (1-R2_2)*(length(Y2) - 1)/(length(Y2) - size(X2,2) - 1);

% Plot expected second death wave, along with the original death wave with
% regards to denormalized cases at time_d = 0.
second_wave_cases = X2(:,21)*maxX2(21);

% Real deaths
figure()
scatter(second_wave_cases, second_wave_deaths, 'Marker', 'o', 'MarkerFaceColor', 'b')
title(sprintf('Real deaths vs Expected deaths in %s for the second wave', test_country{i}))
xlabel('Cases')
ylabel('Deaths')
hold on;
% Sort the (X,Y) points in ascending order to plot the regression curve due
% to the fact that we have a curve in the non-linear regression, instead of
% a line like the linear regression case.
% [X_sorted,sortIdx] = sort(second_wave_cases);
% y_pred = y_pred(sortIdx);

% Plot the line found from the non-linear regression model
% plot(X_sorted,y_pred, 'Marker', 'o', 'Color', 'g'); 
scatter(second_wave_cases, y_pred*maxY2, 'Marker', 'o', 'MarkerFaceColor', 'g')
legend('Real Deaths', 'Expected Deaths')

% Print results
fprintf('%d) Country: %s \n', i, test_country{i})
fprintf('Training normalised RMSE: %2.2f, Training R2: %2.2f, Training AdjR2: %2.2f \n', RMSE1, R2_1, AdjR2_1)
fprintf('Evaluation normalised RMSE: %2.2f, Evaluation R2: %2.2f, Evaluation AdjR2: %2.2f \n\n', RMSE2, R2_2, AdjR2_2)
end

%% Remarks
% 1) In order to deal with value differences between the first wave and the
% second wave, normalization was performed for each wave both for the cases
% and the deaths so that all values are in the range of [0, 1].

% 2) Continuing from (1), the RMSE values presented are normalized as
% stated in (1) for comparitive reasons between the training (first wave)
% and the evaluation (second wave).

% 3) Continuing from the remarks of Exe5, we can see that the linearity
% between cases and deaths is medium to strong since the R2 absolute values 
% are in the range [0.51, 0.93] in training and [0.41, 0.7] in the evaluation.

% 4) Continuing from (3), the AdjR2 absolute values are in the range 
% [0.36, 0.91] in training and [0.41, 0.58] in the evaluation.

% 5) Continuing from (2), comparing the results of RMSE, R2, AdjR2 between
% training and evaluation, it is clear that the model performs much worse on
% the evaluation set (second wave) when the training set gave better
% results, like in France and Germany. This does not occur as much in cases 
% where the training set gave medium results, like in Greece and Czechia.
% This seems a bit counter intuitive, since a better model in the training
% set would be expected to be a better model in the evaluation set as well.

% 6) As revealed in the scatter plots, as well as it was noted in Exe6,
% the predictions are much better for the countries where the max(death value) 
% is higher and for low values of deaths, with the predictions worsening
% as the deaths rise in general. Thus there is higher convergence for low
% values in deaths and less for high values in deaths.

% 7) Summarizing from all the remarks made in Exe5, Exe6 and Exe7 there
% could possibly be better performance when each wave would split in 2
% segments, one containing low deaths and one higher deaths and building a
% different model for each segment to amend to the problem that arises 
% when the deaths rise. If this were the case, then it would be implied
% that as the deaths rise, the country's health system changes behaviour
% due to high load, which has a direct impact on the relationship between
% daily cases and deaths with regards to their time delay. Further testing 
% must be done for this to be considered as an actual possibility. This
% might seem to go against to the fact that as previously stated, when 
% a country has a higher max(death value) then the model performs better.
% As I believe it was explained in the remarks of previous exercises, this  
% is probably due to the fact that a higher max(death value) implies better
% data quality, because the specific country was 'forced' to deal with the
% pandemic more actively as it had a greater negative impact on the specific
% country.

% 8) Austria and Switzerland (Switzerland was removed) show problematic
% results in terms of R2 and AdjR2 and further testing should be done.

% 9) Group38Exe8Prog1.m was not implemented due to time constraints, though
% if it was, a stepwiselm model would be used for the dimensional
% reduction, though intuitively i would expect that the multiple linear
% model 2 would still perform better and the stepwiselm model would be 
% required to be fine tuned in order to converge to the results of the 
% multiple linear model that uses all wave displacements.



