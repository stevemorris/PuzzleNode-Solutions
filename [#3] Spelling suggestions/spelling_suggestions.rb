# Ruby solution to PuzzleNode problem #3: Spelling suggestions
# Given a misspelled search query and two candidate dictionary words, return the candidate
#   dictionary word that has the longest common subsequence with the search query word.
# see http://puzzlenode.com/puzzles/4 for problem details
#
# Usage:   ruby spelling_suggestions.rb [inputfile] [outputfile]
# Example: ruby spelling_suggestions.rb INPUT.txt OUTPUT.txt
# Testing: rspec spelling_suggestions.rb
#
# Solution notes: The class SpellingSuggester initialize method reads each test case
#   from the specified input file, and calls the longest_common_subsequence method
#   to determine the best dictionary word. The longest_common_subsequence method is
#   a Ruby translation of the algorithim described at
#   http://en.wikipedia.org/wiki/Longest_common_subsequence_problem.
#   Finally, the output method writes the resulting words to the specified output file.
#   On my laptop, this program executes the ten test cases (including some extremely
#   complex words) in less than 1/10 of a second total, so I didn't see the need to
#   further optimize the program.

class SpellingSuggester
  def initialize(filename)
    @results = []
    File.open(filename, 'r') do |f|
      f.gets.to_i.times do |n|
        f.gets
        original   = f.gets.rstrip
        candidate1 = f.gets.rstrip
        candidate2 = f.gets.rstrip
        subsequence1_length = longest_common_subsequence(original, candidate1)
        subsequence2_length = longest_common_subsequence(original, candidate2)
        @results << (subsequence1_length > subsequence2_length ? candidate1 : candidate2)
      end
    end
  end

  def output(filename)
    File.open(filename, 'w') do |f|
      @results.each { |result| f.puts result }
    end
  end

  private

  def longest_common_subsequence(string1, string2)
    cols = string1.length + 1
    rows = string2.length + 1
    table = rows.times.collect { Array.new(cols, 0) }
    (1..(cols-1)).each do |col|
      (1..(rows-1)).each do |row|
        if string1[col-1] == string2[row-1]
          table[row][col] = table[row-1][col-1] + 1
        else
          table[row][col] = [table[row][col-1], table[row-1][col]].max
        end
      end
    end
    table[rows-1][cols-1]
  end
end

if $0 == __FILE__
  if ARGV.size == 2
    spelling_suggester = SpellingSuggester.new(ARGV[0])
    spelling_suggester.output(ARGV[1])
  else
    puts 'Usage:   ruby spelling_suggestions.rb [inputfile] [outputfile]'
    puts 'Example: ruby spelling_suggestions.rb INPUT.txt OUTPUT.txt'
    puts 'Testing: rspec spelling_suggestions.rb'
  end
else
  describe SpellingSuggester do
    it 'should create an output file that matches the sample output file' do
      spelling_suggester = SpellingSuggester.new('SAMPLE_INPUT.txt')
      spelling_suggester.output('OUTPUT.txt')
      File.read('OUTPUT.txt').should == File.read('SAMPLE_OUTPUT.txt')
    end
  end
end
