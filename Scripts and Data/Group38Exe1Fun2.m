% Data analysis 2021 - Koniotakis Emmanouil 8616

% Group38Exe1Fun2 version 3.

% This function receives the cases and deaths data and returns the cases
% and deaths for the wave desired.

% We are gonna use a simple method to do this using a peak detector for the
% moving 5-day mean.

% cases and deaths must be a vector
function [wave_cases, first_day_idx, last_day_idx] = Group38Exe1Fun2(cases, wave_num)
% 5-day mean approach
N = 5;

days = length(cases);

moving_mean = zeros(days,1);

% Create N-moving_mean
for i=1:1:days
    j = 0;
    while i-j >= 1 && j <= N-1
       moving_mean(i) = moving_mean(i) + cases(i - j); 
       j = j + 1;
    end
    moving_mean(i) = moving_mean(i)/N;
end

% Find wave by using a N-moving_mean threshold related to the N-moving_mean
% peak. We will assume that the moving_mean will be increasing as the wave
% progresses until it reaches a peak and then it will be decreasing.
wave_peak_idx = zeros(wave_num, 1);
peak_idx = 1;
peak = moving_mean(peak_idx);
count = 0;
% Peak dominance
peak_days = 20;
i = 2;
while i<=days-1
%    peak = moving_mean(peak_idx);
   current = moving_mean(i+1);
   if peak <= current
       peak_idx = i+1; % We need the index, not the value
       peak = moving_mean(peak_idx);
       count = 0;
   else
       count = count + 1;
   % If the peak remains the same for at least 20 days and has not been 
   % stored already, then consider it he peak of the current wave and place
   % its index on the wave_peak_idx but on the reverse order. i.e. If we 
   % have 2 waves, the first wave will be at wave_peak_idx(2) and the 1st
   % wave will be at wave_peak_idx(1). So we flip it afterwards.
       if count == peak_days && wave_num > 0 && isempty(find(wave_peak_idx == peak_idx))
           wave_peak_idx(wave_num) = peak_idx;
           wave_num = wave_num - 1;
           
           % If peak is found, skip peak_idx days, halve the peak and 
           % reset counter
           i = i + peak_idx;
           peak = peak/2;
           count = 0;
       end
   end
   i = i + 1;
end
% Flip wave peaks, so that each peak refers to the corresponding wave.
wave_peak_idx = flip(wave_peak_idx);

% If peak dominance wasn't achieved, consider the peak of the wave
% the current peak independently of the fact that count < peak_days
if wave_peak_idx(end) == 0
    wave_peak_idx(end) = peak_idx;
end

% Find start and end of wave based on peak
first_day_idx = zeros(length(wave_peak_idx),1);
last_day_idx = zeros(length(wave_peak_idx),1);
for i=1:1:length(wave_peak_idx)
   % Wave i peak value
   peak = moving_mean(wave_peak_idx(i));
   % Find lower values from the peak and keep their index
   lower_idx = find(moving_mean <= peak & moving_mean > 0);
   
   % If we are investigating waves after the first, then the first day
   % will be the one that has a moving mean that is the smallest of its
   % consecutive 2*N moving means, thus implying that there is a rise in
   % cases showing the appearance of a consecutive wave to the previous
   % one. We could say that first_day_idx(i) = last_day_idx(i-1)+1, but
   % it is possible that between 2 consecutive waves, there is a plateau
   % of cases, which cannot be considered part of a wave. Thus we will
   % start investigating from the last_day_idx(i-1)+1, meaning the first
   % day after the end of the previous wave.
   if i > 1
       % Keep the cases that are below the peak, but after the previous wave
       lower_idx = find(lower_idx >= last_day_idx(i-1)+1);
       
       % Keep the cases that are below the peak, but above the 2.5% value of 
       % the peak, otherwise we will get a very long wave initiation start,
       % which can be considered a plateau since there is not important wave
       % development and it does not help the current analysis.
       lower_idx = lower_idx(find(moving_mean(lower_idx) >= 0.025 * moving_mean(wave_peak_idx(i))));
       
       % Start with the first day that are in the lower_idx
       first_day_idx(i) = min(lower_idx);
       current = moving_mean(first_day_idx(i));
       count3 = 0;
       
       % Days before peak
       dif = wave_peak_idx(i) -  first_day_idx(i); 
       
       for j=1:dif
           next_idx = first_day_idx(i) + j;
           next = moving_mean(next_idx);
           if current < next
               count3 = count3 + 1;
           else
               count3 = 0;
               current = next;
               first_day_idx(i) = next_idx;
           end
           if count3 == 2*N
                   break
           end    
       end
   
   % If we are investigating the first wave, then we consider the start
   % of the way the day of the first case, since no countries were prepared
   % enough to consider the case of having a plateau at the start of the 
   % pandemic.
   else
       before_idx = lower_idx(find(lower_idx <= wave_peak_idx(i)));
       first_day_idx(i) = min(before_idx);
   end  
   
   % Find the values on the right of the peak
      after_idx = [];
      % Arbitrary threshold that shows that the wave is dying out
      th = 0.05*peak;
      while isempty(after_idx)
      % Find cases after the wave's peak that are below the peak
      temp = lower_idx(find(lower_idx > wave_peak_idx(i)));
      % Keep only the ones below the threshold
      after_idx = temp(find(moving_mean(temp)<= th));
      % If no cases are below th, then increase the threshold by 5%
      th = th + 0.05*peak;
      % If th >= peak, then the peak has not been reached yet in the
      % current wave
      if th >= peak
          last_day_idx(i) = wave_peak_idx(i);
          break
      end
      
      end
      
      if isempty(after_idx) == 0
          % The last day will be the first case among its consecutive N
          % cases to the right of the peak, that is the smallest case among
          % the N consecutive days.
          for w=1:length(after_idx)
              current = moving_mean(after_idx(w));
              count2 = 0;
              for j=1:N
                  if after_idx(w) + j <= length(moving_mean)
                      next = moving_mean(after_idx(w)+j);
                      if current < next
                          count2 = count2 + 1;
                      else
                          break
                      end
                  else 
                      break
                  end
              end
              if count2 == N
                  last_day_idx(i) = after_idx(w);
                  min_value = moving_mean(last_day_idx(i));
                  break
              end
          end
          % If the wave studied is the last one, then assign the latest day
          % as the last day.
          if last_day_idx(i) == 0
              last_day_idx(i) = max(lower_idx);
          end
      end
end
% Wave length
wave_length = last_day_idx - first_day_idx;

wave_cases = zeros(days, length(wave_peak_idx));

% Finally get the waves
for i=1:length(wave_peak_idx)
   wave_cases(1:wave_length(i)+1,i) = cases(first_day_idx(i):last_day_idx(i),1);
end
end

