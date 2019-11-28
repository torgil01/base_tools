function ext = getFslExt
% determine file extensions for FSL based on the environment variable FSLOUTPUTTYPE


[err,otype] = system('echo $FSLOUTPUTTYPE');
otype = deblank(otype);
if err ~= 0, 
    error('Unable to determine value of $FSLOUTPUTTYPE, output is \n %s\n',otype);
end

switch otype,
    case 'NIFTI_GZ',
        ext = 'nii.gz';
    case 'NIFTI',
        ext = 'nii';
    otherwise
        % fsl support other formats such as analyze, but we should not really be using
        % anaything else than nii or nii.gz
        error('unsupported');
end

