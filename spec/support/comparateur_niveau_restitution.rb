RSpec::Matchers.define :evalue_a do |expected|
  match do |actual|
    actual.niveau == expected
  end

  failure_message do |actual|
    "expected that #{actual.niveau.inspect} to equal #{expected}"
  end
end
