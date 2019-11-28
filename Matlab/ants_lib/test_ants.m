% testin ants lib

% template =
% '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test_ants_template_native/MYtemplate.nii.gz';
%template = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test_ants_template_native/resliced_template/Iso_tempateBS.nii.gz';
template = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/template_40/template40_iso/TOS40_iso_tempate.nii.gz';
nativeT1 = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test/0001/T1w/msst1w.nii';

warpedT1 ='/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test/0001/T1w/warp_1cc_t1w.nii';

nativeFLAIR = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test/0001/FLAIR/mfl_0001.nii';
warpedFLAIR = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test/0001/FLAIR/warped_fl_0001.nii';
wmhMask = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test/0001/FLAIR/tmask_0001.nii';
warpedWmhMask = '/home/torgil/Work/TOS/wmh_stat/imageData/ants_norm/test/0001/FLAIR/warped_tmask_0001.nii';
%%% 
[base,fn,ext] = fileparts(warpedT1);
warpName = fullfile(base,fn);


% 1. calculate T1 -> template mapping
opt.maxIter = '100x100x100x20';
opt.transformation = 'SyN[0.25]';
%opt.model = 'MI';
%opt.modelWeight = 1;
%opt.modelRadius = 4;
ants(template,nativeT1,warpedT1,opt) 
% consider returning arguments w. output files

% 2. warp T1 using previous mapping
opts.interpolation = 'spline';
antsWarp(nativeT1,warpName,template,warpedT1,opts);
% 
% % 3. warp FLAIR to tempate
% antsWarp(nativeFLAIR,warpName,template,warpedFLAIR,opts);
% 
% % 4. warp WMH mask to tempate using NN interpol
% opts.interpolation = 'nn';
% antsWarp(wmhMask,warpName,template,warpedWmhMask,opts);

