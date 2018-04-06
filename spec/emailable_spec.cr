require "./spec_helper"

private class User
  include Carbon::Emailable

  def carbon_address
    "user@example.com"
  end
end

describe Carbon::Emailable do
  it "requires carbon_address" do
    User.new.carbon_address.should eq "user@example.com"
  end

  it "defines a default carbon_address_for_from" do
    user = User.new
    user.carbon_address_for_from.should eq user.carbon_address
  end
end
