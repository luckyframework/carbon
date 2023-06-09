require "colorize"
require "lucky_template"
require "wordsmith"
require "file_utils"

class Carbon::EmailTemplate
  def initialize(@email_filename : String, @email_class_name : String)
  end

  def render(path : Path)
    LuckyTemplate.write!(path, template_folder)
  end

  def template_folder
    LuckyTemplate.create_folder do |top_dir|
      top_dir.add_folder(Path["src/emails/templates"]) do |templates_dir|
        templates_dir.add_file("#{@email_filename}_email.cr") do |io|
          ECR.embed("#{__DIR__}/templates/email.cr.ecr", io)
        end
        templates_dir.add_folder("#{@email_filename}_email") do |email_templates_dir|
          email_templates_dir.add_file("html.ecr") do |io|
            ECR.embed("#{__DIR__}/templates/html.ecr.ecr", io)
          end
          email_templates_dir.add_file("text.ecr") do |io|
            ECR.embed("#{__DIR__}/templates/text.ecr.ecr", io)
          end
        end
      end
    end
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
    email_template.render(Path["."])

    display_success_messages
  end

  def email_template
    Carbon::EmailTemplate.new(filename, normalized_email_name)
  end

  private def normalized_email_name : String
    email_name.gsub(/email$/i, "")
  end

  private def filename : String
    Wordsmith::Inflector.underscore(normalized_email_name)
  end

  private def display_success_messages
    snapshot = LuckyTemplate.snapshot(email_template.template_folder)
    paths = snapshot.reject { |_, v| v.folder? }.keys

    output.puts "Generated email template"
    output.puts
    paths.each_with_index do |path, index|
      output.print "  #{green_arrow} #{path.colorize.bold}"
      unless index == paths.size - 1
        output.print '\n'
      end
    end
  end
end
