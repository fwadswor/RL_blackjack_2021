%Script to run games to test agent performance
rng('shuffle')
import = load('TrainedQTable.mat', '-mat');
Q = import.Q_table;

numPlayers = 2; %Agent and dealer
numCards = 2; %Blackjack initial hand = 2 cards
numDecks = 4; %number of decks in shoe
aceHigh = 1; %ace high encoding
numGames = 200000; %number of simulation games
%Initialize win counters
trainedPolicyWin = zeros(1,numGames);
randomPolicyWin = zeros(1,numGames);
fixedPolicyWin = zeros(1,numGames);
for i = 1:numGames
    handOver = 0;
    win = [];
    %Deal cards to numCards x numPlayers matrix
    [dealtCards,deck] = dealCards(numPlayers,numCards,numDecks,aceHigh);
    %Split cards into player and dealer hands
    pHand = dealtCards(1,:);  dHand = dealtCards(2,:);
    shownCard = dHand(2);
    %Evaluate player hand (triplicate, one for each player)
    [pHand,pVal,pBust,pUseAce] = HandEval(pHand);
    %Store evaluations in array to evaluate each player separately by idx
    Hand = [pHand; pHand; pHand];
    Val = [pVal; pVal; pVal];
    Bust = [pBust; pBust; pBust];
    Ace = [pUseAce; pUseAce; pUseAce];
    Ace = Ace + 1;
    deck_reuse = deck;    
    for plyr = 1:3
        hand = Hand(plyr,:);
        handOver = 0;
        deck = deck_reuse;
        while ~Bust(plyr) && ~handOver
            act = ChooseAction(hand,Val(plyr),shownCard,Ace(plyr),plyr,Q);
            if act == 2
                [hand,deck] = PlayerHit(hand,deck);
                [hand,Val(plyr),Bust(plyr),Ace(plyr)] = HandEval(hand);
            else
                handOver = 1;
            end           
        end
    end
    [dBust,dBJ,dVal,deck] = DealerPolicy(dHand,deck);
    for plyr = 1:3
        %Determine winner
        if (Bust(plyr)) || ((dVal > Val(plyr)) && (~dBust))
            win = [win 0];

        elseif (Val(plyr) > dVal) || dBust
            win = [win 1];
        else
            win = [win 0];
        end
    end
    trainedPolicyWin(i) = win(1);
    randomPolicyWin(i) = win(2);
    fixedPolicyWin(i) = win(3);
    
end
%Calculate win % for each agent
tWinRate = sum(trainedPolicyWin)/length(trainedPolicyWin)
rWinRate = sum(randomPolicyWin)/length(randomPolicyWin)
fWinRate = sum(fixedPolicyWin)/length(fixedPolicyWin)
