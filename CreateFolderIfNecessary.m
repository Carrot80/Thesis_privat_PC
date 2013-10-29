%% mkdirIfNecessary
%  Create a folder only, if it does not exist
%  If necessary, the whole path is created
%  reurn state
%  0 = Folder already exist, nothing done
%  1 = Folder does not exist, and is created
function [state] = mkdirIfNecessary( FullPath )
    state = 0;
    if ~exist( FullPath, 'dir')
        mkdir( FullPath );
        state = 1
    end
end


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