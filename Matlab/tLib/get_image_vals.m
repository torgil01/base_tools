function get_image_vals(coords)

error('code does not function');
spm_defaults
switch spm('ver')
    case 'SPM5'
        P = spm_select(Inf,'image','Select image files',[],pwd,'*.*');
    case 'SPM2'
        P=spm_get(inf,'*.img','Select images');
end
V=spm_vol(P);
[numCoords,m]=size(coords);
for j=1:numCoords
    vox=mm2vox(coords(j,:)',V(1).mat);
    for i=1:length(V),
        val(i,j)=spm_sample_vol(V(i),vox(1),vox(2),vox(3),1);
    end
end



% % PRINT REPORT  
% for j=1:n % loop over coords
%     vox=mm2vox(coords(j,:)',V(1).mat);
%     fprintf('[%2i,%2i,%2i] mm [%2i,%2i,%2i] vox\n',coords(j,1),coords(j,2),...
%         coords(j,3),vox(1),vox(2),vox(3));
%     for i = 1: length(V), % loop over images
%         [PATHSTR,name,EXT,VERSN] = fileparts(V(i).fname);
%         fprintf('%s \t\t %8.6f\n',name,val(i,j));
%     end
% end

% make format string
numFormat=' %8.6f\t';
S='%s \t ';
H='';
for i=1:numCoords,
    S=strcat(S,numFormat);
    H=strcat(H,sprintf('[%2i,%2i,%2i]\t',coords(i,1),coords(i,2),coords(i,3)));
end
S=strcat(S,'\n');

% PRINT REPORT 

fprintf('\t\t\t\t%s\n',H);
for i = 1: length(V), % loop over images
    %for j=1:n % loop over coords
        [PATHSTR,name,EXT,VERSN] = fileparts(V(i).fname);
        fprintf(S,name,val(i,:));
    %end
end



% function cp    = mm2vox(mm,mat);
% cp = inv(mat)*[mm; ones(1,size(mm,2))];
% cp = cp(1:3,:);

