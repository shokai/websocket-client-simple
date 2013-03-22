module WebSocket
  module Client
    module Simple

      def self.connect(url)
        ::WebSocket::Client::Simple::Client.new url
      end

      class Client
        include EventEmitter
        attr_reader :url

        def initialize(url)
          @url = url
          uri = URI.parse url
          @socket = TCPSocket.new(uri.host, uri.port || 80)
          @hs = ::WebSocket::Handshake::Client.new :url => url
          @handshaked = false
          frame = ::WebSocket::Frame::Incoming::Client.new
          @closed = false
          once :__close do |err|
            close
            emit :close, err
          end

          Thread.new do
            while !@closed do
              begin
                recv_data = @socket.getc
              rescue => e
                emit :__close, e
              end
              if !@handshaked
                @hs << recv_data
                if @hs.finished?
                  @handshaked = true
                  emit :open
                end
              else
                frame << recv_data
                while msg = frame.next
                  emit :message, msg
                end
              end
            end
          end

          @socket.write @hs.to_s
        end

        def send(data)
          return if !@handshaked or @closed
          frame = ::WebSocket::Frame::Outgoing::Client.new(:data => data, :type => :text, :version => @hs.version)
          begin
            @socket.write frame.to_s
          rescue => e
            emit :__close, e
          end
        end

        def close
          return if @closed
          @closed = true
          @socket.close if @socket
          @socket = nil
          emit :__close
        end

      end

    end
  end
end
