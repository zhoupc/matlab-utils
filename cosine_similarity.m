function C = cosine_similarity(X, Y)
%% compute cosine similarity 
%{
    details of this function 
%}

%% inputs: 
%{
    X: T*m matrix 
    Y: T*n matrix 
%}

%% outputs: 
%{
    C: m*n matrix 
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
%}

%% code 

X = bsxfun(@times, X, 1./sqrt(sum(X.^2, 1))); 
if ~exist('Y', 'var')  || isempty(Y)
    Y = X; 
else
    Y = bsxfun(@times, Y, 1./sqrt(sum(Y.^2, 1))); 
end 

C = X'*Y; 
