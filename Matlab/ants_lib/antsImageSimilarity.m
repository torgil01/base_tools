function si=antsImageSimilarity(varargin)
% function si=antsImageSimilarity(file1,file1)
% function si=antsImageSimilarity(file1,file1,opt)
% opt.metric =  Metric 0 - MeanSquareDifference, 1 - Cross-Correlation (default), 2-Mutual Information , 3-SMI 
%
% Wrapper for the ANTS MeasureImageSimilarity script
%

opt.metric =1;

switch nargin,
    case 2,
        file1=varargin{1};
        file2=varargin{2};
    case 3,
        file1=varargin{1};
        file2=varargin{2};
        iopt = varargin{3};
        if isfield(iopt,'metric'),
            opt.metric = iopt.metric;
        end
    otherwise,
        error('Incorrect number of arguments');
end

command = sprintf('MeasureImageSimilarity 3 %i %s %s',opt.metric,file1,file2);
[status,result] = system(command);
if status == 0,
    % command successful
    % EXTRACT similarity value
    startPos = findstr(result,'metricvalue')+12;
    endPos = findstr(result,'diff')-1;
    si = str2num(result(startPos:endPos));
else
    error('error calling MeasureImageSimilarity:\n%s\n',result);
end



 