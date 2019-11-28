function files = findFiles(baseDir,fileName)
% files = findFiles(baseDir,fileName)
% Search all subdirectories in base dir and return full path to all files
% called "filename" 
% Note that filename is treated as regexp 
%
% Examples:
% regexp = '^file.*.nii'  : find all files starting w. 'file' and ending with nii
% regexp = '.*\.nii$'      : fild all files with .nii ext ($ is for ending) 
%
% files= findFiles(fileDir,'^gr1_wanat\w+[0123456789]Warpxvec.nii')
% Note: 
% use REGEXPTRANSLATE for generating regexp
% 
% CHANGELOG:
% 20.04.12  Fix incorrect recursive call, called an old version of the code, now this
% routine is called
% 21.02.18 Fix bug when there are .-files present


files='';
if ~exist(baseDir,'dir'),
    error(sprintf('Path: %s not found, exiting.',baseDir));
end

tdir=dir(baseDir);
num_files = length(tdir);
k=1;
for i=1:num_files; % two first files are '.' and '..' ## fails with dot files!
    if any(strcmp(tdir(i).name,{'.','..'})),
        continue
    end
    tfiles='';
    t2files='';
    if (tdir(i).isdir==1), % is a dir
        newDir=fullfile(baseDir,tdir(i).name);
        %t2files=findImage2(newDir,fileName);
        t2files=findFiles(newDir,fileName);
    else
        %if (strmatch(fileName,tdir(i).name)),
        if ~isempty(regexpi(tdir(i).name, fileName)),
            files{k} = fullfile(baseDir,tdir(i).name);
            k=k+1;
        end
    end
    fsb=length(t2files);
    if (fsb > 0),
        for j=1:fsb,
            files{k}=t2files{j};
            k=k+1;
        end
    end
end
return
