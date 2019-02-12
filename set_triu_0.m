function X = set_triu_0(X, k)
%% set the upper triangular part of a matrix as 0 
%{
    details of this function 
%}

%% inputs: 
%{
    X: m*n matrix 
    k: above the k-th diagonal of X 
%}

%% outputs: 
%{
    X: the matrix after the processing 
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
%}

%% code 
[m, n] = size(X);
[jj, ii] = meshgrid(1:n, 1:m);
ind = sub2ind([m, n], ii, jj);
if ~exist('k', 'var') || isempty('k')
    k = 0;
end
X(ind(jj>=ii+k)) = 0;
