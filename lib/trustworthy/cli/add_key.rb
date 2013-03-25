module Trustworthy
  class CLI
    class AddKey
      include Trustworthy::CLI::Command

      def self.description
        'Add a new user key for a master key'
      end

      def run(args)
        options = parse_options('add-key', args)
        $terminal.say $terminal.color('Adding a new key to master key', :info)

        Trustworthy::Settings.open(options[:config_file]) do |settings|
          master_key = unlock_master_key(settings)
          username = add_key(settings, master_key)
          $terminal.say "Added #{username} to #{options[:config_file]}"
        end
      end
    end
  end
end
