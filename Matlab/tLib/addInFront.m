function newFilename= addInFront(filename,str)
% newFilename= addInFront(filename,str)
% add string "str" in fornt of a filename
% eg: filename = '/aaa/bbb/file.nii',
% and str = 'r'
% then newFilename = '/aaa/bbb/rfile.nii',

[base,~] = fileparts(filename);
ext = getExt(filename);
[~, fname] = rmExt(filename);
newFname = [str fname ext];
newFilename = fullfile(base,newFname);


% [base,fname,ext] = fileparts(filename);
%newFname = [str fname ext];
%newFilename = fullfile(base,newFname);

