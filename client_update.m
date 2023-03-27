function [Theta] = client_update(X,Z,Theta,L,alpha)

    for l=1:L
        Theta=Theta + (alpha/l)*((X-Theta*Z)*Z');
    end

end