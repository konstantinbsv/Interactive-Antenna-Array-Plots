% Interactive directivity graph

% values for creating initial plot
N = 3;       % number of array elemtents
theta0 = 0;  % steering angle
d = 0.5;     % interelement spacing

% figure
global fig;
fig = figure;

% plot
global sp1;
sp1 = subplot('Position', [0.3, 0.325, 0.65, 0.625]);

% initialize app data variables
setappdata(fig,'N',N);
setappdata(fig,'theta0',theta0);
setappdata(fig,'d',d);

% create intial plot
plot_directivity();

% N slider
max_N = 10;
N_slider = uicontrol('Parent',fig,'Style','slider',...
    'Position',[125,70,400,23],...
    'value', N, 'min',1, 'max',max_N,...
    'SliderStep', [1/(max_N-1), 1/(max_N-1)],...
    'Tag','N_slider',...
    'Callback',@N_slider_callback);
bgcolor = fig.Color;
N_l1 = uicontrol('Parent',fig,'Style','text',...
    'Position',[100,65,23,23],...
    'String','1','BackgroundColor',bgcolor);
N_l2 = uicontrol('Parent',fig,'Style','text',...
    'Position',[525,65,23,23],...
    'String',max_N,'BackgroundColor',bgcolor);
N_l3 = uicontrol('Parent',fig,'Style','text',...
    'Position',[0,67,100,23],...
    'String','Num elements (N)','BackgroundColor',bgcolor);

% theta0 slider
global theta0_slider;
theta0_slider = uicontrol('Parent',fig,'Style','slider',...
    'Position',[125,40,400,23],...
    'value', theta0, 'min',0, 'max',180,...
    'Tag','theta0_slider',...
    'Callback',@theta0_slider_callback);
bgcolor = fig.Color;
delt_l1 = uicontrol('Parent',fig,'Style','text',...
    'Position',[100,35,23,23],...
    'String','0°','BackgroundColor',bgcolor);
delt_l2 = uicontrol('Parent',fig,'Style','text',...
    'Position',[525,35,23,23],...
    'String','180°','BackgroundColor',bgcolor);
delt_l3 = uicontrol('Parent',fig,'Style','text',...
    'Position',[0,34,100,23],...
    'String','Steering Angle(θ_o)','BackgroundColor',bgcolor);
            

% d spacing slider slider
d_slider = uicontrol('Parent',fig,'Style','slider',...
    'Position',[125,10,400,23],...
    'value', d, 'min',0, 'max',2,...
    'Tag','d_slider',...
    'Callback',@d_slider_callback);
bgcolor = fig.Color;
de_l1 = uicontrol('Parent',fig,'Style','text',...
    'Position',[100,5,23,23],...
    'String','0','BackgroundColor',bgcolor);
de_l2 = uicontrol('Parent',fig,'Style','text',...
    'Position',[525,5,23,23],...
    'String','2','BackgroundColor',bgcolor);
d_l3 = uicontrol('Parent',fig,'Style','text',...
    'Position',[0,4,100,23],...
    'String','Spacing (d/λ)','BackgroundColor',bgcolor);


% Broadside button
broadside = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 0.4 0.2 0.075],...
         'String','Broadside (θ_o=90°)',...
         'Callback',@broadside_callback);
     
% Endfire button
endfire = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 0.3 0.2 0.075],...
         'String','Endfire (θ_o=0°)',...
         'Callback',@endfire_callback);
     

% N slider callback
function N_slider_callback(hObject,~)
    N = round(hObject.Value); % N must be an integer
    setappdata(hObject.Parent,'N',N);
    plot_directivity();
end

% theta0 slider callback
function theta0_slider_callback(hObject,~)
    theta0 = hObject.Value; % get slider value;
    setappdata(hObject.Parent,'theta0',theta0);
    plot_directivity();
end

% d slider callback
function d_slider_callback(hObject,~)
    d = hObject.Value; % get slider value;
    setappdata(hObject.Parent,'d',d);
    plot_directivity();
end


function broadside_callback(hObject,~)
    % phase shift theta0 = 90 for broadside
    global theta0_slider;
    theta0 = acos(0)*180/pi;
    setappdata(hObject.Parent,'theta0',theta0);
    set(theta0_slider,'Value',theta0)
    plot_directivity();
end

function endfire_callback(hObject,~)
    global theta0_slider;
    global fig;
    d = getappdata(fig,'d');
    
    % phase shift theta0 = 0 for endfire
    theta0 = acos(1)*180/pi;
    setappdata(hObject.Parent,'theta0',theta0);
    set(theta0_slider,'Value',theta0)
    plot_directivity();
end


% plots polar plot
% N: number of array elements
% theta0: steering angle
% d: interelement spacing, lambda omitted
function plot_directivity()
    global fig;
    % get app data
    N = getappdata(fig,'N');
    theta0 = getappdata(fig,'theta0');
    theta0_r = theta0*pi/180+0.01; % convert theta0 to radians
    d = getappdata(fig,'d');
    
    % display values
    disp("N=" + N + "  θ_o=" + round(theta0,3) + "  d=" + round(d,3));
    
    set(0,'defaultfigurecolor','w')
    delta=.0013;
    x=delta:delta:pi;

    % function
    F=@(N,theta0_r,d,x) ((sin(.5*N*2*pi*d*(cos(x)-cos(theta0_r)))./(.5*N*2*pi*d*(cos(x)-cos(theta0_r)))).^2);
    
    % calculate directivity
    den=trapz(x,F(N,theta0_r,d,x).*sin(x));
    D=2.*F(N,theta0_r,d,x)./den;

    % set(sp1, 'Position', [0.13, 0.16, 0.7750, 0.8150]);
    %display( sp1.Position + [0 0.05 0 0]);
    
    % draw plot
    x_deg=x*180/pi;
    plot(x_deg,D)
    axis([0 180 0 20])
    grid on
    title('Maximum Directivity of Steered Array')
    xlabel('\theta')
    ylabel('D_o')

    % update parameters readout
    D_max=max(D);
    readout_dim = [0.03 0.5 0.5 0.3];
    readout = sprintf('D_{0} = %.2f\n\nN   = %d\n\\theta_{0}   = %0.1f^{o}\nd/\\lambda = %0.3f',...
        D_max, N, theta0, d);
    delete(findall(gcf,'Tag','readout_box')); % clear previous readout
    annotation('textbox', readout_dim,...
        'String', readout,...
        'FitBoxToText','on', 'EdgeColor', 'none',...
        'FontWeight', 'normal', 'tag', 'readout_box');
end