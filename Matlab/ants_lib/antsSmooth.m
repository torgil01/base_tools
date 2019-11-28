function varargout = antsSmooth(varargin)
% Gaussian smoothing trough ANTS command SmoothImage
% sigma is specified in physical units (mm)
% FWHM = sigma*2.3548
%
% Usage:
% varargout = antsSmooth(imageFile,sigma)
% varargout = antsSmooth(imageFile,sigma,outputFile)
% -- in no utput file is given, an 's' will be appended to the original filename

opt.voxelUnits = false;
opt.execute = true;

switch nargin,
    case 2,
        imageFile = varargin{1};
        sigma= varargin{2};
        outputFile = addInFront(imageFile,'s');
    case 3,
        imageFile = varargin{1};
        sigma= varargin{2};
        outputFile = varargin{3};
    otherwise
        error('Incorrect number of input argumants');
end


if ~exist(imageFile,'file'),
    error('could not find image file %s\n',imageFile);
end


command = sprintf('SmoothImage 3 %s %f %s',imageFile,sigma,outputFile);
if opt.execute,
    [err,output]  = system(command);
    if err ~= 0,
        error('Error in antsSmooth.m; output from command:\n %s\n',output);
    end
end


if nargout == 1,
    varargout{1} = command;
end

