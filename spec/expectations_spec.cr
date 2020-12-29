require "./spec_helper"

include Carbon::Expectations

describe Carbon::Expectations do
  describe "#be_delivered" do
    it "can check for delivered emails" do
      adapter = Carbon::DevAdapter.new
      email = FakeEmail.new(subject: "Sent email")
      other_email = FakeEmail.new(subject: "Other email")
      email.should_not be_delivered

      adapter.deliver_now(email)

      email.should be_delivered
      other_email.should_not be_delivered
    end
  end

  describe "#have_delivered_emails" do
    it "can check that emails were not sent" do
      Carbon.should_not have_delivered_emails
    end

    it "can check that emails were sent" do
      adapter = Carbon::DevAdapter.new
      email = FakeEmail.new(subject: "Sent email")

      adapter.deliver_now(email)

      Carbon.should have_delivered_emails
    end
  end
end
