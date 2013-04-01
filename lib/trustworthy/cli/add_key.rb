module Trustworthy
  class CLI
    class AddKey
      include Trustworthy::CLI::Command

      def self.description
        'Add a new user key for a master key'
      end

      def run(args)
        options = parse_options('add-key', args)

        say('Adding a new key to master key')

        prompt = Trustworthy::Prompt.new(options[:config_file], $terminal)
        master_key = prompt.unlock_master_key
        key = master_key.create_key
        username = prompt.add_user_key(key)

        say("Added #{username}")
      end
    end
  end
end
