function varargout=plot_movement(varargin)
% plot movement parameters from SPM realignemnt
% USAGE:
% plot_movement 
% -without any parameters user is promted to select rp*.txt file
% plot_movement('rp.txt')
%

def.plotStyle = 'spm'; % [spm | regular]

if nargin == 0,
    parameterFile = spm_select(1,'^.*\.txt$','Select realingment file');
    if isempty(parameterFile),
        fprintf('No file selected\n');
        return
    end
    rp = spm_load(parameterFile);
elseif nargin == 1,
    parameterFile = varargin{1};
    if exist(parameterFile),
        rp = spm_load(parameterFile);
    else
        error('File not found');
    end
else
  help plot_movement
end

switch  def.plotStyle,
    case 'regular'
        %select the rp*.txt file figure;
        figure,
        subplot(2,1,1);plot(rp(:,1:3)); set(gca,'xlim',[0 size(rp,1)+1]);
        subplot(2,1,2);plot(rp(:,4:6)); set(gca,'xlim',[0 size(rp,1)+1]);
    case 'spm'
        plot_parameters(rp,parameterFile);
end

if nargout > 0,
    % get max vals 
    for i =1:6,
        maxVal(i) = max(abs(rp(:,i)));
    end
    varargout{1} = maxVal;
end

        % from spm code
function plot_parameters(P,parameterFile)
fg=spm_figure('Create','Graphics');
if ~isempty(fg),   
    % display results
    % translation and rotation over time series
    %-------------------------------------------------------------------
    spm_figure('Clear','Graphics');
    
    % print info on rp file 
    
    ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'Visible','off');
    S=sprintf('Image realignment file:\n %s',parameterFile);
    set(get(ax,'Title'),'String',S,'FontSize',11,'FontWeight','Bold','Visible','on');
    
    % translation 
    ax=axes('Position',[0.1 0.55 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    plot(P(:,1:3),'Parent',ax)
    s = ['x translation';'y translation';'z translation'];
    %text([2 2 2], Params(2, 1:3), s, 'Fontsize',10,'Parent',ax)
    legend(ax, s, 0)
    set(get(ax,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
    set(get(ax,'Xlabel'),'String','image');
    set(get(ax,'Ylabel'),'String','mm');


    ax=axes('Position',[0.1 0.25 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    plot(P(:,4:6)*180/pi,'Parent',ax)
    s = ['pitch';'roll ';'yaw  '];
    %text([2 2 2], Params(2, 4:6)*180/pi, s, 'Fontsize',10,'Parent',ax)
    legend(ax, s, 0)
    set(get(ax,'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
    set(get(ax,'Xlabel'),'String','image');
    set(get(ax,'Ylabel'),'String','degrees');

    % print realigment parameters
    spm_print
end
return;
%_______________________________________________________________________