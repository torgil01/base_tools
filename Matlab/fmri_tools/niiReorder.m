function niiReorder(origDir,depDir)
% simplifies original nii sbject directory so that it is easier for
% batching

% TODO: cannot deal with 00_empy dirs fixed this manually for now
% 

opt.fileType = 'nii.gz';
opt.check = false; % check only files, no copy
opt.t1w = true;
opt.dti = false;
opt.fmri = true;

[subjFullPath,subjNo] = dirdir(origDir);  % the source dir name determine the name
for i=1:length(subjNo),
    [ddFp, ddName] =  dirdir(subjFullPath{i});
    subjFullPath{i} = fullfile(subjFullPath{i},ddName{1});
    %fprintf('%s\n',subjFullPath{i});
    if opt.fmri,
        % fmri series
        d = dir(fullfile(subjFullPath{i},'*FE_EPI_CLEAR'));
        if isempty(d),
            error('EPI dir not found for subject %s\n',subjNo{i});
        end
        if length(d) > 1,
            error('inconsistency with EPI dirs for subject %s\n',subjNo{i});
        end
        epiDir = fullfile(subjFullPath{i},d(1).name);
        d = dir(fullfile(epiDir,['FEEPI*.' opt.fileType]));
        if isempty(d),
            error('EPI images not found for subject %s\n',subjNo{i});
        end
        if length(d) > 1,
            error('inconsistency with EPI images for subject %s\n',subjNo{i});
        end
        epiFile = fullfile(epiDir,d(1).name);
    end
    
    
    if opt.t1w,
        % t1w file
        d = dir(fullfile(subjFullPath{i},'*MPRAGE_ASO_SENSE*'));
        if isempty(d),
            error('t1 dir not found for subject %s\n',subjNo{i});
        end
        if length(d) > 1,
            error('inconsistency with t1 dirs for subject %s\n',subjNo{i});
        end
        t1Dir = fullfile(subjFullPath{i},d(1).name);
        d = dir(fullfile(t1Dir,['coMPRAGE*.' opt.fileType]));
        if isempty(d),
            error('t1w images not found for subject %s\n',subjNo{i});
        end
        if length(d) > 1,
            error('inconsistency with t1w images for subject %s\n',subjNo{i});
        end
        t1File = fullfile(t1Dir,d(1).name);
    end
    
    if opt.dti,       
        d = dir(fullfile(subjFullPath{i},'*DTI_high_iso_SENSE'));
        if isempty(d),
            error('DTI dirs not found for subject %s\n',subjNo{i});
        end              
        dtiDir = fullfile(subjFullPath{i},d.name);
        d2 = dir(fullfile(dtiDir,['xDTIhighisoSENSE.' opt.fileType]));          
            if isempty(d2),
                dtiDi
                d.name
                error('dti images not found for subject %s\n',subjNo{i});
            end
            if length(d2) > 1,
                error('inconsistency with dti images for subject %s\n',subjNo{i});
            end
            dtiFile = fullfile(dtiDir,d2(1).name);
            % bvals and bvecs 
            d2 = dir(fullfile(dtiDir,'*.bval'));
            bvalFile = fullfile(dtiDir,d2(1).name);
            d2 = dir(fullfile(dtiDir,'*.bvec'));
            bvecFile = fullfile(dtiDir,d2(1).name);       
    end
    
    if opt.check,
        continue
    end
    
   fprintf('Processing %s\n',subjNo{i});    
    % generate dest dir
    subjNo{i} = subjNo{i}(end-2:end);
    if ~exist(fullfile(depDir,subjNo{i}),'dir'),
        mkdir(depDir,subjNo{i});
    end
    destDir=fullfile(depDir,subjNo{i});
    
   if opt.t1w,
        mkdir(destDir,'T1w');
        t1DestDir = fullfile(destDir,'T1w');
        fprintf('Copy %s -> %s\n',t1File,fullfile(t1DestDir,['t1w.' opt.fileType]));
        copyfile(t1File,fullfile(t1DestDir,['t1w.' opt.fileType]));
    end
    
    if opt.fmri,
        mkdir(destDir,'FMRI');
        epiDestDir = fullfile(destDir,'FMRI');
        fprintf('Copy %s -> %s\n',epiFile,fullfile(epiDestDir,['fmri.' opt.fileType]));
        copyfile(epiFile,fullfile(epiDestDir,['fmri.' opt.fileType]));
    end
    if opt.dti,
        mkdir(destDir,'DTI');
        dtiDestDir = fullfile(destDir,'DTI');        
        % image file
        newDTIFile= sprintf('dti.%s',opt.fileType);
        fprintf('Copy %s -> %s\n',dtiFile,newDTIFile);
        copyfile(dtiFile,fullfile(dtiDestDir,newDTIFile));
        % bval file
        newBvalFile= sprintf('dti.bval');
        fprintf('Copy %s -> %s\n',bvalFile,newBvalFile);
        copyfile(bvalFile,fullfile(dtiDestDir,newBvalFile));
        % bvec file
        newBvecFile= sprintf('dti.bvec');
        fprintf('Copy %s -> %s\n',bvecFile,newBvecFile);
        copyfile(bvecFile,fullfile(dtiDestDir,newBvecFile));
    end
end

    
