clear all; close all; clc;
%% ������ʼ��
x_I = 1; y_I = 1;           % ���ó�ʼ��
x_G = 750; y_G = 750;       % ����Ŀ���
GoalThreshold = 30;         % ����Ŀ�����ֵ
Delta = 30;                 % ������չ���� default:30
RadiusForNeib = 80;         % rewire�ķ�Χ,�뾶r
MaxIterations = 2500;       % ����������
UpdateTime = 50;            % ����·����ʱ����
DelayTime = 0.0;            % ��ͼ�ӳ�ʱ��
%% ������ʼ��:T����,v�ǽڵ�
T.v(1).x = x_I;             % ����ʼ�ڵ���뵽T��
T.v(1).y = y_I; 
T.v(1).xPrev = x_I;         % �ڵ�ĸ��ڵ�����:���ĸ��ڵ����䱾��
T.v(1).yPrev = y_I;
T.v(1).totalCost = 0;         % ����ʼ�ڵ㿪ʼ���ۼ�cost������ȡŷ�Ͼ���
T.v(1).indPrev = 0;         % ���ڵ������
%% ��ʼ������
figure(1);
ImpRgb = imread('map.png');
Imp = rgb2gray(ImpRgb);
imshow(Imp)
xL = size(Imp,1);   % ��ͼx�᳤��
yL = size(Imp,2);   % ��ͼy�᳤��
hold on
plot(x_I, y_I, 'mo', 'MarkerSize',10, 'MarkerFaceColor','m');   % ��������Ŀ���
plot(x_G, y_G, 'go', 'MarkerSize',10, 'MarkerFaceColor','g');
count = 1;
pHandleList = [];
lHandleList = [];
resHandleList = [];
findPath = 0;
update_count = 0;
path.pos = [];
for iter = 1:MaxIterations
    
    %Step 1: �ڵ�ͼ���������һ����x_rand (Sample)
    x_rand = [unifrnd(0,xL),unifrnd(0,yL)];	%���������(x,y)
    
    %Step 2: ���������������ҵ�����ڽ���x_near (Near)
    minDis = sqrt((x_rand(1) - T.v(1).x)^2 + (x_rand(2) - T.v(1).y)^2);
    minIndex = 1;
    for i = 2:size(T.v,2)	% T.v���������洢��size(T.v,2)��ýڵ�����
    	distance = sqrt((x_rand(1) - T.v(i).x)^2 + (x_rand(2) - T.v(i).y)^2);   %���ڵ�����
        if(distance < minDis)
            minDis = distance;
            minIndex = i;   
        end     
    end
    
    x_near(1) = T.v(minIndex).x;    % �ҵ���ǰ������x_rand����Ľڵ�
    x_near(2) = T.v(minIndex).y;
    temp_parent = minIndex;         % ��ʱ���ڵ������
    temp_cost = Delta + T.v(minIndex).totalCost;   % ��ʱ�ۼƴ���

    %Step 3: ��չ�õ�x_new�ڵ� (Steer)
    theta = atan2((x_rand(2) - x_near(2)),(x_rand(1) - x_near(1)));
    x_new(1) = x_near(1) + cos(theta) * Delta;
    x_new(2) = x_near(2) + sin(theta) * Delta;  
    %plot(x_rand(1), x_rand(2), 'ro', 'MarkerSize',10, 'MarkerFaceColor','r');
    %plot(x_new(1), x_new(2), 'bo', 'MarkerSize',10, 'MarkerFaceColor','b');
    
    % ���ڵ��Ƿ���collision-free
    if ~collisionChecking(x_near,x_new,Imp) 
        continue;   %���ϰ���
    end

    %Step 4: ����x_newΪԲ��,�뾶ΪR��Բ�������ڵ� (NearC)
    disToNewList = [];    % ÿ��ѭ��Ҫ�Ѷ������
    nearIndexList = [];
    for index_near = 1:count
        disTonew = sqrt((x_new(1) - T.v(index_near).x)^2 + (x_new(2) - T.v(index_near).y)^2);
        if(disTonew < RadiusForNeib)    % ��������:ŷ�Ͼ���С��R
            disToNewList = [disToNewList disTonew];     % �������������нڵ㵽x_new��cost
            nearIndexList = [nearIndexList index_near];     % �������������нڵ������T������
        end
    end
    
    %Step 5: ѡ��x_new�ĸ��ڵ�,ʹx_new���ۼ�cost��С (ChooseParent)
    for cost_index = 1:length(nearIndexList)    % cost_index�ǻ���disToNewList������,����������������
        costToNew = disToNewList(cost_index) + T.v(nearIndexList(cost_index)).totalCost;
        if(costToNew < temp_cost)    % temp_costΪͨ��minDist�ڵ��·����cost
            x_mincost(1) = T.v(nearIndexList(cost_index)).x;     % ���ϼ�֦�����ڵ������
            x_mincost(2) = T.v(nearIndexList(cost_index)).y;
            if ~collisionChecking(x_mincost,x_new,Imp) 
            	continue;   %���ϰ���
            end
        	temp_cost = costToNew;
        	temp_parent = nearIndexList(cost_index);
        end
    end
    
    %Step 6: ��x_new������T (AddNodeEdge)
    count = count+1;    %���½ڵ������
    
    T.v(count).x = x_new(1);          
    T.v(count).y = x_new(2); 
    T.v(count).xPrev = T.v(temp_parent).x;     
    T.v(count).yPrev = T.v(temp_parent).y;
    T.v(count).totalCost = temp_cost; 
    T.v(count).indPrev = temp_parent;     %�丸�ڵ�x_near��index
    
   l_handle = plot([T.v(count).xPrev, x_new(1)], [T.v(count).yPrev, x_new(2)], 'b', 'Linewidth', 2);
   p_handle = plot(x_new(1), x_new(2), 'ko', 'MarkerSize', 4, 'MarkerFaceColor','k');
   
   pHandleList = [pHandleList p_handle];    %��ͼ�ľ��������Ϊcount
   lHandleList = [lHandleList l_handle];
   pause(DelayTime);
    %Step 7: ��֦ (rewire)
    for rewire_index = 1:length(nearIndexList)
        if(nearIndexList(rewire_index) ~= temp_parent)    % ������֮ǰ�������Сcost�Ľڵ�
            newCost = temp_cost + disToNewList(rewire_index);    % ����neib����x_new�ٵ����Ĵ���          
            if(newCost < T.v(nearIndexList(rewire_index)).totalCost)    % ��Ҫ��֦
                x_neib(1) = T.v(nearIndexList(rewire_index)).x;     % ���ϼ�֦�����ڵ������
                x_neib(2) = T.v(nearIndexList(rewire_index)).y;
                if ~collisionChecking(x_neib,x_new,Imp) 
                    continue;   %���ϰ���
                end
                T.v(nearIndexList(rewire_index)).xPrev = x_new(1);      % �Ը�neighbor��Ϣ���и���
                T.v(nearIndexList(rewire_index)).yPrev = x_new(2);
                T.v(nearIndexList(rewire_index)).totalCost = newCost;
                T.v(nearIndexList(rewire_index)).indPrev = count;       % x_new������
                
                %delete(pHandleList());
                %delete(lHandleList(nearIndexList(rewire_index)));
                lHandleList(nearIndexList(rewire_index)) = plot([T.v(nearIndexList(rewire_index)).x, x_new(1)], [T.v(nearIndexList(rewire_index)).y, x_new(2)], 'r', 'Linewidth', 2);

                %pHandleList = [pHandleList p_handle];    %��ͼ�ľ��������Ϊcount
                %lHandleList = [lHandleList l_handle];
            end
        end
    end
    
    %Step 8:����Ƿ񵽴�Ŀ��㸽�� 
    disToGoal = sqrt((x_new(1) - x_G)^2 + (x_new(2) - y_G)^2);
    if(disToGoal < GoalThreshold && ~findPath)    % �ҵ�Ŀ��㣬������ֻ����һ��
        findPath = 1;

        count = count+1;    %�ֶ���Goal���뵽����
        Goal_index = count;
        T.v(count).x = x_G;          
        T.v(count).y = y_G; 
        T.v(count).xPrev = x_new(1);     
        T.v(count).yPrev = x_new(2);
        T.v(count).totalCost = T.v(count - 1).totalCost + disToGoal;
        T.v(count).indPrev = count - 1;     %�丸�ڵ�x_near��index
    end
    
    if(findPath == 1)
        update_count = update_count + 1;
        if(update_count == UpdateTime)
            update_count = 0;
            j = 2;
            path.pos(1).x = x_G; 
            path.pos(1).y = y_G;
            pathIndex = T.v(Goal_index).indPrev;
            while 1     
                path.pos(j).x = T.v(pathIndex).x;
                path.pos(j).y = T.v(pathIndex).y;
                pathIndex = T.v(pathIndex).indPrev;    % ���յ���ݵ����
                if pathIndex == 0
                    break
                end
                j=j+1;
            end  
            
            for delete_index = 1:length(resHandleList)
            	delete(resHandleList(delete_index));
            end
            for j = 2:length(path.pos)
                res_handle = plot([path.pos(j).x; path.pos(j-1).x;], [path.pos(j).y; path.pos(j-1).y], 'g', 'Linewidth', 4);
                resHandleList = [resHandleList res_handle];
            end
        end
    end  
	pause(DelayTime); %��ͣDelayTime s,ʹ��RRT*��չ�������׹۲�
end

for delete_index = 1:length(resHandleList)
	delete(resHandleList(delete_index));
end
for j = 2:length(path.pos)
	res_handle = plot([path.pos(j).x; path.pos(j-1).x;], [path.pos(j).y; path.pos(j-1).y], 'g', 'Linewidth', 4);
	resHandleList = [resHandleList res_handle];
end
            
disp('The path is found!');

