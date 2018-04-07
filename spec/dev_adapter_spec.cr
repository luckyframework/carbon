require "./spec_helper"

describe Carbon::DevAdapter do
  it "stores emails in memory" do
    adapter = Carbon::DevAdapter.new
    Carbon::DevAdapter.delivered_emails.size.should eq 0

    adapter.deliver_now(FakeEmail.new(subject: "First one"))
    adapter.deliver_now(FakeEmail.new(subject: "Second one"))

    Carbon::DevAdapter.delivered_emails.size.should eq 2
    Carbon::DevAdapter.delivered_emails.first.subject.should eq "First one"
    Carbon::DevAdapter.delivered_emails[1].subject.should eq "Second one"
  end

  it "can check for delivered emails" do
    adapter = Carbon::DevAdapter.new
    email = FakeEmail.new(subject: "Sent email")
    unsent_email = FakeEmail.new(subject: "Unsent email")
    Carbon::DevAdapter.delivered?(email).should be_false

    adapter.deliver_now(email)

    Carbon::DevAdapter.delivered?(email).should be_true
    Carbon::DevAdapter.delivered?(unsent_email).should be_false
  end
end
