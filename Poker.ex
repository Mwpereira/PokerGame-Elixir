defmodule Poker do
  def deal(cards) do

    #Deal cards
    hand1 = Enum.take_every(cards, 2)
    hand2 = cards -- hand1

    #Get suits
    hand1 = Enum.map(hand1, fn(n) -> getCard(n) end)
    hand2 = Enum.map(hand2, fn(n) -> getCard(n) end)

    hand1 = hand1 |> List.keysort(0)
    hand2 = hand2 |> List.keysort(0)

    #Determine the ranking of each hand
    hand1rank = determineHandRank(hand1)
    hand2rank = determineHandRank(hand2)

    #Decide which hand is the winner
    winner = cond do
      hand1rank < hand2rank -> hand1
      hand2rank < hand1rank -> hand2
      true -> determineTieBreaker(hand1, hand2, hand1rank)
    end

    printWinner(winner)
  end

  defp printWinner(winner) do
    winner = Enum.map(winner, fn({rank, suit}) -> if rank==14, do: {1, suit}, else: {rank, suit} end)
    winner = Enum.sort(winner)
    Enum.map(winner, fn({rank, suit}) -> "#{rank}" <> suit end)
  end

  ##################### Tie Breaking ##############################
  defp determineTieBreaker(hand1, hand2, rank) do
    case rank do
      1 -> tbRoyalFlush(hand1, hand2)
      2 -> tbMixedOperations1(hand1, hand2)
      3 -> tbMixedOperations2(hand1, hand2)
      4 -> tbMixedOperations2(hand1, hand2)
      5 -> tbMixedOperations1(hand1, hand2)
      6 -> tbMixedOperations1(hand1, hand2)
      7 -> tbMixedOperations2(hand1, hand2)
      8 -> tbMixedOperations1(hand1, hand2)
      9 -> tbPair(hand1, hand2)
      10 -> tbMixedOperations1(hand1, hand2)
    end
  end

  # Tie-breaker for Royal Flush
  defp tbRoyalFlush(hand1, hand2) do
    winner = compareSuits(hand1, hand2)

    cond do
      winner == nil -> compareSuits(hand1, hand2)
      true -> winner
    end
  end

  # Tie-breaker for Straight Flush, Flush, Straight, and High Card
  defp tbMixedOperations1(hand1, hand2) do
    winner = compareRanks(hand1, hand2)

    cond do
      winner == nil -> compareSuits(hand1, hand2)
      true -> winner
    end
  end

  # Tie-breaker for Four of a Kind, Full House, and Three Of A Kind
  defp tbMixedOperations2(hand1, hand2) do
    rank1 = Enum.map(hand1, fn({rank, suit}) -> rank end)
    rank2 = Enum.map(hand2, fn({rank, suit}) -> rank end)

    n1 = rank1[2]
    n2 = rank2[2]

    cond do
      n1 > n2 -> hand1
      n2 > n1 -> hand2
    end
  end

  # Tie-breaker for Pair
  defp tbPair(hand1, hand2) do
    rank1 = Enum.map(hand1, fn({rank, suit}) -> rank end)
    rank2 = Enum.map(hand2, fn({rank, suit}) -> rank end)

    hand1pair = case rank1 do
      [x,x,_,_,_] -> x
      [_,x,x,_,_] -> x
      [_,_,x,x,_] -> x
      [_,_,_,x,x] -> x
    end

    hand2pair = case rank2 do
      [x,x,_,_,_] -> x
      [_,x,x,_,_] -> x
      [_,_,x,x,_] -> x
      [_,_,_,x,x] -> x
    end

    winner = cond do
      hand1pair > hand2pair -> hand1
      hand2pair > hand1pair -> hand2
      true -> compareRanks(hand1, hand2)
    end

    cond do
      winner == nil -> compareSuits(hand1, hand2)
      true -> winner
    end
  end

  # Determines which hand is higher based on rank
  defp compareRanks(hand1, hand2) do
    rank1 = Enum.map(hand1, fn({rank, suit}) -> rank end)
    rank2 = Enum.map(hand2, fn({rank, suit}) -> rank end)

    sum1 = Enum.sum(rank1)
    sum2 = Enum.sum(rank2)

    cond do
      sum1 > sum2 -> hand1
      sum2 > sum1 -> hand2
      true -> nil
    end
  end

  # Determines which hand is higher based on suits
  defp compareSuits(hand1, hand2) do
    suit1 = Enum.map(hand1, fn({rank, suit}) -> suit end)
    suit2 = Enum.map(hand2, fn({rank, suit}) -> suit end)

    total1 = Enum.reduce(suit1, 0, fn c, acc ->
      <<aacute::utf8>> = c
      acc + aacute
    end)

    total2 = Enum.reduce(suit2, 0, fn c, acc ->
      <<aacute::utf8>> = c
      acc + aacute
    end)

    cond do
      total1 > total2 -> hand1
      true -> hand2
    end
  end

  ##################### CHECK RANKING ##############################
  #Checks if hand is Royal Flush
  defp checkRoyalFlush(hand) do
    cardNums = Enum.map(hand, fn({card, suit}) -> card end)

    straight = case cardNums do
      [10,11,12,13,14] -> true
      _ -> false
    end

    suits = checkSuit(hand)

    straight == true and suits == true
  end

  #Checks if hand is Straight Flush
  defp checkStraightFlush(hand) do
    checkStraight(hand) == true and checkSuit(hand) == true
  end

  #Checks if hand is Full House
  defp checkFullHouse(hand) do
    cards = Enum.map(hand, fn({card, suit}) -> card end)

    case cards do
      [x,x,x,y,y] -> true
      [y,y,x,x,x] -> true
      _ -> false
    end
  end

  #Checks if hand is Flush
  defp checkFlush(hand) do
    checkSuit(hand) == true and checkStraight(hand) == false
  end

  # Check if 'n' number of cards in hand have the same value
  defp checkXOfAKind(hand, n) do
    cards = Enum.map(hand, fn({card, suit}) -> card end)

    Enum.any?(cards, fn(x) -> if(Enum.count(cards--List.duplicate(x, n)) == (5 - n), do: true, else: false) end)
  end

  #Checks if hand is Straight
  defp checkStraight(hand) do
    cards = Enum.map(hand, fn({card, suit}) -> card end)
    x = hd(cards)

    cond do
      [x,x+1,x+2,x+3,x+4] == cards -> true
      [2,3,4,5,14] == cards -> true 
      true -> false
     end
  end

  defp checkTwoPair(hand) do
    cards = Enum.map(hand, fn({card, suit}) -> card end)

    case cards do
      [x,x,y,y,_] -> true
      [_,x,x,y,y] -> true
      [x,x,_,y,y] -> true
      _ -> false
    end
  end

  ###################### MISC METHODS ######################
  #Gets the actual card value and suit as a tuple: ie. {12, "C"}
  defp getCard(cardNum) do
    suit = if(rem(cardNum,13) == 0, do: div(cardNum,13)-1, else: div(cardNum,13))
    card = case (rem(cardNum, 13)) do
      0 -> 13
      1 -> 14
      _ ->rem(cardNum, 13)
    end

    case (suit) do
      0 -> {card, "C"}
      1 -> {card, "D"}
      2 -> {card, "H"}
      3 -> {card, "S"}
      _ -> raise ArgumentError, message: "ArgumentError: Number cannot be represented as a card"
    end
  end

  #Determine what ranking the hand has
  defp determineHandRank(hand) do
    cond do
      checkRoyalFlush(hand) -> 1
      checkStraightFlush(hand) -> 2
      checkXOfAKind(hand, 4) -> 3
      checkFullHouse(hand) -> 4
      checkFlush(hand) -> 5
      checkStraight(hand) -> 6
      checkXOfAKind(hand, 3) -> 7
      checkTwoPair(hand) -> 8
      checkXOfAKind(hand, 2) -> 9
      true -> 10
    end
  end

  #Checks if all suits in hand are the same
  defp checkSuit(hand) do
    handSuits = Enum.map(hand, fn({card, suit}) -> suit end)
    suit = hd(handSuits)
    s = List.duplicate(suit,Enum.count(hand))
    if(handSuits--s == [], do: true, else: false)
  end
end