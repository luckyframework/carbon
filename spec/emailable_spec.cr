require "./spec_helper"

private class User
  include Carbon::Emailable

  def carbon_address
    "user@example.com"
  end
end

private class EmailWithEmailables < Carbon::Email
  from "from@example.com"
  to User.new
  subject "Doesn't matter"
end

describe Carbon::Emailable do
  it "can use a standard String" do
    email = EmailWithEmailables.new

    # TODO: Should normalize getting the `from` address
    email.from.should eq "from@example.com"
    email.to.should eq Carbon::Address.new("user@example.com")
  end
end
