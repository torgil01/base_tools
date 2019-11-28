function rp_plot(rp_files)

%filt = ['^rp_*','.*\.txt$'];
% b = spm_select([Inf],'any','Select realignment parameters',[],pwd,filt);
   scaleme = [-3 3];
   
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
     title(['Motion parameters: shifts (top, in mm) and rotations (bottom, in dg)'], 'interpreter', 'none');
     subplot(2,1,2);
     plot(loadmot(:,4:6)*180/pi);
     grid on;
     ylim(scaleme);   % enable to always scale between fixed values as set above
     title(['Data from ' p], 'interpreter', 'none');
     mydate = date;
     motname = [mydata filesep 'motion_' mydate '.pdf'];
     spm_print(motname,printfig);
     %print(printfig, '-dpng', '-noui', '-r100', motname);  % enable to print to file
     close(printfig);   % enable to close graphic window
   end;