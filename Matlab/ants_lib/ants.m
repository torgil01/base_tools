function varargout=ants(varargin)
% --- matlab wrapper for the ANTS exe
% Usage:
% function ants(fixedImage, movingImage, outputImage)
% function ants(fixedImage, movingImage, outputImage, opt)
%
% opt.model = [CC,MI,PR,MSQ]  default PR
% opt.maxIter = '50x50x50x20'  default
% opt.regularization = 'Gauss[3,0]' default
% opt.transformation = 'SyN[0.25]' defualt
% opt.mask  = ['' (default) | 'path/to/lesion_mask'] ==0 lesion == 1 normal
%   ** NOTE ** mask must be defined in *fixed* image space
% opt.saveCommand
% CHANGELOG:
% 14.05.12  created
% 18.07.12  added option for using lesion mask 

% default settings
opt.model = 'CC';
opt.maxIter = '50x50x50x20';
opt.regularization = 'Gauss[3,0]';
opt.transformation = 'SyN[0.25]';
opt.saveCommand = true;
opt.dim = 3;
opt.modelWeight = 1;
opt.modelRadius = 4;
opt.execute = true; % if true do  execute command 
opt.mask = '';

% parse input 
if ((nargin  < 3) && (nargin > 4)),
    error('incorrect input arguments');    
elseif nargin == 3, 
    fixedImage = varargin{1};
    movingImage = varargin{2};
    outputImage = varargin{3};
elseif nargin == 4, 
    fixedImage = varargin{1};
    movingImage = varargin{2};
    outputImage = varargin{3};
    iopt = varargin{4};              
    if isfield(iopt,'model'),
        opt.model = iopt.model;
    end
    if isfield(iopt,'maxIter'),
        opt.maxIter = iopt.maxIter;
    end
    if isfield(iopt,'regularization'),
        opt.regularization = iopt.regularization;
    end
    if isfield(iopt,'transformation'),
        opt.transformation = iopt.transformation;
    end        
    if isfield(iopt,'modelRadius'),
          opt.modelRadius = iopt.modelRadius;
    end 
    if isfield(iopt,'modelWeight'),
          opt.modelWeight = iopt.modelWeight;
    end 
    if isfield(iopt,'execute'),
          opt.execute = iopt.execute;
    end 
    if isfield(iopt,'mask'),
          opt.mask = iopt.mask;
    end 
    
end

% build command
mFlag = sprintf('-m  %s[%s,%s,%i,%i]',opt.model,fixedImage,movingImage,opt.modelWeight,opt.modelRadius);
iFlag = sprintf('-i %s',opt.maxIter);
oFlag = sprintf('-o %s',outputImage);
tFlag = sprintf('-t %s',opt.transformation);
rFlag = sprintf('-r %s',opt.regularization);
% flag for lesion mask
if isempty(opt.mask),
    xFlag = '';
else
    % check that mask actually exist
    chkFile(opt.mask);        
    xFlag = sprintf('-x %s',opt.mask);
end

command = sprintf('ANTS %i %s %s %s %s %s %s',opt.dim,mFlag,iFlag,oFlag,tFlag,rFlag,xFlag);
fprintf('%s\n',command);
if opt.execute,
    [err,output] = system(command);
    if err ~= 0,
        error('Error in ants.m (ANTS MATLAB wrapper); output from command:\n %s\n',output);
    end
    fprintf('%s\n',output);
end

if nargout == 1,
    % return command string
    varargout{1} = command;
end

% 
% ANTS 3 -m  PR[avg152T1.nii.gz,id77_T1.nii.gz,1,4] -i 100x100x100x20 -o warpedT1.nii.gz -t SyN[0.25] -r Gauss[3,0]
% WarpImageMultiTransform 3 id77_T1.nii.gz w_id77_T1.nii.gz warpedT1Warp.nii  warpedT1Affine.txt 
% WarpImageMultiTransform 3 brainMask.nii iw_brainMask.nii -i  warpedT1Affine.txt
% warpedT1InverseWarp.nii -R id77_T1.nii.gz 


