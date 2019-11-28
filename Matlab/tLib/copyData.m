function copyData(sourceDir,destDir,filePattern)
% function copyData(sourceDir,destDir,filePattern)
%
% Handy function to copy data to new directory 
% where only files matching file pattern will be copied.
% INPUT_
% 	sourceDir	base directory of files to be copied
% 	destDir 	base directory where files are copied to
% 	filePattern	*cell array* with regexp for file patterns
% 
% EXAMPLE_
% 	'^dti.*\.nii$'	copy files starting w. "dti" and ending with ".nii"
% 	'.*\.bval$' 	copy files ending with ".bvals"
%	'^t1w.nii'	copy files named "t1w.nii"


if (~iscell(filePattern)),
   % suppose that only one string is given
   filePattern = {filePattern};
end
   

%filePattern ={'^dti.*\.nii$', '.*\.bval$', '.*\.bvec$','t1w.nii'};
logfile=fullfile(destDir,'logfile.txt');
fid= fopen(logfile,'w+');
for i=1:length(filePattern),
    foundFiles = findFiles(sourceDir,filePattern{i});
    for j=1:length(foundFiles),
        sourceFile = foundFiles{j};
        % strip off source path
        [sPath,fName,ext] = fileparts(foundFiles{j});
        fileName = [fName ext];
        k = strfind(sPath,sourceDir);
        if k > 1,
            error('error there shuld be only one match in string\n %s\n %s\n',sPath,sourceDir);
        end
        cut=length(sourceDir);
        newDirs = sPath(cut+1:end);
        relDest = newDirs;
        newDirList= regexp(newDirs,'/','split');
        baseDir = destDir;
        for m=1:length(newDirList),
            if ~isempty(newDirList{m}),                
                if ~exist(fullfile(baseDir,newDirList{m}),'dir'),
                    mkdir(baseDir,newDirList{m});
                end
                baseDir=fullfile(baseDir,newDirList{m});
            end
        end
        destFile = fullfile(destDir,relDest,fileName);
        % write to logfile
        fprintf(fid,'%s -> %s\n',sourceFile, destFile);
        fprintf('%s -> %s\n',sourceFile, destFile);
        copyfile(sourceFile,destFile)
    end
end
fclose(fid);


    
    
        
        