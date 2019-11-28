function eddy_correct(varargin)
% function eddy_correct(inputVol,outputVol,ref)
% function eddy_correct(inputVol,outputVol,ref,intetrp)
% wrapper for eddy_correct

% defaults
interp = 'trilinear'; %['triliar', 'spline']
switch nargin,
    case 3,
        inputVol = varargin{1};
        outputVol = varargin{2};
        ref= varargin{3};
    case 4,
        inputVol = varargin{1};
        outputVol = varargin{2};
        ref= varargin{3};
        interp = varargin{4};
    otherwise,
        error('Incorrect number of input arguments');
end

if ~exist(inputVol,'file'),
    error('File %s not found, exiting',file);
end

%inputVol = remove_ext(inputVol);
outputVol = remove_ext(outputVol);

command = sprintf('eddy_correct %s %s %i %s ',inputVol,outputVol,ref,interp);
fprintf('%s\n',command);
[err,output] = system(command);
if err ~= 0,
    error('Error in eddy_correct.m (fslnvols wrapper); output from command:\n %s\n',output);
end

