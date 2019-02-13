function writeTiff(I, filename)
%% write a 3D matrix into a tiff stack 
%{
%}

%% inputs
%{
    I: d1*d2*d3 array; tiff file name 
    filename: str; tiff file name 
%}

%% outputs
%{
%}

%% Author
%{
	Pengcheng Zhou 
	Columbia Unviersity, 2019
	zhoupc2018@gmail.com
	XXX License 
%}

%% write tiff stack 
imwrite(I(:, :, 1), filename); 
for m=2:size(I, 3)
    imwrite(I(:, :, m),  filename, 'writemode', 'append'); 
end
