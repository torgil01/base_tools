function [trans] = avscale(transFile)
% Wrapper for FSL "avscale" command
% Input either FSL transform matrix or *ecclog file from eddy_correct 
% the function will return rotations,translations,scales, and skews from
% the transform(s)
% trans.labels
% trans.param(nTrans,labels)

nLabels = 12; % (3*rot,3*trans, 3*scale, 3*skew)
chkFile(transFile);
% 1. determine if input is a transformation matrix or a ecclog file 
fid=fopen(transFile);
line=textscan(fid,'%s',1);
fclose(fid);
if strcmp('processing',line{1}) == 1,
    % ecclog file
    [tFiles,tmpdir] = parseEcclog(transFile);
    length(tFiles)
    param = zeros(length(tFiles),nLabels);
    for i=1:length(tFiles),        
        command = sprintf('avscale --allparams %s',tFiles{i});
        %fprintf('%s\n',command);
        [err, output] = system(command);
        if err ~= 0,
          error('Error in avscale.m;\nOutput from command:\n %s\n',output);
        end        
        param(i,:)=parseOutput(output);
    end
   rmdir(tmpdir,'s');
else
    % transform matrix
    command = sprintf('avscale --allparams %s',transFile);
    fprintf('%s\n',command);
    [err, output] = system(command);   
    if err ~= 0,
        error('Error in avscale.m;\nOutput from command:\n %s\n',output);
    end        
    param=parseOutput(output);
end

trans.labels = ['trans_x','trans_y','trans_z','rot_x','rot_y','rot_z',...
    'scale_x','scale_y','scale_z', 'skew_x','skew_y','skew_z'];
trans.param=param;



function  [tFiles,tmpdir] = parseEcclog(transFile)
% mk tmpdir
tmpdir = tempname;
[tb,tn]=fileparts(tmpdir);
mkdir(tb,tn);
% write t matrices to tmpdir
fid=fopen(transFile);
r=true;
matCount=0;
while r == true,
    line=fgetl(fid);
    line=fgetl(fid);
    line=fgetl(fid);    
    if (isempty(line) | (line == -1)),
        r = false;
    else
        matCount = matCount +1;
        tFiles{matCount} = fullfile(tmpdir,sprintf('T_%i.mat',matCount));
        cmatr = textscan(fid,'%f %f %f %f','CollectOutput',4);
        matr = cell2mat(cmatr);
        %fprintf('%f %f %f %f\n',matr')        
        writeMat(matr',tFiles{matCount});
    end
end
fclose(fid);


function writeMat(mat,fname)
%fprintf('%s\n',fname);
fid=fopen(fname,'w');
fprintf(fid,'%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n',mat);
fclose(fid);

function param=parseOutput(output)
% parse output from avscale
% line 7
% Rotation Angles (x,y,z) [rads] = -0.004118 -0.001391 -0.000041 
% line 9
% Translations (x,y,z) [mm] = -0.553919 -0.475473 -2.080362 
% line 11
% Scales (x,y,z) = 1.004603 1.004677 1.025953 
% line 13
% Skews (xy,xz,yz) = -0.000194 -0.000906 0.003000

param = zeros(12,1);
% split output so that each line is a cell element
oo = strsplit(output,'\n');
% translations
op = textscan(oo{7},'%s (x,y,z) [mm] = %f %f %f');
[param(1),param(2),param(3)] = deal(op{2},op{3},op{4});
% Rotation angles 
op = textscan(oo{6},'%[Rotation Angles] (x,y,z) [rads] = %f %f %f');
[param(4),param(5),param(6)] = deal(op{2},op{3},op{4});
% scales
op = textscan(oo{8},'%s (x,y,z) = %f %f %f');
[param(7),param(8),param(9)] = deal(op{2},op{3},op{4});
% Skews :: Skews (xy,xz,yz) = -0.000194 -0.000906 0.003000 
op = textscan(oo{9},'%s (xy,xz,yz) = %f %f %f');
[param(10),param(11),param(12)] = deal(op{2},op{3},op{4});



