function chkFile(file)
% function chkFile(file)
% check that file exist, exit with error if not 
if ~exist(file,'file'),
    error('File %s not found, exiting',file);
end
