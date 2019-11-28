function saveNii(filename,img)
% saves matlab array img as nifti file using SPM routines
% 11.02.2008 
if exist(filename),
    warning('File exists, will be overwritten.');
end
if ndims(img) == 3,
    V.fname=filename;
    V.mat=eye(4)*2;
    V.mat(1:4,4)=1;
    V.dim = size(img); % denne m� du endre slik at det stemmer med ditt datasett
    V.dt=[4 0];
    V.n = [1 1];
    V.descrip = 'created by saveNii';
    spm_write_vol(V,img); % skriver datasett til fil
elseif ndims(img) == 4,
    nTime = size(img,4);
    dim(1) =size(img,1);
    dim(2) =size(img,2);
    dim(3) =size(img,3);
    for i = 1:nTime,
        V(i).fname=filename;
        V(i).mat=eye(4)*2;
        V(i).mat(1:4,4)=1;
        V(i).dim = dim; % denne m� du endre slik at det stemmer med ditt datasett
        V(i).dt=[4 0];
        V(i).n = [i 1];
        V(i).descrip = 'created by saveNii';
        spm_write_vol(V(i),img(:,:,:,i)); % skriver datasett til fil
    end
    
else
    error('check image dimensions, not 3 or 4');
end