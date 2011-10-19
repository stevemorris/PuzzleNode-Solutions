require 'json'

class Board < Array
  HORZ = 0
  VERT = 1
  
  def initialize(board)
    board.each { |row| self << row.split }
    @width  = self[0].length
    @height = self.length
  end
  
  def place_highest_scoring_word(words)
    find_highest_scoring_word(words)
    @high_word.split('').each_with_index do |char, index|
      if @high_dir == HORZ
        self[@high_row][@high_col + index] = char
      elsif @high_dir == VERT
        self[@high_row + index][@high_col] = char
      end
    end
  end
  
  def find_highest_scoring_word(words)
    high_score = 0
    words.keys.each do |word|
      (HORZ..VERT).each do |dir|
        0.upto(@width - 1) do |col|
          0.upto(@height - 1) do |row|
            score = get_score_at(words[word], dir, col, row)
            if score > high_score
              high_score = score
              @high_word = word
              @high_col  = col
              @high_row  = row
              @high_dir  = dir
            end
          end
        end
      end
    end
  end
  
  def get_score_at(word_values, dir, col, row)
    length = word_values.size
    if dir == HORZ
      return 0 unless col + length < @width
      board_values = self[row][col, length]
    elsif dir == VERT
      return 0 unless row + length < @height
      board_values = self[row, length].collect { |board_row| board_row[col] }
    end
    board_values.zip(word_values).inject(0) { |sum, p| sum + (p[0].to_i * p[1].to_i) }
  end
end

class Words < Hash
  def initialize(dictionary, tiles)
    dictionary.each do |word|
      word_values = get_word_values(word, tiles)
      self[word]  = word_values unless word_values.nil?
    end    
  end
  
  def get_word_values(word, tiles)
    values = []
    tiles  = tiles.dup
    word.each_char do |char|
      return nil if (index = tiles.index(tiles.assoc(char))).nil?
      values << tiles[index][1]
      tiles.delete_at(index)
    end
    values
  end
end

class Tiles < Array
  def initialize(tiles)
    tiles.each { |tile| self << tile.scan(/([a-z])(\d+)/)[0] }
  end
end

input = JSON.parse(File.read('INPUT.json'))
tiles = Tiles.new(input['tiles'])
words = Words.new(input['dictionary'], tiles)
board = Board.new(input['board'])

board.place_highest_scoring_word(words)

File.open('OUTPUT.txt', 'w') do |f|
  board.each_with_index do |board_row, index|
    f.write("\n") unless index == 0
    f.write(board_row.join(' '))
  end
end
