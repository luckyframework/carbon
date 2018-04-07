module Carbon::Expectations
  struct BeDeliveredExpectation
    def match(email : Carbon::Email) : Bool
      Carbon::DevAdapter.delivered?(email)
    end

    def failure_message(email)
      "Expected: #{email} to be delivered"
    end

    def negative_failure_message(email)
      "Expected: #{email} not to be delivered"
    end
  end

  private def be_delivered
    BeDeliveredExpectation.new
  end
end
