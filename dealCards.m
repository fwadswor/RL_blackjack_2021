function [dealtCards,deck] = dealCards(numHands, cardsPerHand, numDecks,aceHigh)
%function deals cards from specified number of decks for input number of 
%cards to input number of players
    deck = [];
    one = ones(1,4); %1x4 vector of ones
    cards = zeros(cardsPerHand,numHands);
    if aceHigh
        c_set = [2 3 4 5 6 7 8 9 10 10 10 10 11];
    else
        c_set = [1 2 3 4 5 6 7 8 9 10 10 10 10];
    end
    %Repeat for each 52 card deck desired in complete shoe
    for d = 1:numDecks
        %Repeat for each number 1-10 plus 3 face cards (Ace encoded as 1)
        for c = 1:4
           %Append four cards of given number to deck, one for each suit
           deck = [deck; c_set];
        end
    end
    %make deck into a row vector
    deck_vec = reshape(deck,1,[]);
    %Shuffle deck
    deck_vec = deck_vec(randperm(length(deck_vec)));   
    %Repeat for desired number of cards per hand
    for cc = 1:cardsPerHand
        %Repeat for number of players
        for p = 1:numHands
            %Deal final card in deck
            cards(p,cc) = deck_vec(end);
            %remove dealt card from deck
            deck_vec(end) = [];
        end
    end
    dealtCards = cards;
    deck = deck_vec;
    
end