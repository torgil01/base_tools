function N4BiasFieldCorrection(varargin)
% wrapper for the N4 bias file correction in ANTS
% Usage:
% N4BiasFileldCorrection(inputImage,correctedImage)
% N4BiasFileldCorrection(inputImage,correctedImage,mask)
switch nargin,
 case 2,
  inputImage = varargin{1};
  correctedImage = varargin{2};
  command = sprintf('N4BiasFieldCorrection -d 3 -i %s -o %s',inputImage,correctedImage);
 case 3,
  inputImage = varargin{1};
  correctedImage = varargin{2};
  mask = varargin{3};
command = sprintf('N4BiasFieldCorrection -d 3 -i %s -o %s -x %s',inputImage,correctedImage,mask);
otherwise,
  error('incorrect number of input args, only 2 or 3');
end


[err,out] = system(command);
if err ~= 0,
    fprintf('%s\n',command);
    error('nonzero exit for command; %s\n with output\n %s\n',err,out);
end

%
