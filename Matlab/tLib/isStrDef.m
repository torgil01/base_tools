function answ=isStrDef(struct,name)
% function answ=isStrDef(struct,name)
% answ = boolean
% struct = structure
% name = string
% Determine if field 'name' is defined in structure 'struct' ie if the
% variable 'struct.name' is defined
% $Id: isStrDef.m,v 1.1.1.1 2004/04/15 15:02:59 ToVan Exp $
fname=fieldnames(struct);
if strmatch(name,fname,'exact') > 0,
    answ=true;
else
    answ=false;
end
return
