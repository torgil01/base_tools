function corrected = n3Correct(t1File,correctedT1)
[base,~] = fileparts(t1File);
mncInFile = fullfile(base,'in.mnc');
mncOutFile = fullfile(base,'out.mnc');
impFile = fullfile(base,'out.imp');
%n3Opts = '-iterations 150 -stop 0.0001 -distance 75 ';

%corrected = t1File;
command = sprintf('mriConvert.sh %s %s',t1File,mncInFile);
system(command);
command = sprintf('n3.sh %s %s',mncInFile,mncOutFile);
system(command);
command = sprintf('mriConvert.sh %s %s',mncOutFile,correctedT1);
system(command);
delete(mncInFile);
delete(mncOutFile);
delete(impFile);

