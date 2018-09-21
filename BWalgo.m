function [A,B,p] = BWalgo(Y,A,B,p)
%BWalgo uses the Baum Welch Algorithm. It takes as input observables Y, 
% matrices A,B and p and outputs optimal values for each.

T = length(Y);
[N,K] = size(B);

alpha   = zeros(N,T);
beta    = zeros(N,T);
gamma   = zeros(N,T);
eta     = zeros(N,N,T-1);

% Forward prop
alpha(:,1)  = p.*B(:,Y(1));
for t = 2:T
    alpha(:,t)  = B(:,Y(t)).*(A*alpha(:,t-1));
end

% Backward prop
beta(:,T) = 1;
for t = fliplr(1:(T-1))
    beta(:,t) = A*(beta(:,t+1).*B(:,Y(t))); 
end

% Update
for t = 1:T-1
    gamma(:,t) = alpha(:,t).*beta(:,t)/sum(alpha(:,t).*beta(:,t));
    eta(:,:,t) = alpha(:,t).*A.*(beta(:,t+1).*B(:,Y(t+1)))'; %/sum(sum( alpha(:,t).*A.*(beta(:,t+1).*B(:,Y(t+1)))'));
    eta(:,:,t) = eta(:,:,t)/sum(sum(eta(:,:,t)));
end
gamma(:,T) = alpha(:,T).*beta(:,T)/sum(alpha(:,T).*beta(:,T));

p = gamma(:,1);
A = sum(eta,3);
A = A./sum(A,2);

for k = 1:K
    B(:,k) = sum(((Y==k).*ones(N,1)')'.*gamma,2)./sum(gamma,2);
end

