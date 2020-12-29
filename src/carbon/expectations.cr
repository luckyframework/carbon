require "./expectations/*"

module Carbon::Expectations
  private def be_delivered
    BeDeliveredExpectation.new
  end

  private def have_delivered_emails
    HaveDeliveredEmailsExpectation.new
  end
end
