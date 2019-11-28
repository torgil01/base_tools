function info = fslinfo(imageFile)
% wrapper for fslinfo
% return info as struct
if ~exist(imageFile,'file'),
    error('File %s not found, exiting',file);
end
[err,output] = system(sprintf('fslinfo %s',imageFile));
if err ~= 0,
    error('Error in fslinfo.m (fslinfo wrapper); output from command:\n %s\n',output);
end

info=struct;
itype={'str' 'int' 'int' 'int' 'int' 'int' 'float' 'float' 'float' 'float' 'float' 'float' 'str'}; 
pos=0;
for i=1:13
    switch itype{i},
        case  'str'         
            [line,steps] = textscan(output(pos+1:end),'%s %s',1);
            fld = char(line{1});            
            info.(fld) = char(line{2});
        case   'int'
            [line,steps] = textscan(output(pos+1:end),'%s %d',1);
            fld = char(line{1});
            info.(fld) = line{2}; 
        case 'float'
           [line,steps] = textscan(output(pos+1:end),'%s %f',1);                  
           fld = char(line{1});
           info.(fld) = line{2}; 
    end
    pos = pos+steps;
end

if isempty(info),
    warning('fslinfo returns empty value');
end
