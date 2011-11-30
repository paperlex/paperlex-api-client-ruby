module CustomExpectations
  def be_boolean
    satisfy {|v| [true, false].include?(v) }
  end
end

RSpec.configure do |c|
  c.include CustomExpectations
end
