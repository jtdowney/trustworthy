require 'highline/import'
require 'optparse'

require 'trustworthy/cli/command'
require 'trustworthy/cli/crypt'
require 'trustworthy/cli/add_key'
require 'trustworthy/cli/init'
require 'trustworthy/cli/decrypt'
require 'trustworthy/cli/encrypt'
require 'trustworthy/cli/passwd'
require 'trustworthy/prompt'

module Trustworthy
  class CLI
    include Trustworthy::CLI::Command

    Commands = {
      'add-key' => Trustworthy::CLI::AddKey,
      'init'    => Trustworthy::CLI::Init,
      'decrypt' => Trustworthy::CLI::Decrypt,
      'encrypt' => Trustworthy::CLI::Encrypt,
      'passwd'  => Trustworthy::CLI::Passwd
    }.freeze

    def self.banner
      "Trustworthy CLI v#{Trustworthy::VERSION}"
    end

    def run(args)
      command = args.shift
      if Commands.key?(command)
        klass = Commands[command]
        klass.new.run(args)
      else
        _print_help
      end
    end

    def _print_help
      say("#{Trustworthy::CLI.banner}\n\n")
      say('Commands:')
      Commands.each do |name, klass|
        say(format('  %-8s %s', name, klass.description))
      end
      say("\nSee 'trustworthy <command> --help' for more information on a specific command")
    end
  end
end
