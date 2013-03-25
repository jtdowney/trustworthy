module Trustworthy
  class CLI
    class Init
      include Trustworthy::CLI::Command

      def self.description
        'Generate a new master key and user keys'
      end

      def default_options
        { :keys => 2 }.merge(super)
      end

      def parse_options(args)
        super('init', args) do |opts, options|
          opts.on('-k', '--keys N', OptionParser::DecimalInteger, 'Number of keys to generate (default: 2, minimum: 2)') do |k|
            options[:keys] = k
          end
        end
      end

      def run(args)
        options = parse_options(args)

        if options[:keys] < 2
          $terminal.say "Must generate at least two keys"
          print_help
          return
        end

        $terminal.say $terminal.color("Creating a new master key with #{options[:keys]} keys.", :info)
        master_key = Trustworthy::MasterKey.create

        Trustworthy::Settings.open(options[:config_file]) do |settings|
          options[:keys].times do
            username = add_key(settings, master_key)
            $terminal.say "Key #{username} added."
          end

          $terminal.say "Created #{options[:config_file]}"
        end
      end
    end
  end
end
