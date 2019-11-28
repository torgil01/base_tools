function varargout = antsWarp(varargin)
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

if nargin==3,
    imageFile = varargin{1};
    warpFile= varargin{2};
    referenceFile = varargin{3};
    % figure out of if filenames are given as paths
    [base,fname,ext] = fileparts(imageFile);
    imageFileName = [fname ext];    
    warpedImageFile =fullfile(base,['w' imageFileName]);
elseif nargin ==4,    
    imageFile  = varargin{1};
    warpFile= varargin{2};
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



% if ~exist(imageFile,'file'),
%     error('could not find image file %s\n',imageFile);
% end

affineFile = [warpFile 'Affine.txt'];
% if ~exist(affineFile,'file'),
%     error('could not find affine transformation %s\n',affineFile);
% end
diffeoFile = [warpFile 'Warp.nii.gz'];

% this is the correct command
% other variants seem to give incorrect results
% WarpImageMultiTransform 3 rFA_049.nii wrFA_049.nii 
% templaterFA_049Warp.nii templaterFA_049Affine.txt -R template.nii

% interpolation: linear default
% --use-NN: Use Nearest Neighbor Interpolation. 
% --use-BSpline: Use 3rd order B-Spline Interpolation. 

%  -R: reference_image space that you wish to warp INTO.
% 	   --tightest-bounding-box: Computes the tightest bounding box using all the affine transformations. It will be overrided by -R reference_image if given.
% 	   --reslice-by-header: equivalient to -i -mh, or -fh -i -mh if used together with -R. It uses the orientation matrix and origin encoded in the image file header. 
% 	   It can be used together with -R. This is typically not used together with any other transforms.

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
    sprintf('WarpImageMultiTransform 3 %s %s %s %s -R %s %s',...
    imageFile,warpedImageFile,diffeoFile,affineFile,referenceFile,options);
fprintf('%s\n',command);
if opt.execute,
    system(command);
end

if nargout == 1,
    varargout{1} = command;
end


