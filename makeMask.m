%%%%makeMask.m
%%%%written by YuyangZhang,ZJU,20250420

function [matrixofgrating,GratingRect] = makeMask(windowRect,BackGround)

contrastofgrating=0.4; %对比度
sizeofgrating=300; %光栅大小
GratingRect=CenterRect([0 0 sizeofgrating sizeofgrating],windowRect);%%光栅呈现于屏幕中央,光栅的位置矩阵
[x,y]=meshgrid(-sizeofgrating/2:sizeofgrating/2,-sizeofgrating/2:sizeofgrating/2);
angleofgrating=45;  %光栅的倾斜角度，单位度
gratingperiod=40; %空间周期
sf=1/gratingperiod;  %转换成空间频率
a1=2*pi*sf*cos(angleofgrating*pi/180);
b1=2*pi*sf*sin(angleofgrating*pi/180);

a2=2*pi*sf*cos((angleofgrating+90)*pi/180);
b2=2*pi*sf*sin((angleofgrating+90)*pi/180);

maskradius=sizeofgrating/2;


%Circlemask=exp(-(x.^2+y.^2)/(2*sd^2));%生成三维高斯mask
Circlemask=(x.^2+y.^2 <= maskradius^2);%生成圆形mask

%matrixofgrating=round(Background*(1+contrastofgrating*(sin(a1*x+b1*y)+sin(a2*x+b2*y)).*Circlemask));   %灰度棋盘格
matrixofgrating=round(BackGround*(1+contrastofgrating*sign(sin(a1*x+b1*y)+sin(a2*x+b2*y)).*Circlemask));   %黑白棋盘格
%surf(x,y,matrixofgrating)
end