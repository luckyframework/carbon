require "./spec_helper"

describe "SendGrid adapter" do
  {% unless flag?("skip-integration") %}
    describe "deliver_now" do
      it "delivers the email successfully" do
        email = fake_email text_body: "text template",
          to: [Carbon::Address.new("foo@example.com")]
        adapter = Carbon::SendGridAdapter.new(api_key: "")
        adapter.deliver_now(email)
      end
    end
  {% end %}

  describe "params" do
    it "sets personalizations" do
      to_without_name = Carbon::Address.new("to@example.com")
      to_with_name = Carbon::Address.new("Jimmy", "to2@example.com")
      cc_without_name = Carbon::Address.new("cc@example.com")
      cc_with_name = Carbon::Address.new("Kim", "cc2@example.com")
      bcc_without_name = Carbon::Address.new("bcc@example.com")
      bcc_with_name = Carbon::Address.new("James", "bcc2@example.com")

      recipient_params = params_for(
        to: [to_without_name, to_with_name],
        cc: [cc_without_name, cc_with_name],
        bcc: [bcc_without_name, bcc_with_name]
      )[:personalizations].first

      recipient_params[:to].should eq(
        [
          {name: nil, email: "to@example.com"},
          {name: "Jimmy", email: "to2@example.com"},
        ]
      )
      recipient_params[:cc].should eq(
        [
          {name: nil, email: "cc@example.com"},
          {name: "Kim", email: "cc2@example.com"},
        ]
      )
      recipient_params[:bcc].should eq(
        [
          {name: nil, email: "bcc@example.com"},
          {name: "James", email: "bcc2@example.com"},
        ]
      )
    end

    it "removes empty recipients from personalizations" do
      to_without_name = Carbon::Address.new("to@example.com")

      recipient_params = params_for(to: [to_without_name])[:personalizations].first

      recipient_params.keys.should eq [:to]
      recipient_params[:to].should eq [{name: nil, email: "to@example.com"}]
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
      params_for(text_body: "text")[:content].should eq [{type: "text/plain", value: "text"}]
      params_for(html_body: "html")[:content].should eq [{type: "text/html", value: "html"}]
      params_for(text_body: "text", html_body: "html")[:content].should eq [
        {type: "text/plain", value: "text"},
        {type: "text/html", value: "html"},
      ]
    end
  end
end

private class FakeEmail < Carbon::Email
  getter text_body, html_body

  def initialize(
    @from = Carbon::Address.new("from@example.com"),
    @to = [] of Carbon::Address,
    @cc = [] of Carbon::Address,
    @bcc = [] of Carbon::Address,
    @subject = "subject",
    @text_body : String? = nil,
    @html_body : String? = nil
  )
  end

  from @from
  to @to
  cc @cc
  bcc @bcc
  subject @subject
end

private def params_for(**email_attrs)
  email = fake_email(**email_attrs)
  Carbon::SendGridAdapter::Email.new(email, api_key: "fake_key").params
end

private def fake_email(**email_attrs)
  FakeEmail.new(**email_attrs)
end
