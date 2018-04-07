require "./spec_helper"

describe Carbon::DevAdapter do
  it "stores emails in memory" do
    adapter = Carbon::DevAdapter.new
    Carbon::DevAdapter.delivered_emails.size.should eq 0

    adapter.deliver_now(FakeEmail.new(subject: "First one"))
    adapter.deliver_now(FakeEmail.new(subject: "Second one"))

    Carbon::DevAdapter.delivered_emails.size.should eq 2
    Carbon::DevAdapter.delivered_emails[1].subject.should eq "First one"
    Carbon::DevAdapter.delivered_emails[1].subject.should eq "Second one"
  end
end
