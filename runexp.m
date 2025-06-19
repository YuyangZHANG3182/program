%%%%runexp.m
%%%%written by YuyangZhang,ZJU,20250418
function runexp
    Screen('Preference', 'SkipSyncTests', 1);

    
    % 获取屏幕尺寸，计算让窗口居中的位置
    screenSize = get(0, 'ScreenSize');  % [left bottom width height]
    figWidth  = 400;
    figHeight = 280;
    figLeft   = screenSize(3)/2 - figWidth/2;
    figBottom = screenSize(4)/2 - figHeight/2;
    hFig = figure( ...
        'Name', '被试信息输入', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Position', [figLeft, figBottom, figWidth, figHeight], ...
        'Resize', 'off', ...
        'Color', [0.94 0.94 0.94] ...
    );

    % 标签和控件 
    % 1. 姓名标签 + 编辑框
    uicontrol('Parent', hFig, ...
              'Style', 'text', ...
              'Position', [50, 220, 80, 25], ...
              'String', '姓名：', ...
              'FontSize', 11, ...
              'HorizontalAlignment', 'right');
    hNameEdit = uicontrol('Parent', hFig, ...
                          'Style', 'edit', ...
                          'Position', [140, 220, 200, 28], ...
                          'FontSize', 11, ...
                          'BackgroundColor', 'white');

    % 2. 性别标签 + 下拉菜单
    uicontrol('Parent', hFig, ...
              'Style', 'text', ...
              'Position', [50, 170, 80, 25], ...
              'String', '性别：', ...
              'FontSize', 11, ...
              'HorizontalAlignment', 'right');
    hGenderMenu = uicontrol('Parent', hFig, ...
                            'Style', 'popupmenu', ...
                            'Position', [140, 170, 200, 28], ...
                            'String', {'男', '女'}, ...
                            'FontSize', 11, ...
                            'BackgroundColor', 'white');

    % 3. 年龄标签 + 编辑框
    uicontrol('Parent', hFig, ...
              'Style', 'text', ...
              'Position', [50, 120, 80, 25], ...
              'String', '年龄：', ...
              'FontSize', 11, ...
              'HorizontalAlignment', 'right');
    hAgeEdit = uicontrol('Parent', hFig, ...
                         'Style', 'edit', ...
                         'Position', [140, 120, 200, 28], ...
                         'FontSize', 11, ...
                         'BackgroundColor', 'white');

    % 4. 条件标签 + 下拉菜单
    uicontrol('Parent', hFig, ...
              'Style', 'text', ...
              'Position', [50, 70, 80, 25], ...
              'String', '条件：', ...
              'FontSize', 11, ...
              'HorizontalAlignment', 'right');
    hCondMenu = uicontrol('Parent', hFig, ...
                          'Style', 'popupmenu', ...
                          'Position', [140, 70, 200, 28], ...
                          'String', {'1', '2', '3'}, ...
                          'FontSize', 11, ...
                          'BackgroundColor', 'white');

    % 5. “确定”按钮
    uicontrol('Parent', hFig, ...
              'Style', 'pushbutton', ...
              'Position', [figWidth/2 - 50, 20, 100, 30], ...
              'String', '确  定', ...
              'FontSize', 12, ...
              'Callback', @(src,evt) uiresume(hFig));  % 点击后恢复执行

    % 阻塞，直到用户点击“确定”
    uiwait(hFig);

    % 读取并处理用户输入
    subname = strtrim(get(hNameEdit, 'String'));       % 姓名
    genderIndex = get(hGenderMenu, 'Value');           % 性别下标（1=男,2=女）
    genderOptions = get(hGenderMenu, 'String');        % {'男','女'}
    gender = genderOptions{genderIndex};                % 取出性别字符串
    ageStr = strtrim(get(hAgeEdit, 'String'));          % 年龄字符串
    age = str2double(ageStr);                           % 转为数值
    condIndex = get(hCondMenu, 'Value');                % 条件下标（1->'1',2->'2',3->'3'）
    condOptions = get(hCondMenu, 'String');             % {'1','2','3'}
    cond = str2double(condOptions{condIndex});          % 转为数值 1/2/3

    % 关闭 GUI 窗口
    close(hFig);

    % 检查用户输入的有效性（可选）
    if isempty(subname)
        error('必须输入被试姓名！');
    end
    if isnan(age) || age <= 0
        error('请输入合法的年龄（数字）！');
    end
    if ~ismember(cond, [1,2,3])
        error('条件必须是 1、2 或 3！');
    end

    %生成参数矩阵
    
    % 列1为被试姓名
    % 列2为条件（时间是否固定），1为双固定，2为前固定后变化，3为前变化后固定
    % 列3为掩蔽刺激前的时间(ms)
    % 列4为掩蔽刺激时间（ms)
    % 列5为掩蔽刺激和目标刺激之间的时间(ms)
    % 列6为掩蔽光栅方向(-45为0,45为1）
    % 列7为目标光栅方向（同上）
    % 列8为被试反应方向（1=右箭头，0=Z键，-1=无响应）
    % 列9为反应时(s)
    % 列10为是否正确（1正确，0错误）

    % 参数设置
    col = 10;                                    % 列数
    preangle = [45, -45];                        % 掩蔽刺激的角度
    postangle = [45, -45];                       % 目标刺激的角度

    % 生成原始参数矩阵
    [x1, x2] = ndgrid(preangle, postangle);
    combinedpara = [x1(:), x2(:)];
    paramatrix0 = zeros(length(combinedpara(:,1)), col);
    paramatrix0(:,6) = combinedpara(:,1);
    paramatrix0(:,7) = combinedpara(:,2);
    paramatrix0 = repmat(paramatrix0, 90, 1);     % 复制90次

    % 光栅参数
    contrast = 0.4;
    sizeofgrating = 150;
    BackGround = 128;
    [x, y] = meshgrid(-sizeofgrating/2:sizeofgrating/2, -sizeofgrating/2:sizeofgrating/2);
    gratingperiod = 40;
    sf = 1 / gratingperiod;

    maskradius = sizeofgrating/2;
    Circlemask = (x.^2 + y.^2 <= maskradius^2);   % 生成圆形mask

    % 按键参数
    maxResponseTime = 2;                          % 最大响应时间2秒
    validKeys = [KbName('m'), KbName('z')];       % 只检测右箭头和Z键

    % 不同条件设置时间
    if cond == 1
        paramatrix0(:,2) = 1;
        paramatrix0(:,3) = 710;
        paramatrix0(:,4) = 35;
        paramatrix0(:,5) = 71;
    elseif cond == 2
        paramatrix0(:,2) = 2;
        paramatrix0(:,3) = 710;
        paramatrix0(:,4) = 35;
        paramatrix0(:,5) = repmat([71*5, 71*10, 71]', 120, 1);
    elseif cond == 3
        paramatrix0(:,2) = 3;
        paramatrix0(:,3) = repmat([71*6, 71*10, 71]', 120, 1);
        paramatrix0(:,4) = 35;
        paramatrix0(:,5) = 71*11 - paramatrix0(:,3);
    end

    % 顺序随机化
    idx = randperm(size(paramatrix0, 1));         % 生成 1 到行数的随机排列  
    paramatrix = paramatrix0(idx, :);             % 重新排列行得到打乱后的矩阵 

    % 初始化 Psychtoolbox
    PsychDefaultSetup(2);
    screenID = max(Screen('Screens'));
    white = WhiteIndex(screenID);
    black = BlackIndex(screenID);
    [window, windowRect] = PsychImaging('OpenWindow', screenID, 128);
    frame_rate = Screen('FrameRate', window);      % 刷新率
    framedur = 1 / frame_rate;                     % 一帧的时间
    HideCursor;

    % 生成 mask
    [matrixofgrating, GratingRect] = makeMask(windowRect, BackGround);

    % 注视点和光栅参数
    Screen('TextSize', window, 30);                 % 设置文字大小
    Screen('TextFont', window, 'SimHei');           % 设置中文字体
    textColor = [255 255 255];                      % 白色文字
    
    % 在正式实验前显示一张指导语图片 
    % 读取图片文件
    instrImage = imread('guidance.png');
    InstrTex = Screen('MakeTexture', window, instrImage);

    % 将图片居中绘制
    [imgH, imgW, ~] = size(instrImage);
    % 计算居中矩形：以窗口中心为基准，图片大小为 imgW × imgH
    dstRect = CenterRectOnPoint([0 0 imgW imgH], windowRect(3)/2, windowRect(4)/2);

    % 绘制并呈现
    Screen('DrawTexture', window, InstrTex, [], dstRect);
    Screen('Flip', window);

    % 在这里等待被试按下空格键继续
    RestrictKeysForKbCheck(KbName('space'));  % 只检测空格
    KbWait(-1);
    RestrictKeysForKbCheck([]);  % 恢复所有按键检测

    % 显示完后清空并关闭纹理
    Screen('Close', InstrTex);

    % 绘制中央注视点（白色十字）
    fixationSize = 20;                              % 注视点大小
    [winWidth, winHeight] = RectSize(windowRect);
    fixationRect = CenterRect([0 0 fixationSize fixationSize], windowRect);
    Screen('DrawLine', window, black, winWidth/2 - fixationSize, winHeight/2, winWidth/2 + fixationSize, winHeight/2, 3);
    Screen('DrawLine', window, black, winWidth/2, winHeight/2 - fixationSize, winWidth/2, winHeight/2 + fixationSize, 3);

    % 绘制提示文字
    DrawFormattedText(window, '按空格键开始', 'center', winHeight*0.8, textColor);
    Screen('Flip', window);

    % 等待空格键按下
    RestrictKeysForKbCheck(KbName('space'));        % 只检测空格键
    KbWait(-1);                                     % 阻塞等待按键
    RestrictKeysForKbCheck([]);                     % 恢复所有按键检测

    % 正式实验循环（360 次）
    for i = 1:360    
        t1 = paramatrix(i,3) / 1000;
        t2 = paramatrix(i,4) / 1000;
        t3 = paramatrix(i,5) / 1000;
        ang1 = paramatrix(i,6);
        ang2 = paramatrix(i,7);

        angleofgrating1 = ang1;
        angleofgrating2 = ang2;
        a1 = 2 * pi * sf * cos(angleofgrating1 * pi/180);
        b1 = 2 * pi * sf * sin(angleofgrating1 * pi/180);
        a2 = 2 * pi * sf * cos(angleofgrating2 * pi/180);
        b2 = 2 * pi * sf * sin(angleofgrating2 * pi/180);
        grating1 = round(BackGround * (1 + contrast * sin(a1 * x + b1 * y) .* Circlemask));
        grating2 = round(BackGround * (1 + contrast * sin(a2 * x + b2 * y) .* Circlemask));

        % 前掩蔽
        GratingTexture = Screen('MakeTexture', window, matrixofgrating);  % 把矩阵变为纹理
        Screen('DrawTexture', window, GratingTexture, [], GratingRect);   % 画纹理
        Screen('Flip', window);
        WaitSecs(t1);

        % 显示掩蔽光栅
        Texture = Screen('MakeTexture', window, grating1);
        Screen('DrawTexture', window, Texture, [], CenterRect([0 0 sizeofgrating sizeofgrating], windowRect));
        Screen('Flip', window);
        WaitSecs(t2);

        % 后掩蔽
        GratingTexture = Screen('MakeTexture', window, matrixofgrating);
        Screen('DrawTexture', window, GratingTexture, [], GratingRect);
        Screen('Flip', window);
        WaitSecs(t3);

        % 显示目标光栅
        Texture = Screen('MakeTexture', window, grating2);
        Screen('DrawTexture', window, Texture, [], CenterRect([0 0 sizeofgrating sizeofgrating], windowRect));
        onset = Screen('Flip', window);
        WaitSecs(0.2);
        Screen('Flip', window);

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
                pressedKeys = find(firstPress);                   % 找到所有被按下的键
                validPress = find(ismember(pressedKeys, validKeys));  % 筛选有效键
                if ~isempty(validPress)
                    keyCode = pressedKeys(validPress(1));
                    rt = firstPress(keyCode) - onset;
                    response = (keyCode == KbName('m'));  % Z键=0，右箭头=1
                    break;
                end
            end
        end

        % 记录结果
        paramatrix(i,8) = response;
        paramatrix(i,9) = rt;

        % 判断正确性 (目标方向: 45对应右箭头(1), -45对应Z键(0))
        correctResponse = (ang2 == 45);  % 45度应右箭头(1), -45应Z键(0)
        paramatrix(i,10) = (response == correctResponse);

        % 试次间空屏
        Screen('FillRect', window, 128);
        Screen('Flip', window);
        WaitSecs(0.5);  % 500ms空屏

        % —— 清理 —— 
        Screen('Close', Texture);  % 释放纹理内存 
    end
    sca;

    % 保存数据 
    % 先把 paramatrix 转为表格
    dataTable = array2table(paramatrix, ...
        'VariableNames', {'Subject','Condition','MaskPreTime','MaskTime', ...
                          'MaskTargetGap','MaskAngle','TargetAngle','Response','RT','Correct'});
    % 添加 Subject 列（全为 subname）
    dataTable.Subject = repmat({subname}, size(paramatrix,1), 1);
    % 添加性别列
    dataTable.Gender = repmat({gender}, size(paramatrix,1), 1);
    % 添加年龄列
    dataTable.Age = repmat(age, size(paramatrix,1), 1);

    %s数据分析
    data = dataTable

    % 筛选正确试次
    filteredData = data(data.Correct == 1, :);

    % 根据光栅方向一致性分组
    isEqual = filteredData.MaskAngle == filteredData.TargetAngle;
    group1 = filteredData(isEqual, :);    % 一致
    group2 = filteredData(~isEqual, :);   % 不一致

    % 计算反应时的平均值，忽略NaN值
    meanGroup1 = mean(group1.RT, 'omitnan');
    meanGroup2 = mean(group2.RT, 'omitnan');
    dat(i,1)=meanGroup1;
    dat(i,2)=meanGroup2;
    % 显示结果
    disp(['光栅方向一致时反应时平均值: ', num2str(meanGroup1)]);
    disp(['光栅方向不一致时反应时平均值: ', num2str(meanGroup2)]);
    
    % 指定 summary 文件名
    summaryFile = 'summary.csv';

    % 如果文件不存在，先用空表格初始化
    if ~exist(summaryFile, 'file')
        Subject         = string.empty(0,1);
        Gender          = string.empty(0,1);
        Age             = double.empty(0,1);
        C1_congruent    = double.empty(0,1);
        C1_incongruent  = double.empty(0,1);
        C2_congruent    = double.empty(0,1);
        C2_incongruent  = double.empty(0,1);
        C3_congruent    = double.empty(0,1);
        C3_incongruent  = double.empty(0,1);
        T0 = table(Subject, Gender, Age, ...
                   C1_congruent, C1_incongruent, ...
                   C2_congruent, C2_incongruent, ...
                   C3_congruent, C3_incongruent);
        writetable(T0, summaryFile);
    end
    
    % 1. 读出汇总表
     S = readtable(summaryFile, 'TextType', 'string');

    % 2. 把“条件一致/不一致”这6列都转成 double
    numVars = {'C1_congruent', 'C1_incongruent', ...
           'C2_congruent', 'C2_incongruent', ...
           'C3_congruent', 'C3_incongruent'};

    for k = 1:numel(numVars)
      varName = numVars{k};
      colData = S.(varName);

      if iscell(colData)
        % 如果读出来的的确是 cell array，逐个把字符串转成数字
        % 空单元格会被 str2double 变成 NaN
        S.(varName) = cellfun(@(x) str2double(x), colData);
      elseif isstring(colData)
        % 如果是 string 类型，也直接用 str2double 转
        S.(varName) = str2double(colData);
      elseif isa(colData, 'double')
        % 已经是 double，就不动
      else
        error('第 %d 列“%s”的数据类型不支持转换，请检查。', k, varName);
      end
    end

    % 3. 查找行、更新数值
    rowIdx = find(S.Subject == subname);
    if isempty(rowIdx)
    % 直接用 table(...) 构造新行，盘点所有列名不用 cell2table
      Tnew = table(string(subname), string(gender), age, ...
                 NaN, NaN, ...   % C1_congruent, C1_incongruent
                 NaN, NaN, ...   % C2_congruent, C2_incongruent
                 NaN, NaN, ...   % C3_congruent, C3_incongruent
                 'VariableNames', S.Properties.VariableNames);
      S = [S; Tnew];
      rowIdx = height(S);
    end

    % 4. 根据 cond 更新对应列
    switch cond
      case 1
        S.C1_congruent(rowIdx)   = meanGroup1;
        S.C1_incongruent(rowIdx) = meanGroup2;
      case 2
        S.C2_congruent(rowIdx)   = meanGroup1;
        S.C2_incongruent(rowIdx) = meanGroup2;
      case 3
        S.C3_congruent(rowIdx)   = meanGroup1;
        S.C3_incongruent(rowIdx) = meanGroup2;
      otherwise
        error('cond 必须为 1、2 或 3');
    end

     % 5. 写回 CSV
     writetable(S, summaryFile);
     

    % 构造文件名并保存
    filename = sprintf('%s_cond%d.csv', subname, cond);
    writetable(dataTable, filename);

end
