def count_laser_hits(north_side, conveyor_belt, south_side)
  robot_offset = conveyor_belt.index('X')
  
  north_lasers = north_side.chomp.split('').collect { |c| c == '|' ? true : false }
  nw_lasers    = north_lasers[0, robot_offset + 1].reverse
  ne_lasers    = north_lasers[robot_offset..-1]
  
  south_lasers = south_side.chomp.split('').collect { |c| c == '|' ? true : false }
  sw_lasers    = south_lasers[0, robot_offset + 1].reverse
  se_lasers    = south_lasers[robot_offset..-1]
  
  west_hits = 0
  nw_lasers.each_with_index { |laser, i| west_hits += 1 if laser && i % 2 == 0 }
  sw_lasers.each_with_index { |laser, i| west_hits += 1 if laser && i % 2 == 1 }
  
  east_hits = 0
  ne_lasers.each_with_index { |laser, i| east_hits += 1 if laser && i % 2 == 0 }
  se_lasers.each_with_index { |laser, i| east_hits += 1 if laser && i % 2 == 1 }
  
  return west_hits, east_hits
end

results = []

File.open("input.txt", "r") do |file|
  until file.eof?
    west_hits, east_hits = count_laser_hits(file.gets, file.gets, file.gets)
    file.gets
    
    results << (west_hits <= east_hits ? 'GO WEST' : 'GO EAST')
  end
end

File.open('output.txt', 'w') do |file|
  results.each do |result|
    file.puts result
  end
end
