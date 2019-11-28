function par=parsePAR(parFile)
% read the General information field in a PAR/REC file 
% 11 - 47 
% read 34 lines
try
    fid=fopen(parFile);
    lines=textscan(fid,'%s',34,'headerLines',11,'whitespace','\n'); 
    fclose(fid);
catch
    if exist(fid),
        fclose(fid);
    end
    error('error reading');
end
par=struct;
for i=1:length(lines{1}),
    [field,value]=parseLine(lines{1}{i});
    % strArray = struct('field1',val1,'field2',val2, ...)  
    par=setfield(par,field,value);
end

function [field,value]=parseLine(line);
%1234567890123456789012345678901234567890123456789
% .    Presaturation     <0=no 1=yes> ?   :   0
tfield=deblank(line(6:40));
tvalue=deblank(line(45:end));
% crop tfield at < ( or [ 
[tfield, rem]=strtok(deblank(tfield),'([<');
tfield=deblank(tfield);
% replace whitespace and / with _ in tfield 
ind=strfind(tfield,' ');
tfield(ind)='_';
ind=strfind(tfield,'/');
tfield(ind)='_';
ind=strfind(tfield,'\');
tfield(ind)='_';
ind=strfind(tfield,'.');
tfield(ind)='_';
field=tfield;
if validateStr(lower(tvalue),'1234567890-'),
    % single integer 
    value=str2num(tvalue);
elseif validateStr(lower(tvalue),'1234567890- '),
    % several integers
    value=str2num(tvalue);
elseif validateStr(lower(tvalue),'1234567890.-'),
    % is a single float
    value=str2num(tvalue);
elseif  validateStr(lower(tvalue),'1234567890.- '),
    % several float values
    value=str2num(tvalue);
else
    % string
    value=tvalue;
end

