function chkImageSimiliarity(fileName,baseDir,refImg)
% check image similarity using ANTs imagesimilarity util
% useful for checking normalization
% INPUT
% filename <- regexp for searching for matching files
% baseDir  <- place where files are
% refImg   <- some reference image (mean?)


opt.metric = 1; % see help antsImageSimilarity

files = findFiles(baseDir,fileName);
if isempty(files),
    fprintf('No files found, exiting');
    return
else
    si = zeros(length(files),1);
    for i=1:length(files),
        si = antsImageSimilarity(files{i},refImg,opt);                
        fprintf('%12.4f\t%s\n',si,files{i});
    end
end


