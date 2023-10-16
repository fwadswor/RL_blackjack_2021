function [newHand,value,bust,useableAce] = HandEval(hand)
%function evaluates current player hand
%
%Outputs:
%  
%   newHand: hand with face cards and aces resolved
%   value: sum of current hand
%   bust: flag indicating if hand value exceeds 21
%   useableAce: flag indicating whether hand has ace of value 11

    %Determine aces in hand
    heldAces = (hand==11);
    numAces = sum(heldAces);
  
    %If no aces in hand
    if numAces == 0
        %Find hand value        
        value = sum(hand);
        useableAce = 0;        
        if value <= 21            
            bust = 0;        
        else            
            bust = 1;
        end
        
    %If at least one Ace in hand
    else
        %Find hand value
        value = sum(hand);
        %if not bust
        if value <= 21
            useableAce = 1;
            bust = 0;
        else
            aceCount = numAces;
            value_temp = value;
            while value_temp > 21 && aceCount > 0
                value_temp = value_temp - 10;
                aceCount = aceCount - 1;                               
            end
            if value_temp > 21
                useableAce = 0;
                bust = 1;
            else
                a = find(hand==11);
                k = 1;
                while value > 21
                    hand(a(k)) = 1;
                    value = sum(hand);
                    k = k+1;
                end
                bust = 0;
                if isempty(find(hand==11))
                    useableAce = 0;
                else
                    useableAce = 1;
                end                       
            end  
        end                  
    end
    newHand = hand;
end
