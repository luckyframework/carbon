require "colorize"
require "teeplate"
require "wordsmith"
require "file_utils"

class Carbon::EmailTemplate < Teeplate::FileTree
  directory "#{__DIR__}/templates"

  def initialize(
    @email_filename : String,
    @email_class_name : String
  )
  end
end

class Gen::Email < LuckyTask::Task
  include LuckyTask::TextHelpers
  summary "Generate a new Email"

  positional_arg :email_name, "The name of the email", format: /^[A-Z]/

  def help_message
    <<-TEXT
    Generate a new email with html and text formats.
    The email name must be CamelCase. No other options are available.
    Examples:
      lucky gen.email WelcomeUser
      lucky gen.email SubscriptionRenewed
      lucky gen.email ResetPassword
    TEXT
  end

  def call
    template = Carbon::EmailTemplate.new(filename, normalized_email_name)
    template.render(output_path.to_s)

    display_success_messages
  end

  private def normalized_email_name : String
    email_name.gsub(/email$/i, "")
  end

  private def filename : String
    Wordsmith::Inflector.underscore(normalized_email_name)
  end

  private def output_path : Path
    Path[".", "src", "emails"]
  end

  private def display_success_messages
    output.puts <<-MESSAGE
    Generated email template

      #{green_arrow} #{email_class_template_path.colorize.bold}
      #{green_arrow} #{email_class_template_file("html").colorize.bold}
      #{green_arrow} #{email_class_template_file("text").colorize.bold}
    MESSAGE
  end

  private def email_class_template_filename
    "#{filename}_email.cr"
  end

  private def email_class_template_path
    "src/emails/#{email_class_template_filename}"
  end

  private def email_class_template_file(file)
    "src/emails/templates/#{filename}_email/#{file}.ecr"
  end
end
