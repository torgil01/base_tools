function res=ispath(p)
remain = path;
%pArray=[];
count=1;
res=false;
while true
   [str, remain] = strtok(remain,';');
   if isempty(str),  break;  end
   %disp(sprintf('%s', str))
   pArray{count}=str;
   count=count+1;
end
for count=1:length(pArray),
    if strcmp(p,pArray{count}),
        res=true;
        break; 
    end
end