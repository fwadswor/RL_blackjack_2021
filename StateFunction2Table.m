function [ state ] = StateFunction2Table( enc_state )
%Function decodes encoded state value (scalar) into individual
%state features (1x3 vector)
%   
%   encoded_state = (sum - 1) + 18(dealerCard -2) + 180(useableAce)
%
%   Output: state = [sum,dealerCard,useableAce]
    orig_enc_state = enc_state;
    if enc_state < 183
        ace = 0;
    else
        ace = 1;
        enc_state = enc_state - 180;
    end  
    
    d = mod(enc_state,18)+1;
    
    if d >= 4 
        sum = d;
    else
        sum = 18+d;
    end
    dealerCard = (orig_enc_state - 180*ace - (sum-1))/18 + 2;
    state = [sum,dealerCard,ace];    
end

