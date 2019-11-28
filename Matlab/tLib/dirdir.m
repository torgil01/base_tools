function varargout = dirdir( path )
% DIRDIR List subdirectories of a directory.
% usage 
% (1) fullapth = dirdir(path)  
% : return absolute path to sub directorues in "path" as cell array
% (2) [fullapth, dirNames] = dirdir(path)
% : return absolute path to sub directorues in "path" cell array and
% only directory names as cell array

if nargin == 0
    path = pwd;
end
dirList =[];
dirListFullpath = [];
d=dir(path);
j=1;
for i=3:length(d),
    if d(i).isdir,
        dirList{j} = d(i).name;
        dirListFullpath{j}=fullfile(path,d(i).name);  % absolute path
        j=j+1;
    end
end


switch nargout,
    case 0,
        for i =1:length(dirList),
            fprintf('%s\n',dirListFullpath{i}),
        end
    case 1,
        % only return full path
        varargout{1} =  dirListFullpath;
    case 2
        varargout{1} =  dirListFullpath;
        varargout{2} =  dirList;
    otherwise,
        error('incorrect number of output arguments');
end