% ==========================================================================
% Clustered System Identification: A Sample-Efficient Approach for 
% Personalized Linear Model Estimations
% Leonardo F. Toso, Han Wang,  James Anderson
% ==========================================================================

clc;clear all; close all


%% System Data:

% System dimensions

nx=3;
nu=2;

% Nominal systems: 
A_0={};
A_0{1}=[0.5  0.3   0.1;
        0    0.2   0;
        0.1    0  0.3];

A_0{2}=[-0.3   0    0;
        0.1  0.4   0;
        0.2  0.3  0.5];

A_0{3}=[-0.1  0.1     0.1;
        0.1   0.15   0.1;
        0.1    0     0.2];


B_0={};
B_0{1}=[1     0.5;
        0.1     1;
        0.75  1.5];

B_0{2}=[1.5   0.1;
        0.5   2.5;
        0.1  1.5];

B_0{3}=[0.8   0.1;
        0.1   1.5;
        0.4  0.8];



% noise level, input signal and initial state

sigu = [0.11 0.12 0.05];
sigw = [0.11 0.12 0.05];
sigx = [0.11 0.12 0.05];
mu=[0 0 0];

%Rollout length

T=50;

%Number of experiments

N=100;

%Number of clients

M=50;


%Number of clusters
k=3;


%Number of systems per cluster 

Nsys_cluster=[10 24 16];


% Generating the system matrices for each cluster according to
% inter-cluster bounded heterogeneity

[A,B,Aj,Bj,S_clusters] = sysgen(A_0,B_0,k,Nsys_cluster); % This function generates similar systems

%Number of global iterations

R=700; 

%Number of local iterations

L=1;

%Generating the offline data
% Simulate the dynamical system 
% x_{t+1} = Ax_t + Bu_t + w_t

X={};
Z={};
W={};
for i=1:M
    id=S_clusters(i);
    [X{i},Z{i},W{i}] = syssim(A,B,T,N,i,sigu(id),sigw(id),sigx(id),mu(id));
end

%% Clustered FedSysID

[Error] = sysid(A,B,Aj,Bj,M,R,L,k,X,Z);

%% Plotting the numerical results:

%Convergence
cluster_id=1:1:k;
colors= [0 0.4470 0.7410;0.4940 0.1840 0.5560;0.8500 0.3250 0.0980];
for i=1:k
    figure(i);
    fig=plot(1:1:R-1,Error(i,:),'LineWidth',1.2,'Color',colors(i,:));
    legend(strcat('$ID = $',num2str(i)),'Interpreter','latex');
    xlab=xlabel('r','Interpreter','latex');
    ylab=ylabel('$e_r$','Interpreter','latex');
    set(xlab,'FontSize',20);
    set(ylab,'FontSize',20);
    set(gca,'FontSize',20)
    xlim([1 R-1]) 
    grid on; box
end
