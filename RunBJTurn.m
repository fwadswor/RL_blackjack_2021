
function [newHand,playerBet,stay,deck,surrender,split,double,hand1,hand2] = RunBJTurn(pHand,act,deck,ante,bet)


          
    
    %Anonymous function for checking blackjack
    %bjCheck = @(hand) sum(hand) == 11 && sum(ismember(hand,1));
    
    stay = 0;
    surrender = 0;
    split = 0;
    double = 0;
    
    hand1 = [];
    hand2 = [];
    
    %Separate vector for hand values (reduce face cards to 10)
    %pHandTens = pHand - (pHand - 10).*(pHand > 10);
    %heldAces = (pHand==1);
    %pHandTens(heldAces) = 11;
    [h,pHandVal] = new_EvaluateHand(pHand);
    
    
    
    %Event of dealt blackjack to player or dealer
    
        
    if pHandVal == 21
        newHand = pHand;
        
        
    elseif pHandVal < 21
        
        switch act
            case 1 % Hit       
            [card,d] = PlayerHit(deck);
            newHand = [pHand, card];
            deck = d;
            
            case 2 % Stay
            stay = 1; newHand = pHand;
            
            
            case 3 %Double down
            bet = bet + ante;
            double = 1;
            newHand = pHand;
            
            case 4 %Split
            split = 1;
            %[c1,d1] = PlayerHit(deck);
            %[c2,d2] = PlayerHit(d1);
            %hand1 = [pHand(1), c1];
            %hand2 = [pHand(2), c2];
            %deck = d2;
            hand1 = pHand(1);
            hand2 = pHand(2);
            newHand = pHand;
            
            case 5 %Surrender
                bet = bet / 2;
                surrender = 1;
                newHand = pHand;
                
        end
        
    else % hand > 21 --> player bust
        newHand = pHand;
        
            
        
        
    end
    
    
    
    
playerBet = bet;  
    
end

