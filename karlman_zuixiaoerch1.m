    
clear all;  % 清除工作区中的所有变量
close all; % 关闭所有已打开的图形窗口
clc;           % 清空命令窗口的内容

% 打印脚本开始的信息（可选）
fprintf('Script started.\n');

% 这里开始编写你的MATLAB脚本内容...

% 步骤1: 运行模型，并提取所需数据用于其他步骤(模型的数据已经通过设置，输入到工作区)
% 具体方法为用Scope记录模型仿真过程数据，然后配置为输出到工作区
modelname = 'Battery.slx';
sim(modelname);

% 步骤2: 根据之前离线辨识的结果，确定参数给定初值，注意：递推用的是c1-c3
% 获取模型的运行步长，用于递推的输入，因为我们的模型是定步长.，所以可以用如下接口获取


lambda = 0.99;

U_L   = ScopeData4.signals(2).values; % Scope中的数据索引似乎从1开始
I = ScopeData4.signals(3).values; 
SOC = ScopeData4.signals(1).values;
time_val = ScopeData4.time;
% 输入:
%   U_L: 端电压向量(V), I: 电流向量(A), time: 时间(s), SOC: 电量状态(0~1)
%   lambda: 遗忘因子(0.95~0.99), Cn: 电池额定容量(Ah)
% 输出:
%   R0, R1, C1: 估计参数, theta_history: 参数向量历史记录

% 初始化
n = length(U_L);
Delta_t = 0.1;              % 采样间隔0.1s
theta = [0.5; 0.01; -0.005]; % 初始参数向量[α; θ2; θ3]
P = 1e6 * eye(3);           % 协方差矩阵
OCV = zeros(n,1);           % 存储OCV
R0 = zeros(1, size(U_L, 1) - 1);
R1 = zeros(1, size(U_L, 1) - 1);
C1 = zeros(1, size(U_L, 1) - 1);


% 定义OCV-SOC函数（用户提供）
OCV_fun = @(soc) -95.82*soc^8 + 549.26*soc^7 - 1219.4*soc^6 + ...
    1387.01*soc^5 - 883.38*soc^4 + 320.4*soc^3 - ...
    64.45*soc^2 + 6.89*soc + 2.91;

% 历史变量初始化
y_prev = 0;                 % y(k-1)
I_prev = 0;                 % I(k-1)
theta_history = zeros(3, n); % 记录参数变化

for k = 2:n
    % Step 1: 计算当前OCV（通过SOC）
    OCV(k) = OCV_fun(SOC(k));
    y_k = OCV(k) - U_L(k);   % 当前输出 y(k)

    % Step 2: 构建数据向量φ（新顺序: [y_prev; I(k); I_prev]）
    phi = [y_prev; I(k); I_prev];

    % Step 3: 计算先验误差
    e = y_k - phi' * theta;

    % Step 4: 计算增益矩阵
    K = P * phi / (lambda + phi' * P * phi);

    % Step 5: 更新参数向量
    theta = theta + K * e;
    theta_history(:, k) = theta;

    % Step 6: 更新协方差矩阵
    P = (eye(3) - K * phi') * P / lambda;

    % Step 7: 保存历史数据
    y_prev = y_k;
    I_prev = I(k);

   alpha = theta(1);
   R0(k) = -theta(3) / alpha;
   R1(k) = R0(k) * alpha / (1 - alpha);
   C1(k) = (Delta_t * alpha) / (R1(k) * (1 - alpha));
end

% Step 8: 解析物理参数（使用最终theta值）

