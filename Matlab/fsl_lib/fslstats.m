function answ = fslstats(varargin)
% matlab wrapper for fslatats
% Usage:
% answ = fslstats(file,operation)
% answ = fslstats(file,operation,mask) % mask is a binary mask file
% note that it is not neccesary to specify the -k flag when using a mask
% ------- options ------------------
% supported options
% -r           : output <robust min intensity> <robust max intensity>
% -R           : output <min intensity> <max intensity>
% -e           : output mean entropy ; mean(-i*ln(i))
% -E           : output mean entropy (of nonzero voxels)
% -v           : output <voxels> <volume>
% -V           : output <voxels> <volume> (for nonzero voxels)
% -m           : output mean
% -M           : output mean (for nonzero voxels)
% -s           : output standard deviation
% -S           : output standard deviation (for nonzero voxels)
% -w           : output smallest ROI <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <tmin> <tsize> containing nonzero voxels
% -x           : output co-ordinates of maximum voxel
% -X           : output co-ordinates of minimum voxel
% -c           : output centre-of-gravity (cog) in mm coordinates
% -C           : output centre-of-gravity (cog) in voxel coordinates
% -p <n>       : output nth percentile (n between 0 and 100)
% -P <n>       : output nth percentile (for nonzero voxels)
% -a           : use absolute values of all image intensities
% -n           : treat NaN or Inf as zero for subsequent stats

% parse input
mask = '';
switch nargin,
    case 2, 
        file = varargin{1};
        operation = varargin{2};
    case 3,
        file = varargin{1};
        operation = varargin{2};
        mask = varargin{3};
    otherwise, 
        error('Incorrect number of input arguments');
end

% the mask must be first in order to affect the stats computations
if ~isempty(mask),
    operation = [' -k ' mask ' ' operation];
end
command = sprintf('fslstats %s %s',file,operation);
fprintf('%s\n',command);
[err,out] = system(command);
if err ~= 0,
    error('nonzero exit for command; %s\n with output\n %s\n',err,out);
end
answ = str2num(out);


