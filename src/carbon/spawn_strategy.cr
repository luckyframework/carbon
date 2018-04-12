class Carbon::SpawnStrategy < Carbon::DeliverLaterStrategy
  def run(email, &block)
    spawn do
      block.call
    end
  end
end
