function value = getFsfParam(param,fsfFile)
% return value of a given paramater form  a FEAT fsf file

if ~exist(fsfFile,'file'),
    error('file %s not found\n',fsfFile);
end

try
    fid=fopen(fsfFile);
    lines=textscan(fid,'%s','whitespace','\n'); 
    fclose(fid);
catch
    if exist(fid),
        fclose(fid);
    end
    error('error reading');
end

indx = [];
for ii=1:length(lines{1}),
    ss = lines{1}{ii};
    indx = strfind(ss,param);
    if ~isempty(indx)
        break
    end    
end
if isempty(indx)
    error('no tag = %s found\n',param);
    value =[];
end
% ss = 'set tag value'
tmpVal = ss(indx+length(param)+1:end);
if strfind(tmpVal,'"'),
    value = tmpVal(2:end-1);
else
    value = str2num(tmpVal);
end

    

