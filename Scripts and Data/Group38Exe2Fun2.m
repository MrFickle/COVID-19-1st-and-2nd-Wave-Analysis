% Data analysis 2021 - Koniotakis Emmanouil 8616


% This function fixes inaccuracies in data based on the country for
% smoother analysis. These inaccuracies have been found by manually
% reviewing the respective data. Thus, for every new country that requires
% testing, it should be added here and be corrected separately.

% cases and deaths are both vectors as inputs and outputs
function [cases, deaths, l1] = Group38Exe2Fun2(cases, deaths, country, l1)

switch country
    case 'France'
        cases(1:55) = 0;
        deaths(1:61) = 0;
    case 'Italy'
        cases(1:51) = 0;
        deaths(1:53) = 0;
    case 'Spain'
        cases(1:54) = 0;
        cases(346:348) = [];
        deaths(346:348) = [];
        l1 = l1+3;
    case 'Germany'
        cases(1:55) = 0;
    case 'Sweden'
        cases(1:56) = 0;
        cases(346:348) = [];
        deaths(346:348) = [];
        l1 = l1+3;
    case 'United_Kingdom'
        cases(1:55) = 0;
    case 'Belgium'
        cases(1:59) = 0;
        cases(348) = [];
        deaths(348) = [];
        l1 = l1+1;
    case 'Switzerland'
        cases(347:348) = [];
        deaths(347:348) = [];
        l1 = l1+2;
end
end