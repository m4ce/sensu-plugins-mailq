#!/usr/bin/env ruby
#
# check-mailq.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'

class CheckMailQueue < Sensu::Plugin::Check::CLI
  option :mailq_cmd,
         :description => "Path to mailq executable (default: /usr/bin/mailq)",
         :long => "--mailq-cmd <PATH>",
         :default => "/usr/bin/mailq"

  option :warn,
         :description => "Warn if LENGTH exceeds current mail queue",
         :short => "-w <LENGTH>",
         :long => "--warn <LENGTH>",
         :proc => proc(&:to_i),
         :default => 1

  option :crit,
         :description => "Critical if LENGTH exceeds current mail queue",
         :short => "-c <LENGTH>",
         :long => "--critical <LENGTH>",
         :proc => proc(&:to_i),
         :default => 5

  def initialize()
    super

    raise "Unable to find mailq command" unless File.executable?(config[:mailq_cmd])
  end

  def run
    mailq = %x[#{config[:mailq_cmd]}]
    if mailq =~ /^Mail queue is empty$/
      ok("Mail queue is empty")
    else
      # calculate queue length
      length = mailq[/^-- \d+ Kbytes in (\d+) Request/, 1].to_i

      critical("Mail queue has #{length} messages") if length >= config[:crit]
      warning("Mail queue has #{length} messages") if length >= config[:warn]
    end
  end
end
