function nVol = fslnvols(imageFile)
% wrapper for fslnvols
if ~exist(imageFile,'file'),
    error('File %s not found, exiting',file);
end
[err,output] = system(sprintf('fslnvols %s',imageFile));
if err ~= 0,
    error('Error in fslnvols.m (fslnvols wrapper); output from command:\n %s\n',output);
end
nVol = str2num(output);
if isempty(nVol),
    warning('fslnvol returns empty value');
end

