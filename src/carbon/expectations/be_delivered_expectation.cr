struct Carbon::Expectations::BeDeliveredExpectation
  def match(email : Carbon::Email) : Bool
    Carbon::DevAdapter.delivered?(email)
  end

  def failure_message(email)
    FailureMessage.new(email).build
  end

  def negative_failure_message(email)
    "Expected: #{email} not to be delivered"
  end
end
