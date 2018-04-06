require "./spec_helper"

private class User
  include Carbon::Emailable

  def carbon_address
    "user@example.com"
  end
end

describe Carbon::Emailable do
  pending "requires carbon_address" do
    User.new.should eq(Carbon::Address)
  end
end
