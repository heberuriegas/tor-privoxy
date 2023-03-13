module TorPrivoxy
  class Switcher
    attr_reader :privoxy_data, :current

    def initialize privoxy_data
      @privoxy_data = privoxy_data
      @current = 0
    end
    
    def next
      @current = current + 1
      @current = 0 if current >= privoxy_data.size
    end

    def host
      privoxy_data[current][:host]
    end

    def password
      privoxy_data[current][:password]
    end
    
    def privoxy_port
      privoxy_data[current][:privoxy_port]
    end
    
    def control_port
      privoxy_data[current][:control_port]
    end
  end
end
