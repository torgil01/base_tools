function varargout = mri_watershed(imageFile)
% skull strip image using freesurfer tool mri_watershed

defaults.crop = false;
defaults.stripPrefix = '';
defaults.stripPostfix = '_brain';
defaults.mriWatershedOpts = ' -atlas';
%defaults.mriWatershedOpts = ''; % use defaults 
if ~exist(imageFile),
    error('File %s not found!',imageFile);
end

origExt = '';
ext = getExt(imageFile);
fn = rmExt(imageFile);
[base,fName,~] = fileparts(fn);
% if  strcmp(ext,'.nii.gz'),
%     % mri_watershed do not support writing *nii.gz 
%     %origExt = ext;
%     %ext = '.nii';
% end

stripImageFile = fullfile(base,[defaults.stripPrefix fName defaults.stripPostfix ext]);

command = sprintf('mri_watershed %s %s %s',defaults.mriWatershedOpts,imageFile,stripImageFile);
system(command);

if defaults.crop,
    % New way to crop:
    % 1. comp rigid transform template -> watershed brain
    % 2. transform cube of 1 to native
    % 3. crop
    
    vox = abs(voxsize(stripImageFile));
    fprintf('Cropping %s\n',stripImageFile);
    % note 'r' file generated here
    % not consistent, shoud rename file to ss
    resize_img(stripImageFile,vox,[[-78 -120 -65]; [78 80 90]],false);
end

%  if strcmp(origExt,'.nii.gz')
%      gzip(stripImageFile);
%      stripImageFile = replaceExt(stripImageFile,'.nii.gz');
%  end

switch nargout,
    case  1,
        varargout{1} = stripImageFile;
    otherwise
        %error('incorrect number of output args');
end

  
   
