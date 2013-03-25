require 'spec_helper'

describe Trustworthy::CLI do
  def _trustworthy(args)
    `bundle exec trustworthy #{args}`
  end

  describe 'help' do
    it 'should list available commands' do
      _trustworthy('').should include('Commands:')
    end

    it 'should run when no valid command is provided' do
      _trustworthy('-h').should include('Commands:')
    end
  end
end
