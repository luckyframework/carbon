require "./spec_helper"

describe "SendGrid adapter" do
  describe "params" do
    it "sets personalizations" do
      address = Carbon::Address.new("to@example.com")
      address_2 = Carbon::Address.new("Jimmy", "to2@example.com")
      params_for(to: [address, address_2])[:personalizations].should eq(
        [
          {:to => [{name: nil, email: "to@example.com"},
                   {name: "Jimmy", email: "to2@example.com"}]},
        ]
      )
    end

    it "sets the subject" do
      params_for(subject: "My subject")[:subject].should eq "My subject"
    end

    it "sets the from address" do
      address = Carbon::Address.new("from@example.com")
      params_for(from: address)[:from].should eq({email: "from@example.com"}.to_h)

      address = Carbon::Address.new("Sally", "from@example.com")
      params_for(from: address)[:from].should eq({name: "Sally", email: "from@example.com"}.to_h)
    end

    it "sets the content" do
    end
  end
end

private class FakeEmail < Carbon::Email
  def initialize(
    @from = Carbon::Address.new("from@example.com"),
    @to = [] of Carbon::Address,
    @cc = [] of Carbon::Address,
    @bcc = [] of Carbon::Address,
    @subject = "subject",
    @text_body = "text body",
    @html_body = "html body"
  )
  end

  from @from
  to @to
  cc @cc
  bcc @bcc
  subject @subject
end

private def params_for(**email_attrs)
  email = FakeEmail.new(**email_attrs)
  Carbon::SendGridAdapter::Email.new(email, api_key: "fake_key").params
end
