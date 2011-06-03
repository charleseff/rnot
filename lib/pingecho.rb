# taken from https://github.com/myronmarston/vcr/blob/30b6242a1b0e97a21c27808e416e9b9e8215f994/lib/vcr/ping.rb

# Ruby 1.8 provides Ping.pingecho, but it was removed in 1.9.
# So we try requiring it, and if that fails, define it ourselves.
begin
  require 'ping'
rescue LoadError
  # This is copied, verbatim, from Ruby 1.8.7's ping.rb.
  require 'timeout'
  require "socket"

  module Ping
    def pingecho(host, timeout=5, service="echo")
      begin
        timeout(timeout) do
          s = TCPSocket.new(host, service)
          s.close
        end
      rescue Errno::ECONNREFUSED
        return true
      rescue Timeout::Error, StandardError
        return false
      end
      return true
    end
    module_function :pingecho
  end
end
