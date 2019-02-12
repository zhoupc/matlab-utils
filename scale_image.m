function y = scale_image(y)
%% what does this function do 
%{
    details of this function 
%}

%% inputs: 
%{
%}

%% outputs: 
%{
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
%}

%% code 
gamma = 0.05; 
ind_nnz = (y>0); 
y_nnz = y(ind_nnz); 
y_thr = max(y)/5; 
ind_lower = (y_nnz<y_thr); 
ind_upper = (y_nnz>=y_thr); 

%% convert data in the lower part to follow exponential distribution 
y_lower = y_nnz(ind_lower); 
[~, idx] = sort(y_lower); 
y_lower(idx) = expinv(linspace(0.0001, 0.9999, length(y_lower))); 
y_nnz(ind_lower) = (y_lower-min(y_lower))/range(y_lower)*gamma; 

%% convert data in the upper part to follow normal distribution 
y_upper = y_nnz(ind_upper); 
[~, idx] = sort(y_upper); 
y_upper(idx) = norminv(linspace(0.0001, 0.9999, length(y_upper))); 
y_nnz(ind_upper) = (y_upper -min(y_upper))/range(y_upper) * (1-gamma)+gamma; 

%% 
y(ind_nnz) = y_nnz; 