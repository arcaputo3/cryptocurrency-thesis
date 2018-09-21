% The following script utilizes max entropy of market entiment parameter e
% to create HMMs representing the hidden market sentiment of BTC prices

% Import BTC Daily Price Data
btcAll = xlsread('BTC.xlsx');
btcAll = btcAll(:,5);
totalT = 400;
btc = btcAll((end-totalT):end);
% Convert to time frame t
t = 1;

% Init Parameters
R = zeros(length(btc)-t,1);
Y = R;
e = 0.001*(5:50);
entropy = zeros(length(e),1);

% Iterate over all e
for j = 1:length(e)
    for i = (t+1):t:length(btc)
        R(i) = (btc(i) - btc(i-t))/btc(i-t);
        if R(i) >= e(j)
            Y(i) = 1;
        elseif R(i) < -e(j)
            Y(i) = 3;
        else
            Y(i) = 2;
        end
    end
    
    % Create Y and Q
    Y = Y((1+t):t:end); 
    Q = createQ(Y);
    
    % Calc entropy
    mu = tabulate(Y);
    mu = mu(:,3)/100;
    entropy(j) = -sum(mu'*(Q.*log2(Q)));
end
[M,I] = max(entropy);
eStar = e(I)
%{
% Plotting
plot(e,entropy)
title('Epsilon vs. Entropy')
ylabel('Entropy')
xlabel('Epsilon')

%}
%{
mc = dtmc(Q,'StateNames',["Bearish","Stagnant","Bullish"]);
figure;
graphplot(mc,'ColorNodes',true,'ColorEdges',true);
%}
%{

yyaxis right
plot(R)
yyaxis left
plot(btc)
title('BTC Price vs. Weekly Returns')
%}

Y = zeros(length(btc)-1,1);
R = Y;
c = 1.2;
for i = 2:length(btc)
    R(i) = (btc(i) - btc(i-t))/btc(i-t);
    if R(i) > c*eStar
        Y(i) = 1;
    elseif R(i) < -c*eStar
        Y(i) = 3;
    else
        Y(i) = 2;
    end
end
Y = Y(2:end);

% Init HMM

A = 0.25*(ones(3)+eye(3));
B = A;
p = (1/3)*ones(3,1);


% Solve for optimal hidden variable prob
iter = 200;
for i = 1:iter
    [A,B,p] = BWalgo(Y,A,B,p);
end

X = HMMdp(Y,A,B,p);

x = 1:length(X) ; %// extract "X" column
y = btc(2:end);
z= X; %// everything in the Z=0 plane

%// draw the surface (actually a line)
hs=surf([x(:) x(:)],[y(:) y(:)],[z(:) z(:)], ...  % Reshape and replicate data
     'FaceColor', 'none', ...    % Don't bother filling faces with color
     'EdgeColor', 'interp', ...  % Use interpolated color for edges
     'LineWidth', 2);

view(2);
colorbar
title('BTC Price vs. Hidden Variable')
%{
yyaxis right
plot(btc)
yyaxis left
p1 = plot(X,'LineWidth',1);
title('BTC Price vs. Hidden Variable')
%}