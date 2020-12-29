require "./expectations/failure_message"
require "./expectations/*"

module Carbon::Expectations
  private def be_delivered
    BeDeliveredExpectation.new
  end
end
