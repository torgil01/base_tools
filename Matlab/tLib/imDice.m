function dce = imDice(imA,imB)
% calculate Dice coefficient between two binary images A and B.
% images are assumed to be in nii format
% dce = imDice(imA,imB)
% dce = 2*overlap(A,B)/(vol(A)+vol(B)
% -------------------------------------
% Testing
% imDice(A,A) = 1;
% imDice(A,B) = 0.9982  (1 pixel more in B)
% imDice(A,B) = 0.9963  (2 pix more in B)
% 
% ---------------------------
% TRV 28.02.2011

% check image dimensions
Va = spm_vol(imA);
Vb= spm_vol(imB);

% should really check that images are binary 

if ~all(Va.dim == Vb.dim),
    error('Image dimensions must be equal; A=[%i %1 %i], B=[%i %i %i]',Va.dim,Vb.dim)
end

% read image data im memory; 
volA = spm_read_vols(Va);
volB = spm_read_vols(Vb);

ov = volA & volB;
overlap = sum(ov(:) > 0);
szA = sum(volA(:) > 0);
szB = sum(volB(:) > 0);

dce = 2*overlap/(szA + szB);



