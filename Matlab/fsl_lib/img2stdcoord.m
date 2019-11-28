function xyzmm = img2stdcoord(xyzvox,file,template)
% wrapper for fsl's img2stdcoord
% Note if function isused only for converting from vox - > mm
% just use the filename for template also

coordTempFile =tempname;
command = sprintf('img2stdcoord -std %s -img %s %s',template,file,coordTempFile);
%try
    fid = fopen(coordTempFile,'w+');
    fprintf(fid,'%d %d %d',xyzvox(1),xyzvox(2),xyzvox(3));
    fclose(fid);
    
    [err,out] = system(command);
    if err ~= 0,
        error('nonzero exit for command; %s\n with output\n %s\n',command,out);
    end
    xyzmm = str2num(out);
%catch ME
 %   delete(coordTempFile);
    
%end
delete(coordTempFile);


