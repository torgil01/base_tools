function id =getID(file,lev)
% id =getID(file,lev)
% get id from file. 
% usually file is one or two levels deep 
% 1 level => studyDir/id/file.nii
% 2 levels => studyDir/id/subDir/file.nii
% 3 levels => studyDir/id/scandate/seriesDir/file.nii
% 

% determine if this is a file or a directory
typ = exist(file);

switch typ,
    case 2, % a file        
        if lev == 1,
            [base,~] = fileparts(file);
            [~,id] = fileparts(base);
        elseif lev == 2,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [~,id] = fileparts(base2);
        elseif lev == 3,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [base3,~] = fileparts(base2);
            [~,id] = fileparts(base3);
        end
    case 7,
        % fileparts act differently if path is given as "/aa/bb/cc" or as
        % "/aa/bb/cc/" -- the logical behavior is the latter, therefore we
        % add a file seperator at the end if it is not there
        if ~strcmp(filesep,file(end:end))
            file = [file filesep];
        end
        if lev == 1,
            [base,~] = fileparts(file);
            [~,id] = fileparts(base);
        elseif lev == 2,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [~,id] = fileparts(base2);
        elseif lev == 3,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [base3,~] = fileparts(base2);
            [~,id] = fileparts(base3);
        end             
    otherwise,
        error('Error in getID, unable to parse input: %s\n file or directory must exist!',file);
end
        