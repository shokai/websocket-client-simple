require File.expand_path 'test_helper', File.dirname(__FILE__)

class TestWebSocketClientSimple < MiniTest::Test
  
  def test_onopen
    
    EM::run{
      
      EchoServer.start

      res = nil

      EM::add_timer 1 do
        WebSocket::Client::Simple.connect EchoServer.url do |client|
          client.on :open do
            client.send "hello world"
          end

          client.on :message do |msg|
            res = msg.to_s
          end
        end
      end

      EM::add_timer 2 do
        assert_equal res, "hello world"
        EM::stop_event_loop
      end
    }
    
  end
  
end
