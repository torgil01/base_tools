function filename = replaceExt(fullFileName,newExt)
% function filename = replaceExt(fullFileName,newExt)
% replace original extention of filename with neew extension 
% 

if isempty(fullFileName),
  filename = '';  
else
  [base,fn1,ext] = fileparts(fullFileName);
  fn2 = [fn1 ext];
  [filename,ext] = strtok(fn2,'.');
  if strcmp(newExt(1),'.'),
      filename = fullfile(base,[filename newExt]);
  else
      filename = fullfile(base,[filename '.' newExt]);
  end
end
