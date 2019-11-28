function dispLine(varargin)
fid=1; %std out
if nargin == 1,
    numChar=varargin{1};
    symbol='-';
elseif nargin == 2,
    numChar=varargin{1};
    symbol=varargin{2};
elseif nargin == 3,
    numChar=varargin{1};
    symbol=varargin{2};
    fid=varargin{3};
else
    error('Error in dispLine, incorrect number of arguments');
    numChar=72;
    symbol='-';
end
if ~isa(numChar,'double'),
    numChar=72;
end
S=char(numChar);
for i=1:numChar,
    S(i)=symbol;
end
fprintf(fid,'%s\n',S);
return

    

    