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

        unless options.has_key?(:input_file) && options.has_key?(:output_file)
          print_help
          return
        end

        prompt = Trustworthy::Prompt.new(options[:config_file], $terminal)
        File.open(options[:input_file], 'rb') do |input_file|
          plaintext = input_file.read
          master_key = prompt.unlock_master_key
          ciphertext = master_key.encrypt(plaintext)
          File.open(options[:output_file], 'w+') do |output_file|
            wrapped_ciphertext = ciphertext.scan(/.{1,64}/).join("\n")
            output_file.write('-----BEGIN TRUSTWORTHY ENCRYPTED FILE-----')
            output_file.write("\n")
            output_file.write("Version: Trustworthy/#{Trustworthy::VERSION}")
            output_file.write("\n")
            output_file.write("\n")
            output_file.write(wrapped_ciphertext)
            output_file.write("\n")
            output_file.write('-----END TRUSTWORTHY ENCRYPTED FILE-----')
            output_file.write("\n")
          end
        end

        say("Encrypted #{options[:input_file]} to #{options[:output_file]}")
      end
    end
  end
end
