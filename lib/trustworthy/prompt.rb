module Trustworthy
  class Prompt
    def initialize(config_file, terminal = HighLine.new)
      @config_file = config_file
      @terminal = terminal
    end

    def add_user_key(key)
      Trustworthy::Settings.open(@config_file) do |settings|
        username = nil
        loop do
          username = _ask('Username: ')
          if settings.has_key?(username)
            _error("Key #{username} is already in use")
          else
            break
          end
        end

        loop do
          password = _ask_password('Password: ')
          password_confirm = _ask_password('Password (again): ')
          if password == password_confirm
            settings.add_key(key, username, password)
            break
          else
            _error('Passwords do not match.')
          end
        end

        username
      end
    end

    def unlock_master_key
      usernames_in_use = []
      Trustworthy::Settings.open(@config_file) do |settings|
        raise 'must have two keys to unlock master key' unless settings.recoverable?

        username1, key1 = _unlock_key(settings, usernames_in_use)
        usernames_in_use << username1

        username2, key2 = _unlock_key(settings, usernames_in_use)

        master_key = Trustworthy::MasterKey.create_from_keys(key1, key2)
        _say('Reconstructed master key')

        master_key
      end
    end

    def _unlock_key(settings, usernames_in_use)
      username = nil
      loop do
        username = _ask('Username: ')
        if usernames_in_use.include?(username)
          _error("Key #{username} is already in use")
        elsif settings.find_key(username).nil?
          _error("Key #{username} does not exist")
        else
          break
        end
      end

      key = nil
      begin
        password = _ask_password('Password: ')
        key = settings.unlock_key(username, password)
      rescue ArgumentError
        _error("Password incorrect for #{username}")
        retry
      end

      _say("Unlocked #{username}")

      [username, key]
    end

    def _ask(question)
      @terminal.ask(question).to_s
    end

    def _ask_password(question)
      @terminal.ask(question) { |q| q.echo = false }.to_s
    end

    def _say(message)
      @terminal.say(message)
    end

    def _error(message)
      colored_message = @terminal.color(message, :error)
      _say(colored_message)
    end
  end
end
