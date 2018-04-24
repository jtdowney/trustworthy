module Trustworthy
  class CLI
    class Decrypt
      include Trustworthy::CLI::Command
      include Trustworthy::CLI::Crypt

      def self._command
        'decrypt filename'
      end

      def parse_options(args)
        options = super(args)
        if options[:input_file].to_s.end_with?('.tw') && !options.key?(:output_file)
          options[:output_file] = File.basename(options[:input_file], '.tw')
        end
        options
      end

      def _transform(prompt, options, input_file)
        wrapped_ciphertext = input_file.read
        unless wrapped_ciphertext.include?('TRUSTWORTHY ENCRYPTED FILE')
          say("File #{options[:input_file]} does not appear to be a trustworthy encrypted file")
          throw :error
        end

        master_key = prompt.unlock_master_key
        ciphertext = _strip_ciphertext(wrapped_ciphertext)
        plaintext = master_key.decrypt(ciphertext)
        File.open(options[:output_file], 'wb+') do |output_file|
          output_file.write(plaintext)
        end

        say("Decrypted #{options[:input_file]} to #{options[:output_file]}")
      end

      def _strip_ciphertext(ciphertext)
        ciphertext
          .gsub(/-+(BEGIN|END) TRUSTWORTHY ENCRYPTED FILE-+/, '')
          .gsub(/^Version: .*$/, '')
          .delete("\n")
      end
    end
  end
end
