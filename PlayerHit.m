function [newHand,newDeck] = PlayerHit(hand,deck)
%Function administers card to input hand from input deck
    card = deck(end);
    deck(end) = [];
    newHand = [hand, card];
    newDeck = deck;
end

