function average_images2(fileName,baseDir,averageFile)
% Finds all files under <baseDir> and makes a mean image of these 
% the mean image is saved as <avarageFile>
% The program use the findImage function to search through the directories
% 
% average_images2(filename,basedir,meanImage)
% 
% filename = 'file.nii'; finner alle file.nii under basedir
% filename = 'file' ; finner alle file* under basedir



files = findFiles(baseDir,fileName);

for i=1:length(files),
    fprintf('%s\n',files{i})
end
do_average(files,averageFile)

function do_average(P,filename)
%spm_defaults
% get raw images
%V   = spm_vol(P);
imgDat = (0);
length(P)
for i=1:length(P)
    V   = spm_vol(P{i});
    imgDat = imgDat + spm_read_vols(V);
end;
% save average image
imgDat = imgDat/length(P);
VA=V;
VA.fname   = filename;
VA.descrip = 'Average';
spm_write_vol(VA,imgDat);
return
