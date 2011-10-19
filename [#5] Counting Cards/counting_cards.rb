class Rounds < Array
  def initialize(input_lines)
    turns_lines = input_lines.slice!(0, 4)
    self << [build_turns(turns_lines)]
    until input_lines.empty?
      alternatives = []
      turns_lines = input_lines.slice!(0, 4)
      until input_lines.empty? || input_lines.first.chr != '*'
        signal_line = input_lines.slice!(0)
        alternatives << build_turns(turns_lines, signal_line)
      end
      self << alternatives
    end
  end
  
  def build_turns(turns_lines, signal_line = nil)
    turns = { :Shady => [], :Rocky => [], :Danny => [], :Lil => [] }
    signal = signal_line.split.slice(1..-1) unless signal_line.nil?
    turns_lines.each do |turn_line|
      turn = turn_line.split
      player = turn.slice!(0).to_sym
      turn.each do |move|
        if player == :Lil && !(move =~ /\?\?/).nil?
          turns[player] << signal.slice!(0)
        else
          turns[player] << move
        end
      end
    end
    turns
  end
end

class Hands < Hash
  def initialize(hands)
    if hands.nil?
      self.replace({ :Shady => [], :Rocky => [], :Danny => [], :Lil => [], :discard => [] })
    else
      self.replace(Marshal.load(Marshal.dump(hands)))
    end
  end
  
  def build(turns)
    turns.each_pair do |player, moves|
      moves.each do |move|
        card, other_player = move.split(':')
        unless card.include?('??')
          action = card.slice!(0)
          if action == '+' && other_player.nil?
            return false if card_in_play?(card)
            self[player] << card
          elsif action == '+'
            return false if card_in_play_except_by?(card, other_player.to_sym)
            self[player] << card
          elsif action == '-'
            return false if player == :Rocky && !card_in_play_by?(card, :Rocky)
            return false if player == :Lil && !card_in_play_by?(card, :Lil)
            self[player].delete(card)
            self[:discard] << card if other_player == 'discard'
          end
        end
      end
    end
    true
  end
  
  def card_in_play?(card)
    cards_in_play = []
    self.each_value { |cards| cards_in_play += cards }
    cards_in_play.include?(card)
  end
  
  def card_in_play_by?(card, player)
    self[player].include?(card)
  end
  
  def card_in_play_except_by?(card, except_player)
    cards_in_play = []
    self.each_pair { |player, cards| cards_in_play += cards unless player == except_player }
    cards_in_play.include?(card)
  end
end

class Game < Hash
  def initialize
    @rounds = []
    @lils_hands = []
  end
  
  def build(input_lines)
    @rounds = Rounds.new(input_lines)
  end
  
  def get_lils_hands
    find_lils_hands(0, 0)
    results = []
    @lils_hands.each do |hand|
      output_line = ''
      hand.each do |card|
        output_line << ' ' unless output_line.empty?
        output_line << card
      end
      results << output_line
    end
    results
  end
  
  def find_lils_hands(round, alternative, parent_hands = nil, lils_hands = [])
    hands = Hands.new(parent_hands)
    return unless hands.build(@rounds[round][alternative])
    self[parent_hands] << hands unless parent_hands.nil?
    lils_hands << hands[:Lil]
    if round == @rounds.size - 1
      @lils_hands = lils_hands
      return
    end
    self[hands] = []
    @rounds[round + 1].each_index do |alternative|
      find_lils_hands(round + 1, alternative, hands, lils_hands.dup)
    end
  end
end

game = Game.new
File.open('INPUT.txt', 'r') { |file| game.build(file.readlines) }
results = game.get_lils_hands
File.open('SOLUTION.txt', 'w') do |file|
  results.each { |output_line| file.puts output_line }
end
