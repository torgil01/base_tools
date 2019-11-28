function varargout = antsKellySlater(varargin)
% Wrapper for ANTS command: "KellySlater"
% 
% Usage
%   antsKellySlater(segImage,wmProb,gmProb,outputThickness)
% 
% SegImage : should contain the value 3 where WM exists and the value 2 where GM exists 
%
% Changelog:
% 21.01.13  -- command has to be run in data directory, produces additional output files; 
% corrfield, invfield, surf
%

opts.execute = false;
switch nargin,
    case 4,
        segImage = varargin{1};
        wmProb  = varargin{2};
        gmProb = varargin{3};
        thickness = varargin{4};
        chkFile(segImage);
        chkFile(wmProb);
        chkFile(gmProb);
    otherwise
        error('Incorrect number of input arguments');
end

% assume data dir is where the segmented image is 
[dataDir,fn] = fileparts(segImage);
baseDir = pwd;
cd(dataDir);
command = sprintf('KellySlater 3 %s %s %s %s 0.02 50 8 0 0.5',segImage,wmProb,gmProb,thickness);
cd(baseDir);

if opts.execute,
    [err,output]  = system(command);
    if err ~= 0,
        error('Error in antsImageMath.m; output from command:\n %s\n',output);
    end
end

if nargout == 1,
    varargout{1} = command;
end



