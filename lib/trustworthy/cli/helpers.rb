module Trustworthy
  class CLI
    module Helpers
      def add_key(settings, master_key)
        key = master_key.create_key
        username = ask('Username: ')

        loop do
          password = ask_password('Password: ')
          password_confirm = ask_password('Password (again): ')
          if password == password_confirm
            settings.add_key(key, username, password)
            break
          else
            error 'Passwords do not match.'
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
        info "Reconstructed master key"

        master_key
      end

      def _unlock_key(settings, usernames_in_use)
        username = nil
        loop do
          username = ask('Username: ')
          if usernames_in_use.include?(username)
            error "Key #{username} is already in use"
          elsif settings.find_key(username).nil?
            error "Key #{username} does not exist"
          else
            break
          end
        end

        key = nil
        begin
          password = ask_password('Password: ')
          key = settings.unlock_key(username, password)
        rescue ArgumentError
          error "Password incorrect for #{username}"
          retry
        end

        info "Unlocked #{username}"

        [username, key]
      end
    end
  end
end
