module Carbon::Emailable
  private abstract def emailable : Carbon::Address | String

  # Adapter's should use this to get the Carbon::Address
  def carbon_address : Carbon::Address
    ensure_carbon_address(emailable)
  end

  # Adapter's should use this to get the Carbon::Address when used for 'from'
  def carbon_address_for_from : Carbon::Address
    ensure_carbon_address(emailable_for_from)
  end

  private def emailable_for_from
    emailable
  end

  private def ensure_carbon_address(value : Carbon::Address) : Carbon::Address
    value
  end

  private def ensure_carbon_address(value : String)
    {%
      raise <<-ERROR

      #{@type}#emailable returned String, but it must return a Carbon::Address

      Try this...

        ▸ Carbon::Address.new("person@gmail.com")
      ERROR
    %}
  end

  private def ensure_carbon_address(value : T) forall T
    {%
      raise <<-ERROR

      #{@type}#emailable returned #{T}, but it must return a Carbon::Address

      Try this...

        ▸ Carbon::Address.new(name: "Name", address: "person@gmail.com")
      ERROR
    %}
  end
end
