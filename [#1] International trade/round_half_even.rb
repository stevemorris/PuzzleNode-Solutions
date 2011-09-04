# As mentioned in the problem description at http://puzzlenode.com/puzzles/2, there's a
#   a bug with BigDecimal rounding in Ruby 1.9.2. To get around this bug, I created a
#   round_half_even method and extended the Float class. This file should be required
#   from international_trade.rb for the solution to run correctly.
#
# The round_half_even method below works, but it's a bit of a hack. I convert the float
#   to a string to do the rounding, then back to a float. This is a temporary workaround
#   until the bug is fixed in BigDecimal, hopefully with the release of Ruby 1.9.3, so I
#   won't worry too much about the approach.
#
# To show the round_half_even method works correctly, run 'rspec round_half_even.rb' from
#   the command line. I've adapted these specs from ones posted on GitHub by Shane Emmons:
#   https://github.com/semmons99/rubyspec/blob/540a7ca56d35673ccde118875d38e933a5a4894d/library/bigdecimal/round_spec.rb

class Float
  def round_half_even(ndigits = 2)
    raise ArgumentError, 'ndigits must be a positive' if ndigits < 0
    value, remainder = self.to_s.split('.')
    remainder += '0'*(ndigits - remainder.size) if ndigits > remainder.size
    value += remainder.slice!(0, ndigits)
    round_up = (remainder =~ /^50*$/) ? value[-1].to_i.odd? : remainder[0].to_i >= 5
    value = value.to_i
    value += (value >= 0 ? 1 : -1) if round_up
    value.to_f / 10**ndigits
  end
end

require 'rspec'

describe "Float::round_half_even" do
  it "rounds values > 5 up, < 5 down and == 5 towards even neighbor" do
     1.50.round_half_even(0).should ==  2.0
     1.51.round_half_even(0).should ==  2.0
     1.49.round_half_even(0).should ==  1.0
    -1.50.round_half_even(0).should == -2.0
    -1.51.round_half_even(0).should == -2.0
    -1.49.round_half_even(0).should == -1.0
     2.50.round_half_even(0).should ==  2.0
     2.51.round_half_even(0).should ==  3.0
     2.49.round_half_even(0).should ==  2.0
    -2.50.round_half_even(0).should == -2.0
    -2.51.round_half_even(0).should == -3.0
    -2.49.round_half_even(0).should == -2.0
  end
end
