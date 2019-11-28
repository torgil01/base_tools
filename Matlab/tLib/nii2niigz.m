function nii2niigz(imageDir)
% convert *.nii files to *.nii.gz
% Usage: 
% niigz2nii(imageDir)
% Finds all *.nii files in image dir and gzip 
% See also: niigz2nii
% dependency: findFiles

niiFiles = findFiles(imageDir,'.*\.nii$');
if isempty(niiFiles),
    fprintf('No *.nii files found in %s\n',imageDir);
end

for i=1:length(niiFiles),
    fprintf('Compressing %s\n',niiFiles{i});
    gzip(niiFiles{i});
    delete(niiFiles{i});
end



