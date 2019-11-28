function collectFiles(sourceDir,destDir,filePattern,lev)
% collectFiles(sourceDir,destDir,filePattern,lev)
%
% copy files matching filePattern from sourceDir to a single directory "destDir"
% The routine is intended to copy files from a study--subject file three to a single directory. 
% The files might have to be renamed.
% Parameters 
%   sourceDir       : where the original files are
%   destDir         : where the files are copied
%   filePattern     : regexp for finding source files
%   lev             : source directory structure, 
%                     lev=1 :: studyDir/id/file.nii; 
%                     lev=2 :: studyDir/id/subDir/file.nii
%                     lev=3 :: studyDir/id/scandate/seriesDir/file.nii
%                     

opt.simulate = false;
opt.rename = true;

copyFiles = findFiles(sourceDir,filePattern);
if isempty(copyFiles),
    warning('No files found in %s matching search pattern %s, exiting.',sourceDir,filePattern);
end

if ~exist(destDir,'dir'),
    warning('Creating destination dir; $s\n',destDir);
    [basePath,destDirName] = fileparts(destDir);
    mkdir(basePath,destDirName);
end        
for i=1:numel(copyFiles),
  [~,fn,ext] = fileparts(copyFiles{i});
  if opt.rename,
      id = getID(copyFiles{i},lev);
      destFile = fullfile(destDir,[id '_' fn ext]);
      % check in case of several scans for same ID
      if exist(destFile,'file'),
          destFile = fullfile(destDir,[id '_' fn '_2' ext]);
      end
  else
      destFile = fullfile(destDir,[fn ext]);      
  end
  fprintf('copying %s -> %s\n',copyFiles{i},destFile);
  if ~opt.simulate,
      copyfile(copyFiles{i},destFile);
  end
end

