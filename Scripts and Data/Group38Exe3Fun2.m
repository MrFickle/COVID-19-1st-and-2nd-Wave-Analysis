% Data analysis 2021 - Koniotakis Emmanouil 8616

% Find 1-a parametric and bootstrap confidence interval for mean for a
% vector and perform hypothesis testing.

function [h,p,ci] = Group38Exe3Fun2(vector, alpha, mean_test)
% Initialize params. First row is for parametric and 2nd for bootstrap.
ci = NaN(2,2);
h = NaN(2,1);
p = NaN(2,1);

% Find 95% parametric confidence interval for mean
n = length(vector);
mu = mean(vector);
sd = std(vector);
tcrit = tinv((1-alpha/2),n-1);
sterr_mu = sd/sqrt(n);

% Lower value in CI
ci(1,1) = mu - tcrit*sterr_mu;
% Upper value in CI
ci(1,2) = mu + tcrit*sterr_mu;

% Hypothesis test for parametric
[h(1),p(1)] = ttest(vector, mean_test, alpha);

% Find 95% bootstrap confidence interval for mean time delay using the
% sample created above
% Percentile bootstrap approach
B = 10*n;
klower = floor((B+1)*alpha/2);
kup = B+1-klower;

Bx = NaN*ones(B,n);
meanBx = NaN*ones(B,1);
for j=1:B
    el = unidrnd(n,1,n);
    Bx(j,:) = vector(el);
    meanBx(j) = mean(Bx(j,:));     
end
meanBx_sorted = sort(meanBx);   % Sort in ascending order
% Lower value in CI
ci(2,1) = meanBx_sorted(klower); 
% Upper value in CI
ci(2,2) = meanBx_sorted(kup);  

% Hypothesis test for bootstrap
B_test = [mean_test ; meanBx];
B_test = sort(B_test);
rank_test = find(B_test == mean_test);
if rank_test < klower || rank_test > kup
    p(2) = 2*(1-rank_test/(B+1));
    h(2) = 1;
else
    p(2) = 2*rank_test/(B+1);
    h(2) = 0;
end

end