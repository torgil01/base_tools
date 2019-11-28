function simpleDcmSummary(dcmFiles)
% simple summary of dicom data
% supply cell array of dcm files
% tags
tags{1} = 'StudyDate';
tags{2} = 'AcquisitionTime';
tags{3} = 'PatientID';
tags{4} = 'PatientName';
tags{5} = 'PatientBirthDate';
tags{6} = 'PatientSex';
tags{7} = 'PatientAge';
tags{8} = 'PatientSize';
tags{9} = 'PatientWeight';
% header 
fprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',tags{:});
for k=1:length(dcmFiles),
    chkFile(dcmFiles{k});
    dcmTags = dicominfo(dcmFiles{k});

    for i=1:length(tags)
        tagValue = getfield(dcmTags,tags{i});    
        if isnumeric(tagValue),
            fprintf('%f\t',tagValue);
        elseif ischar(tagValue),
            fprintf('%s\t',tagValue);
        elseif isstruct(tagValue),        
            fnames = fieldnames(tagValue);
            % will break if we have subfields here
            strVal='';
            for j=1:length(fnames),            
                strVal =[strVal ' ' getfield(tagValue,fnames{j})];
            end
            fprintf('%s\t',strVal);
        end
    end
    fprintf('\n');
end


        