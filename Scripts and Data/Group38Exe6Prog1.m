% Data analysis 2021 - Koniotakis Emmanouil 8616

% Same as Exe5 but use multiple linear regression using as independent
% variables the daily cases with various time delays, thus using the
% vectors x(t), x(t-1), ..., x(t-20). Find best multiple linear regression
% model among the 3 following models per country:
% 1) Simple linear regression (Same as Exe5)
% 2) Multiple linear regression using all independent variables x(t-time_d)
% 3) Multiple linear regression using specific independent variables
% x(t-time_d).



clear all

% Load datasets
deaths = readtable('Covid19Deaths.xlsx');
cases = readtable('Covid19Confirmed.xlsx');

% Use same country set as in Exercise 4
test_country = {'Czechia', 'France', 'Greece', 'Germany', 'Austria', 'Switzerland'};

% Number of countries
num = length(test_country);

% Initialize min RMSE vector for the gof test and time delay for min RMSE 
% vector for the 3 models.
minRMSE = zeros(num,1);
% min_e_std = zeros(l1, num);
mintd = zeros(num,1);

% Find time delay that gives maximum cross correlation between cases and
% deaths.
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

% Find first wave for deaths
wave_num = 1;
[temp_deaths, first_day_deaths, last_day_deaths] = Group38Exe1Fun2(temp_deaths, wave_num);
wave_deaths = temp_deaths(1:(last_day_deaths-first_day_deaths+1));

% Length of first wave for deaths.
l1 = length(wave_deaths);

% In the case of finding the first wave for cases, given the problem 
% description, we will consider x(t) the wave of cases and y(t+time_d) the
% wave of deaths. Thus we need to find the normal first day of the start
% of the death wave, to find the first non zero death case. For negative 
% values of time_d that go before the first death, we will simply create
% the death wave using zero padding, since we know that the deaths prior
% to the first death, will be by definition 0. Since we are researching the
% first wave, there is no restriction when having positive time_d values 
% beyond the normal end of the first wave in deaths.
[~, first_day_cases, ~] = Group38Exe1Fun2(temp_cases, wave_num);

% Time delay values
time_d = -20:1:0;

% Afterwards for every possible value of time delay we are testing, we
% will create a displaced death wave, that has the same length as the 
% case wave using the first_day_deaths are the start of the death wave
% for time delay = 0.
% Initialize RMSE and error vectors
RMSE = zeros(length(time_d),1);
std_e = zeros(length(time_d),l1);

% Find difference in days between normal first day of cases and normal
% first day of deaths. Obviously, first_day_deaths > first_day_cases.
dif = first_day_deaths - first_day_cases;

% Initialize the independent variables x(t-time_d), each corresponds to 
% a column, starting with time_d = -20.
X = zeros(l1, length(time_d));

% Get RMSE for the various time delays
for j = 1:length(time_d)
    delay = time_d(j);
    dif2 = dif - abs(delay);
    if dif2 < 0
%     wave_cases = [zeros(abs(dif2), 1); temp_cases(first_day_cases:(last_day_deaths - dif - abs(dif2)))];
        X(:, j) = [zeros(abs(dif2), 1); temp_cases(first_day_cases:(last_day_deaths - dif - abs(dif2)))];
    else
        % dif2 >= 0 
%         wave_cases = [temp_cases((first_day_deaths - abs(delay)):(last_day_deaths - abs(delay)))];
        X(:, j) = temp_cases((first_day_deaths - abs(delay)):(last_day_deaths - abs(delay)));
    end
    % MODEL 1: Simple Linear Regression
    % Create simple linear regression model using as the independent
    % variable X the wave_cases and as the dependant variable the
    % wave_deaths.     
    [RMSE(j,1), std_e(j,:)] = Group38Exe5Fun1(X(:, j), wave_deaths); 
end

% Get RMSE and std_e from best model 1
[RMSE1, I] = min(RMSE);
std_e1 = std_e(I,:);
% Get time delay value for which it was achieved
mintd(i) = time_d(I);

% MODEL 2: Multiple Linear Regression using all independent variables x(t-time_d)
[RMSE2, std_e2] = Group38Exe6Fun1(X, wave_deaths);

% MODEL 3: Multiple Linear Regression using some of the independent 
% variables x(t-time_d). The ones used derive from using PCA.
[RMSE3, std_e3] = Group38Exe6Fun2(X, wave_deaths);

% Get min RMSE achieved and standar deviation of error for diagnostic plot
[minRMSE(i), I] = min([RMSE1 RMSE2 RMSE3]);
if I == 1
    model_num = 1;
    min_e_std = std_e1;
elseif I == 2
    model_num = 2; 
    min_e_std = std_e2;
else 
    model_num = 3;
    min_e_std = std_e3;
end

% Diagnostic Plot
Group38Exe5Fun2(wave_deaths, min_e_std, test_country{i})

% Print results
if I == 1
fprintf('Country: %s, RMSE1: %2.2f, RMSE2: %2.2f, RMSE3: %2.2f, Regression model used: %d, Best time delay: %d, Time delay range tested: [%d, %d]\n', test_country{i}, RMSE1, RMSE2, RMSE3, I, mintd(i), time_d(1), time_d(end))
else
fprintf('Country: %s, RMSE1: %2.2f, RMSE2: %2.2f, RMSE3: %2.2f, Regression model used: %d, Time delay range tested: [%d, %d]\n', test_country{i}, RMSE1, RMSE2, RMSE3, I, time_d(1), time_d(end))   
end
end

%% Remarks
% 1) The best model seems to be the 2nd model, since 5/6 countries tested
% performed better using this model. The 3rd model was the best only for
% one country. The gof test was evaluated using the RMSE values.

% 2) As expected, the 2nd model that uses multiple linear regression with 
% the most wave displacements performs better due to the fact that more
% information is used to build the model, without illogical values for
% the time delays. The 3rd model could possibly perform similarly to the
% 2nd model when the number of principal components used is fine tuned so
% that RMSE3 converges to RMSE2. For that, further testing is required.

% 3) Reviewing the diagnostic plots we can see that most countries show
% similar adaptation patterns in regards to the best model used. Comparing
% the results to those of Exe5 where simple linear regression was used, we
% can spot the following:
% a) The outliers in the diagnostic plots are slightly reduced in absolute 
% value and in number, which shows better predictability in the multiple 
% linear regression model.
% b) There seems to be better linearity when the deaths are low while the
% max(death value) of the country tested is highest and this linearity
% becomes weaker as the deaths increase. This was also true for the simple
% linear model, but the linearity was slightly weaker.
% c) The variance of the standard error as it was also implied in (b), is
% reduced mostly in low death values but also in general. This is also
% obvious from the RMSE values between the models.


