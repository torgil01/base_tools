function fslroi(inputVol,outputVol,tstart,tlength)
% function fslroi(inputVol,outputVol,tstart,tlength)
%
% wrapper for fslroi, only for time-axis
% ARGS:
% inputVol   : path to input vol that is to be cropped in time
% outputVol  : path to new image file 
% tstart     : start point for volume (remember that t=0 is the first point)
% tlength    : number of volumes to keep
% 
if ~exist(inputVol,'file'),
    error('File %s not found, exiting',file);
end
nVols = fslnvols(inputVol);
if nVols < tlength, 
    error('Input volume has only %i time points, but the crop length is %i',nVols,tlength);
end
[err,output] = system(sprintf('fslroi %s %s %i %i',inputVol,outputVol,tstart,tlength));
if err ~= 0,
    error('Error in fslroi.m (fslroi wrapper); output from command:\n %s\n',output);
end
