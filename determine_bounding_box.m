function [rrange, crange] = determine_bounding_box(img, w)
%% given an image, determine its bounding box [rmin, rmax] and [cmin, cmax]
%{
    details of this function 
%}

%% inputs: 
%{
    img: d1*d2(*d3), the image 
    w: integer, extend the boundary by adding a margin
%}

%% outputs: 
%{  
    rrange: [rmin, rmax]
    crange: [cmin, cmax]
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
%}

%% code 
if ~exist('w', 'var') || isempty(w)
    w = 1; 
end
img = sum(img, 3); 
[d1, d2] = size(img); 
[r, c] = find(img); 
rrange = [max(1, min(r)-w), min(d1, max(r)+w)]; 
crange = [max(1, min(c)-w), min(d2, max(c)+w)]; 
