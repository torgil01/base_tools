function rotateBvecs(bvec,bvecCorr,eccLog)
% rotateBvecs(bvec_in,bvec_rot,corr_ecclog);
% wrapper for fdt_rotate_bvecs
% note that in an new fsl install the fdt_rotate_bvecs script scrip is 
% sh and must be changed to bash to work
command = sprintf('fdt_rotate_bvecs %s %s %s  ',bvec,bvecCorr,eccLog);
fprintf('%s\n',command);
[err,output] = system(command);
if err ~= 0,
    error('Error in fdt_rotate_bvecs ; output from command:\n %s\n',output);
end