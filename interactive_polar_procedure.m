% Version:  1.0
% Course:   UBC ELEC 411
% Date:     15-Dec-2020
% Author:   Konstantin Borissov
% Purpose:  Interactive tool for visualizing the systematic procedure used 
%           for plotting the polar pattern of an array factor.

% values for creating initial plot
N = 3;      % number of array elemtents
alpha = 0;  % interelement phase shift
d = 0.5;    % interelement spacing

% figure
global fig;
fig = figure('Position', [400 50 600 500]);
movegui('center');

% plot
global sp1;
sp1 = subplot('Position', [0.3, 0.325, 0.65, 0.625]);

% initialize app data variables
setappdata(fig,'N',N);
setappdata(fig,'alpha',alpha);
setappdata(fig,'d',d);
setappdata(fig,'true_nulls',0)

% create intial plot
create_plot();

% special character definitions
alpha_char = char(hex2dec('03b1'));
pi_char = char(hex2dec('03C0'));
lambda_char = char(hex2dec('03BB'));

% 
info_dim = [0.825 0.031 0.0 0.0];
annotation('textbox', info_dim,...
    'String', 'Konstantin Borissov - v1.0',...
    'FitBoxToText', 'on','EdgeColor', 'none',...
    'Color', '#CCCCCC',...
    'FontSize', 6, 'FontWeight', 'normal');

% slider parameters
s_height = 21/450;      % slider height
s_width = 400/560;      % slider width
s_h_spacing = 27/450;   % slider spacing
s_h_bottom = 10/450;    % slider bottom

% N slider
max_N = 10;
N_slider = uicontrol('Parent',fig,'Style','slider',...
    'Units', 'normalized',...
    'Position',[125/560,s_h_bottom+s_h_spacing*2,s_width,s_height],...
    'value', N, 'min',2, 'max',max_N,...
    'SliderStep', [1/(max_N-1), 1/(max_N-1)],...
    'Tag','N_slider',...
    'Callback',@N_slider_callback);
bgcolor = fig.Color;
N_l1 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[100/560,s_h_bottom+s_h_spacing*2-0.0143,23/560,s_height],...
    'String','2','BackgroundColor',bgcolor);
N_l2 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[525/560,s_h_bottom+s_h_spacing*2-0.0143,23/560,s_height],...
    'String',max_N,'BackgroundColor',bgcolor);
N_l3 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[0/560,s_h_bottom+s_h_spacing*2-0.0119,100/560,s_height],...
    'String','Num elements (N)','BackgroundColor',bgcolor);

% alpha slider
global alpha_slider;
alpha_slider = uicontrol('Parent',fig,'Style','slider',...
    'Units', 'normalized',...
    'Position',[125/560,s_h_bottom+s_h_spacing,s_width,s_height],...
    'value', alpha, 'min',-2*pi, 'max',2*pi,...
    'Tag','alpha_slider',...
    'Callback',@alpha_slider_callback);
bgcolor = fig.Color;
delt_l1 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[100/560,s_h_bottom+s_h_spacing-0.0143,23/560,s_height],...
    'String',['-2', pi_char],'BackgroundColor',bgcolor);
delt_l2 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[525/560,s_h_bottom+s_h_spacing-0.0143,23/560,s_height],...
    'String',['2', pi_char],'BackgroundColor',bgcolor);
delt_l3 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[0/560,s_h_bottom+s_h_spacing-0.0119,100/560,s_height],...
    'String',['Phase Shift (',alpha_char,')'],'BackgroundColor',bgcolor);
            

% d spacing slider slider
global d_slider;
d_slider = uicontrol('Parent',fig,'Style','slider',...
    'Units', 'normalized',...
    'Position',[125/560,s_h_bottom,s_width,s_height],...
    'value', d, 'min',0, 'max',1,...
    'Tag','d_slider',...
    'Callback',@d_slider_callback);
bgcolor = fig.Color;
de_l1 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[100/560,s_h_bottom-0.0119,23/560,s_height],...
    'String','0','BackgroundColor',bgcolor);
de_l2 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[525/560,s_h_bottom-0.0119+0.02,23/560,s_height-0.02],...
    'String','1','BackgroundColor',bgcolor);
de_l3 = uicontrol('Parent',fig,'Style','text',...
    'Units', 'normalized',...
    'Position',[0/560,s_h_bottom-0.0143,100/560,s_height],...
    'String',['Spacing (d/',lambda_char,')'],'BackgroundColor',bgcolor);

% button parameters
b_width = 0.2;
b_height = 0.0625;
b_h_spacing = 0.0775;
b_h_bottom = 0.215;
% Broadside button
broadside = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 b_h_bottom+b_h_spacing*2 b_width b_height],...
         'String',['Broadside (',alpha_char,'=0)'],...
         'Tooltip', [alpha_char,'=0'],...
         'Callback',@broadside_callback);
     
% Endfire button
endfire = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 b_h_bottom+b_h_spacing*1 b_width b_height],...
         'String',['Endfire (',alpha_char,'=-kd)'],...
         'Tooltip', [alpha_char,'=-kd'],...
         'Callback',@endfire_callback);
     
% Hansen and Woodyard condition button
hansen_woodyard = uicontrol('Parent', fig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.01 b_h_bottom b_width b_height],...
         'String','Hansen-Woodyard',... % (α=-(kd+π/N))
         'Tooltip', [alpha_char,'=-(kd+',pi_char,'/N)', newline,...
                    'd<', lambda_char, '/2*(1-1/N)'],...
         'Callback',@hansen_woodyard_callback);
     
     
% options checkbox
true_nulls_check = uicontrol('Parent', fig,'Style','checkbox',...
         'Units','normalized',...
         'Position',[0.03 b_h_bottom+b_h_spacing*3 0.15 b_height/1.5],...
         'String','Show true nulls',...
         'Tooltip', 'Shows true nulls found by solving for AF numerator = 0',...
         'BackgroundColor', 'white',...
         'Callback',@true_nulls_callback);

% N slider callback
function N_slider_callback(hObject,~)
    N = round(hObject.Value); % N must be an integer
    setappdata(hObject.Parent,'N',N);
    create_plot();
end

% alpha slider callback
function alpha_slider_callback(hObject,~)
    alpha = hObject.Value; % get slider value;
    setappdata(hObject.Parent,'alpha',alpha);
    create_plot();
end

% d slider callback
function d_slider_callback(hObject,~)
    d = hObject.Value; % get slider value;
    setappdata(hObject.Parent,'d',d);
    create_plot();
end


function broadside_callback(hObject,~)
    % phase shift alpha = 0 for broadside
    global alpha_slider;
    alpha = 0;
    setappdata(hObject.Parent,'alpha',alpha);
    set(alpha_slider,'Value',alpha)
    create_plot();
end

function endfire_callback(hObject,~)
    global alpha_slider;
    global fig;
    d = getappdata(fig,'d');
    
    % phase shift alpha = -kd for broadside
    alpha = -2*pi*d;
    setappdata(hObject.Parent,'alpha',alpha);
    set(alpha_slider,'Value',alpha)
    create_plot();
end

function hansen_woodyard_callback(hObject,~)
    global d_slider;
    global alpha_slider;
    global fig;
    N = getappdata(fig,'N');
    d = getappdata(fig,'d');
    
    % check if d is within accetable range to keep backlobe 
    % from becoming larger than main beam
    if (~(d < 1/2*(1-1/N)))
        d = 1/2*(1-1/N);
    end
    setappdata(hObject.Parent,'d',d);
    set(d_slider,'Value',d);
    
    % phase shift alpha = -(kd + pi/N) for Hansen-Woodyard
    alpha = -(2*pi*d + pi/N);
    setappdata(hObject.Parent,'alpha',alpha);
    if (-2*pi <= alpha && alpha <= 2*pi) % keep slider within limits
        set(alpha_slider,'Value',alpha);
    end
    create_plot();
end

function true_nulls_callback(hObject,~)
    true_nulls = hObject.Value;
    setappdata(hObject.Parent,'true_nulls',true_nulls);
    create_plot();
end


% plots polar plot
% N: number of array elements
% alpha: progressive interelement phase shift (alpha = alpha) 
% d: interelement spacing, lambda omitted
function create_plot()
    global fig;
    % get app data
    N = getappdata(fig,'N');
    alpha = getappdata(fig,'alpha');
    d = getappdata(fig,'d');
    true_nulls = getappdata(fig,'true_nulls');
    
    % display values
    global alpha_char;
    disp(['N=', num2str(N), ' ',...
        alpha_char,'=', num2str(round(alpha,3)), ' ',...
        'd/', char(hex2dec('03BB')), '=', num2str(round(d,3))]);
    
    set(0,'defaultfigurecolor','w')
    theta = -2*pi:.01:2*pi;

    % antenna factors function
    psi = @(d, alpha, theta) (2*pi*d*cos(theta) + alpha);       
    AF = @(N, d, alpha, theta)...
    abs(sin(N/2*psi(d, alpha, theta))./(N*sin(psi(d, alpha, theta)/2)));

    % nulls function
    % note: abs(n) should be < N
    theta_null = @(N,d,alpha,n) acos(1/(2*pi*d)*(2*pi*n/N-alpha));
    
   
    % make plot
    delete(gca); % clear plot
    cartesian_pos = [0.24 0.21 0.7 0.77];
    axes('position', cartesian_pos);
    plot(theta, AF(N, 0.5, -pi, theta/2));
    
    % format y-axis
    delete(findall(gcf,'Tag','ylabel')); % clear previous label
    y_lab = ylabel('|f\psi(x)|', 'Tag', 'ylabel');
    y_lab.Position(1) = -7.5;
    y_lab.Position(2) = 0.5;
    yticks([0 1]);
    yticklabels({});    % clear previous y tick marks
    yticklabels({'0', '1'});
    
    % format x-axis
    xticks([-5/2*pi -2*pi -pi 0 pi 2*pi 5/2*pi])
    xticklabels({'-5/2*pi', '-2\pi', '-\pi', '0', '\pi', '2\pi','-5/2*pi'})
    ax = gca;
    ax.XAxis.MinorTick = 'on';
    ax.XAxis.MinorTickValues = -2*pi:pi/4:2*pi;
    ax.XAxisLocation = 'origin'; % move x-axis to origin
    cartesian_axis = [-9/4*pi 9/4*pi -3 1];
    axis(cartesian_axis);
    
    % find nulls on cartesian plot
    n=1;
    i=1;    % keeps track of total number of nulls in visible region
    cart_nulls = double.empty(10,0); % preallocate nulls array
    
    % TODO: this loop can be optimized
    while 1
        null_c_n = theta_null(N,0.5,-pi,-n)*2;  % cartesian null
        
        % check if both nulls outside visible region or if either imaginary
        vis_max = 2*pi*d + alpha;
        vis_min = -2*pi*d + alpha;
        if (~isreal(null_c_n) || (-null_c_n<vis_min && vis_max<null_c_n) || n >= N) 
            break;
        end
        
        % add negative and positive nulls to array
        if (vis_min<=-null_c_n)
            cart_nulls(i) = -null_c_n;      % save cartesian null to array
            i = i + 1;                      % increment array index    
        end
        if (null_c_n<=vis_max)
            cart_nulls(i) = null_c_n;   
            i = i + 1;
        end
        
        n = n + 1;           % increment n 
    end
    
    % plot nulls on cartesian plot
    for null=cart_nulls
        % nulls are symmetric about x = 0
        line([null null], [0 -1.5], 'linestyle', '--', 'Color', 'black');
    end
    
    
    % create polar plot
    
    % calculate dimensions and postition of polar plot
    % calculate x axis normalization factor relative to cartesian plot
    x_norm_factor = cartesian_pos(3)/(cartesian_axis(2)-cartesian_axis(1));
    kd = 2*pi*d; % from plotting procedure
    % calculate polar plot width and height
    polar_w = 2*kd*x_norm_factor;
    polar_h = 3/4*cartesian_pos(4);
    % calculate alpha shift relative to cartesian axis
    alpha_shift = alpha*x_norm_factor;
    % calculate polar axes x and y position
    polar_x0 = cartesian_pos(1) + cartesian_pos(3)/2 - polar_w/2 + alpha_shift;
    y0_norm_factor = 0.5*(-cartesian_axis(3)/(cartesian_axis(4)-cartesian_axis(3)));
    polar_y0 = cartesian_pos(2) + y0_norm_factor*cartesian_pos(4) - polar_h/2;
    
    % plot polar on top of cartesian
    polar_pos = [polar_x0 polar_y0 polar_w polar_h];
    polaraxes('Position', polar_pos);
    polarplot(theta, AF(N, d, alpha, theta));
    ax = gca;
    ax.RAxisLocation = 330; % move r axis labels
    %ax.RColor = '#4DBEEE';
    rlim([0 1]);
    
    % find real nulls on polar plot
    
    % find nulls true nulls on polar plot in quadrants I and II
    n=1;
    i=1;    % keeps track of total number of nulls
    polar_nulls = double.empty(10,0); % preallocate nulls array
    
    % TODO: this loop can be optimized
    while 1
        null_p_n1 = theta_null(N,d,alpha,n);    % true polar null
        null_p_n2 = theta_null(N,d,alpha,-n);
        
        % check if nulls imaginary
        if (~isreal(null_p_n1) && ~isreal(null_p_n2) || n >= N) 
            break;
        end
        
        % add negative and positive n nulls to array
        if (isreal(null_p_n1))
            polar_nulls(i) = null_p_n1;     % save polar null
            i = i + 1;                      % increment array index    
        end
        if (isreal(null_p_n2))
            polar_nulls(i) = null_p_n2;
            i = i + 1;
        end
        
        n = n + 1;           % increment n 
    end
    
    % plot nulls on polar plot
    if true_nulls % if show exact nulls:
        for null=polar_nulls
            line([0 null], [0 1], 'linestyle', '--', 'Color', 'red');
        end
    else     % show approx nulls
        for i=1:length(cart_nulls)
            null = acos((cart_nulls(i)-alpha)/(2*pi*d)); % map null to polar
            if (null < 0)    % rotate null 180 if across from plot
                null = null+pi;
            end
            if (isreal(null))
                line([0 null], [0 1], 'linestyle', '--', 'Color', 'black');
            end
            %label=sprintf('%.1f^{o}', null*180/pi);
            %annotation('textarrow',[0.3 0.5], [0.3 0.5],'String',label);
        end
    end

    % array factor display
    N_char = num2str(N);
    kd_char = num2str(round(2*pi*d,2));
    alpha_ch = num2str(round(alpha,2),'%+2.2f');
    af_dim = [0.017 0.5 0.5 0.3];
    AF_equation = ['$$AF(\psi) = $$', newline,...
        '$$\sum\limits_{n=0}^{', N_char-1,...
        '} e^{jn(', kd_char ,'cos\theta', alpha_ch,')}$$'];
    delete(findall(gcf,'Tag','af_box')); % clear previous
    annotation('textbox', af_dim,...
        'String', AF_equation,...
        'Interpreter','latex',...
        'FitBoxToText','on', 'EdgeColor', 'none',...
        'FontWeight', 'normal', 'tag', 'af_box');
    
    
    % update parameters readout
    readout_dim = [0.03 0.335 0.5 0.3];
    d_char = num2str(round(d,3));
    %readout = sprintf('N   = %d\n\\alpha   = %0.3f\nd/\\lambda = %0.3f',...
    %    N, alpha, d);
    readout = ['$$N = ', N_char, '$$', newline,...
        '$$\alpha = ',alpha_ch, '\ rad$$', newline,...
        '$$d/\lambda = ', d_char,'$$'];
    delete(findall(gcf,'Tag','readout_box')); % clear previous readout
    annotation('textbox', readout_dim,...
        'String', readout,...
        'Interpreter','latex',...
        'FitBoxToText','on', 'EdgeColor', 'none',...
        'FontWeight', 'normal', 'tag', 'readout_box');
    
end