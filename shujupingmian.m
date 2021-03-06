% ==================
clear all;
close all;
clc;
format long; 

%% ======The initialization of the basic parameters=====
Num_Cell_x=50;
Num_Cell_y=50;

Total_time=30;     % the number of total integrated frames
Total_time_data=30;
Time_point=30;
T_step=1;          % The size of the time cell:Time_step

q1=0.001;          % q1,q2 the level of process noise in target motion
q1_1=0.01;

Re_x = 1; %Resolution of x-axis
Re_y = 1;
axisX = 0:Re_x:Num_Cell_x;
axisY = 0:Re_y:Num_Cell_y; %步长为分辨率
numX = length(axisX); %取长度
numY = length(axisY);


%% ---------- initial distribution of target state 
delta_p=0.05;  % the stardard deviation of the inital distribution of position
delta_v=0.01;   % the stardard deviation of the inital distribution of velocity
new_velocity_Variance=delta_v^2;             % standard deviation 0.1;
% q2=2;                  % q2 the measurement noise
          
%% ---------- transition matrix          
F = [1 T_step 0   0; 
    0    1    0   0; 
    0    0    1   T_step; 
    0    0    0   1];            
           
Q=q1*[T_step^3/3  T_step^2/2  0           0 ;
        T_step^2/2  T_step      0           0 ;
        0             0         T_step^3/3  T_step^2/2;
        0             0         T_step^2/2  T_step];                         % ProcessNoise covariance matrix          
%Q = diag(20, 0.2, 20, 0.2);                      % JMPD文中所用ProcessNoise covariance matrix     
%% ---------- Rao-balckwellision parameters
Q_l=q1*[T_step,0;0,T_step];
Q_n=q1*[T_step^3/3,0;0,T_step^3/3];
Q_ln=q1*[T_step^2/2,0;0,T_step^2/2];
A_1_t=eye(2)-Q_ln/(Q_n)*T_step;
Q_1_l=Q_l-(Q_ln.')*(inv(Q_n))*Q_ln;

%% ------ load the continuious target trajectory 

Target_number=3;                        

velocity_init = 1; %
[initx,x] = GenerateTarget(Target_number,velocity_init,axisX,axisY,Total_time,F,Q);

x_dis = ceil(x(1,:,:)/Re_x)*Re_x; %能分辨的目标位置， ceil朝正无穷方向取整
y_dis = ceil(x(3,:,:)/Re_y)*Re_y;

%% ---------- MC parameters            
repeati = 50;
SNR_T = [6];
SNR_num = length(SNR_T);  %length()函数，求数组的长度

% NpT = 2.^[6,8,9,10];
Np_T = 512;
Np_num = length(Np_T);
    
E_target_state_MC=zeros(7,Total_time,Target_number,repeati,SNR_num,Np_num); %（7，时间，MC次数变化，SNR变化，粒子数变化）
single_run_time=zeros(Total_time,repeati,SNR_num,Np_num);
% figure(12);hold on;plot(squeeze(Pre_T_particle(1,t,:,:)),squeeze(Pre_T_particle(4,t,:,:)),'c.',x_c(1:3:13,t),x_c(2:3:14,t),'rx','LineWidth',2,'MarkerSize',8);

%% ===================== Particle filtering =========================
for Np_i=1:Np_num%Np_num%3%  %表示进行Np_num次不同粒子数的粒子滤波
    Np = Np_T(Np_i);   %每次的粒子数       
    for SNR_i=1:SNR_num  %进行SNR_num次不同信噪比的粒子滤波
        %根据SNR加上目标幅度，得到每一帧观测值
        SNR_dB=SNR_T(SNR_i);  %每次的信噪比
        Frame_data = zeros(Num_Cell_y,Num_Cell_x,Total_time);
        Sigma_noise = 1;
        Frame_data = GenerateFrame(Num_Cell_y,Num_Cell_x,Total_time,SNR_dB,Sigma_noise,x,x_dis,y_dis,Target_number);
    end    
end

figure(2)
px=1:50;
py=1:50;
[X,Y]=meshgrid(px,py);
surf(X,Y,Frame_data(px,py,15));%第15帧平面
