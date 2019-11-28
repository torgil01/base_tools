function niiDeploy(origDir,depDir)
% Deployment tool for directory that have been reordered, see "niiReorder.m" 
% The script simply copies selected series from the sorce to the destination
% Useful for keeping a "clean" source and moving files to the work-dir


opt.fileType = 'nii.gz';
opt.check = false; % check only files, no copy
opt.t1w = true;
opt.dti = false;
opt.fmri = true;

[subjFullPath,subjNo] = dirdir(origDir);  % the source dir name determine the name
for i=1:length(subjNo),
    [ddFp, ddName] =  dirdir(subjFullPath{i});
    %subjFullPath{i} = fullfile(subjFullPath{i},ddName{1});
    fprintf('%s\n',subjFullPath{i});
    if opt.fmri,
        % fmri series
        epiDir = fullfile(subjFullPath{i},'FMRI');
        if ~exist(epiDir,'dir'),
            error('EPI dir not found for subject %s\n path is %s\n',epiDir);
        end
        epiFile = fullfile(epiDir,['fmri.' opt.fileType]);
        if ~exist(epiFile,'file'),
            error('EPI images not found for subject %s\n dir is %s\n',subjNo{i},epiFile);
        end        
    end
    
    
    if opt.t1w,
        % t1w file
        t1Dir = fullfile(subjFullPath{i},'T1w');
        if ~exist(t1Dir,'dir'),
            error('T1 dir not found for subject %s\n path is %s\n',epiDir);
        end
        t1File = fullfile(t1Dir,['t1w.' opt.fileType]);
        if ~exist(t1File,'file'),
            error('T1 images not found for subject %s\n dir is %s\n',subjNo{i},epiFile);
        end
    end
    
    if opt.dti,       
        d = dir(fullfile(subjFullPath{i},'DTI'));
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

    
