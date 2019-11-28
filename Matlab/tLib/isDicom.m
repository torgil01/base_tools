function answ=isDicom(file)
% Returns true/false whether given file is a DICOM file or not.
% A dicomfile is identified by skipping forward 128 bytes and reading the
% string "DICM"
% |------128b--------|DICM
% $Id: isDicom.m,v 1.1.1.1 2004/04/15 15:02:59 ToVan Exp $
if exist(file) == 2,
    fid=fopen(file);
else 
    error(sprintf('File %s could not be found',file));
end
if fid == -1,
    error(sprintf('File %s could not be opened',file));
    answ=0;
    return
end
offset=128;
status=fseek(fid,offset,'bof');
if status ==0,
    % success
    S=char(fread(fid,4,'char'));
    S=S';
    if strcmp('DICM',S),
        % OK file is DICOM
        answ=true;
    else
        answ=false;
    end
else
    error(sprintf('File %s could not be read',file));
    answ=0;
    return
end
fclose(fid);