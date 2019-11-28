function answ=validateStr(string,char)
% Validates that the string 'string' only contains the characters in
% 'char', 
% Example 1:
%  string = 'abab', char='ab' validateStr = true
% Example 2:
%  string = 'abab', char='ac' validateStr = false
% Example 3:
%  string = 'abab', char='abc' validateStr = true 
% $Id: validateStr.m,v 1.1.1.1 2004/04/15 15:02:59 ToVan Exp $

if (ischar(string) & ischar(char)),
    for i=1:length(string),
        j=1;
        while j <= length(char),
            if strcmp(string(i),char(j)),
                break
            end
            j=j+1;
        end
        if j >length(char),
            answ=false;
            return
        end
    end
    answ=true;
else
    error('Error in validateStr, input arguments must be strings');
    answ=false;
end
return
