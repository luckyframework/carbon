require "./spec_helper"

private class BareMinimumEmail < Carbon::Email
  subject "My great subject"
  from Carbon::Address.new("from@example.com")
  to Carbon::Address.new("to@example.com")
end

private class CustomizedRecipientsEmail < BareMinimumEmail
end

describe Carbon::Email do
  it "can build a bare minimum email" do
    email = BareMinimumEmail.new

    email.subject.should eq "My great subject"
    email.from.should eq Carbon::Address.new("from@example.com")
    email.to.should eq Carbon::Address.new("to@example.com")
  end

  it "recipients can be customized" do
    email = CustomizedRecipientsEmail.new

    email.subject.should eq "My great subject"
    email.from.should eq Carbon::Address.new("from@example.com")
    email.to.should eq Carbon::Address.new("to@example.com")
  end

  it "can use Carbon::Emailable in from and recipients" do
  end

  it "can render templates" do
  end

  it "can customize headers" do
  end

  it "has a shortcut for setting reply-to" do
  end

  it "can use symbols to render methods" do
  end

  it "normalizes recipients" do
  end
end
