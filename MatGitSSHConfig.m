%第四步：验证密钥位置
% 1. 检查密钥文件是否在正确位置
ssh_dir = getenv('USERPROFILE') + "\.ssh";
disp("您的SSH密钥应该存放在: " + ssh_dir);

% 2. 列出.ssh文件夹内容
if exist(ssh_dir, 'dir')
    disp("✅ .ssh目录存在");
    % 查看目录内容
    dir_contents = dir(ssh_dir);
    for i = 1:length(dir_contents)
        if ~dir_contents(i).isdir && ~startsWith(dir_contents(i).name, '.')
            disp("   " + dir_contents(i).name + " (" + dir_contents(i).bytes + " 字节)");
        end
    end
else
    disp("❌ .ssh目录不存在");
    disp("请确认密钥已生成并保存在正确位置");
end

%第五步 配置MATLAB识别SSH密钥
% 1. 获取Git设置对象
git = settings().matlab.sourcecontrol.git;

% 2. 设置私钥文件路径（将username替换为您的Windows用户名）
% 如果您使用的是 id_ed25519 密钥
git.PrivateKeyFile.PersonalValue = "C:\Users\ZXL\.ssh\id_rsa";

% 3. 设置公钥文件路径
git.PublicKeyFile.PersonalValue = "C:\Users\ZXL\.ssh\id_rsa.pub";

% 4. 如果您生成密钥时设置了密码（passphrase），启用此设置
% 如果生成时直接按了回车（无密码），跳过这一步
% git.KeyHasPassphrase.PersonalValue = true;

disp("✅ MATLAB SSH密钥配置完成");
%第六步 将公钥添加到GitHub
% 读取并显示公钥
pubkey_path = getenv('USERPROFILE') + "\.ssh\id_rsa.pub";
if exist(pubkey_path, 'file')
    fid = fopen(pubkey_path, 'r');
    pubkey_content = fread(fid, '*char')';
    fclose(fid);
    
    disp("您的公钥内容：");
    disp(pubkey_content);
    
    % 尝试复制到剪贴板
    try
        clipboard('copy', strtrim(pubkey_content));
        disp("✅ 公钥已复制到剪贴板");
    catch
        disp("⚠️ 请手动复制上面的公钥内容");
    end
end