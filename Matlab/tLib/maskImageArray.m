function varargout=maskImageArray(varargin)
% mask image to remove noise threshold
% Usage:
% masked = maskImageArray(img,threshold)
% [masked, mask] = maskImageArray(img,threshold)
% masked = maskImageArray(img,mask)

% process input
useMask=false;
if nargin == 2,
    if length(varargin{2}) > 1,
        % second argument is mask
        img = varargin{1};
        mask = varargin{2};
        useMask=true;
        img=img.*mask;
        varargout{1}=img;
        if nargout == 2,
            varargout{2}=mask;
        end
    else
        img = varargin{1};
        threshold = varargin{2};
        img(img  < threshold) = 0;
        if nargout == 2,
            [nx,ny,nz]=size(img);
            mask = zeros(nx,ny,nz);
            mask(img  > threshold)= 1;
            varargout{2}=mask;
        end
        varargout{1}=img;
    end
else
    error('Incorrect number of input arguments');
end

    

