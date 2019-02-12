function [xfit, pars, rss] =fit_von_mises2(phi, x)
%% fit von mises distribution
% inputs:
%   phi: 1D vector, angles between 0 and 2pi
%   x: 1D vector, response magnitudes
% output:
%   xfit: fitted responses 
%   pars: fitted coefficients
%   rss: squared error

%% code
phi = reshape(phi, [], 1);
x = reshape(x, [], 1);

% estimate theta with two cosine fit
s = x' * exp(2i*phi);
theta = angle(s)/2;
xm = mean(x);
x = x-xm;
if x'*x ==0 
    pars = [xm, 0, 0, 0, pi];
    xfit = xm + x;    
    rss = 1; 
    return; 
end 
c = cos(phi-theta);

% binary search for optimal width
nwidths = 64;
max_width = 2*pi;
widths = linspace(0, max_width, nwidths); 
%(logspace(0, log10(max_width), nwidths));
best = [];
bounds = [1, nwidths];
while diff(bounds)>1
    mid = floor(mean(bounds));
    candidate = amps(widths(mid), c, x);
    if isempty(best) || best.rss>candidate.rss
        best = candidate;
    end
    if candidate.direction>0
        bounds(2) = mid;
    else
        bounds(1) = mid;
    end
end

a = best.a;
rss = best.rss/(x'*x); % relative rss 
w = best.w;
gm = best.gm;
% if a(1)<a(2)
%     a = fliplr(a);
%     theta = theta + pi;
% end

pars = [xm - gm*a, a(1), a(2), theta, w];
g = @(c, w) exp(-w*(1-c));
xfit = pars(1)+a(1)*g(cos(phi-theta),w)+a(2)*g(-cos(phi-theta), w);

end


function results = amps(w, c, x)

g = @(c, w) exp(-w*(1-c));
von_mises2 = @(phi, a0, a1, a2, theta, w) ...
    a0+a1*g(cos(phi-theta),w)+a2*g(-cos(phi-theta), w);

G = [g(c, w), g(-c, w)];
gm = mean(G, 1);
G = bsxfun(@minus, G, gm);
a = G \ x;
d = x - G*a;
rss = d'*d;
direction = sign(d'*((G.*[1-c, 1+c])*a));

results = struct('rss', rss, 'a', a, 'gm', gm, 'w', w, 'direction', direction);
end