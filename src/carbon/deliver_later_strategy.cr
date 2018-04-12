abstract class Carbon::DeliverLaterStrategy
  abstract def run(email : Carbon::Email, &block)
end
