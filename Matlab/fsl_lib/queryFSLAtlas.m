function queryFSLAtlas(clusterDat)
% function queryFSLAtlas(clusterDat)
% read FSL cluster zstat file and output reformatted file with antomical labels for z-max
%  - cluster dat is the text file under the cope dirs called cluster_zstat1_std.txt
% Changelog;:
% 18.09.2013 created
% 

atlasList = {'Cerebellar Atlas in MNI152 space after normalization with FLIRT',...    
    'Cerebellar Atlas in MNI152 space after normalization with FNIRT',...    
    'Harvard-Oxford Cortical Structural Atlas',...
    'Harvard-Oxford Subcortical Structural Atlas',...
    'JHU ICBM-DTI-81 White-Matter Labels',...
    'JHU White-Matter Tractography Atlas',...
    'Juelich Histological Atlas',...
    'MNI Structural Atlas',...
    'Oxford Thalamic Connectivity Probability Atlas',...
    'Talairach Daemon Labels'};

atlas = atlasList{10};
%[nCoords,dim] = size(coords);
fid = fopen(clusterDat);
%C = textscan(fid,'%i%i%f%f%f%i%i%i%f%f%f%f%i%i%i%f','Headerlines',1,'Delimiter','\t'); 
C = textscan(fid,'%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n','Headerlines',1,'Delimiter','\t'); 
fclose(fid);    
% 
%  C contain the follwoing fields
% Cluster Index	    1
% Voxels	        2
% P	                3
% -log10(P)	        4
% Z-MAX	            5
% Z-MAX X (mm)	    6
% Z-MAX Y (mm)	    7
% Z-MAX Z (mm)	    8
% Z-COG X (mm)	    9
% Z-COG Y (mm)	    10
% Z-COG Z (mm)	    11
% COPE-MAX	        12
% COPE-MAX X (mm)   13
% COPE-MAX Y (mm)	14
% COPE-MAX Z (mm)	15
% COPE-MEAN	        16

xCoords = C{6};
yCoords = C{7};
zCoords = C{8};
nCoords = length(xCoords);

fprintf('ke\tp-val\tZ-max\tX(mm)\tY(mm)\tZ(mm)\tlabel\n');
for i=1:nCoords,            
    command = sprintf('atlasquery -a "%s" -c %i,%i,%i',atlas,xCoords(i),yCoords(i),zCoords(i));
    %fprintf('%s\n',command);
    [err,output] = system(command);
    %fprintf('%s\n',output);
    % the output string is like this:
    % <b>Talairach Daemon Labels</b><br>Left Cerebrum.Sub-lobar.Insula.Gray Matter.Brodmann area 13
    % -- need to strip off everything before <br>
    indx= findstr(output,'<br>');
    label = output(indx+4:end);    
    % now print a pretty table 
    % cluster size \t p-val \tZ-max \t coords(xyz) mm
    clusterSize = C{2}(i);
    pVal = C{3}(i);
    zMax = C{5}(i);
    fprintf('%i\t%12.8f\t%12.8f\t%i\t%i\t%i\t%s',clusterSize,pVal,zMax,xCoords(i),...
        yCoords(i),zCoords(i),label);
end

% function mm2vox(coord)
% stdImage = '/usr/share/fsl/data/standard/MNI152_T1_2mm.nii.gz';
% sprintf('std2imgcoord -img %s -std %s -vox -xfm transf.mat %s',stdImage,image,coordFile)

    