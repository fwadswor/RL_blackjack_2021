clear all

numAct = 5;
gamma = 0.99;
alpha = 0.01;
epsilon = 0.01;

numEpisodes = 10000;
handsPerEpisode = 100;
numCardsDealer = 13;

%Game parameters
ante = 20;
numPlayers = 2; %Agent and dealer
numCards = 2; %Blackjack initial hand = 2 cards
numDecks = 4;

Q_Table = zeros(20,numCardsDealer+1,numAct);

bjCheck = @(hand) sum(hand) == 11 && sum(ismember(hand,1));

rEpisode = [];

mean_hand = zeros(1,numEpisodes);
for i = 1:numEpisodes
    
    j = 0;
    rTotal = [];
    mean_hand_val = [];
    
    while j < handsPerEpisode
        % Per hand parameters and flags
        player_card_count = 2;
        player_bet = ante;
        bust = 0;
        stay = 0;
        split = 0;
        double = 0;
        twenty_one = 0;
        numHands = 1;
        rolloutAction = [];
        rolloutReward = [];
        
        
        %Function call to deal cards to dealer and player
        [dealtCards,deck] = dealCards(numPlayers,numCards,numDecks,0);
        %Sort dealt card tensor into player and dealer hands
        %Replace face cards with 10
        pHand = dealtCards(1,:);        
        dHand = dealtCards(2,:);
        
        pHand = pHand - (pHand > 10) .* (pHand - 10);
        dHand = dHand - (dHand > 10) .* (dHand - 10);
        
        [pHandAces,pHandVal,p21] = new_EvaluateHand(pHand);
        [dHandAces,dHandVal,d21] = new_EvaluateHand(dHand);
        mean_hand_val = [mean_hand_val, pHandVal];
        shownCard = pHand(2);
        STATE = [pHand(1), pHand(2), dHand(2), 1];
        
        %Check player and dealer for natural blackjack
        player_bj = bjCheck(pHandVal);
        dealer_bj = bjCheck(dHandVal);
        %[val,to,b] = EvaluateHand(pHand);
        rolloutState = [pHandVal];
        
        
         %%%%%%%%%%%%%%%%%%%%%%%%
        %Put stuff in here for cases of natural blackjacks, use continue
        %statement at end to return to top of while loop. Remember to store
        %everything
        
        if p21  || d21
            if ~p21 %Dealer BJ
                
            elseif ~d21 %Player BJ
                player_bet = 1.5 * player_bet;
            else %Both natural BJ
                %disp("FUCK")
            end                                
            continue
        end        
        %%%%%%%%%%%%%%%%%%%%%%
      while ~stay &&  ~bust && ~twenty_one
        
            %val = sum(pHandVal);
            %Determine allowed actions
            if STATE(1) == STATE(2)

                A = [1 2 3 4 5];
                if STATE(2) == 1

                    split_aces = 1; 
                end

            elseif player_card_count > 2 

                A = [1 2];

            else
                A = [1 2 3 5];
            end
            
             %Continuous uniform distribution from (0,1)
            actionDist = rand;

            if actionDist < epsilon
                %Select random action
                Action = randsample(A,1);                                
            else
                Q_temp = zeros(numAct,1);
                A_not = setdiff([1,2,3,4,5],A);
                
                for q = A
                    Q_temp(q) = Q_Table(pHandVal, shownCard,q);
                end
                for q_n = A_not
                    Q_temp(A_not) = -inf;
                end
                
                [Qmax,Action] = max(Q_temp);
                maxIndex = find(Q_temp == Qmax);
                if length(maxIndex) > 1
                    act_idx = randsample(length(maxIndex),1);
                    Action = maxIndex(act_idx);
                elseif length(maxIndex)==1
                    %Do MF nothing
                end
            end
            
            rolloutAction = [rolloutAction, Action];
            
            %Take action and transition to new state            
            [pHand,player_bet,stay,deck,surrender,split,double,hand1,hand2] ...
             = RunBJTurn(pHand,Action,deck,ante,player_bet);
            %Replace new face card with 10 if applicable
            pHand = pHand - (pHand > 10) .* (pHand - 10);
            
            %Determine resulting state and whether player episode is to
            %terminate
            if double
                [pHand, deck] = PlayerHit(deck);
                [h, val, twenty_one, bust] = new_EvaluateHand(pHand);
                rolloutState = val;
                stay = 1;
            elseif split
                [h,first_val] = new_EvaluateHand(pHand);              
                [card1,deck] = PlayerHit(deck);
                [card2,deck] = PlayerHit(deck);
                pHand1 = [hand1, card1];
                pHand2 = [hand2, card2];
                [h1, val1, twenty_one_1, bust1] = new_EvaluateHand(pHand1);
                [h2, val2, twenty_one_2, bust2] = new_EvaluateHand(pHand2);
                rolloutState = first_val;                                                
                numHands = 2;
                stay = 1; %Round must terminate after split hands are hit once
            else
                [h, val, twenty_one, bust] = new_EvaluateHand(pHand);
                if ~bust && ~twenty_one && ~stay
                    rolloutState = [rolloutState, val];
                end
            end
            
            player_card_count = player_card_count + 1;
                        
      end
      [dealerBust,d_BJ,d_val,newDeck] = DealerPolicy(dHand,deck);
      
      if numHands == 1           
            if bust || surrender || ((d_val > val) && ~dealerBust)
                reward = -player_bet;
            elseif dealerBust || (d_val < val)
                reward = player_bet;
            else
                reward = 0;
            end
            
      else
            if bust1 || surrender || (d_val > val1)
                reward = -player_bet;
            elseif dealerBust || (d_val < val1)
                reward = player_bet;
            else
                reward = 0;
            end
            
            if bust2 || surrender || (d_val > val2)
                reward = reward - player_bet;
            elseif dealerBust || (d_val < val2)
                reward = reward + player_bet;            
            end
      end
        
        S = rolloutState; ACTION = rolloutAction;
        
        for k = 1:length(S)            
            maxQ = max(Q_Table(S(k),shownCard,:));
            Q_Table(S(k),shownCard,ACTION(k)) = ...
            Q_Table(S(k),shownCard,ACTION(k))  + ...
            alpha*(reward + gamma*maxQ - Q_Table(S(k),shownCard, ACTION(k)));
        end
        
        rTotal = [rTotal, reward];
        j = j+1;
        
    end
    rEpisode = [rEpisode, sum(rTotal)];
    mean_hand(i) = sum(mean_hand_val)/length(mean_hand_val);
    if mod(i,50)==0
        fprintf("Episode %d \n",i)
    end
    
    
    
end
color_map = @(x) 8.*x + 2;


figure(1)
plot(rEpisode)
xlabel('Episodes')
ylabel('Total Reward')

figure(2)
surf(color_map(Q_Table(:,:,1)))
xlim([0,16])
ylim([0,20])
title('hit')
view(0,90)
colormap('jet')


figure(3)
surf(color_map(Q_Table(:,:,2)))
xlim([0,16])
ylim([0,20])
title('stay')
view(0,90)
colormap('jet')

