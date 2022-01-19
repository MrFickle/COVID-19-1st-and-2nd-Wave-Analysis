% Data analysis 2021 - Koniotakis Emmanouil 8616

% This function fixes problems at the data, such as:
% 1) Removing days that are before the start of the first wave
% 2) Replacing NaN values
% 3) Replacing negative values in deaths
% 4) Replacing negative values in cases

% cases and deaths both on input and output are vectors.
function [cases, deaths] = Group38Exe1Fun1(cases, deaths)

% 1) Removing days that are before the start of the first wave
k = find(cases == 0);

% While the cases remain at 0 remove the case, up until a case pops up.
first_case = 0;
for i=1:length(k)
    current = k(i);
    if i+1<= length(k)
        next = k(i+1);
    else
        first_case = current+1;
        break
    end
    % When the first case is found keep the first case's index.
    if next - current ~= 1
       first_case = current+1;
       break
    end        
end

% Keep only the cases and deaths after the first case
cases = cases(first_case:end,1);
deaths = deaths(first_case:end,1);

% 2) Replacing NaN values
% Find index of nan values in cases
nan_index = find(isnan(cases(:,1)));
l = length(nan_index);

if l>0
    % Replace the NaN values with the mean of the closest 2 non NaN values.
    for i=1:l
        % Indices of values to use to replace nan values
        prev_index = nan_index(i)-1;
        next_index = nan_index(i)+1;
        
        % Check whether the values to be used are nan. If so go to the closest
        % element on the respective direction.
        while isnan(cases(prev_index,1)) & prev_index > 0
            prev_index = prev_index -1;
        end
        
        while isnan(cases(next_index,1))
            next_index = next_index + 1;
        end
        
        % Now that the indices to use are found, replace the nan value
        prev_value = cases(prev_index,1);
        next_value = cases(next_index,1);
        cases(nan_index(i),1) = round((prev_value + next_value)/2);
    end
end
% 3) Replacing negative values in deaths
% Find the negative values in deaths, make them equal to zero and remove
% these deaths from the previous day.
k = find(deaths < 0);
while ~isempty(k)
for i=k
   deaths(i-1,1) = deaths(i-1,1) + deaths(i,1);
   deaths(i,1) = 0;
end
k = find(deaths < 0);
end

% 4) Replacing negative values in cases
% Find the negative values in cases, make them equal to zero and remove
% these cases from the previous day.
k = find(cases < 0);
while ~isempty(k)
for i=k
   cases(i-1,1) = cases(i-1,1) + cases(i,1);
   cases(i,1) = 0;
end
k = find(cases < 0);
end

end