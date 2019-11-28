function newFilename= addInEnd(filename,str)
% newFilename= addInEnd(filename,str)
% add string "str" in end of a filename
% eg: filename = '/aaa/bbb/file.nii',
% and str = '_r'
% then newFilename = '/aaa/bbb/file_r.nii',

[base,~] = fileparts(filename);
ext = getExt(filename);
[~, fname] = rmExt(filename);
newFname = [fname str ext];
newFilename = fullfile(base,newFname);

% old code
% [base,fname,ext] = fileparts(filename);
% newFname = [fname str ext];
% newFilename = fullfile(base,newFname);
