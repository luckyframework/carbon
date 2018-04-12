require "./spec_helper"

describe "SendGrid adapter" do
  {% unless flag?("skip-integration") %}
    describe "deliver_now" do
      it "delivers the email successfully" do
        send_email_to_send_grid text_body: "text template",
          to: [Carbon::Address.new("paul@thoughtbot.com")]
      end

      it "delivers emails with reply_to set" do
        send_email_to_send_grid text_body: "text template",
          to: [Carbon::Address.new("paul@thoughtbot.com")],
          headers: {"Reply-To" => "noreply@badsupport.com"}
      end
    end
  {% end %}

  describe "params" do
    it "is not sandboxed by default" do
      params_for[:mail_settings][:sandbox_mode][:enable].should be_false
    end

    it "handles headers" do
      headers = {"Header1" => "value1", "Header2" => "value2"}
      params = params_for(headers: headers)

      params[:headers].should eq headers
    end

    it "sets extracts reply-to header" do
      headers = {"reply-to" => "noreply@badsupport.com", "Header" => "value"}
      params = params_for(headers: headers)

      params[:headers].should eq({"Header" => "value"})
      params[:reply_to].should eq({email: "noreply@badsupport.com"})
    end

    it "sets extracts reply-to header regardless of case" do
      headers = {"Reply-To" => "noreply@badsupport.com", "Header" => "value"}
      params = params_for(headers: headers)

      params[:headers].should eq({"Header" => "value"})
      params[:reply_to].should eq({email: "noreply@badsupport.com"})
    end

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

private def params_for(**email_attrs)
  email = FakeEmail.new(**email_attrs)
  Carbon::SendGridAdapter::Email.new(email, api_key: "fake_key").params
end

private def send_email_to_send_grid(**email_attrs)
  api_key = ENV.fetch("SEND_GRID_API_KEY")
  email = FakeEmail.new(**email_attrs)
  adapter = Carbon::SendGridAdapter.new(api_key: api_key, sandbox: true)
  adapter.deliver_now(email)
end
