function varargout=antsWarpInverse(varargin)
% imageFile,warpFile,referenceFile
% warp image file using warps specified in warp file
% 
% ants warps are stored in 4 files, a affine transformation stored in a
% text file and three warp files (nifti) 
% all files have the same base name
% 
% (name)Affine.txt
% (name)Warpxvec.nii
% (name)Warpyvwc.nii
% (name)Warpzvec.nii
% 
% the input parameter 'warpFile' specifies name 
%


opt.interpolation = 'linear'; % 'nn', 'spline'
opt.tightestboundingbox = false; % true|false
opt.execute = true;
opt.echoCommand = true;

if nargin==3,
    imageFile = varargin{1};
    warpFile = varargin{2};
    referenceFile = varargin{3};
    warpedImageFile =fullfile(base,['w' imageFileName]);
elseif nargin ==4,
    imageFile = varargin{1};
    warpFile = varargin{2};
    referenceFile = varargin{3};
    warpedImageFile = varargin{4};
elseif nargin == 5,
    imageFile  = varargin{1};
    warpFile= varargin{2};
    referenceFile = varargin{3};   
    warpedImageFile = varargin{4};
    iopt = varargin{5};              
    if isfield(iopt,'interpolation'),
        opt.interpolation = iopt.interpolation;
    end
    if isfield(iopt,'tightestboundingbox'),
        opt.tightestboundingbox = iopt.tightestboundingbox;
    end
    if isfield(iopt,'execute'),
          opt.execute = iopt.execute;
    end 
else
    error('Incorrect number of input argumants');        
end


if ~exist(imageFile,'file'),
    error('could not find image file %s\n',imageFile);
end
% figure out of if filenames are given as paths 
[base,fname,ext] = fileparts(imageFile);
imageFileName = [fname ext];

affineFile = [warpFile 'Affine.txt'];
if ~exist(affineFile),
    error('could not find affine transformation %s\n',affineFile);
end
diffeoFile = [warpFile 'InverseWarp.nii'];


% this is the correct command
% other variants seem to give incorrect results
% WarpImageMultiTransform 3 rFA_049.nii wrFA_049.nii 
% templaterFA_049Warp.nii templaterFA_049Affine.txt -R template.nii

options = '';
switch lower(opt.interpolation),
    case 'nn',
        options = sprintf('%s --use-NN ',options);
    case 'spline',
        options = sprintf('%s --use-BSpline ',options);
end

if opt.tightestboundingbox,   
    options = sprintf('%s --tightest-bounding-box ',options);
end



command = ...
    sprintf('WarpImageMultiTransform 3 %s %s -i %s %s -R %s %s',...
    imageFile,warpedImageFile,affineFile,diffeoFile,referenceFile,options);

if opt.echoCommand,
    fprintf('%s\n',command);
end
if opt.execute,
    system(command);
end

if nargout == 1,
    varargout{1} = command;
end


