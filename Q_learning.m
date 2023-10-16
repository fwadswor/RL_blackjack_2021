%Q-learning script
clear all
%Load data
import = load('SARS_data.mat');
SARS = import.SARS_total;
SARS = single(SARS);
%State feature vectors
sums = 4:21;
shownCards = 2:11;
aces = 1:2;
actions = 1:2;
%Hyperparameters
alpha = 0.01;
gamma = 0.95;
%Check imported data array
[data_samples,sample_size] = size(SARS)
if sample_size ~= 4
    error("Data points in SARS not correct dimensions")
end

%-----Parse Data into state, action, reward, and next state vectors------
%Decode states from integer encoding to state indices for Q table
s = zeros(data_samples,3);
sp = zeros(data_samples,3);
for n = 1:data_samples
    s(n,:) = StateFunction2Table(SARS(n,1));
    sp(n,:) = StateFunction2Table(SARS(n,4));    
end
%Slice action and reward vectors
a = SARS(:,2); r = SARS(:,3);
%Change encoding of useable ace state component for
%use as index
s(:,3) = s(:,3)+1;
sp(:,3) = sp(:,3)+1;
%Initialize Q-table and state visit counter
Q_table = zeros(sums(end),shownCards(end),aces(end),actions(end));
state_visit = zeros(sums(end),shownCards(end),aces(end));
%Update Q-table
for k = 1:data_samples
    maxQ = max(Q_table(sp(k,1),sp(k,2),sp(k,3),:));
    Q_table(s(k,1),s(k,2),s(k,3),a(k)) = Q_table(s(k,1),s(k,2),s(k,3),a(k)) ...
        + alpha*(r(k) + gamma*maxQ - Q_table(s(k,1),s(k,2),s(k,3),a(k)));
    state_visit(s(k,1),s(k,2),s(k,3)) = state_visit(s(k,1),s(k,2),s(k,3))+1;
end

%Save trained Q-table
save('TrainedQTable.mat','Q_table','-mat')

%----------------------Plotting------------------------------
Q_plot = zeros(sums(end),shownCards(end),aces(end));

for ii = 4:sums(end)
    for jj = 2:shownCards(end)
        for kk = aces
            if Q_table(ii,jj,kk,2) > Q_table(ii,jj,kk,1)
                Q_plot(ii,jj,kk) = 2;
            else
                Q_plot(ii,jj,kk) = -2;
            end
        end
    end
end

figure(1)
subplot(1,2,1)
surf(Q_plot(:,:,1))
axis([2 11 4 21])
xticks(2:11)
yticks(4:21)
colormap('jet')
title('No useable Ace')
view(0,90)
ylabel('Player Hand Sum')
xlabel('Dealer Shown Card')


subplot(1,2,2)
surf(Q_plot(:,:,2))
axis([2 11 4 21])
xticks(2:11)
yticks(4:21)
colormap('jet')
title('Useable Ace')
view(0,90)
ylabel('Player Hand Sum')
xlabel('Dealer Shown Card')

figure(2)
subplot(1,2,1)
surf(Q_table(:,:,1,1))
axis([2 11 4 21])
xticks(2:11)
yticks(4:21)
colormap('jet')
title('Stay Value')
view(0,90)
ylabel('Player Hand Sum')
xlabel('Dealer Shown Card')


subplot(1,2,2)
surf(Q_table(:,:,1,2))
axis([2 11 4 21])
xticks(2:11)
yticks(4:21)
colormap('jet')
title('Hit Value')
view(0,90)
ylabel('Player Hand Sum')
xlabel('Dealer Shown Card')

figure(3)
subplot(1,2,1)
surf(state_visit(:,:,1))
axis([2 11 4 21])
xticks(2:11)
yticks(4:21)
colormap('jet')
title('Ace')
view(0,90)
ylabel('Player Hand Sum')
xlabel('Dealer Shown Card')


subplot(1,2,2)
surf(state_visit(:,:,2))
axis([2 11 4 21])
xticks(2:11)
yticks(4:21)
colormap('jet')
title('No Ace')
view(0,90)
ylabel('Player Hand Sum')
xlabel('Dealer Shown Card')






