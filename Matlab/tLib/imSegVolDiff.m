function vd = imSegVolDiff(imA,imRef)
% function vd = imSegVolDiff(imA,imB)
% 
% VD = abs(1 - vol(A)/vol(Ref)) 
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

szRef = sum(volRef(:) > 0);
szA = sum(volA(:) > 0);

vd = abs(1 -szA/szRef) ;


