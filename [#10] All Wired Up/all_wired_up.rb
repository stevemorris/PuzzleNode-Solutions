class Circuits
  def initialize(filename)
    @lines = []
    File.open(filename, 'r') { |f| @lines = f.readlines }
    @lights = []
    @lines.each_with_index do |line, row|
      unless (col = line.index('@')).nil?
        col = move_left(row, col)
        @lights << get_element(row, col)
      end
    end
  end
  
  def output(filename)
    File.open(filename, 'w') do |f|
      @lights.each { |light| f.puts(light ? 'on' : 'off') }
    end
  end
  
  private
  
  def get_element(row, col)
    case @lines[row][col]
    when '0'
      false
    when '1'
      true
    when 'A'
      row1, col1 = move_up_left(row, col)
      row2, col2 = move_down_left(row, col)
      get_element(row1, col1) & get_element(row2, col2)
    when 'O'
      row1, col1 = move_up_left(row, col)
      row2, col2 = move_down_left(row, col)
      get_element(row1, col1) | get_element(row2, col2)
    when 'X'
      row1, col1 = move_up_left(row, col)
      row2, col2 = move_down_left(row, col)
      get_element(row1, col1) ^ get_element(row2, col2)
    when 'N'
      row1, col1 = move_up_left(row, col)
      !get_element(row1, col1)
    end
  end
  
  def move_left(row, col)
    line = @lines[row][0..col].chop
    line.length - line.reverse.index(/[^-]/, 1) - 1
  end
  
  def move_up_left(row, col)
    row -= 1 until @lines[row][col - 1] == '-'
    return row, move_left(row, col)
  end
  
  def move_down_left(row, col)
    row += 1 until @lines[row][col - 1] == '-'
    return row, move_left(row, col)
  end
end

describe Circuits do
  it 'should create a lights output file that matches the simple example' do
    circuits = Circuits.new('simple_circuits.txt')
    circuits.output('output.txt')
    File.read('output.txt').should == File.read('simple_output.txt')
  end
end unless $0 == __FILE__

if $0 == __FILE__
  circuits = Circuits.new(ARGV[0])
  circuits.output(ARGV[1])
end
