module WebSocket
  module Client
    module Simple

      def self.connect(url)
        ::WebSocket::Client::Simple::Client.new url
      end

      class Client
        include EventEmitter
        attr_reader :url, :handshake

        def initialize(url)
          @url = url
          uri = URI.parse url
          @socket = TCPSocket.new(uri.host, uri.port || 80)
          @handshake = ::WebSocket::Handshake::Client.new :url => url
          @handshaked = false
          frame = ::WebSocket::Frame::Incoming::Client.new
          @closed = false
          once :__close do |err|
            close
            emit :close, err
          end

          @thread = Thread.new do
            while !@closed do
              begin
                recv_data = @socket.getc
                unless @handshaked
                  @handshake << recv_data
                  if @handshake.finished?
                    @handshaked = true
                    emit :open
                  end
                else
                  frame << recv_data
                  while msg = frame.next
                    emit :message, msg
                  end
                end
              rescue => e
                emit :error, e
              end
            end
          end

          @socket.write @handshake.to_s
        end

        def send(data, opt={:type => :text})
          return if !@handshaked or @closed
          type = opt[:type]
          frame = ::WebSocket::Frame::Outgoing::Client.new(:data => data, :type => type, :version => @handshake.version)
          begin
            @socket.write frame.to_s
          rescue Errno::EPIPE => e
            emit :__close, e
          end
        end

        def close
          return if @closed
          send nil, :type => :close
          @closed = true
          @socket.close if @socket
          Thread.kill @thread if @thread
          @socket = nil
          emit :__close
        end

        def open?
          @handshake.finished? and !@closed
        end

      end

    end
  end
end
