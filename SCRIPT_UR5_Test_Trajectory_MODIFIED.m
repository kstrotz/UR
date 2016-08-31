% UR5 Test Trajectory
% SCRIPT_UR5_Test_Trajectory

%%

clear all
clc
drawnow

host = input('Enter server IP address: ','s');
port = int16(input('Enter port number: '));
backlog = int16(input('Enter backlog number: '));

obj = URMatlabClass(host,port,backlog);

%% Define time function
% Define t_init and t_goal
t_init = 0; 
t_goal = 5;

% Fit coefficients
% Function outputs
F = [0,1,0,0];
% Function inputs
t = t_init;
T(:,1) = [t^3; t^2; t; 1];
t = t_goal;
T(:,2) = [t^3; t^2; t; 1];
t = t_init;
T(:,3) = [3*t^2; 2*t; 1; 0];
t = t_goal;
T(:,4) = [3*t^2; 2*t; 1; 0];

C = F*minv(T);

%% Define trajectory 
q_init = [0;-pi/2;-pi/2; pi/2;0;0];
q_goal = [0;-pi/2; pi/2; -3*pi/2;0;0];

% Combine configrations
T = [q_init,q_goal];

% Combine input (s = 0, s = 1)
s = 0.0;
S(:,1) = [s; 1];
s = 1.0;
S(:,2) = [s; 1];

% Calculate coefficients for trajectory
M = T*minv(S);

%% Calculate position
% s = C*[t^3; t^2; t; 1];
% q = M*[s; 1];
%- Calculate velocity
% ds/dt = C*[3*t^2; 2*t; 1; 0];
% dq/ds = M*[1; 0];
dt = 0.10;
for t = t_init:dt:t_goal
    % Calculate position
    s = C*[t^3; t^2; t; 1];
    q = M*[s; 1];
    qRecord(int32(t/dt+1),:) = q';
    % Calculate velocity
    dsdt = C*[3*t^2; 2*t; 1; 0];
    dqds = M*[1; 0];
    dqdt = dqds*dsdt;
    dqdtRecord(int32(t/dt+1),:) = dqdt';
    msg = sprintf('(%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f)',[q',dqdt']);
    obj.msg(msg);
    obj.getjoints();
    j{int32(t/dt+1),:} = obj.JOINTS;
    obj.getvels();
    v{int32(t/dt+1),:} = obj.VELS;
    pause(dt)
    %fprintf('%s\n',msg);
end
for i = t_goal+dt:dt:t_goal+5
    obj.getjoints();
    j{int32(i/dt+1),:} = obj.JOINTS;
    obj.getvels();
    v{int32(i/dt+1),:} = obj.VELS;
    qRecord(int32(i/dt+1),:) = q';
    dqdtRecord(int32(i/dt+1),:) = dqdt';
    pause(dt)
end


for m = 1:numel(j)
    for n = 1:6 
        jointData(m,n) = j{m}{n};
        velData(m,n) = v{m}{n};
        qDes(m,n) = qRecord(m,n);
        dqdtDes(m,n) = dqdtRecord(m,n);
    end
end

obj.clse();
k = 0:dt:t_goal+5;

for l = 1:n
    subplot(1,6,l)
    plot(k,jointData(:,l),'r',k,velData(:,l),'b',k,qDes(:,l),'g',k,dqdtDes(:,l),'m');
    header = 'Joint';
    num = num2str(l);
    head = strcat(header,' ',num);
    title(head);
    xlabel('Time (s)');
    ylabel('Rad or Rad/s');
    %legend('Position','Velocity','Desired Position','Desired Velocity');
end

