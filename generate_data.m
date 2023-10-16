%Script generates {s,a,r,s'} data tuples for Q-learning of
%2 player blackjack environment using uniform random behavioral policy
clear all
tic
%ACTION: [1,2] == ['stay','hit']
numEpisodes = 3000;
handsPerEpisode = 1000;

ante = 10; %reward amount
numPlayers = 2; %Agent and dealer
numCards = 2; %Blackjack initial hand = 2 cards
numDecks = 4;
aceHigh = 1;

encode_state = @(hand,dCard,ace) (hand-1) + 18*(dCard-2)+ 180*(ace);

SARS = int16([]);
SARS_total = int16([]);

for i = 1:numEpisodes
    rng('shuffle')
    SARS=int16([]);
    parfor ii = 1:handsPerEpisode
        handOver = 0;
        while ~handOver
            %-----Params and storage arrays-----
            state = [];
            state_fcn = [];
            action = [];
            reward = [];

            %-----------Simulate Hand-----------
            %Deal cards to numCards x numPlayers matrix
            [dealtCards,deck] = dealCards(numPlayers,numCards,numDecks,aceHigh);
            %Split cards into player and dealer hands
            pHand = dealtCards(1,:);  dHand = dealtCards(2,:);
            %Evaluate player hand
            [pHand,pVal,pBust,pUseAce] = HandEval(pHand);

            %Select action using random policy
            while (~pBust)&&(~handOver)
                state = [state, [pVal;dHand(2);pUseAce]];
                state_fcn = [state_fcn, encode_state(pVal,dHand(2),pUseAce)];
                reward = [reward 0];
                actSelect = rand;
                if actSelect < 0.5
                    action = [action, 2];                 
                    [pHand,deck] = PlayerHit(pHand,deck);
                    [pHand,pVal,pBust,pUseAce] = HandEval(pHand);
                else
                    action = [action, 1];                 
                    handOver = 1;
                    break
                end
            end
            %Resolve dealer hand
            [dBust,dBJ,dVal,deck] = DealerPolicy(dHand,deck);
                %Determine winner
                if (pBust) || ((dVal > pVal) && (~dBust))
                    reward = [reward, -ante];
                    %Lose state encoded by 0
                    state_fcn = [state_fcn, 0];
                elseif (pVal > dVal) || dBust
                    reward = [reward, ante/5];
                    %Win state encoded by 2
                    state_fcn = [state_fcn, 2];
                else
                    reward = [reward, 0];
                    %Draw state encoded by 1
                    state_fcn = [state_fcn, 1];
                end
                reward(1) = [];
                for p =1:length(action)
                    SARS = [SARS; [state_fcn(p), action(p),reward(p),state_fcn(p+1)]];
                end
        end
    end
    SARS_total = [SARS_total;SARS];
end
toc
save('SARS_data.mat','SARS_total','-mat')