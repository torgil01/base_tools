function varargout = antsImageMath(varargin)
% Wrapper for ANTS command: "ImageMath"
% 
% Usage
%   antsImageMath(image1,operand,resultImage)
%   antsImageMath(image1,image2,operand,resultImage)
%
% Examples
%    Multilpy image by 1000 : antsImageMath(image1,'m 1000',resultImage)
%    Divide image A by image B: antsImageMath(imageA,imageB,'/',resultImage)


opts.execute = false;
switch nargin,
    case 3
        twoImages = false;
        image1 = varargin{1};
        operand = varargin{2};
        result = varargin{3};
        chkFile(image1);
    case 4,
        twoImages = true;
        image1 = varargin{1};
        image2  = varargin{2};
        operand = varargin{3};
        result = varargin{4};
        chkFile(image1);
        chkFile(image2);
    otherwise
        error('Incorrect number of input arguments');
end


if twoImages,
    command = sprintf('ImageMath 3 %s %s %s %s',result,operand,image1,image2);
else
    command = sprintf('ImageMath 3 %s %s %s',result,operand,image1);
end
    
if opts.execute,
    [err,output]  = system(command);
    if err ~= 0,
        error('Error in antsImageMath.m; output from command:\n %s\n',output);
    end
end

if nargout == 1,
    varargout{1} = command;
end



