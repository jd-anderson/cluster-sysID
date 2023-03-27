function [A,B,Aj,Bj,S_clusters] = sysgen(A_0,B_0,n_cluster,Nsys_cluster)

Aj={};
Bj={};
for k=1:n_cluster
    Aj{k}=A_0{k};
    Bj{k}=B_0{k};
end 

A={};
B={};
A_cluster={};
B_cluster={};
S_clusters=[];
for k=1:n_cluster
    for j=1:Nsys_cluster(k)
        S_clusters=[S_clusters k];
        A_cluster{j}=Aj{k};
        B_cluster{j}=Bj{k};
    end
    A=[A A_cluster];
    B=[B B_cluster];
end


end