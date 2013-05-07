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

        unless options.has_key?(:input_file) && options.has_key?(:output_file)
          print_help
          return
        end

        prompt = Trustworthy::Prompt.new(options[:config_file], $terminal)
        File.open(options[:input_file], 'r') do |input_file|
          wrapped_ciphertext = input_file.read
          unless wrapped_ciphertext.include?('TRUSTWORTHY ENCRYPTED FILE')
            say("File #{options[:input_file]} does not appear to be a trustworthy encrypted file")
            return
          end

          ciphertext = wrapped_ciphertext.gsub(/-+(BEGIN|END) TRUSTWORTHY ENCRYPTED FILE-+/, '')
          ciphertext = ciphertext.gsub(/^Version: .*$/, '')
          ciphertext = ciphertext.gsub("\n", '')

          master_key = prompt.unlock_master_key
          plaintext = master_key.decrypt(ciphertext)
          File.open(options[:output_file], 'wb+') do |output_file|
            output_file.write(plaintext)
          end
        end

        say("Decrypted #{options[:input_file]} to #{options[:output_file]}")
      end
    end
  end
end
