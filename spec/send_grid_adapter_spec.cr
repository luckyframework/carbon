require "./spec_helper"

describe "SendGrid adapter" do
  describe "params" do
    it "sets personalizations" do
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
    @to = Carbon::Address.new("to@example.com"),
    @cc = Carbon::Address.new("cc@example.com"),
    @bcc = Carbon::Address.new("bcc@example.com"),
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
