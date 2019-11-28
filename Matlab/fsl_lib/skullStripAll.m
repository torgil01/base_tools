function skullStripAll(studyDir,filePattern)
% skull strip a bunch of t1 files, sutable for FSL;FEAT
% 
% Inputs 
% studyDir     : here to look for files searces all folder below
% filePattern  : regexp pattern for finding files
%                example: 't1w.*.nii.gz'  
%                see help findFiles for other examples
% 
% Output
% skull stripped image called "filename_brain.*"
% brain mask  called "filename_mask.*"
% output files are written to the same directory as the original image file resides


opt.overwrite = false;
files = findFiles(studyDir,filePattern);
for ii=1:length(files),
    [basePath,fn] = fileparts(files{ii});
    [bb, fileName , ext2]  = fileparts(fn);
    fileName = fullfile(basePath,fileName);
    ssFile = [fileName '_brain'];
    maskFile = [fileName '_mask'];
	if (exist(ssFile,'file') & exist(maskFile,'file')),
	 fprintf('Skipping, BET already; %s exist\n',ssFile);
	else	
	    fprintf('Skull stripping %s -> %s\n',fileName,ssFile);
    	runBet(fileName,ssFile,maskFile);
	end
end
