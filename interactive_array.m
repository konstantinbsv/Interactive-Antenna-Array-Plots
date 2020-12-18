% Interactive tool for plotting 2-D patterns of an isotropic array

% values for creating initial plot
N = 3;      % number of array elemtents
alpha = 0;  % interelement phase shift
d = 0.5;    % interelement spacing

% figure
global fig;
fig = figure;

% plot
global sp1;
sp1 = subplot('Position', [0.13, 0.16, 0.7750, 0.8150]);

% initialize app data variables
setappdata(fig,'N',N);
setappdata(fig,'alpha',alpha);
setappdata(fig,'d',d);

% create intial plot
plot_polar();
title_dim = [0.175 0.9 0.575 0.075];
annotation('textbox', title_dim,...
    'String', 'Isotropic Array Pattern - Azimuth Cut (Elevation Angle = 0^{\circ})',...
    'FitBoxToText','on', 'EdgeColor', 'none', 'FontWeight', 'bold');

% N slider
max_N = 10;
N_slider = uicontrol('Parent',fig,'Style','slider',...
    'Units', 'normalized',...
    'Position',[125/560,70/420,400/560,23/420],...
    'value', N, 'min',1, 'max',max_N,...
    'SliderStep', [1/(max_N-1), 1/(max_N-1)],...
    'Tag','N_slider',...
    'Callback',@N_slider_callback);
bgcolor = fig.Color;
N_l1 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[100/560,65/420,23/560,23/420],...
    'String','1','BackgroundColor',bgcolor);
N_l2 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[525/560,65/420,23/560,23/420],...
    'String',max_N,'BackgroundColor',bgcolor);
N_l3 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[0/560,67/420,100/560,23/420],...
    'String','Num elements (N)','BackgroundColor',bgcolor);

% alpha slider
global alpha_slider;
alpha_slider = uicontrol('Parent',fig,'Style','slider',...
    'Units', 'normalized',...
    'Position',[125/560,40/420,400/560,23/420],...
    'value', alpha, 'min',-2*pi, 'max',2*pi,...
    'Tag','alpha_slider',...
    'Callback',@alpha_slider_callback);
bgcolor = fig.Color;
delt_l1 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[100/560,35/420,23/560,23/420],...
    'String','-2π','BackgroundColor',bgcolor);
delt_l2 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[525/560,35/420,23/560,23/420],...
    'String','2π','BackgroundColor',bgcolor);
delt_l3 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[0/560,34/420,100/560,23/420],...
    'String','Phase Shift (α)','BackgroundColor',bgcolor);
            

% d spacing slider slider
d_slider = uicontrol('Parent',fig,'Style','slider',...
    'Units', 'normalized',...
    'Position',[125/560,10/420,400/560,23/420],...
    'value', d, 'min',0, 'max',2,...
    'Tag','d_slider',...
    'Callback',@d_slider_callback);
bgcolor = fig.Color;
de_l1 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[100/560,5/420,23/560,23/420],...
    'String','0','BackgroundColor',bgcolor);
de_l2 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[525/560,5/420,23/560,23/420],...
    'String','2','BackgroundColor',bgcolor);
d_l3 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[0/560,4/420,100/560,23/420],...
    'String','Spacing (d/λ)','BackgroundColor',bgcolor);


% Broadside button
broadside = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 0.5 0.2 0.075],...
         'String','Broadside (α=0)',...
         'Tooltip', 'α=0',...
         'Callback',@broadside_callback);
     
% Endfire button
endfire = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 0.4 0.2 0.075],...
         'String','Endfire (α=-kd)',...
         'Tooltip', 'α=-kd',...
         'Callback',@endfire_callback);
     
% Hansen and Woodyard condition button
hansen_woodyard = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 0.3 0.2 0.075],...
         'String','Hansen-Woodyard',... % (α=-(kd+π/N))
         'Tooltip', 'α=-(kd+π/N)',...
         'Callback',@hansen_woodyard_callback);

% N slider callback
function N_slider_callback(hObject,~)
    N = round(hObject.Value); % N must be an integer
    setappdata(hObject.Parent,'N',N);
    plot_polar();
end

% alpha slider callback
function alpha_slider_callback(hObject,~)
    alpha = hObject.Value; % get slider value;
    setappdata(hObject.Parent,'alpha',alpha);
    plot_polar();
end

% d slider callback
function d_slider_callback(hObject,~)
    d = hObject.Value; % get slider value;
    setappdata(hObject.Parent,'d',d);
    plot_polar();
end


function broadside_callback(hObject,~)
    % phase shift alpha = 0 for broadside
    global alpha_slider;
    alpha = 0;
    setappdata(hObject.Parent,'alpha',alpha);
    set(alpha_slider,'Value',alpha)
    plot_polar();
end

function endfire_callback(hObject,~)
    global alpha_slider;
    global fig;
    d = getappdata(fig,'d');
    
    % phase shift alpha = -kd for broadside
    alpha = -2*pi*d;
    setappdata(hObject.Parent,'alpha',alpha);
    set(alpha_slider,'Value',alpha)
    plot_polar();
end

function hansen_woodyard_callback(hObject,~)
    global alpha_slider;
    global fig;
    N = getappdata(fig,'N');
    d = getappdata(fig,'d');
    
    % phase shift alpha = -(kd + pi/N) for Hansen-Woodyard
    alpha = -(2*pi*d + pi/N);
    setappdata(hObject.Parent,'alpha',alpha);
    if (-2*pi <= alpha && alpha <= 2*pi) % keep slider within limits
        set(alpha_slider,'Value',alpha)
    end
    plot_polar();
end

% plots polar plot
% N: number of array elements
% alpha: progressive interelement phase shift (alpha = alpha) 
% d: interelement spacing, lambda omitted
function plot_polar()
    global fig;
    % get app data
    N = getappdata(fig,'N');
    alpha = getappdata(fig,'alpha');
    d = getappdata(fig,'d');
    
    % display values
    disp("N=" + N + "  α=" + round(alpha,3) + "  d/λ=" + round(d,3));
    
    set(0,'defaultfigurecolor','w')
    theta = 0:.005:2*pi;

    % antenna factors function
    AF = sin(N*pi*d*sin(theta)+N*alpha/2)./(N*sin(pi*d*sin(theta)+alpha/2)); 

    % make plot
    % set(sp1, 'Position', [0.13, 0.16, 0.7750, 0.8150]);
    %display( sp1.Position + [0 0.05 0 0]);
    polarpattern(theta*180/pi,abs(AF), 'MagnitudeLim', [0 1]);
    view([-90 90]);
    %set(gcf,'Units','normalized',...
    %     'OuterPosition',[0.5,0.5,0.8,0.8]);
    
    % update parameters readout
    readout_dim = [0.03 0.5 0.5 0.3];
    readout = sprintf('N   = %d\n\\alpha   = %0.3f\nd/\\lambda = %0.3f',...
        N, alpha, d);
    delete(findall(gcf,'Tag','readout_box')); % clear previous readout
    annotation('textbox', readout_dim,...
        'String', readout,...
        'FitBoxToText','on', 'EdgeColor', 'none',...
        'FontWeight', 'normal', 'tag', 'readout_box');
    
end