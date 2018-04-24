module Trustworthy
  class CLI
    module Crypt
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def parse_options(args)
        options = super(_command, args) do |opts, inner_options|
          opts.on('-o', '--output FILE', "File to write #{_command}ed contents to") do |file|
            inner_options[:output_file] = file
          end
        end
        options[:input_file] = args.shift
        options
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
        unless options[:input_file] && options[:output_file]
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
