require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestWebSocketClientSimple < MiniTest::Test

  def port
    (ENV['WS_PORT'] || 18080).to_i
  end

  def test_echo
    msgs = ['foo','bar','baz']
    res1 = []
    res2 = []

    EM::run{
      @channel = EM::Channel.new

      ## echo server
      WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => port) do |ws|
        ws.onopen do
          sid = @channel.subscribe do |mes|
            ws.send mes
          end
          ws.onmessage do |msg|
            @channel.push msg
          end
          ws.onclose do
            @channel.unsubscribe sid
          end
        end
      end

      ## client1 --> server --> client2
      EM::add_timer 1 do
        url = "ws://localhost:#{port}"
        client1 = WebSocket::Client::Simple.connect url
        assert_equal client1.open?, false
        client2 = WebSocket::Client::Simple.connect url
        assert_equal client2.open?, false

        client1.on :message do |msg|
          res1.push msg
        end

        client2.on :message do |msg|
          res2.push msg
        end

        client1.on :open do
          msgs.each do |m|
            client1.send m
          end
        end

        client1.on :close do
          EM::stop_event_loop
        end

        client2.on :close do
          EM::stop_event_loop
        end

        EM::add_timer 3 do
          assert_equal client1.open?, true
          assert_equal client2.open?, true
          client1.close
          client2.close
          EM::stop_event_loop
        end
      end
    }

    assert_equal msgs.size, res1.size
    assert_equal msgs.size, res2.size

    msgs.each_with_index do |msg,i|
      assert_equal msg, res1[i].to_s
      assert_equal msg, res2[i].to_s
    end

  end

end
