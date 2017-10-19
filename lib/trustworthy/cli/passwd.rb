module Trustworthy
  class CLI
    class Passwd
      include Trustworthy::CLI::Command

      def self.description
        'Change a keys password'
      end

      def run(args)
        options = parse_options('passwd', args)

        prompt = Trustworthy::Prompt.new(options[:config_file], $terminal)
        username = prompt.change_user_password

        say("Changed password for #{username}")
      end
    end
  end
end
