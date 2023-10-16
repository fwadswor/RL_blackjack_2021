function [ SARS ] = GenerateBatchData( batchSize, t)

    

    numEpisodes = batchSize

    ante = 20;
    numPlayers = 2; %Agent and dealer
    numCards = 2; %Blackjack initial hand = 2 cards
    numDecks = 4;
    aceHigh = 1;

    bjCheck = @(hand) sum(hand) == 11 && sum(ismember(hand,1));
    encode_state = @(hand,dCard,ace) (hand-1) + 18*(dCard-2)+ 180*(ace);

    SARS = int16([]);


    for i = 1:numEpisodes

        j = 0;
        rTotal = [];
        handOver = 0;

        while ~handOver

            %-----Params and storage arrays-----
            state = [];
            state_fcn = [];
            action = [];
            reward = [];
            %SARS = [];


            %-----------------------------------

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

            [dBust,dBJ,dVal,deck] = DealerPolicy(dHand,deck);
                %Determine winner
                if (pBust) || ((dVal > pVal) && (~dBust))
                    reward = [reward, -ante];
                    %Lose state encoded by 0
                    state_fcn = [state_fcn, 0];

                elseif (pVal > dVal) || dBust
                    reward = [reward, ante];
                    %Win state encoded by 2
                    state_fcn = [state_fcn, 2];
                else
                    reward = [reward, 0];
                    %Draw state encoded by 1
                    state_fcn = [state_fcn, 1];
                end

                reward(1) = [];
    %             if length(state_fcn) ~= length(reward)+1
    %                 disp("Fuckin up")
    %             else
    %                 state_fcn
    %                 action
    %                 reward
    %                 disp('-------------------------')
    %             end

                for p =1:length(action)
                    SARS = [SARS; [state_fcn(p), action(p),reward(p),state_fcn(p+1)]];
                end

            %-----------------------------------

        end

    end

end

