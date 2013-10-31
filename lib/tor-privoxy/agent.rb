require 'net/telnet'
require 'mechanize'
require 'capybara'
require 'capybara-webkit'

module TorPrivoxy
  class Agent
    def initialize options={} , &callback
      options.reverse_merge!(host: '127.0.0.1', password: '', privoxy_port: 8118, control_port: 9051, capybara: false)
      @proxy = Switcher.new(options[:host], options[:password], { options[:privoxy_port] => options[:control_port] })
      
      @mechanize = Mechanize.new
      @capybara = options[:capybara]

      if @capybara == true
        @selenium_profile = Selenium::WebDriver::Firefox::Profile.new
        @webkit_browser = Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new)
      end

      set_proxy_in_clients

      if @capybara == true
        Capybara.register_driver :selenium do |app|
          Capybara::Selenium::Driver.new(app, :profile => @selenium_profile)
        end

        Capybara.register_driver :webkit do |app|
          Capybara::Webkit::Driver.new(app, browser: @webkit_browser)
        end
      end

      @callback = callback
      @callback.call self
    end

    def method_missing method, *args, &block
      begin
        @mechanize.send method, *args, &block
      rescue Mechanize::ResponseCodeError # 403 etc
        switch_circuit
        retry
      end
    end

    def switch_circuit
      localhost = Net::Telnet::new('Host' => @proxy.host, 'Port' => @proxy.control_port,
                                 'Timeout' => @circuit_timeout, 'Prompt' => /250 OK\n/)
      localhost.cmd("AUTHENTICATE \"#{@proxy.pass}\"") { |c| throw "cannot authenticate to Tor!" if c != "250 OK\n" }
      localhost.cmd('signal NEWNYM') { |c| throw "cannot switch Tor to new route!" if c != "250 OK\n" }
      localhost.close

      @proxy.next
      
      set_proxy_in_clients

      @callback.call self
    end

    def set_proxy_in_clients
      @mechanize.set_proxy(@proxy.host, @proxy.port)

      if @capybara == true
        @selenium_profile["network.proxy.type"] = 1 # manual proxy config
        @selenium_profile["network.proxy.http_port"] = @proxy.host
        @selenium_profile["network.proxy.http_port"] = @proxy.port

        @webkit_browser.set_proxy(host: @proxy.host, port: @proxy.port)
      end
    end

    def ip
      @mechanize.get('http://ifconfig.me/ip').body
    rescue Exception => ex
      puts "error getting ip: #{ex.to_s}"
      return ""
    end
  end
end
