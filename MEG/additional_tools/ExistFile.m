%% ExistFile
%  Check the existance of a file
%  File name can be relative or absolute
%  reurn state
%  0 = File does not exist
%  1 = File does exist
function [state] = ExistFile(FileName)
    state = 0;
    if exist('appdata.txt', 'file')
        state = 1;
    end 
end