%%%%pre_exp.m
%%%%written by YuyangZhang,ZJU,20250418; YuzeSong,ZJU,20250418

%quest法确定阈限
function pre_exp
Screen('Preference', 'SkipSyncTests', 1);

subname=input('name=','s');

%:生成参数矩阵程序

%列1为被试姓名
%列2为条件（时间是否固定），1为双固定，2为前固定后变化，3为前变化后固定
%列3为掩蔽刺激前的时间(ms)
%列4为掩蔽刺激时间（ms)
%列5为掩蔽刺激和目标刺激之间的时间(ms)
%列6为掩蔽光栅方向(-45为0,45为1）
%列7为目标光栅方向（同上）
%列8为被试是否看到掩蔽刺激（1=看到，0=未看到）
%列9为反应时(s)

%参数设置
col=9;%列数
preangle=[45,-45];%掩蔽刺激的角度
postangle=[45,-45];%目标刺激的角度

%生成原始参数矩阵
[x1,x2]=ndgrid(preangle,postangle);
combinedpara=[x1(:),x2(:)];
paramatrix0=zeros(length(combinedpara(:,1)),col);
paramatrix0(:,6)=combinedpara(:,1);
paramatrix0(:,7)=combinedpara(:,2);
paramatrix0=repmat(paramatrix0,30,1);%复制30次

%光栅参数
contrast=0.4;
sizeofgrating=150;
BackGround=128;
[x,y]=meshgrid(-sizeofgrating/2:sizeofgrating/2,-sizeofgrating/2:sizeofgrating/2);
gratingperiod=40;  
sf=1/gratingperiod; 

maskradius=sizeofgrating/2;
Circlemask=(x.^2+y.^2 <= maskradius^2);%生成圆形mask

%按键参数
maxResponseTime = 2; % 最大响应时间2秒
validKeys = [KbName('m') KbName('z')]; % 只检测M和Z键

%设置时间
paramatrix0(:,2)=1;
paramatrix0(:,3)=710;
paramatrix0(:,5)=710;

%顺序随机化
idx = randperm(size(paramatrix0, 1));    % 生成 1 到行数的随机排列  
paramatrix=paramatrix0(idx, :);          % 重新排列行得到打乱后的矩阵 





% 阈值先验估计（单位：ms，假设范围10-100ms）
thresholdGuess = log(30); % 初始猜测阈限取log30≈3.4（对应30ms）
thresholdGuessSD = 3;     % 先验标准差
pThreshold = 0.5;


% 心理测量函数参数（Weibull函数）
beta = 3.5;   % 斜率参数（与任务难度相关）
delta = 0.01; % 猜测概率（适用于二选一任务）
gamma = 0.5;  % 随机正确率（二选一任务为0.5）

% 初始化QUEST结构体
q = QuestCreate(thresholdGuess, thresholdGuessSD, pThreshold, ...
                beta, delta, gamma, 0.1);
q.normalizePdf = 1; % 确保概率密度归一化

%—— 初始化 ——
PsychDefaultSetup(2);
screenID = max(Screen('Screens')); 
white = WhiteIndex(screenID);
black = BlackIndex(screenID);
[window, windowRect] = PsychImaging('OpenWindow', screenID, 128);
frame_rate=Screen('FrameRate',window);%刷新率
framedur=1/frame_rate;%一帧的时间
HideCursor;


%—— 生成 mask ——
[matrixofgrating, GratingRect]=makeMask(windowRect,BackGround);

%注视点和光栅参数
Screen('TextSize', window, 30);          % 设置文字大小
Screen('TextFont', window, 'SimHei');    % 设置中文字体
textColor = [255 255 255];               % 白色文字

% 绘制中央注视点（白色十字）
fixationSize = 20;                        % 注视点大小
[winWidth, winHeight] = RectSize(windowRect);
fixationRect = CenterRect([0 0 fixationSize fixationSize], windowRect);
Screen('DrawLine', window, black, winWidth/2-fixationSize, winHeight/2, winWidth/2+fixationSize, winHeight/2, 3);
Screen('DrawLine', window, black, winWidth/2, winHeight/2-fixationSize, winWidth/2, winHeight/2+fixationSize, 3);

% 绘制提示文字
DrawFormattedText(window, '按空格键开始', 'center', winHeight*0.8, textColor); 
Screen('Flip', window);

% 等待空格键按下
RestrictKeysForKbCheck(KbName('space'));  % 只检测空格键
KbWait(-1);                               % 阻塞等待按键
RestrictKeysForKbCheck([]);   % 恢复所有按键检测


%正式实验
for i=1:60
    tTest = QuestQuantile(q);    % QUEST推荐的下一个刺激强度（log时间）
    tActual = exp(tTest);        % 转换为实际时间（ms）
    paramatrix(i,4) = tActual;

    t1=paramatrix(i,3)/1000;
    t2=paramatrix(i,4)/1000;
    t3=paramatrix(i,5)/1000;
    ang1=paramatrix(i,6);
    ang2=paramatrix(i,7);
    angleofgrating1=ang1;  
    angleofgrating2=ang2; 
    a1=2*pi*sf*cos(angleofgrating1*pi/180);
    b1=2*pi*sf*sin(angleofgrating1*pi/180);
    a2=2*pi*sf*cos(angleofgrating2*pi/180);
    b2=2*pi*sf*sin(angleofgrating2*pi/180);
    grating1=round(BackGround*(1+contrast*sin(a1*x+b1*y).*Circlemask));
    grating2=round(BackGround*(1+contrast*sin(a2*x+b2*y).*Circlemask));
    
    %前掩蔽
    GratingTexture=Screen('MakeTexture',window, matrixofgrating);%把矩阵变为纹理
    Screen('DrawTexture',window,GratingTexture,[],GratingRect);%画纹理
    Screen(window,'Flip');
    WaitSecs(t1);

    
    % 显示掩蔽光栅
    Texture=Screen('MakeTexture',window, grating1);
    
    % 生成居中矩形并绘制纹理
    
    Screen('DrawTexture', window, Texture, [], CenterRect([0 0 sizeofgrating sizeofgrating], windowRect));
    Screen(window,'Flip');
    WaitSecs(t2);

    %后掩蔽
    GratingTexture=Screen('MakeTexture',window, matrixofgrating);%把矩阵变为纹理
    Screen('DrawTexture',window,GratingTexture,[],GratingRect);%画纹理
    Screen(window,'Flip');%呈现光栅
    WaitSecs(t3);

    % 显示目标光栅
    Texture=Screen('MakeTexture',window, grating2);
    
    % 生成居中矩形并绘制纹理

  Screen('DrawTexture', window, Texture, [], CenterRect([0 0 sizeofgrating sizeofgrating], windowRect));
  onset=Screen('Flip',window);
  WaitSecs(0.2);
  Screen(window,'Flip'); 
  
    % 清空键盘缓存
    KbQueueRelease();
    KbQueueCreate();
    KbQueueStart();
    
    % 等待响应
    response = -1;
    rt = NaN;
    while GetSecs() - onset < maxResponseTime
        [pressed, firstPress] = KbQueueCheck();
        
        if pressed
            % 修复部分：正确提取有效按键
            pressedKeys = find(firstPress); % 找到所有被按下的键的索引
            validPress = find(ismember(pressedKeys, validKeys)); % 筛选有效键
            
            if ~isempty(validPress)
                % 取第一个有效按键
                keyCode = pressedKeys(validPress(1));
                rt = firstPress(keyCode) - onset;
                
                % 转换为0/1响应（Z键=0，M键=1）
                response = (keyCode == KbName('m'));
                break;
            end
        end
    end

 % 记录结果
    paramatrix(i,8) = response; 
    paramatrix(i,9) = rt;
    
    q = QuestUpdate(q, tTest, response);
 
    % 试次间空屏
    Screen('FillRect', window, 128);
    Screen('Flip', window);
    WaitSecs(0.5); % 500ms空屏   

%—— 清理 ——
Screen('Close', Texture);  % 释放纹理内存 
end 

threshold = exp(QuestMean(q));
disp(threshold);
sca;

% ========== 保存数据 ==========
dataTable = array2table(paramatrix,...
    'VariableNames',{'Subject','Condition','MaskPreTime','MaskTime',...
    'MaskTargetGap','MaskAngle','TargetAngle','Response','RT'});
dataTable.Subject = repmat({subname}, 120, 1);
filename = sprintf('%s.csv', subname);
writetable(dataTable, filename);
writetable(dataTable, filename);

end 