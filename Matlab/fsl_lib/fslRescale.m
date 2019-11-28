function fslRescale(input_img,rescaled_img,meanVal)
% rescale image to "meanVal" using fslmaths 
% function fslRescale(input_img,rescaled_img,meanVal)
% similar to shell cmd: 
% fslmaths img.nii -inm 100 scaled_img
command = sprintf('fslmaths %s -inm %f %s',input_img,meanVal,rescaled_img);
fprintf('%s\n',command);
[err,out] = system(command);
if err ~= 0,
    error('nonzero exit for command; %s\n with output\n %s\n',err,out);
end


