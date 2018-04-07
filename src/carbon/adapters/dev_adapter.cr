class Carbon::DevAdapter < Carbon::Adapter
  class_getter delivered_emails = [] of Carbon::Email

  def deliver_now(email : Carbon::Email)
    @@delivered_emails << email
  end
end
