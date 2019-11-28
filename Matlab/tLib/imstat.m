function S=imstat(A,tresh)
% return basic info about matrix A in structure S
% S.max = max value
% S.min = min value
% S.mean = mean value
% S.nx = dim x
% S.ny = dim y
% S.sdev = std deviation
% S.massCenter = center of mass
if isa(A,'char'),
    % assume that A is a nii file
    x = spm_read_vols(spm_vol(A));
    x=x(:);
else
    x=A(:);
end
%x(x == NaN) = 0;
x=x(x > tresh);
x=x(x <= 1);
S.npix=length(x);
S.treshold=tresh;
S.max = max(x);
S.min = min(x);
S.sdev=std(x);
%[S.nx,S.ny]=size(A);
S.mean=mean(x);
S.median=median(x);
S.kurtosis=kurtosis(x);
S.skewness=skewness(x);
