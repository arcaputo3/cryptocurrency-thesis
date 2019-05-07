function [X] = HMMdp(Y,A,B,p)
%HMMdp solves for the most likely configuration of X given theta parameters
% using dynamic programming

[N,~] = size(B);
T = length(Y);
M = zeros(N,T-1);
R = zeros(N,T-1);
X = zeros(T,1);

for i = 1:N
    [M(i,1),R(i,1)] = max(log(p) + log(A(:,i)) + log(B(:,Y(1))));
end

for t = 2:T-1
    for i = 1:N
        [M(i,t),R(i,t)] = max(log(A(:,i)) + log(B(:,Y(t))) + log(M(:,t-1)));
    end
end

[~,RT] = max(B(:,Y(T))+M(:,T-1));
X(T) = RT;

for t = fliplr(1:(T-1))
    X(t) = R(X(t+1),t);
end