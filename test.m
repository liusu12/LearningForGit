% 一键配置脚本（替换YOUR_SSH_PATH为您的实际路径）
function one_click_ssh_setup()
    % ========== 在这里设置您的SSH路径 ==========
    YOUR_SSH_PATH = 'D:\Program Files (x86)\Git\usr\bin\ssh.exe';  % ← 修改这里！
    % ==========================================
    
    fprintf('开始配置SSH: %s\n\n', YOUR_SSH_PATH);
    
    % 1. 配置环境变量
    setenv('GIT_SSH', YOUR_SSH_PATH);
    fprintf('✅ 已设置GIT_SSH环境变量\n');
    
    % 2. 配置Git
    git_ssh_path = strrep(YOUR_SSH_PATH, '\', '/');
    system(['git config --global core.sshCommand "', git_ssh_path, '"']);
    fprintf('✅ 已配置Git SSH命令\n');
    
    % 3. 添加到PATH
    git_bin = fileparts(fileparts(YOUR_SSH_PATH));
    git_bin = fullfile(git_bin, 'bin');
    if exist(git_bin, 'dir')
        setenv('PATH', [git_bin, ';', getenv('PATH')]);
        fprintf('✅ 已添加Git到PATH\n');
    end
    
    % 4. 测试
    fprintf('\n测试SSH连接...\n');
    [status, result] = system(['"', YOUR_SSH_PATH, '" -T git@github.com 2>&1']);
    
    if contains(result, 'successfully authenticated')
        fprintf('✅ SSH配置成功！\n');
        fprintf('您现在可以使用SSH进行Git操作了。\n\n');
        
        % 检查并建议切换远程地址
        [status, remote] = system('git config --get remote.origin.url');
        if status == 0
            remote = strtrim(remote);
            if contains(remote, 'https://')
                fprintf('建议切换到SSH地址:\n');
                fprintf('  git remote set-url origin git@github.com:liusu12/LearningForGit.git\n');
            end
        end
    else
        fprintf('⚠️  SSH连接测试失败: %s\n', result);
        fprintf('请检查:\n');
        fprintf('1. SSH密钥是否已生成\n');
        fprintf('2. 公钥是否已添加到GitHub\n');
    end
    
    fprintf('\n配置完成！\n');
end

% 运行一键配置
