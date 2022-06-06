clear all; close all; clc;
%% ������ʼ��
x_I = 1; y_I = 1;           % ���ó�ʼ��
x_G = 750; y_G = 750;       % ����Ŀ���
Thr = 30;                   % ����Ŀ�����ֵ
Delta = 40;                 % ������չ���� 
%% ������ʼ��
T.v(1).x = x_I;           	% T������Ҫ��������v�ǽڵ㣬�����Ȱ���ʼ����뵽T������
T.v(1).y = y_I; 
T.v(1).xPrev = x_I;         % ��ʼ�ڵ�ĸ��ڵ���Ȼ���䱾��
T.v(1).yPrev = y_I;
T.v(1).dist=0;              % �Ӹ��ڵ㵽�ýڵ�ľ��룬�����ȡŷ�Ͼ���
T.v(1).indPrev = 0;         % ���ڵ������
%% ��ʼ������
figure(1);
ImpRgb = imread('map.png');
Imp = rgb2gray(ImpRgb);
imshow(Imp)
xL = size(Imp,1);   % ��ͼx�᳤��
yL = size(Imp,2);   % ��ͼy�᳤��
hold on
plot(x_I, y_I, 'mo', 'MarkerSize',10, 'MarkerFaceColor','m');
plot(x_G, y_G, 'go', 'MarkerSize',10, 'MarkerFaceColor','g');   % ��������Ŀ���
count = 1;
for iter = 1:3000

    %Step 1: �ڵ�ͼ���������һ����x_rand
    x_rand = [unifrnd(0,800),unifrnd(0,800)];	% ���������(x,y)
    
    %Step 2: ���������������ҵ�����ڽ���x_near 
    minDis = sqrt((x_rand(1) - T.v(1).x)^2 + (x_rand(2) - T.v(1).y)^2);
    minIndex = 1;
    for i = 2:size(T.v,2)	% T.v���������洢��size(T.v,2)��ýڵ�����
    	distance = sqrt((x_rand(1) - T.v(i).x)^2 + (x_rand(2) - T.v(i).y)^2);   % ���ڵ�����
        if(distance < minDis)
            minDis = distance;
            minIndex = i;   
        end     
    end
    x_near(1) = T.v(minIndex).x;    % �ҵ���ǰ������x_rand����Ľڵ�
    x_near(2) = T.v(minIndex).y;
    
    %Step 3: ��չ�õ�x_new�ڵ�
    theta = atan2((x_rand(2) - x_near(2)),(x_rand(1) - x_near(1)));
    x_new(1) = x_near(1) + cos(theta) * Delta;
    x_new(2) = x_near(2) + sin(theta) * Delta;  
    
    
    %���ڵ��Ƿ���collision-free
    if ~collisionChecking(x_near,x_new,Imp) 
        continue;   % ���ϰ���
    end
    
    count = count+1;
    
    %Step 4: ��x_new������T 
    T.v(count).x = x_new(1);          
    T.v(count).y = x_new(2); 
    T.v(count).xPrev = x_near(1);     
    T.v(count).yPrev = x_near(2);
    T.v(count).dist = Delta;
    T.v(count).indPrev = minIndex;     % �丸�ڵ�x_near��index
    
    %Step 5:����Ƿ񵽴�Ŀ��㸽�� 
    disToGoal = sqrt((x_new(1) - x_G)^2 + (x_new(2) - y_G)^2);
    if(disToGoal < Thr)
        break
    end
   %Step 6:��x_near��x_new֮���·��������
   plot([x_near(1), x_new(1)], [x_near(2), x_new(2)], 'b', 'Linewidth', 2);
   plot(x_new(1), x_new(2), 'ko', 'MarkerSize', 4, 'MarkerFaceColor','k');
   
   pause(0.02);     % ��ͣ0.02s��ʹ��RRT��չ�������׹۲�
end
%% ·���Ѿ��ҵ��������ѯ
if iter < 2000
    path.pos(1).x = x_G; path.pos(1).y = y_G;
    path.pos(2).x = T.v(end).x; path.pos(2).y = T.v(end).y;
    pathIndex = T.v(end).indPrev; % �յ����·��
    j=0;
    while 1
        path.pos(j+3).x = T.v(pathIndex).x;
        path.pos(j+3).y = T.v(pathIndex).y;
        pathIndex = T.v(pathIndex).indPrev;
        if pathIndex == 1
            break
        end
        j=j+1;
    end  % ���յ���ݵ����
    path.pos(end+1).x = x_I; path.pos(end).y = y_I; % ������·��
    for j = 2:length(path.pos)
        plot([path.pos(j).x; path.pos(j-1).x;], [path.pos(j).y; path.pos(j-1).y], 'g', 'Linewidth', 4);
    end
else
    disp('Error, no path found!');
end
