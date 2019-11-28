function runBet(varargin)
% skull strip image using "bet" 
% Usage:
% runBet(inputFile,outputFile)
% runBet(inputFile,outputFile,maskFile)
% if full path is only given to input file, the other files will be written to the same
% directory
% --

if nargin == 2,
    inputFile = varargin{1};
    outputFile = varargin{2};
elseif nargin == 3, 
    inputFile = varargin{1};
    outputFile = varargin{2};
    maskFile = varargin{3};
else
    help runBet 
    error('Incorrect number of arguments');
end


[basePath,fn, ext] = fileparts(inputFile);
ext=getExt(inputFile);
if isempty(basePath),
    basePath = pwd;
end
if isempty(ext),
    % assume default ext
    inputFile = [inputFile '.' getFslExt];
end
    
if ~exist(inputFile,'file') 
    error('Image file=%s not found\n',inputFile);
end

if nargin == 2,
    command = sprintf('bet %s %s -f 0.5 -R',inputFile,outputFile);
    system(command);
elseif nargin == 3,
    command = sprintf('bet %s %s -R -f 0.5 -m',inputFile,outputFile); 
    system(command)
    % the mask will always be named "outputFile_mask"
    [bb, fn] = fileparts(outputFile);
    ext = getFslExt;    
    outMask = fullfile(basePath,[fn '_mask.' ext]);
    [aa,bb,ext2] = fileparts(maskFile);
    if isempty(ext2),
        ext2= getFslExt;
        maskFile = [maskFile '.' ext2];
    end    
    movefile(outMask,maskFile);
end
   
