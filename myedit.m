function [] = myedit(filename)
%% create a new m file based on the template
%{
    you can create your own template by editing func_template.m in the same
    folder. 
%}

%% inputs: 
%{
    filename: string, the name of your file 
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

%%

% check whether the file existed or not  
if exist(filename, 'file')
   fprintf('The target file has been existed. Do you want to start a new one?\n'); 
   temp = input('Y/N: ', 's'); 
   if ~strcmpi(temp, 'Y')
       return; 
   end
end

% filenames 
tmp_dir = fileparts(which('myedit.m'));
template_file = fullfile(tmp_dir, 'func_template.m');
f_template = fopen(template_file, 'rt');
f_target = fopen(filename, 'wt');
[tdir, tname, ~] = fileparts(filename);

% first line
fgetl(f_template);
fprintf(f_target, 'function [] = %s()\n', fullfile(tdir, tname));

% copy the rest
tmp_line = fgetl(f_template);
while ischar(tmp_line)
    fprintf(f_target, '%s\n', tmp_line);
    tmp_line = fgetl(f_template);
end

% start editing
edit(filename)