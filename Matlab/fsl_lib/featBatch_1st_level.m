function featBatch_1st_level
% generate FEAT job files from job template. 
% changelog:
% 19.02.13 -- remove file ext when insertig file names in FEAT script. If we give full
% file names FNIRT will not work correctly

imageDir = '/home/torgil/Work/AD/fmri_2012/ImageData';
%
param.epi.dirPrefix = 'FMRI';
param.epiName = 'fmri_150.nii.gz';
param.t1w.dirPrefix = 'T1w';
param.t1w.filePrefix = 't1w_brain';
param.brainMask = 'mask_t1w_brain'; % need this to fnirt to MNI
param.imageExt = 'nii.gz';
param.jobTemplate ='/home/torgil/Work/AD/fmri_2012/fsl/jobTemplate/jobTemplate_token.fsf';
param.jobFileName =''; % auto here 
param.statDirName = '/home/torgil/Work/AD/fmri_2012/fsl/1stLevel';  %%
param.batchFileDir = '/home/torgil/Work/AD/fmri_2012/fsl/1stLevel';  %%

% identify all relevant subjects in study dir
subjDir = dirdir(imageDir);
if isempty(subjDir),
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
                epiDir{1} = seriesDirs{j};                
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
    fprintf('epiDir = %s \t anatDir = %s\n',epiDir{1},anatDir);
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

% find brainmask in anatDir
brainMask = fullfile(anatDir,[param.brainMask '.' param.imageExt]);
if ~exist(brainMask,'file'),
    error('Brainmask file %s not found in %s\n',brainMask,anatDir);
end


% % make new subject folder in param.statDirName
% if ~exist(subjectStatDir,'dir'),
%     mkdir(param.statDirName,ID);
% end
% now set up one FEAT dir for each functional run
% we assume here that each each run have the same paradigm
token = cell(5,2);
for ii=1:length(epiDir),
    [basePath seriesName] = fileparts(epiDir{ii});
    
    % name of new batch file
%    sType = setSeriesType(seriesName);
    batchName =sprintf('%s_batch.fsf',ID); 
    fsfFile = fullfile(param.batchFileDir,batchName);
    
    % in case we have multiple runs for each subject we might want to make sub dirs for
    % each subject
    %outputDir = fullfile(subjectStatDir,ID);    
    outputDir = subjectStatDir;
    
    
    % find file inside epi dir
    %featFile = setFeatFile(epiDir{ii},param.imageExt);
    
    featFile = fullfile(epiDir{ii},param.epiName);
    
    fwhm = getFsfParam('fmri(smooth)',param.jobTemplate);
    tr = getFsfParam('fmri(tr)',param.jobTemplate);
    highPassCutoff = getFsfParam('fmri(paradigm_hp)',param.jobTemplate);
    [noiseLevel, noiseAR] = estnoise(fwhm,highPassCutoff/tr,featFile);
    
    %noiseLevel = 1; noiseAR = 1;
    
    % all values are now collected, insert into template 
    token{1,1} = '%OutputDir';
    token{1,2} = sprintf('"%s"',outputDir);
    token{2,1} = '%FeatFile1';
    token{2,2} = sprintf('"%s"',remove_ext(featFile));
    token{3,1} = '%NoiseLevel';
    token{3,2} = strtrim(sprintf('%16.10f',noiseLevel));
    token{4,1} = '%NoiseAR1';
    token{4,2} = strtrim(sprintf('%16.10f',noiseAR));
    token{5,1} = '%T1Image';
    token{5,2} = sprintf('"%s"',remove_ext(t1wFile{1}));
    token{6,1} = '%Brainmask';
    token{6,2} = sprintf('"%s"',remove_ext(brainMask));        

    % now insert values in tempate and make batch file 
    replaceTokens(token,param.jobTemplate,fsfFile);
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