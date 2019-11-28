function files=rec_dir(dirPath,ext)
% Based on rec_dir
% searces recursevly in structure and return all subdirs

see function subdir
files='';
if ~exist(dirPath),
    error(sprintf('Path: %s not found, exiting.',dirPath));
end
tdir=dir(dirPath);
[num_files dummy] = size(tdir);
k=1;
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
return
