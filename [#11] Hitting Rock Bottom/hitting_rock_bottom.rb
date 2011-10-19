class Cave
  def initialize(filename)
    lines = []
    File.open(filename, 'r') { |f| lines = f.readlines }
    @water_units = lines.shift.to_i
    lines.shift; lines.shift
    columns = lines.collect { |line| line.chomp.split('') }.transpose
    @map = columns.collect { |column| Array.new(column.index('#'), false) }
    @mid_stream = false
    flow_water(0, 0)
  end
  
  def output(filename)
    depths = @map.collect { |column| column.count(true).to_s }
    last_col = depths.index('0') - 1
    depths[last_col] = '~' unless @map[last_col][-1]
    File.open(filename, 'w') { |f| f.puts(depths.join(' ')) }
  end
  
  private
  
  def flow_water(col, row)
    return unless @water_units > 0
    @map[col][row] = true
    @water_units -= 1
    flow_water(col, row + 1) if @map[col][row + 1] == false
    flow_water(col + 1, row) if @map[col + 1][row] == false
  end
end

cave = Cave.new('complex_cave.txt')
cave.output('output.txt')
