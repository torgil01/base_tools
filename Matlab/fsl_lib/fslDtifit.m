function fslDtifit(varargin)
% function fslDtifit(dtiFile,outFile,mask,bvec,bval)
% wrapper for dtifit

% defaults
%interp = 'trilinear'; %['triliar', 'spline']
switch nargin,
    case 5,
        inputVol = varargin{1};
        outFile = varargin{2};
        mask = varargin{3};
        bvec = varargin{4};
        bval = varargin{5};
    otherwise,
        error('Incorrect number of input arguments');
end

if ~exist(inputVol,'file'),
    error('File %s not found, exiting',inputVol);
end


command = sprintf('dtifit -w -k %s -o %s -m %s -r %s -b %s ',...
    inputVol,outFile,mask,bvec,bval);
fprintf('%s\n',command);
[err,output] = system(command);
if err ~= 0,
    error('Error in fslDtifit.m ( wrapper); output from command:\n %s\n',output);
end
