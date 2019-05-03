function [options]=fix_missing_options(options_default, options)
%% function goal
%{
	details
%}

%% inputs
%{
	options_default: struct variable; default options
	options: struct variable; new options
%}

%% outputs
%{
	options: struct variable; fill the missing fields of the input
	options with the default values 
%}

%% Author
%{
	Pengcheng Zhou 
	Columbia Unviersity, 2019
	zhoupc2018@gmail.com
	GPL License 
%}

%% code

fields_default = fieldnames(options_default); 
for m=1:length(fields_default)
    tmp_field = fields_default{m}; 
    if ~isfield(options, tmp_field) || isempty(options.(tmp_field))
        options.(tmp_field) = options_default.(tmp_field); 
    end 
end 