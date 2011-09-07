# Ruby solution to PuzzleNode problem #2: Cheap tourist, fast tourist
# Given that Steve and Jennifer want to travel from city A to city Z, find the
#   sequence of flights most suitable for each one.
# see http://puzzlenode.com/puzzles/3 for problem details
#
# Usage:   ruby cheap_tourist_fast_tourist.rb [inputfile] [outputfile]
# Example: ruby cheap_tourist_fast_tourist.rb input.txt output.txt
# Testing: rspec cheap_tourist_fast_tourist.rb
#
# Solution notes: The key to this solution is the find_best_trip method, which
#   is based on the find shortest path algorithm from graph theory. For this
#   to work, import each test case into a graph data structure: a hash with
#   the departure city as the key and an array of flights from that city as
#   the value. The find_best_trip method also needs a comparison method to
#   determine the better of two trips, either the cheapest_trip or fastest_trip
#   method. See embedded comments below for more details.

module FlightOptimizer
  # For each test case in the input file, find the cheapest and fastest
  #   trips from and to the specified cities, and write the results to the
  #   output file
  def self.run(input_file, from, to, output_file)
    File.open(input_file, 'r') do |fin|
      fin.gets.to_i.times do |n|
        fin.gets
        # Read the flight data for a test case and store in a graph data
        #   structure, converting times to seconds and money to cents for
        #   easier calculations later on
        graph = {}
        fin.gets.to_i.times do
          input = fin.gets.rstrip.split(/ |:|\./)
          from  = input.shift.to_sym
          graph[from] ||= []
          graph[from] <<
            { from: from, to: input.shift.to_sym,
              depart: (input.shift.to_i * 60) + input.shift.to_i,
              arrive: (input.shift.to_i * 60) + input.shift.to_i,
              price: (input.shift.to_i * 100) + input.shift.to_i }
        end
        # Find the cheapest & fastest trips for the current test case and write
        #   the formatted results to the output file
        File.open(output_file, n == 0 ? 'w' : 'a') do |fout|
          fout.puts unless n == 0
          [:cheapest_trip, :fastest_trip].each do |compare|
            trip = find_best_trip(graph, :A, :Z, compare)
            fout.puts "%02d:%02d %02d:%02d %d.%02d" %
              [trip[:depart] / 60, trip[:depart] % 60, trip[:arrive] / 60,
               trip[:arrive] % 60, trip[:price] / 100, trip[:price] % 100]
          end
        end
      end
    end
  end

  private

  # Variation on the find shortest path algorithm from graph theory, with some
  #   additional parameters: compare (the comparison method to use), trip (the summary
  #   data built-up for the best trip), and flight (full data for the current node)
  def self.find_best_trip(graph, from, to, compare, path = [], trip = nil, flight = nil)
    path << from
    trip = { depart: nil, arrive: 0, price: 0 } if trip.nil? # Initialize trip summary
    unless flight.nil?
      # Add on to the trip summary with flight data from the current node in the graph
      trip[:depart] = flight[:depart] if trip[:depart].nil?
      trip[:arrive] = flight[:arrive]
      trip[:price] += flight[:price]
    end
    return trip if from == to # Reached the destination node so return the trip summary
    best_trip = nil
    graph[from].each do |flight|
      # Try each valid path through the graph, potentially selecting a new best trip 
      unless path.include?(flight[:to]) || flight[:depart] < trip[:arrive]
        new_trip  = find_best_trip(graph, flight[:to], to, compare, path.dup, trip.dup, flight)
        best_trip = send(compare, new_trip, best_trip)
      end
    end
    best_trip
  end

  # Comparision method for determing the cheaper of two trips
  def self.cheapest_trip(trip1, trip2)
    return trip1 if trip2.nil?
    return trip2 if trip1.nil?
    case trip1[:price] <=> trip2[:price]
      when -1 then trip1
      when  0 then fastest_trip(trip1, trip2) # Pick faster trip if same price
      when  1 then trip2
    end
  end

  # Comparision method for determing the faster of two trips
  def self.fastest_trip(trip1, trip2)
    return trip1 if trip2.nil?
    return trip2 if trip1.nil?
    case trip1[:arrive] - trip1[:depart] <=> trip2[:arrive] - trip2[:depart]
      when -1 then trip1
      when  0 then cheapest_trip(trip1, trip2) # Pick cheaper trip if same time
      when  1 then trip2
    end
  end
end

if $0 == __FILE__
  if ARGV.size == 2
    FlightOptimizer.run(ARGV[0], :A, :Z, ARGV[1])
  else
    puts 'Usage:   ruby cheap_tourist_fast_tourist.rb [inputfile] [outputfile]'
    puts 'Example: ruby cheap_tourist_fast_tourist.rb input.txt output.txt'
    puts 'Testing: rspec cheap_tourist_fast_tourist.rb'
  end
else
  describe FlightOptimizer do
    it 'should create an output file that matches the sample output file' do
      FlightOptimizer.run('sample-input.txt', :A, :Z, 'output.txt')
      File.read('output.txt').should == File.read('sample-output.txt')
    end
  end
end
