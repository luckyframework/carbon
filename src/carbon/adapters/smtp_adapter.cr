require "email"

class Carbon::SMTPAdapter < Carbon::Adapter
  @client : EMail::Client?

  def initialize(@config : EMail::Client::Config)

  end

  def client :  EMail::Client
    @client ||= EMail::Client.new(@config)
  end

  def self.carbon_email_to_crystal_email( email : Carbon::Email)
    output = EMail::Message.new
    output.from EMail::Address.new(email.from.address, email.from.name)

    email.to.each do |dest|
      output.to EMail::Address.new(dest.address, dest.name)
    end

    output.subject email.subject

    email.cc.each do |carbon_copy_dest|
      output.cc EMail::Address.new(carbon_copy_dest.address, carbon_copy_dest.name)
    end

    email.bcc.each do |hidden_carbon_copy_dest|
      output.cc EMail::Address.new(hidden_carbon_copy_dest.address, hidden_carbon_copy_dest.name)
    end

    if text_body = email.text_body
      output.message text_body
    end

    if html_body = email.html_body
      output.message_html html_body
    end

    email.headers.each do |key, value|
      output.custom_header key, value
    end

    output
  end

  def deliver_now(email : Carbon::Email)
    client.start do
      send Carbon::SMTPAdapter.carbon_email_to_crystal_email(email)
    end
  end

end