module Trustworthy
  class CLI
    class Encrypt
      include Trustworthy::CLI::Command

      def self.description
        'Encrypt a file using the master key'
      end

      def parse_options(args)
        super('encrypt', args) do |opts, options|
          opts.on('-i', '--input FILE', 'File to encrypt') do |file|
            options[:input_file] = file
          end

          opts.on('-o', '--output FILE', 'File to write encrypted contents to') do |file|
            options[:output_file] = file
          end
        end
      end

      def run(args)
        options = parse_options(args)

        unless options.has_key?(:input_file)
          $terminal.say 'Must provide an input file'
          print_help
          return
        end

        unless options.has_key?(:output_file)
          $terminal.say 'Must provide an output file'
          print_help
          return
        end

        plaintext = File.read(options[:input_file])
        Trustworthy::Settings.open(options[:config_file]) do |settings|
          master_key = unlock_master_key(settings)
          ciphertext = master_key.encrypt(plaintext)
          File.open(options[:output_file], 'wb+') do |file|
            file.write(ciphertext)
          end
        end

        $terminal.say "Encrypted #{options[:input_file]} to #{options[:output_file]}"
      end
    end
  end
end
