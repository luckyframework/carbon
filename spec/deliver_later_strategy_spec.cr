require "./spec_helper"

private class CustomDeliverLaterStrategy < Carbon::DeliverLaterStrategy
  property? sent : Bool = false

  def run(email : Carbon::Email, &block)
    self.sent = true
    block.call
  end
end

private abstract class CustomizedBaseEmail < Carbon::Email
end

private class CustomizedEmail < CustomizedBaseEmail
  subject "Test"
  from "test@example.com"
  to "to@example.com"
end

describe "Deliver later strategy" do
  it "can be customized" do
    strategy = CustomDeliverLaterStrategy.new
    use_custom_strategy(strategy)
    strategy.sent?.should be_false

    CustomizedEmail.new.deliver_later

    strategy.sent?.should be_true
  end
end

private def use_custom_strategy(strategy)
  CustomizedBaseEmail.configure do |settings|
    settings.adapter = Carbon::DevAdapter.new
    settings.deliver_later_strategy = strategy
  end
end
