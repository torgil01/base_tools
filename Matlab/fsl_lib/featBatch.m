function featBatch
% generate FEAT job files from job template. 

% study dir is structured as follows: 
% studyDir -> subject -> 301_fMRI_smerte_K_SENSE 
%                     -> 801_MPRAGE_ASO_SENSE
%                     -> 401_fMRI_smerte_K_SENSE
%                     -> 501_fMRI_smerte_K_SENSE
imageDir = '/home/torgil/Work/Placebo/FSL/ImageData';

param.epi.dirPrefix = 'fMRI_smerte';
param.t1w.dirPrefix = 'MPRAGE';
param.t1w.filePrefix = 'coMPRAGEASOSENSE_brain';
param.imageExt = 'nii.gz';
%param.jobTemplate ='/home/torgil/Work/Placebo/FSL/FEAT/batchTemplate/batch_template_melodic.fsf';
param.jobTemplate ='/home/torgil/Work/Placebo/FSL/FEAT/batchTemplate/batch_template_hp282_fwhm8.fsf';
param.jobFileName =''; % auto here 
param.statDirName = '/home/torgil/Work/Placebo/FSL/FEAT/1st_level_HP282';  %%
param.batchFileDir = '/home/torgil/Work/Placebo/FSL/FEAT/1st_level_HP282';

% identify all relevant subjects in study dir
subjDir = dirdir(imageDir);
if isempty(subjDir),/home/torgil/Work/Placebo/FSL/FEAT
    error('No studies found in %s\',imageDir);
end
% Loop over subjects
for i=1:length(subjDir),
    fprintf('Processing subj %s\n',subjDir{i});
    [seriesDirs, seriesDirNames] = dirdir(subjDir{i});
    if ~isempty(seriesDirs),
        epiDir = '';
        anatDir = '';
        ii =1;
        for j=1:length(seriesDirs),
            if strfind(seriesDirNames{j},param.epi.dirPrefix),
                % found epi dir
%                 if strfind(seriesDirNames{j},'smerte_S'),
%                     epiDir{ii} = seriesDirs{j};
%                     ii=ii+1;
%                 end
                if strfind(seriesDirNames{j},'smerte_K'),
                    epiDir{ii} = seriesDirs{j};
                    ii=ii+1;
                end
%                 if strfind(seriesDirNames{j},'smerte_M'),
%                     epiDir{ii} = seriesDirs{j};
%                     ii=ii+1;
%                 end
%                 
            end
            if strfind(seriesDirNames{j},param.t1w.dirPrefix),
                anatDir = seriesDirs{j};                                    
            end
        end
        if isempty(epiDir),
            warning('No epi found in %s',subjDir{i});
            continue
        end
        if isempty(anatDir),
            warning('No anat found in %s\n Skipping subject\n',subjDir{i});
            continue
        end
    end
    mkJob(subjDir{i},anatDir,epiDir,param)    
end

%end of main func




function mkJob(subjDir,anatDir,epiDir,param)
% generate FEAT job files for 1st level analysis
% there are several 1.level analysis for each subject. 
% we generate one analysis for each 1st level a
% feat_output_dir/subject/analysis_1

% figure out subject ID
[basePath ID] = fileparts(subjDir);
subjectStatDir = fullfile(param.statDirName,ID);

% find T1w in anatDir 
t1wFile = findFiles(anatDir,['^' param.t1w.filePrefix]);
if isempty(t1wFile),
    error('T1w file not found in %s\n',anatDir);
end

% make new subject folder in param.statDirName
if ~exist(subjectStatDir,'dir'),
    mkdir(param.statDirName,ID);
end
% now set up one FEAT dir for each functional run
% we assume here that each each run have the same paradigm
token = cell(5,2);
for ii=1:length(epiDir),
    [basePath seriesName] = fileparts(epiDir{ii});
    

    % name of new batch file
    sType = setSeriesType(seriesName);
    batchName =sprintf('%s_%s.fsf',ID,sType); 
    fsfFile = fullfile(param.batchFileDir,batchName);
    
    outputDir = fullfile(subjectStatDir,sType);
    
    % find file inside epi dir
    featFile = setFeatFile(epiDir{ii},param.imageExt);
    fwhm = getFsfParam('fmri(smooth)',param.jobTemplate);
    tr = getFsfParam('fmri(tr)',param.jobTemplate);
    highPassCutoff = getFsfParam('fmri(paradigm_hp)',param.jobTemplate);
    [noiseLevel, noiseAR] = estnoise(fwhm,highPassCutoff/tr,featFile);
    
    %noiseLevel = 1; noiseAR = 1;
    
    % all values are now collected, insert into template 
    token{1,1} = '%OutputDir';
    token{1,2} = sprintf('"%s"',outputDir);
    token{2,1} = '%FeatFile1';
    token{2,2} = sprintf('"%s"',featFile);
    token{3,1} = '%NoiseLevel';
    token{3,2} = strtrim(sprintf('%16.10f',noiseLevel));
    token{4,1} = '%NoiseAR1';
    token{4,2} = strtrim(sprintf('%16.10f',noiseAR));
    token{5,1} = '%T1Image';
    token{5,2} = sprintf('"%s"',t1wFile{1});
    

    % now insert values in tempate and make batch file 
    replaceTokens(token,param.jobTemplate,fsfFile);
end



function sType = setSeriesType(seriesDirName)
sType = '';
if strfind(seriesDirName,'smerte_S'),
    sType = 'S';
end
if strfind(seriesDirName,'smerte_K'),
    sType = 'K';
end
if strfind(seriesDirName,'smerte_M'),
    sType = 'M';
end
if isempty(sType),
    error('could not determine series type');
end





function fullFilePath = setFeatFile(imageDir,imageExt)
% search for file with extension imageExt in imageDir, throw error if not found
reg = sprintf('.*\\.%s$',imageExt);
file = findFiles(imageDir,reg);
if isempty(file),
    error('no files found in %s with extension %s\n',imageDir,imageExt);
end
if numel(file) > 1,
    error('multiple files found in %s\n',imageDir);
end

fullFilePath = file{1};



function replaceTokens(tokenList,inFile,outFile)
% Identifies a set of tokens in a text file "inFile" and replaces them with the new values
% in tokenList. Modified file written to outFile. 
% Input
%   tokenList{:,1} = token
%   tokenList{:,2} = newValue
%   inFile         = text file with tokens
%   outFile        = text file with tokens replaced
% NOTE:
% If tokens not detected no errors will be thrown. 
% a sed script does the actual swap

debug = true; % print sed script

% first we generate the sed script,
% the sed script hold a command in each line 

if isempty(tokenList),
    error('tokenList empty');
end 

scriptFile = tempname;
fid = fopen(scriptFile,'a+');

for i =1:length(tokenList)
    a = tokenList{i,1};
    b = tokenList{i,2};
    %iscell(a)
    %iscell(b)
    fprintf(fid,'s,%s,%s,\n',a,b);
end
fclose(fid);

% now execute script
command = sprintf('sed -f %s %s > %s',scriptFile,inFile,outFile);
fprintf('%s\n',command);
system(command);

if debug,
    type(scriptFile);
end
delete(scriptFile);


% sed 's/%token%/REPLACED/1;s/%token2%/REPLACED2/' example.txt 
