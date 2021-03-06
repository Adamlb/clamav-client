# clamav-client - ClamAV client
# Copyright (C) 2014 Franck Verrot <franck@verrot.fr>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "clamav/connection"
require "clamav/commands/ping_command"
require "clamav/commands/quit_command"
require "clamav/commands/scan_command"
require "clamav/commands/instream_command"
require "clamav/util"
require "clamav/wrappers/new_line_wrapper"
require "clamav/wrappers/null_termination_wrapper"

module ClamAV
  class Client
    def initialize(connection = default_connection)
      @connection = connection
      connection.establish_connection
    end

    def execute(command)
      command.call(@connection)
    end

    def default_connection
      ClamAV::Connection.new(
        :socket => resolve_default_socket,
        :wrapper => ::ClamAV::Wrappers::NewLineWrapper.new
      )
    end

    def resolve_default_socket
      unix_socket, tcp_host, tcp_port = ENV.values_at('CLAMD_UNIX_SOCKET', 'CLAMD_TCP_HOST', 'CLAMD_TCP_PORT')
      if tcp_host && tcp_port
        ::TCPSocket.new(tcp_host, tcp_port)
      else
        ::UNIXSocket.new(unix_socket || '/usr/local/var/run/clamav/clamd.sock')
      end
    end
  end
end
