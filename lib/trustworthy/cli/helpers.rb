module Trustworthy
  class CLI
    module Helpers
      def add_key(settings, master_key)
        key = master_key.create_key
        username = $terminal.ask('Username: ').to_s

        loop do
          password = $terminal.ask('Password: ') { |q| q.echo = false }.to_s
          password_confirm = $terminal.ask('Password (again): ') { |q| q.echo = false }.to_s
          if password == password_confirm
            settings.add_key(key, username, password)
            break
          else
            $terminal.say 'Passwords do not match.'
          end
        end

        username
      end

      def unlock_master_key(settings)
        usernames_in_use = []

        username1, key1 = _unlock_key(settings, usernames_in_use)
        usernames_in_use << username1

        username2, key2 = _unlock_key(settings, usernames_in_use)

        master_key = Trustworthy::MasterKey.create_from_keys(key1, key2)
        $terminal.say "Reconstructed master key"

        master_key
      end

      def _unlock_key(settings, usernames_in_use)
        username = nil
        loop do
          username = $terminal.ask('Username: ').to_s
          if usernames_in_use.include?(username)
            $terminal.say "Key #{username} is already in use"
          elsif settings.find_key(username).nil?
            $terminal.say "Key #{username} does not exist"
          else
            break
          end
        end

        key = nil
        begin
          password = $terminal.ask('Password: ') { |q| q.echo = false }.to_s
          key = settings.unlock_key(username, password)
        rescue ArgumentError
          $terminal.say "Password incorrect for #{username}"
          retry
        end

        $terminal.say "Unlocked #{username}"

        [username, key]
      end
    end
  end
end
