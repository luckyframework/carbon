require "./spec_helper"

private class User
  include Carbon::Emailable

  def emailable : Carbon::Address
    Carbon::Address.new("user@example.com")
  end
end

private class BareMinimumEmail < Carbon::Email
  subject "My great subject"
  from Carbon::Address.new("from@example.com")
  to Carbon::Address.new("to@example.com")
end

private class EmailWithTemplates < BareMinimumEmail
  templates text, html
end

private module Namespaced
  class EmailWithTemplates < BareMinimumEmail
    templates text, html
  end
end

private class CustomizedRecipientsEmail < BareMinimumEmail
  cc "cc@example.com"
  bcc ["bcc@example.com"]
end

private class EmailWithEmailables < Carbon::Email
  from "from@example.com"
  to User.new
  subject "Doesn't matter"
end

private class EmailWithAttributes < BareMinimumEmail
  header "Custom-Header", header_value
  from "from@example.com"
  reply_to "reply_to@example.com"

  private def header_value
    "header_value"
  end
end

private class EmailWithCustomAttributes < Carbon::Email
  from :custom_from
  to :custom_to
  cc :custom_cc
  bcc :custom_bcc
  subject :custom_subject

  private def custom_from
    "from@example.com"
  end

  private def custom_to
    "to@example.com"
  end

  private def custom_cc
    "cc@example.com"
  end

  private def custom_bcc
    "bcc@example.com"
  end

  private def custom_subject
    "custom subject"
  end
end

describe Carbon::Email do
  it "can build a bare minimum email" do
    email = BareMinimumEmail.new

    email.subject.should eq "My great subject"
    email.from.should eq Carbon::Address.new("from@example.com")
    email.to.should eq [Carbon::Address.new("to@example.com")]
    email.headers.should eq({} of String => String)
  end

  it "recipients can be customized" do
    email = CustomizedRecipientsEmail.new

    email.cc.should eq [Carbon::Address.new("cc@example.com")]
    email.bcc.should eq [Carbon::Address.new("bcc@example.com")]
    email.headers.should eq({} of String => String)
  end

  it "can use Emailables" do
    email = EmailWithEmailables.new

    email.from.should eq Carbon::Address.new("from@example.com")
    email.to.should eq [Carbon::Address.new("user@example.com")]
  end

  it "can render templates" do
    email = EmailWithTemplates.new

    email.text_body.should contain "text template"
    email.html_body.should contain "html template"
  end

  it "can render templates on a namespaced class" do
    email = Namespaced::EmailWithTemplates.new

    email.text_body.should contain "namespaced text template"
    email.html_body.should contain "namespaced html template"
  end

  it "can customize headers" do
    email = EmailWithAttributes.new
    email.headers["Custom-Header"].should eq "header_value"
  end

  it "has a shortcut for setting reply-to" do
    email = EmailWithAttributes.new
    email.headers["Reply-To"].should eq "reply_to@example.com"
  end

  it "can use symbols to call methods" do
    email = EmailWithCustomAttributes.new

    email.from.should eq Carbon::Address.new("from@example.com")
    email.to.should eq [Carbon::Address.new("to@example.com")]
    email.cc.should eq [Carbon::Address.new("cc@example.com")]
    email.bcc.should eq [Carbon::Address.new("bcc@example.com")]
    email.subject.should eq "custom subject"
    email.headers.should eq({} of String => String)
  end

  it "normalizes recipients" do
  end
end
