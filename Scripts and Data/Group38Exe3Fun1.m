% Data analysis 2021 - Koniotakis Emmanouil 8616


% Find peak value, day and date for a country on a certain wave.
function [peak_value, peak_day, peak_date] = Group38Exe3Fun1(wave_vector, distribution, country_table, dif)
% Create a pdf from the wave_vector using the given distribution.
% Create days vector
days = (1:1:length(wave_vector))';
               
% Initialize relative frequency values for pdfs
rel_freq = zeros(length(days), 1);

% Total observations
abs_freq_sum = sum(wave_vector);
        
% Get pdf
freq_pd = fitdist(days, distribution, 'Frequency', wave_vector);
% Find y values from pdf
rel_freq(:) = pdf(freq_pd, days);

% Convert relative frequency, to frequency
abs_freq = rel_freq * abs_freq_sum;

% Get max abs_freq value and index. This is the estimated peak and the 
% estimated peak date respectively, relative to the wave's days.
[peak_value,I] = max(abs_freq);

% Get the index of the estimated peak date relative to the original table
peak_day = I + dif+3;
% Get the estimated peak date
peak_date = country_table(1,peak_day).Properties.VariableNames;
end