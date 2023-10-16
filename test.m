encode_state = @(hand,dCard,ace) (hand-1) + 18*(dCard-2)+ 180*(ace);
state = [];
for a = 0:1
    for d = 2:11
        for s = 4:21
            state = [state;[s,d,a]];
        end
    end
end

enc_state=zeros(1,360);
for i = 1:360
    enc_state(i) = encode_state(state(i,1),state(i,2),state(i,3));
end

dec_state = [];
for j = 1:length(enc_state)
    dec_state = [dec_state; StateFunction2Table(enc_state(j))];
end
dec_state