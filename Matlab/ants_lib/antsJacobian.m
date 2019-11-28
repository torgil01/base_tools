function varargout = antsJacobian(varargin)
% Wrapper for ANTS command: "ANTSJacobian"
%
% Compute Jacobian or logJacobian form a ANTS warp field
% the Jacobian will be defined in the space that the warp fileld is mapping TO
% Such that if we have a warp "native_space -> template_space", the Jacobian will be in
% template space. Note that the Jacobain only includes the nonlinear warp, not the affine
% part. One can chose to include a mask (defined in the space the mapping is to), an
% alternatively to normalize the Jacobian to the total volume in the mask.
% 
% Usage: 
%   antsJacobian(warpField,jacobainFile)
%   antsJacobian(warpField,jacobainFile,brainMask) : used default options
%   antsJacobian(warpField,jacobainFile,brainMask,opts)
% Where:
%  warpField             : name of ANTS warp field
%  jacobianFile          : name of file to save the jacobian 
%                          *(default is to save the logJacobian not the Jacobian)
%                          **Note that the filename will automatically be appended
%                          "logJacobian.nii.zg" so if jacobianFile='SPM', then the file
%                          will be saved as "SPMlogJacobian.nii.gz
%  brainMask             : binary mask usually of the brain in temp,ate space
%  opts.takeLog          : [true|false] wether to save the logJacobian or not, default is "true"
%  opts.normalizeByMask  : [true|false] normalize the Jacobian by the volume in the mask,
%                          default is "true" if a mask is given

opts.takeLog = true;
opts.normalizeByMask = true;
opts.execute = true;

optFields = {'takeLog', 'normalizeByMask', 'execute'};

switch nargin,
    case 2,
        warpFile = varargin{1};
        outputFile = varargin{2};
    case 3,
        warpFile = varargin{1};
        outputFile = varargin{2};        
        maskFile = varargin{3};
        useMask = true;
    case 4,
        warpFile = varargin{1};
        outputFile = varargin{2};        
        maskFile = varargin{3};
        useMask = true;
        iopts = varargin{4};
        opts = evalOpts(iopts,opts,optFields);
    otherwise
        error('Incorrect number of input arguments');
end

% remove ext from output file
outputFile = remove_ext(outputFile);

chkFile(warpFile);
if useMask,
    chkFile(maskFile);
end

options = sprintf('%i ',opts.takeLog);
if useMask,
    options = sprintf('%s %s %i',options,maskFile,opts.normalizeByMask);
end

command = sprintf('ANTSJacobian 3 %s %s %s',warpFile,outputFile,options);
if opts.execute,
    [err,output]  = system(command);
    if err ~= 0,
        error('Error in antsJacobian.m; output from command:\n %s\n',output);
    end
end

if nargout == 1,
    varargout{1} = command;
end


% ANTSJacobian 3 warp_t1Warp.nii.gz warp2_ 1 brainmask.nii.gz 1 
 


function opts = evalOpts(iopts,opts,optFields)
%
for i=1:numel(optFields),
    if isfield(iopts,optFields{i}),
        tmp = eval(sprintf('iopts.%s',optFields{1}));
        opts.(sprintf('%s',optFields{i})) = tmp;
        %opts = struct(optFields{i},tmp);        
    end
end



