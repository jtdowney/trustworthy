module Trustworthy
  class CLI
    class Encrypt
      include Trustworthy::CLI::Command
      include Trustworthy::CLI::Crypt

      def self._command
        'encrypt filename'
      end

      def parse_options(args)
        options = super(args)
        unless options.has_key?(:output_file)
          options[:output_file] = "#{options[:input_file]}.tw"
        end
        options
      end

      def _transform(prompt, options, input_file)
        plaintext = input_file.read
        master_key = prompt.unlock_master_key
        ciphertext = master_key.encrypt(plaintext)
        File.open(options[:output_file], 'wb+') do |output_file|
          _format_ciphertext(output_file, ciphertext)
        end

        say("Encrypted #{options[:input_file]} to #{options[:output_file]}")
      end

      def _format_ciphertext(output_file, ciphertext)
        wrapped_ciphertext = ciphertext.scan(/.{1,64}/).join("\n")
        output_file.puts('-----BEGIN TRUSTWORTHY ENCRYPTED FILE-----')
        output_file.puts("Version: Trustworthy/#{Trustworthy::VERSION}")
        output_file.puts
        output_file.puts(wrapped_ciphertext)
        output_file.puts('-----END TRUSTWORTHY ENCRYPTED FILE-----')
      end
    end
  end
end
