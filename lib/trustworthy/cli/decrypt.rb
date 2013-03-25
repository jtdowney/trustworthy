module Trustworthy
  class CLI
    class Decrypt
      include Trustworthy::CLI::Command

      def self.description
        'Decrypt a file using the master key'
      end

      def parse_options(args)
        super('encrypt', args) do |opts, options|
          opts.on('-i', '--input FILE', 'File to decrypt') do |file|
            options[:input_file] = file
          end

          opts.on('-o', '--output FILE', 'File to write decrypted contents to') do |file|
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

        File.open(options[:input_file], 'rb') do |input_file|
          ciphertext = input_file.read
          Trustworthy::Settings.open(options[:config_file]) do |settings|
            master_key = unlock_master_key(settings)
            plaintext = master_key.decrypt(ciphertext)
            File.open(options[:output_file], 'wb+') do |output_file|
              output_file.write(plaintext)
            end
          end
        end

        $terminal.say "Decrypted #{options[:input_file]} to #{options[:output_file]}"
      end
    end
  end
end
