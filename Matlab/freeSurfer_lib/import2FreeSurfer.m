function runReconAll(subjDir,nCores)
% run recon-all -all 

command = sprintf('export SUBJECTS_DIR=%s',destDir);
system(command)

t1Files = findFiles(sourceDir,t1FileName);
if isempty(t1Files),
    error('No files found')
    exit
end

for i=1:length(t1Files),
    id = getID(t1Files{i},idlevel);
    command = sprintf('recon-all -i %s -subjid %s',t1Files{i},id);
    fprintf('%s\n',command)
end

