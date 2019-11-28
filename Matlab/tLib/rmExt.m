function varargout = rmExt(fullFileName)
% function filename = rmExt(fullFileName)
% remove extension from filename 
% 
[base,fn1,ext] = fileparts(fullFileName);
fn2 = [fn1 ext];
[filename,ext] = strtok(fn2,'.');
filepath = fullfile(base,filename);

switch nargout,
  case 1,
      varargout{1}  = filepath;
  case 2,
    varargout{1}  = filepath;
    varargout{2}  = filename;
  otherwise
    error('incorrect numner of output args');
end
