function ts = fslmeants(imageFile,mask)
% wrapper for fslmeants
% return ts as float vector
if ~exist(imageFile,'file'),
    error('File %s not found, exiting',file);
end
if ~exist(mask,'file'),
    error('File %s not found, exiting',file);
end

[err,output] = system(sprintf('fslmeants -i %s -m %s',imageFile,mask));
if err ~= 0,
    error('Error in fslmeants.m (fslmeants wrapper); output from command:\n %s\n',output);
end
%length(output)
cts = textscan(output(1:end),'%f');
ts = cell2mat(cts);
