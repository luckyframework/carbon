require "./spec_helper"

private class User
  include Carbon::Emailable

  private def emailable : Carbon::Address
    Carbon::Address.new("user@example.com")
  end

  private def emailable_for_from
    Carbon::Address.new("User's Name", "user@example.com")
  end
end

private class UserWithoutEmailableForFrom
  include Carbon::Emailable

  private def emailable : Carbon::Address
    Carbon::Address.new("user@example.com")
  end
end

describe Carbon::Emailable do
  it "carbon_address returns the emailable" do
    User.new.carbon_address.should eq Carbon::Address.new("user@example.com")
  end

  it "carbon_address_for_from returns the emailable" do
    User.new.carbon_address_for_from.should eq Carbon::Address.new("User's Name", "user@example.com")
  end

  it "provides a default carbon_address_for_from" do
    UserWithoutEmailableForFrom.new.carbon_address_for_from.should eq Carbon::Address.new("user@example.com")
  end
end
