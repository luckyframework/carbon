require "./spec_helper"

private class BareMinimumEmail < Carbon::Email
  subject "My great subject"
  from Carbon::Address.new("from@example.com")
  to Carbon::Address.new("to@example.com")
end

describe Carbon::Email do
  it "can build a bare minimum email" do
    email = BareMinimumEmail.new

    email.subject.should eq "My great subject"
    email.from.should eq Carbon::Address.new("from@example.com")
    email.to.should eq Carbon::Address.new("to@example.com")
  end
end
