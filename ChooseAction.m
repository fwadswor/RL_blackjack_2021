function [ action ] = ChooseAction( hand,handVal,shownCard,uAce,agent_type,Q_table )
%function chooses agent actions (hit,stay) for AgentAnalytics.m
    %Trained agent
    if agent_type == 1
        action = max(Q_table(handVal,shownCard,uAce,:));
    %Random agent
    elseif agent_type == 2
        actRand = rand;
        if actRand < 0.5
            action = 1;
        else
            action = 2; %action = 2;
        end
        %Fixed policy agent
    else
        if handVal < 17
            action = 2;
        else
            action = 1; %action = 2;
        end
    end
end



