module Trustworthy
  class CLI
    module Crypt
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def parse_options(args)
        super(_command, args) do |opts, options|
          opts.on('-i', '--input FILE', "File to #{_command}") do |file|
            options[:input_file] = file
          end

          opts.on('-o', '--output FILE', "File to write #{_command}ed contents to") do |file|
            options[:output_file] = file
          end
        end
      end

      def run(args)
        catch(:error) do
          options = _check_options(args)
          prompt = Trustworthy::Prompt.new(options[:config_file], $terminal)
          File.open(options[:input_file], 'rb') do |input_file|
            _transform(prompt, options, input_file)
          end
        end
      end

      def _command
        self.class._command
      end

      def _check_options(args)
        options = parse_options(args)
        unless options.has_key?(:input_file) && options.has_key?(:output_file)
          print_help
          throw :error
        end
        options
      end

      module ClassMethods
        def description
          "#{_command.capitalize} a file using a master key"
        end
      end
    end
  end
end
