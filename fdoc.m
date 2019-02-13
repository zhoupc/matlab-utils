function []=fdoc(file_name)
%% add documentary info to existing files
%{
%}

%% inputs
%{
	file_name: str; matlab function file name
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

%% code
if ~exist(file_name, 'file')
    error('The file does not exist. Please check your input.\n');
else
    fp = fopen(file_name, 'r');
    fp_new = fopen(['temp_', file_name], 'w');
end

%% find the function definition
while ~feof(fp)
    tmp_str = fgetl(fp);
    fprintf(fp_new, '%s\n', tmp_str);
    
    if contains(tmp_str, 'function') && contains(tmp_str, '(')
        %find inputs and outputs
        tmp_str = erase(tmp_str, {'function', '[', ']', ' '});
        idx_eq = strfind(tmp_str, '=');
        % left side
        if isempty(idx_eq)
            output_vars = {};
        else
            output_vars = strsplit(tmp_str(1:(idx_eq-1)), ',');
        end
        % right side
        idx_lp = strfind(tmp_str, '(');
        idx_rp = strfind(tmp_str, ')');
        input_vars = strsplit(tmp_str((idx_lp+1):(idx_rp-1)), ',');
        
        % add a header
        
        % load author information
        tmp_folder = fileparts(which('fdoc.m'));
        meta_file = fullfile(tmp_folder, 'metainfo.mat');
        if ~exist(meta_file, 'file')
            fprintf('We need some info from you: \n');
            metainfo.author = 'author name';
            metainfo.affiliation = 'affiliation';
            metainfo.email = 'email';
            metainfo.license = 'license';
        else
            load(meta_file, 'metainfo');
        end
        
        %% start writing the file
        one_p = '%';
        two_p = '%%';
        % function description
        fprintf(fp_new, '%s function goal\n', two_p);
        fprintf(fp_new, '%s{\n\tdetails\n%s}\n\n', one_p, one_p);
        
        % inputs
        fprintf(fp_new, '%s inputs\n', two_p);
        fprintf(fp_new, '%s{\n', one_p);
        for m=1:length(input_vars)
            fprintf(fp_new, '\t%s: type; description\n', input_vars{m});
        end
        fprintf(fp_new, '%s}\n\n', one_p);
        % outputs
        fprintf(fp_new, '%s outputs\n', two_p);
        fprintf(fp_new, '%s{\n', one_p);
        for m=1:length(output_vars)
            fprintf(fp_new, '\t%s: type; description\n', output_vars{m});
        end
        fprintf(fp_new, '%s}\n\n', one_p);
        % author
        fprintf(fp_new, '%s Author\n', two_p);
        fprintf(fp_new, '%s{\n', one_p);
        fprintf(fp_new, '\t%s\n', metainfo.author);
        temp = date();
        idx = strfind(temp, '-');  idx = idx(end)+1;
        fprintf(fp_new, '\t%s, %s\n', metainfo.affiliation, temp(idx:end));
        fprintf(fp_new, '\t%s\n', metainfo.email);
        fprintf(fp_new, '\tXXX License \n');
        fprintf(fp_new, '%s}\n\n', one_p);
        
        break;
    end
end

% copy the rest
while ~feof(fp)
    tmp_str = fgetl(fp);
    fprintf(fp_new, '%s\n', tmp_str);
end
fclose(fp);
fclose(fp_new);

movefile(['temp_', file_name], file_name);
edit(file_name);