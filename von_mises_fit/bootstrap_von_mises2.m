function [xfit, pars, rss, pvals] =bootstrap_von_mises2(phi, x, shuffles)

[xfit, pars, rss] = fit_von_mises2(phi, x); 

if ~exist('shuffles', 'var') || isempty(shuffles)
    shuffles = 5000; 
end 

k = 0; 
n = length(x); 
for m=1:shuffles
    [~, ~, tmp_rss] = fit_von_mises2(phi, x(randperm(n))); 
    k = k + (tmp_rss<rss); 
end

pvals = k / shuffles; 