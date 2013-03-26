module Trustworthy
  class CLI
    module Command
      include Trustworthy::CLI::Helpers

      def default_options
        { :config_file => 'trustworthy.yml' }
      end

      def parse_options(command, args)
        options = default_options
        @parser = OptionParser.new do |opts|
          opts.banner = "#{Trustworthy::CLI.banner}\n\nUsage: trustworthy #{command} [options]\n"
          opts.on('-c', '--config FILE', 'Configuration file to use (default: trustworthy.yml)') do |file|
            options[:config_file] = file
          end

          opts.on_tail('-h', '--help', 'Show this message') do
            puts opts
            exit
          end

          if block_given?
            yield opts, options
          end
        end
        @parser.parse!(args)
        options
      end

      def print_help
        if @parser
          puts @parser
        end
      end

      def ask(prompt)
        $terminal.ask(prompt).to_s
      end

      def ask_password(prompt)
        $terminal.ask(prompt) { |q| q.echo = false }.to_s
      end

      def error(message)
        say_color(message, :error)
      end

      def info(message)
        say_color(message, :info)
      end

      def say(message)
        $terminal.say(message)
      end

      def say_color(message, color)
        colored_message = $terminal.color(message, color)
        say(colored_message)
      end
    end
  end
end
