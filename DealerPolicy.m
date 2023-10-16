function [bust,blackjack,handValue,newDeck] = DealerPolicy(hand, deck)

    

    %Obtain deck size (13k x 4)
    deckSize = size(deck);
    
    %Initialize flags and counter
    blackjack = 0; 
    bust = 0; % Control flag to indicate hand score above 21
    hit = 1; % Control flag to indicate hand score below 17
    cardCount = 2; % Counter of hand size
    Hand = hand; % Initial dealer hand vector without suits 
    
    %Repeat process as long as dealer has not busted and hand value is
    %below 17
    while ~bust && hit         
        %Hand(Hand > 10) = 10; % Replace face cards with value of 10
        heldAces = (Hand == 1); % Indices of aces in dealer hand        
        aces = sum(heldAces); % Number of aces in dealer hand      
        %Evaluate for no aces in hand
        if aces == 0            
            handValue = sum(Hand); % Value of hand
            
            if handValue > 21 % Dealer bust
                bust = 1;
            elseif handValue > 16 % Dealer must stay above 17
                bust = 0;
                hit = 0;
            else
                card = deck(end);
                deck(end) = [];                 
                %Append drawn card to hand vector
                Hand = [Hand, card];              
            end            
        %At least one Ace in dealer hand    
        else 
            Hand(heldAces) = 11;
            handValue = sum(Hand);
            %Reduce soft hands, use ace as 1 instead of 11
            while handValue > 21 && aces > 0
                handValue = handValue - 10;
                aces = aces - 1;
            end            
            if handValue > 21 %Dealer bust
                bust = 1;
            elseif handValue > 16 %Dealer must stay above 17
                bust = 0;
                hit = 0;
            else
                card = deck(end);
                deck(end) = [];   
                %Append drawn card to hand vector
                Hand = [Hand, card];
            end
        end                 
    end
    newDeck = deck;
    handValue = sum(Hand);
end

