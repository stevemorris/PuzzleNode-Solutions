require 'json'
require 'date'
require 'money'

class Rental < Hash
  SALES_TAX = 0.0411416
  
  def initialize(rental)
    self[:name] = rental['name']
    year = Time.now.year.to_s
    if rental.has_key?('seasons')
      seasons = rental['seasons'].sort do |a, b|
        a.values.first['start'] <=> b.values.first['start']
      end
      self[:seasons] = seasons.collect do |season_hash|
        season     = season_hash.values.first
        start_date = "#{year}-#{season['start']}"
        year.succ! if season['end'] < season['start']
        end_date   = "#{year}-#{season['end']}"
        { :start => Date.parse(start_date),
          :end   => Date.parse(end_date),
          :rate  => Money.parse(season['rate']) }
      end
    else
      self[:seasons] = [ { :start => Date.parse("#{year}-01-01"),
                           :end   => Date.parse("#{year}-12-31"),
                           :rate  => Money.parse(rental['rate']) } ]
    end
    cleaning_fee = rental.has_key?('cleaning fee') ? rental['cleaning fee'] : '$0'
    self[:cleaning_fee] = Money.parse(cleaning_fee)
  end
  
  def cost(start_date, end_date)
    first = start_date
    last  = end_date - 1
    total = self[:seasons].inject(Money.new(0, 'USD')) do |sum, season|
      days = season_days(season, first, last)
      sum + (season[:rate] * days)
    end
    total += self[:cleaning_fee]
    total *= (1 + SALES_TAX)
    total.format(:thousands_separator => false)
  end
  
  def season_days(season, first, last)
    return 0 if first > season[:end] || last < season[:start]
    first = season[:start] if first < season[:start]
    last  = season[:end] if last > season[:end]
    (last - first).to_i + 1
  end
end

json = []
File.open('vacation_rentals.json', 'r') { |f| json = JSON.parse(f.read) }
rentals = json.collect { |rental| Rental.new(rental) }

start_date = end_date = ''
File.open('input.txt', 'r') { |f| start_date, end_date = f.read.split(' - ') }
start_date = Date.parse(start_date)
end_date   = Date.parse(end_date)

File.open('output.txt', 'w') do |f|
  rentals.each_with_index do |rental, i|
    f.write("\n") if i > 0
    f.write "#{rental[:name]}: #{rental.cost(start_date, end_date)}"
  end
end
