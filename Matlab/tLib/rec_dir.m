function files=rec_dir(dirPath,ext)
% ***************************************************************
%$Id: recurseDir.m,v 1.3 2002/08/09 13:13:11 TRV Exp $
% ***************************************************************
%
% function [files] = recurseDir(dirPath,ext)
%
% Arguments:
%    dirPath : path
%    ext     : file extention
% Purpose:
%   descent recursively into directory 'dirPath' and return 
%   structure 'files' containing files that have the extention 'ext'
%   This function is similar toi the matlab 'dir' comand
% Returns: 
%   Structure files with elements:
%   files(i).name :  name of file i
%   files(i).full_filename : filename including full path
% Changelog
%   21.01.2003 modify code to accept empty file suffix
%   12.04.2007 code can now handle files that have '.' in the filenames,
%   use the fileparts command

files='';
if ~exist(dirPath),
    error(sprintf('Path: %s not found, exiting.',dirPath));
end
tdir=dir(dirPath);
[num_files dummy] = size(tdir);
k=1;
if strcmp(ext,''), %special case for files w. no extention
    % for files wo. suffix default behaviour is to include these and exclude all others
    for i=3:num_files; % two first files are '.' and '..'
        tfiles='';
        t2files='';
        if (tdir(i).isdir==1), % is a dir
            newDir=fullfile(dirPath,tdir(i).name);
            t2files=rec_dir(newDir,ext);
        else,
            if isempty(findstr(tdir(i).name,'.')), %if no suffix we add file to list
                % if file extention match file filter add file to struct
                S=fullfile(dirPath,tdir(i).name);
                files(k).name=tdir(i).name;
                files(k).full_filename=S;
                k=k+1;
            end
        end
        [dummy fsb]=size(t2files);
        if (fsb > 0),
            for j=1:fsb,
                files(k).name=t2files(j).name;
                files(k).full_filename=t2files(j).full_filename;
                k=k+1;
            end
        end
    end
else
    for i=3:num_files; % two first files are '.' and '..'
        tfiles='';
        t2files='';
        if (tdir(i).isdir==1), % is a dir
            newDir=fullfile(dirPath,tdir(i).name);
            t2files=rec_dir(newDir,ext);
        else,
            [pathstr, name, fext] = fileparts(tdir(i).name); % fext returns dot.
            last=fext(2:end);
            if (strcmp(ext,last)), % if file extention match file filter add file to struct
                S=fullfile(dirPath,tdir(i).name);
                files(k).name=tdir(i).name;
                files(k).full_filename=S;
                k=k+1;
            end
        end
        [dummy fsb]=size(t2files);
        if (fsb > 0),
            for j=1:fsb,
                files(k).name=t2files(j).name;
                files(k).full_filename=t2files(j).full_filename;
                k=k+1;
            end
        end
    end
end
return
