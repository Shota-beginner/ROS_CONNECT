function auto_git_push(fileList, commitMessage)
% autoGitPushFile: 指定したファイルだけGit addしてcommit/pushする
% 使い方：autoGitPushFile({'ファイル1.m', 'ファイル2.m'}, '変更内容')


if nargin < 2
    commitMessage = 'Update'; % デフォルトメッセージ
end

disp('--- 特定ファイルGit管理自動化開始 ---');

% ファイルをステージング
for i = 1:length(fileList)
    file = fileList{i};
    addCmd = sprintf('git add "%s"', file);
    [status, cmdout] = system(addCmd);
    if status ~= 0
        error('git add 失敗: %s\n%s', file, cmdout);
    else
        fprintf('git add 成功: %s\n', file);
    end
end

% コミット
commitCmd = sprintf('git commit -m "%s"', commitMessage);
[status, cmdout] = system(commitCmd);
if status ~= 0
    if contains(cmdout, 'nothing to commit')
        disp('コミットする変更はありません。');
    else
        error('git commit 失敗: %s', cmdout);
    end
else
    disp('git commit 成功');
end

% プッシュ
[status, cmdout] = system('git push');
if status ~= 0
    error('git push 失敗: %s', cmdout);
else
    disp('git push 成功');
end

disp('--- 指定ファイルGit管理完了 ---');

end
