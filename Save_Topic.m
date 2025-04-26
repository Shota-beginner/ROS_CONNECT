% ROS CONNECTION ESTABLISH
% option : rosinit('http://<ROS_MASTER_IP>:11311');

rosinit

% サブスクライバ作成
% メッセージ型の指定は無くても良い
sub = rossubscriber('/cmd_vel', 'geometry_msgs/Twist');

% ログ用変数の初期化
logTime = [];
logLinearX = [];
logAngularZ = [];

disp('Logging /cmd_vel. Press Ctrl+C or close the figure to stop.');

% 可視化用 Figure（省略可能）
% animatedline：
figure;
h1 = animatedline('Color', 'b'); % linear.x
h2 = animatedline('Color', 'r'); % angular.z
legend('linear.x', 'angular.z');
xlabel('Time [s]');
ylabel('Velocity');
grid on;

% タイマー開始
startTime = rostime('now');

while true
    % タイムアウト1秒以内で受信
    msg = receive(sub, 1);

    % 現在の時刻（秒）
    elapsed = rostime('now') - startTime;
    t = double(elapsed.Sec) + double(elapsed.Nsec)*1e-9;

    % 値を記録
    logTime(end+1) = t;
    logLinearX(end+1) = msg.Linear.X;
    logAngularZ(end+1) = msg.Angular.Z;

    % 可視化
    addpoints(h1, t, msg.Linear.X);
    addpoints(h2, t, msg.Angular.Z);
    drawnow limitrate;
end

% 終了時にログを保存（必要なら）
save('cmd_vel_log.mat', 'logTime', 'logLinearX', 'logAngularZ');
