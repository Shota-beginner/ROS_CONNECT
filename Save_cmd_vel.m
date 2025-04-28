%% 初期化
rosshutdown
clc
clear

% ROSネットワーク接続
rosinit("http://192.168.43.9:11311");

%% 必要なトピックのサブスクライバを作成
sub_cmd_vel = rossubscriber('/cmd_vel');
sub_tf = rossubscriber('/tf');
sub_map = rossubscriber('/map');
sub_pose = rossubscriber('/cartographer/pose');  % Cartographerの場合
sub_goal = rossubscriber('/move_base/goal');
sub_global_plan = rossubscriber('/move_base/TrajectoryPlannerROS/global_plan');
sub_local_plan = rossubscriber('/move_base/TrajectoryPlannerROS/local_plan');
sub_navfn_plan = rossubscriber('/move_base/NavfnROS/plan');

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

% タイマー開始
startTime = rostime('now');

disp('Logging topics... Press Ctrl+C or close MATLAB to stop.');

%% メインループ
while true
    
    % 時間計測
    elapsed = rostime('now') - startTime;
    t = double(elapsed.Sec) + double(elapsed.Nsec)*1e-9;
    logTime(end+1) = t;

    % cmd_vel
    msg_cmd = receive(sub_cmd_vel, 1);
    log_cmd_vel.linear_x(end+1) = msg_cmd.Linear.X;
    log_cmd_vel.angular_z(end+1) = msg_cmd.Angular.Z;

    % pose
    msg_pose = receive(sub_pose, 1);
    pos = msg_pose.Pose.Pose.Position;
    ori = msg_pose.Pose.Pose.Orientation;
    yaw = quat2yaw([ori.W, ori.X, ori.Y, ori.Z]);
    log_pose.x(end+1) = pos.X;
    log_pose.y(end+1) = pos.Y;
    log_pose.yaw(end+1) = yaw;

    % goal
    msg_goal = receive(sub_goal, 1);
    pos_goal = msg_goal.Pose.Position;
    log_goal.x(end+1) = pos_goal.X;
    log_goal.y(end+1) = pos_goal.Y;

    % global plan
    msg_global = receive(sub_global_plan, 1);
    log_global_plan{end+1} = extractPlan(msg_global);

    % local plan
    msg_local = receive(sub_local_plan, 1);
    log_local_plan{end+1} = extractPlan(msg_local);

    % navfn plan
    msg_navfn = receive(sub_navfn_plan, 1);
    log_navfn_plan{end+1} = extractPlan(msg_navfn);

    % map
    msg_map = receive(sub_map, 1);
    log_map{end+1} = readImage(msg_map);

    % tf
    msg_tf = receive(sub_tf, 1);
    log_tf{end+1} = msg_tf;

    % 適宜可視化や保存処理を入れてもOK
    
end

%% クォータニオン→ヨー角変換
function yaw = quat2yaw(q)
    % q = [w x y z]
    angles = quat2eul([q(1) q(2) q(3) q(4)]);
    yaw = angles(1);
end

%% ナビゲーションプランを座標リストに変換
function path = extractPlan(plan_msg)
    poses = plan_msg.Poses;
    path = zeros(length(poses), 2);
    for i = 1:length(poses)
        path(i,1) = poses(i).Pose.Position.X;
        path(i,2) = poses(i).Pose.Position.Y;
    end
end
