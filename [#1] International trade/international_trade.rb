# Ruby solution to PuzzleNode problem #1: International trade
# Given an XML file with currency conversions and a CSV file of sales transactions
#   from various stores in different countries, find the total sales in US dollars
#   for a particular item.
# see http://puzzlenode.com/puzzles/2 for problem details
#
# Usage:   ruby international_trade.rb [transfile] [ratesfile] [outputfile]
# Example: ruby international_trade.rb TRANS.csv RATES.xml OUTPUT.txt
# Testing: rspec international_trade.rb
#
# Solution notes: The class Transactions initialize method reads and parses the
#   specified sales transactions CSV file (using the CSV library) and the specified
#   currency exchange rates file (using the Nokogiri gem). The output_total method
#   calculates the total sales for an item (DM1182) in a target currency (USD), and
#   then writes the total to the specified output file. The most complex aspect of
#   the solution is finding the sequence of rates that converts a transaction from
#   the sales currency to the target currency. The find_rates_path mmethod returns
#   this sequence, using a find shortest path recursive algorithim from graph theory.
#   Each returned sequence (or path) is multiplied together and cached via memoization
#   in the conversion hash. Then the converted transaction amount is rounded using the
#   round_half_even method (see round_half_even.rb for details on this method).

require 'csv'
require 'nokogiri'
require './round_half_even'

class Transactions
  def initialize(trans_filename, rates_filename)
    @transactions = []
    CSV.foreach(trans_filename, headers: true) do |row|
      amount, currency = row['amount'].split
      @transactions << { store: row['store'].to_sym, sku: row['sku'].to_sym,
        amount: amount.to_f, currency: currency.to_sym }
    end
    @rates = {}
    Nokogiri::XML(File.open(rates_filename)).css('rate').each do |node|
      from = node.css('from').text.to_sym
      @rates[from] ||= []
      @rates[from] << [node.css('to').text.to_sym, node.css('conversion').text.to_f]
    end
  end

  def output_total(sku, to, filename)
    total = 0.0
    conversions = {}
    @transactions.each do |transaction|
      next unless transaction[:sku] == sku
      from = transaction[:currency]
      conversions[[from, to]] ||= find_rates_path([from, 1.0], to).reduce(:*)
      total += (transaction[:amount] * conversions[[from, to]]).round_half_even
    end
    File.open(filename, 'w') { |f| f.puts total.round(2) }
  end

  private

  def find_rates_path(node, finish, path = [])
    path << node
    return path.collect { |node| node.last } if node.first == finish
    shortest = nil
    @rates[node.first].each do |newnode|
      unless path.include?(newnode)
        newpath = find_rates_path(newnode, finish, path.dup)
        shortest = newpath if shortest.nil? || newpath.length < shortest.length
      end
    end
    shortest
  end
end

if $0 == __FILE__
  if ARGV.size == 3
    transactions = Transactions.new(ARGV[0], ARGV[1])
    transactions.output_total(:DM1182, :USD, ARGV[2])
  else
    puts 'Usage:   ruby international_trade.rb [transfile] [ratesfile] [outputfile]'
    puts 'Example: ruby international_trade.rb TRANS.csv RATES.xml OUTPUT.txt'
    puts 'Testing: rspec international_trade.rb'
  end
else
  describe Transactions do
    it 'should create an output file that matches the sample output file' do
      transactions = Transactions.new('SAMPLE_TRANS.csv', 'SAMPLE_RATES.xml')
      transactions.output_total(:DM1182, :USD, 'OUTPUT.txt')
      File.read('OUTPUT.txt').should == File.read('SAMPLE_OUTPUT.txt')
    end
  end
end
