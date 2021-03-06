function V = FKanimate(angles, des_pos, arm_lengths, frame,enable_pause)
%% Initialization for configuration
% Configuration in 2D space
% angles includes all the joint angles, where each row is a single frame of
% the animation
% arm_lengths includes all the arm lengths
% des_pos is the desired position of the end effector
if nargin <= 3
    arm_lengths = ones(N_JOINTS);
    enable_pause = 1;
elseif   nargin < 5
    enable_pause = 1;
end
N_JOINTS = length(angles);
assert(N_JOINTS == length(arm_lengths));
persistent f

%N_FRAMES = size(angles,1);
%N_JOINTS = size(angles,2);
if frame == 1
    AXIS = max([sum(arm_lengths), des_pos(1), des_pos(2)]); % TODO: Error handle, unreachable
    figure
    plot(des_pos(1), des_pos(2), 'k.', 'markersize',20);
    axis([-AXIS AXIS -AXIS AXIS]);
    hold on;
    grid on;

    [X,Y] = FK2D(angles, arm_lengths);
    % Init with 0,0 for plotting
    X = [0 X];
    Y = [0 Y];
    
    f = plot(X,Y, 'linewidth',4);    
else 
    [X,Y] = FK2D(angles, arm_lengths);
    X = [0 X];
    Y = [0 Y];
    set(f, 'xdata', X, 'ydata', Y);
end
if enable_pause
pause(0.01);
end
%end

end