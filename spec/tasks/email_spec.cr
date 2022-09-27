require "../spec_helper"

include CleanupHelper

describe Gen::Email do
  it "generates a new email" do
    with_cleanup do
      generator = Gen::Email.new
      generator.output = IO::Memory.new
      generator.print_help_or_call ["PasswordReset"]

      generator.output.to_s.should contain("src/emails/templates/password_reset_email/html.ecr")
    end
  end

  it "doesn't duplicate the word Email" do
    with_cleanup do
      generator = Gen::Email.new
      generator.output = IO::Memory.new
      generator.print_help_or_call ["WelcomeUserEmail"]

      generator.output.to_s.should contain("src/emails/templates/welcome_user_email/html.ecr")
    end
  end
end
