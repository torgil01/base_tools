function dcmStruct = dcmSummarize(varargin)
% dcmStruct = dcmSummarize(dcmFile)
% dcmStruct = dcmSummarize(dcmFile,dcmTags)
%
% Summarize metadata in dicom file "dcmFile"
% metadata is returned in struct. Optional struct "dcmTags" can be used to 
% specify the tags to be extracted. See dicom-dict.txt for the tags that
% can be used. Unfortunately only tag names can be used, not tag numbers. 
% Note that the dicomtags must be given as an cell array.

% defaults
doPrint=true;

switch nargin
    case 1,
        dcmFile = varargin{1};
        dcmExtractTags = setDefaultExtractTags;
    case 2,
        dcmFile = varargin{1};
        dcmExtractTags = varargin{2};
    otherwise,
        error('Only one or two input arguments');
end

chkFile(dcmFile);
dcmTags = dicominfo(dcmFile);

for i =1:length(dcmExtractTags),
    dcmStruct{i}{1} = dcmExtractTags{i};
    dcmStruct{i}{2} = eval(['dcmTags.' dcmExtractTags{i}]);
    if doPrint,
        fprintf('%s; %s\n',dcmStruct{i}{1},dcmStruct{i}{2});
    end
end


function tags = setDefaultExtractTags
tags{1} = 'StudyDate';
tags{2} = 'AcquisitionTime';
tags{3} = 'SeriesDescription';
%tags{4} = 'PatientName';
tags{4} = 'PatientID';
tags{5} = 'PatientBirthDate';
tags{6} = 'PatientSex';
tags{7} = 'PatientAge';
tags{8} = 'PatientSize';
tags{9} = 'PatientWeight';
tags{10} = 'ScanningSequence';
tags{11} = 'RepetitionTime';
tags{12} = 'EchoTime';
%tags{13} = 'InversionTime';
%tags{14} = 'NumberOfAverages';