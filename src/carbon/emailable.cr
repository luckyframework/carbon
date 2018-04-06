module Carbon::Emailable
  abstract def carbon_address : Carbon::Address

  def carbon_address_for_from
    carbon_address
  end
end
