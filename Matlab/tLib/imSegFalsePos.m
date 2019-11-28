function fp = imSegFalsePos(imA,imRef)
% function fp = imSegFalsePos(imA,imRef)
% return false positive ration (fp) between a binary image (0|1) imA and a reference image 
% imRef. fp is defined as
%   fp = (vol(imA) - overlap(imA,imRef))/vol(imRef)
% imA and imRef are NII images
% ---------------------------------------------
% See Shiee NI 2009 for definition of FP 
% this is however defined differently by deBoer, NI 2009
% ----------------------------------------------
% 
% TRV 28.02.2011

% check image dimensions
Va = spm_vol(imA);
Vref= spm_vol(imRef);

% should really check that images are binary 

if ~all(Va.dim == Vref.dim),
    error('Image dimensions must be equal; A=[%i %1 %i], B=[%i %i %i]',Va.dim,Vref.dim)
end

% read image data im memory; 
volA = spm_read_vols(Va);
volRef = spm_read_vols(Vref);

ov = volA & volRef;
overlap = sum(ov(:) > 0);
szRef = sum(volRef(:) > 0);
szA = sum(volA(:) > 0);

fp = (szA - overlap)/szRef;


