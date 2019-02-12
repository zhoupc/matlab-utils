function doesExist = exist_in_workspace(var_name, ws)
%% check whether a variable is in the base workspace or not

%% inputs: 
%{
    var_name: string, variable name 
    ws:  string, the workspace to check (default: base)
%}

%% outputs: 
%{
    doesExist: boolean, exist -- true; does not exist -- false
%}

%% author: 
%{
    Pengcheng Zhou 
    Columbia University, 2018 
    zhoupc1988@gmail.com
%}

%% code 
if ~exist('ws', 'var') || isempty(ws)
    ws = 'base'; 
end
temp = evalin(ws,sprintf('whos(''%s'');', var_name)); %or 'base'
doesExist = ~isempty(temp); 