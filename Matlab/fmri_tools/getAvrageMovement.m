function getAvrageMovement(studyDir,doPlot)
% calc mean scan to scan movement from SPM "rp0_fmri.txt" files
% 
% 25.11.15 also compute as last two colums scan-to-scan translation and rotation 
% (1) is given by: T = |dtMat| = sqrt(sum(dtMat.*dtMat)) 
% (2) is given by: A = acos(0.5*(trace(R)-1))  where R is the rotaion matrix
% 
% see : https://en.wikipedia.org/wiki/Rotation_matrix#Basic_rotations
% 

rpFiles=findFiles(studyDir,'^rp_.*.txt');
fprintf('found %i rp files\n\n',numel(rpFiles));

% if we plot the data
if doPlot,
    fprintf('Plotting files\n');
    rp_plot(rpFiles)
end


% print two textfiles 
% (1) the mean of the x,y z translations and xyz-rotations from the rp-file
% (2) the mean,max, std 
% table arrays 
T1 = sprintf('ID\t mean-tx\t mean-ty\t mean-tz\t mean-rotx\t mean-rot-y\t mean-rotz\n');
T2 = sprintf('ID\t mean-trans\t min_trans\t max_trans\t std-trans\t mean-rot\t min_rot\t max_rot\t std-rot\n');
for i=1:numel(rpFiles),    
    fid=fopen(rpFiles{i}); 
    T = textscan(fid,'%f%f%f%f%f%f'); 
    fclose(fid);
    tMat = cell2mat(T);
    dtMat =diff(tMat);
    % get id
    id = getID(rpFiles{i},2);
    transl = calcTransl(dtMat); % calculate scan-to-scan translation and return vector
    sTrans = getStats(transl); % calculate mean, min, max etc
    
    rots = calcRots(dtMat); % calculate scan-to-scan-rotations and return vector
    sRot = getStats(rots); % calculate mean, min, max etc
    
    meanT=mean(dtMat);
    
    T1 = [T1 sprintf('%s\t%12.8f\t%12.8f\t%12.8f\t%12.8f\t%12.8f\t%12.8f\n',id,meanT)];
    T2 = [T2 sprintf('%s\t%12.8f\t%12.8f\t%12.8f\t%12.8f\t%12.8f\t%12.8f\t%12.8f\t%12.8f\n',...
        id,sTrans.mean,sTrans.min,sTrans.max,sTrans.sdev,sRot.mean,sRot.min,sRot.max,sRot.sdev)];
end

fprintf('%s\n',T1);

fprintf('%s\n',T2);



function rots = calcRots(dtMat)
%
[nl,~] = size(dtMat);
rots = zeros(nl,1);
R = zeros(3,3);
for i=1:nl,
    R = mkRotationMatrix(dtMat(i,4),dtMat(i,5),dtMat(i,6));
    rots(i) =  getRotAngle(R);
end



function transl = calcTransl(dtMat)
%
[nl,~] = size(dtMat);
transl = zeros(nl,1);
for i=1:nl,
    transl(i) = norm(dtMat(i,1:3));
end

function R = mkRotationMatrix(a,b,c)
% construct rotatin matrix from axis rotations a, b and c
% a,b,c is in radians
Rx = zeros(3,3);
Rx(1,1) = 1;
Rx(2,2) = cos(a);
Rx(2,3) = -sin(a);
Rx(3,2) = sin(a);
Rx(3,3) = cos(a);

Ry = zeros(3,3);
Ry(1,1) = cos(b);
Ry(1,3) = sin(b);
Ry(2,2) = 1;
Ry(3,1) = -sin(b);
Ry(3,3) = cos(b);

Rz = zeros(3,3);
Rz(1,1) = cos(c);
Rz(1,2) = -sin(c);
Rz(2,1) =  sin(c);
Rz(2,2) = cos(c);
Rz(3,3) = 1;

% multyply axis rotations <- correct order?
R = Rz*Ry*Rx;


function th = getRotAngle(R)
% compute rotatio angle from rotation matrix R
% the "rotation angle" is the rotation around some axis
% see: https://en.wikipedia.org/wiki/Rotation_matrix#Basic_rotations
% generally 
% trace(R) = 1 + 2cos(theta)
% ie
% theta = acos(0.5*(trace(R) -1))

tr = trace(R);
th = acos(0.5*(tr-1));

function id =getID(file,lev)
% get id from file. 
% usually file is one or two levels deep 
% 1 level => studyDir/id/file.nii
% 2 levels => studyDir/id/subDir/file.nii
% 3 levels => studyDir/id/scandate/seriesDir/file.nii
%lev =1;

% determine if this is a file or a directory
typ = exist(file);

switch typ,
    case 2, % a file        
        if lev == 1,
            [base,~] = fileparts(file);
            [~,id] = fileparts(base);
        elseif lev == 2,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [~,id] = fileparts(base2);
        elseif lev == 3,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [base3,~] = fileparts(base2);
            [~,id] = fileparts(base3);
        end
    case 7,
        % fileparts act differently if path is gioven as "/aa/bb/cc" or as
        % "/aa/bb/cc/" -- the logical behavior is the latter, therefore we
        % add a file seperator at the end if it is not there
        if ~strcmp(filesep,file(end:end))
            file = [file filesep];
        end
        if lev == 1,
            [base,~] = fileparts(file);
            [~,id] = fileparts(base);
        elseif lev == 2,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [~,id] = fileparts(base2);
        elseif lev == 3,
            [base1,~] = fileparts(file);
            [base2,~] = fileparts(base1);
            [base3,~] = fileparts(base2);
            [~,id] = fileparts(base3);
        end             
    otherwise,
        error('Error in getID, unable to parse input: %s\n file or directory must exist!',file);
end

function S = getStats(x)
% return data on vector 
x = x(:); 
S.npix=length(x);
S.max = max(x);
S.min = min(x);
S.sdev=std(x);
S.mean=mean(x);
S.median=median(x);
S.kurtosis=kurtosis(x);
S.skewness=skewness(x);

function rp_plot(rp_files)

%filt = ['^rp_*','.*\.txt$'];
% b = spm_select([Inf],'any','Select realignment parameters',[],pwd,filt);
   scaleme = [-3 3];
   scalerot = [-0.08 0.08];
   mydata = pwd;

   for i = 1:numel(rp_files)

     [p nm e v] = spm_fileparts(rp_files{i});

     printfig = figure;
     set(printfig, 'Name', ['Motion parameters: subject ' num2str(i) ], 'Visible', 'on');
     loadmot = load(deblank(rp_files{i}));
     subplot(2,1,1);
     plot(loadmot(:,1:3));
     grid on;
     ylim(scaleme);  % enable to always scale between fixed values as set above
     title(['Motion parameters: shifts (top, in mm) and rotations (bottom, in rad)'], 'interpreter', 'none');
     subplot(2,1,2);
     plot(loadmot(:,4:6));
     grid on;
     ylim(scalerot);   % enable to always scale between fixed values as set above
     title(['Data from ' p], 'interpreter', 'none');
     mydate = date;
     motname = [mydata filesep 'motion_' mydate '.pdf'];
     spm_print(motname,printfig);
     %print(printfig, '-dpng', '-noui', '-r100', motname);  % enable to print to file
     close(printfig);   % enable to close graphic window
   end;