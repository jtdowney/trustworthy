module Trustworthy
  class CLI
    class AddKey
      include Trustworthy::CLI::Command

      def self.description
        'Add a new user key for a master key'
      end

      def run(args)
        options = parse_options('add-key', args)
        info 'Adding a new key to master key'

        Trustworthy::Settings.open(options[:config_file]) do |settings|
          master_key = unlock_master_key(settings)
          username = add_key(settings, master_key)
          info "Added #{username} to #{options[:config_file]}"
        end
      end
    end
  end
end
