require "./spec_helper"

describe Carbon::Address do
  it "accepts just an address or a name and address" do
    address = Carbon::Address.new("hi@example.com")
    address.name.should be_nil
    address.address.should eq "hi@example.com"

    address = Carbon::Address.new("Hello", "hi@example.com")
    address.name.should eq "Hello"
    address.address.should eq "hi@example.com"
  end

  it "compares addresses based on name and address" do
    address = Carbon::Address.new("Hello", "hi@example.com")
    matching_address = Carbon::Address.new("Hello", "hi@example.com")
    non_matching_address = Carbon::Address.new("Bye", "hi@example.com")

    address.should eq matching_address
    address.should_not eq non_matching_address
  end
end
