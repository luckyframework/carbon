require "./spec_helper"

abstract class BaseTestEmail < Carbon::Email
  subject "My great subject"
  from Carbon::Address.new("from@example.com")
  to Carbon::Address.new("to@example.com")
end

BaseTestEmail.configure do |setting|
  setting.adapter = Carbon::DevAdapter.new
end

private class EmailWithBeforeCallbacks < BaseTestEmail
  property ran_before_callback : Bool = false

  before_send do
    self.ran_before_callback = true
  end
end

private class EmailWithAfterCallbacks < BaseTestEmail
  property ran_after_callback : Bool = false

  after_send do |_response|
    self.ran_after_callback = true
  end
end

private class EmailWithBothBeforeAndAfterCallbacks < BaseTestEmail
  property ran_before_callback : Bool = false
  property ran_after_callback : Bool = false

  before_send :mark_before_send
  after_send :mark_after_send

  private def mark_before_send
    self.ran_before_callback = true
  end

  private def mark_after_send(_response)
    self.ran_after_callback = true
  end
end

private class EmailUsingBeforeToStopSending < BaseTestEmail
  before_send :dont_actually_send
  after_send :never_actually_ran

  property ran_after_callback : Bool = false

  private def dont_actually_send
    @deliverable = false
  end

  private def never_actually_ran(_response)
    self.ran_after_callback = true
  end
end

describe "before/after callbacks" do
  context "before an email is sent" do
    it "runs the before_send callback" do
      email = EmailWithBeforeCallbacks.new
      email.ran_before_callback.should eq(false)
      email.deliver
      Carbon.should have_delivered_emails

      email.ran_before_callback.should eq(true)
    end
  end

  context "after an email is sent" do
    it "runs the after_send callback" do
      email = EmailWithAfterCallbacks.new
      email.ran_after_callback.should eq(false)
      email.deliver
      Carbon.should have_delivered_emails

      email.ran_after_callback.should eq(true)
    end
  end

  context "running both callbacks" do
    it "runs both callbacks" do
      email = EmailWithBothBeforeAndAfterCallbacks.new
      email.ran_before_callback.should eq(false)
      email.ran_after_callback.should eq(false)
      email.deliver
      Carbon.should have_delivered_emails

      email.ran_before_callback.should eq(true)
      email.ran_after_callback.should eq(true)
    end
  end

  context "Halting the deliver before it's sent" do
    it "never sends" do
      email = EmailUsingBeforeToStopSending.new
      email.deliver
      Carbon.should_not have_delivered_emails
      email.deliverable?.should eq(false)
      email.ran_after_callback.should eq(false)
    end
  end
end
