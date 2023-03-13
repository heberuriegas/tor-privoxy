require 'net/telnet'
require 'mechanize'
require 'capybara'
begin
  require 'capybara-webkit'
rescue LoadError => e
  
end

module TorPrivoxy
  class Agent
    def initialize options={} , &callback
      options.reverse_merge!(host: '127.0.0.1', password: '', control: { 8118 => 9051 }, capybara: false)
      @proxy = Switcher.new(options[:host], options[:password], options[:control])
      @capybara = options[:capybara]
      
      @mechanize = Mechanize.new

      set_selenium
      set_clients_proxy
      register_capybara_drivers

      @circuit_timeout = 10
      if callback
        @callback = callback
        @callback.call self
      end
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
      
      set_clients_proxy

      if @callback
        @callback.call self
      end
    end

    def set_selenium
      return unless @capybara == true
      
      @selenium_profile = Selenium::WebDriver::Firefox::Profile.new
      @webkit_browser = defined?(Capybara::Webkit).nil? ? nil : Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new)
    end

    def set_clients_proxy
      set_mechanize_proxy
      set_capybara_proxy
    end

    def set_mechanize_proxy
      @mechanize.set_proxy(@proxy.host, @proxy.port.to_i)
    end

    def set_capybara_proxy
      return unless @capybara == true

      @selenium_profile["network.proxy.type"] = 1
      @selenium_profile["network.proxy.http"] = @proxy.host
      @selenium_profile["network.proxy.ssl"] = @proxy.host
      @selenium_profile["network.proxy.http_port"] = @proxy.port.to_i

      @webkit_browser.set_proxy(host: @proxy.host, port: @proxy.port.to_i) unless @webkit_browser.nil?
    end

    def register_capybara_drivers
      return unless @capybara == true

      Capybara.register_driver :selenium do |app|
        Capybara::Selenium::Driver.new(app, :profile => @selenium_profile)
      end

      Capybara.register_driver :webkit do |app|
        Capybara::Webkit::Driver.new(app, browser: @webkit_browser)
      end unless @webkit_browser.nil?
    end

    def ip
      @mechanize.get('http://canihazip.com/s').body
    rescue exception
      puts "error getting ip: #{exception.to_s}"
      return ""
    end
  end
end
