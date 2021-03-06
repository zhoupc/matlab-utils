function [] = fnew(func_name, rm_old, update_meta, target_dir)
%% create a matlab function file using standard template 
%{
    This function is creatd using standard template 
%}

%% inputs: 
%{
    func_name: str, function name 
    rm_old: boolean, remove old files or not (default: no deletion)
    update_meta: boolean, update meta info or not (default: no update)    
    target_dir: directory (str), the target folder to include the file 
%}

%% outputs: 
%{
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
    GPL-3.0 License 
%}

%% code 
if ~exist('rm_old', 'var') || isempty(rm_old)
    rm_old = false; 
end
if ~exist('update_meta', 'var') || isempty(update_meta)
    update_meta = false; 
end

if ~exist('target_dir', 'var') || isempty(target_dir)
    target_dir = pwd(); 
end

file_name = fullfile(target_dir, sprintf('%s.m', func_name));
if exist(file_name, 'file') && ~rm_old
    fprintf('The target file has been existed. Do you want to start a new one?\n');
    temp = input('Y/N: ', 's');
    if ~strcmpi(temp, 'Y')
        return;
    end
end
fp = fopen(file_name, 'w');

%% load author information 
tmp_folder = fileparts(which('fnew.m')); 
meta_file = fullfile(tmp_folder, 'metainfo.mat');
if ~exist(meta_file, 'file') || update_meta
    fprintf('We need some info from you: \n'); 
    metainfo.author = input('Your name: ', 's'); 
    metainfo.affiliation = input('Where are you working: ', 's'); 
    metainfo.email = input('Your email address: ', 's'); 
    metainfo.license = input('which license do you want to use (GPL 3.0, BSD 2.0, etc.): ', 's'); 
    save(meta_file, 'metainfo'); 
else
    load(meta_file); 
end 

%% start writing the file 
one_p = '%'; 
two_p = '%%'; 
fprintf(fp, 'function [output1]=%s(input1, intput2)\n', func_name); 
% function description 
fprintf(fp, '%s function goal\n', two_p); 
fprintf(fp, '%s{\n\tdetails\n%s}\n\n', one_p, one_p); 

% inputs
fprintf(fp, '%s inputs\n', two_p); 
fprintf(fp, '%s{\n\tinput1: boolean; explain input1\n\tinput2: 3X3 matrix; explain input2\n%s}\n\n', one_p, one_p);  

% outputs 
fprintf(fp, '%s outputs\n', two_p); 
fprintf(fp, '%s{\n\toutput1: str; explain output1\n\toutput2: double scalar; explain output\n%s}\n\n', one_p, one_p);  

% author 
fprintf(fp, '%s Author\n', two_p); 
fprintf(fp, '%s{\n', one_p); 
fprintf(fp, '\t%s\n', metainfo.author); 
temp = date(); 
idx = strfind(temp, '-');  idx = idx(end)+1; 
fprintf(fp, '\t%s, %s\n', metainfo.affiliation, temp(idx:end)); 
fprintf(fp, '\t%s\n', metainfo.email); 
fprintf(fp, '\tXXX License \n'); 
fprintf(fp, '%s}\n\n', one_p); 

% code 
fprintf(fp, '%s code', two_p); 
fclose(fp); 
edit(file_name); 