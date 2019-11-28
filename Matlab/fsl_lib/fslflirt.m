function  = fslflirt(input,reference,output)
% wrapper for flirt
if ~exist(input,'file'),
    error('input file %s not found, exiting',file);
end
if ~exist(refernce,'file'),
    error('refernce file %s not found, exiting',file);
end

[err,output] = system(sprintf('flirt -in %s -ref %s -out %s',input,reference,output));
if err ~= 0,
    error('Error in fslflirt.m (flirt wrapper); output from command:\n %s\n',output);
end
