abstract class Carbon::Adapter
  abstract def deliver_now(email : Carbon::Email)
end
