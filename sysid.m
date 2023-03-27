function [Error] = sysid(A,B,Aj,Bj,M,R,L,k,X,Z)

nx = size(A{1},1);
nu = size(B{1},2);

%Initialization:

Theta_0={};
for j=1:k
    Theta_0{j}=(2/4)*[Aj{j} Bj{j}] + 0.1*[rand(nx,nx) rand(nx,nu)];
end

alpha=1e-3; %step size

Theta_s=Theta_0;%server
Theta_c={};%client
Error=zeros(k,R-1);
N_sysid_misclass=[]; %number of systems with the cluster id missclassified

for r=1:R-1

    %The server broadcast all the global models to all clients 

    for i=1:M
        Theta_c{i}=Theta_s;
    end

    %Each client estimates their cluster id

    s_i=[];
    for i=1:M
        Error_cluster_id=[];
        for j=1:k
            Error_cluster_id=[Error_cluster_id norm(X{i}-Theta_c{i}{j}*Z{i},"fro")];
        end
        [~,sij]=min(Error_cluster_id);
        s_i{i}=zeros(1,k);
        s_i{i}(sij)=1;
    end
    
  
    %Client side - Local updates

    Theta_i={};
    for i=1:M
        id=find(s_i{i}==1);
        Theta_i{i} = client_update(X{i},Z{i},Theta_s{id},L,alpha);
    end
    
    %Server aggregation

    Theta_avg=[];
    for j=1:k
        Theta_avg{j}=zeros(nx,nx+nu);
    end

    for i=1:M
        id=find(s_i{i}==1);
        Theta_avg{id}=Theta_avg{id} + Theta_i{i};
    end

    %Total number of systems per cluster:

    N_cluster_total=zeros(1,k);
    for i=1:M
        id=find(s_i{i}==1);
        N_cluster_total(id)=N_cluster_total(id)+1;
    end

    for j=1:k
        if N_cluster_total(j) > 0
            Theta_s{j}=Theta_avg{j}/(N_cluster_total(j));
        end  
    end
    

    for j=1:k
        Error(j,r)=norm(Theta_s{j}-[Aj{j} Bj{j}],"fro");
    end
    
 
end
end