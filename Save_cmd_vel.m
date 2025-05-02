%% 初期化
rosshutdown
clc
clear

% ROSネットワーク接続
rosinit("http://192.168.43.9:11311");

%% 初期化
rosshutdown
clc
clear

% ROSネットワーク接続
rosinit("http://192.168.43.9:11311");

%% トピックの安全なサブスクライバ作成（try-catch付き）
try 
    sub_cmd_vel = rossubscriber('/cmd_vel'); 
catch 
    warning('/cmd_vel not found'); sub_cmd_vel = []; 
end

try 
    sub_tf = rossubscriber('/tf'); 
catch
    warning('/tf not found'); sub_tf = []; 
end

try 
    sub_map = rossubscriber('/map'); 
catch 
    warning('/map not found'); sub_map = []; 
end

try 
    sub_pose = rossubscriber('/cartographer/pose'); 
catch 
    warning('/cartographer/pose not found'); sub_pose = []; 
end

try 
    sub_goal = rossubscriber('/move_base/goal'); 
catch 
    warning('/move_base/goal not found'); sub_goal = []; 
end

try 
    sub_global_plan = rossubscriber('/move_base/TrajectoryPlannerROS/global_plan'); 
catch 
    warning('/global_plan not found'); sub_global_plan = []; 
end

try 
    sub_local_plan = rossubscriber('/move_base/TrajectoryPlannerROS/local_plan'); 
catch 
    warning('/local_plan not found'); sub_local_plan = []; 
end

try 
    sub_navfn_plan = rossubscriber('/move_base/NavfnROS/plan'); 
catch 
    warning('/navfn_plan not found'); sub_navfn_plan = []; 
end

%% ログ変数初期化
logTime = [];
log_cmd_vel = struct('linear_x', [], 'angular_z', []);
log_pose = struct('x', [], 'y', [], 'yaw', []);
log_goal = struct('x', [], 'y', []);
log_global_plan = {};
log_local_plan = {};
log_navfn_plan = {};
log_map = {};
log_tf = {};

startTime = rostime('now');
disp('Logging topics... Press Ctrl+C or close MATLAB to stop.');

%% メインループ
while true
    elapsed = rostime('now') - startTime;
    t = double(elapsed.Sec) + double(elapsed.Nsec)*1e-9;
    logTime(end+1) = t;

    % 以下すべて try-catch で個別に囲む
    try
        msg_cmd = receive(sub_cmd_vel, 1);
        log_cmd_vel.linear_x(end+1) = msg_cmd.Linear.X;
        log_cmd_vel.angular_z(end+1) = msg_cmd.Angular.Z;
    catch
        warning('cmd_vel reception failed at t=%.2f', t);
    end

    try
        msg_pose = receive(sub_pose, 1);
        pos = msg_pose.Pose.Pose.Position;
        ori = msg_pose.Pose.Pose.Orientation;
        yaw = quat2yaw([ori.W, ori.X, ori.Y, ori.Z]);
        log_pose.x(end+1) = pos.X;
        log_pose.y(end+1) = pos.Y;
        log_pose.yaw(end+1) = yaw;
    catch
        warning('pose reception failed at t=%.2f', t);
    end

    try
        msg_goal = receive(sub_goal, 1);
        pos_goal = msg_goal.Pose.Position;
        log_goal.x(end+1) = pos_goal.X;
        log_goal.y(end+1) = pos_goal.Y;
    catch
        warning('goal reception failed at t=%.2f', t);
    end

    try
        msg_global = receive(sub_global_plan, 1);
        log_global_plan{end+1} = extractPlan(msg_global);
    catch
        warning('global_plan reception failed at t=%.2f', t);
    end

    try
        msg_local = receive(sub_local_plan, 1);
        log_local_plan{end+1} = extractPlan(msg_local);
    catch
        warning('local_plan reception failed at t=%.2f', t);
    end

    try
        msg_navfn = receive(sub_navfn_plan, 1);
        log_navfn_plan{end+1} = extractPlan(msg_navfn);
    catch
        warning('navfn_plan reception failed at t=%.2f', t);
    end

    try
        msg_map = receive(sub_map, 1);
        log_map{end+1} = readImage(msg_map);
    catch
        warning('map reception failed at t=%.2f', t);
    end

    try
        msg_tf = receive(sub_tf, 1);
        log_tf{end+1} = msg_tf;
    catch
        warning('tf reception failed at t=%.2f', t);
    end
end
