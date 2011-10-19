class Drawing
  def initialize(filename)
    commands = []
    File.open(filename, 'r') { |f| commands = f.readlines }
    size    = commands.shift.to_i; commands.shift
    @canvas = size.times.collect { Array.new(size, false) }
    @x = @y = size / 2
    @angle  = 0
    @canvas[@x][@y] = true
    commands.each { |command| draw(command.split) }
  end
  
  def output(filename)
    File.open(filename, 'w') do |f|
      @canvas.each do |row|
        f.puts(row.collect { |cell| cell ? 'X' : '.' }.join(' '))
      end
    end
  end
  
  private
  
  def draw(command)
    case command[0]
    when 'REPEAT'
      command[1].to_i.times { draw(command[2..-1]) }
    when '['
      command[1..-2].each_slice(2) { |command| draw(command) }
    else
      case command[0]
      when 'FD'
        move(command[1].to_i, @angle)
      when 'BK'
        move(command[1].to_i, (@angle + 180) % 360)
      when 'RT'
        turn(command[1].to_i)
      when 'LT'
        turn(360 - command[1].to_i)
      end
    end
  end
  
  def move(units, angle)
    units.times do
      case angle
      when 0
        @canvas[@x -= 1][@y     ] = true
      when 45                    
        @canvas[@x -= 1][@y += 1] = true
      when 90                    
        @canvas[@x     ][@y += 1] = true
      when 135                   
        @canvas[@x += 1][@y += 1] = true
      when 180                   
        @canvas[@x += 1][@y     ] = true
      when 225                   
        @canvas[@x += 1][@y -= 1] = true
      when 270                   
        @canvas[@x     ][@y -= 1] = true
      when 315                   
        @canvas[@x -= 1][@y -= 1] = true
      end
    end
  end
  
  def turn(angle)
    @angle += angle
    @angle %= 360
  end
end

describe Drawing do
  it 'should create a drawing file that matches the simple example' do
    drawing = Drawing.new('simple.logo')
    drawing.output('output.txt')
    File.read('output.txt').should == File.read('simple_out.txt')
  end
end unless $0 == __FILE__

if $0 == __FILE__
  drawing = Drawing.new(ARGV[0])
  drawing.output(ARGV[1])
end
