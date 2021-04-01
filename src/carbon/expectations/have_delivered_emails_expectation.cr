class Carbon::Expectations::HaveDeliveredEmailsExpectation
  def match(_carbon : Carbon.class) : Bool
    !Carbon::DevAdapter.delivered_emails.empty?
  end

  def failure_message(_carbon : Carbon.class)
    "Expected: Carbon to have delivered emails, but found none"
  end

  def negative_failure_message(_carbon : Carbon.class)
    "Expected: Carbon to have no delivered emails, but found some"
  end
end
