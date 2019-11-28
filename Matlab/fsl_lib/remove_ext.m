function fn = remove_ext(filename)
% function remove_ext(filename)
% wrapper for "remove_ext" in fsl 
% this should be written in clean matlab

command = sprintf('remove_ext %s',filename);
%fprintf('%s\n',command);
[err,out] = system(command);

if err ~= 0,
    error('nonzero exit for command; %s\n with output\n %s\n',command,out);
end
fn = out(1:end-1);
