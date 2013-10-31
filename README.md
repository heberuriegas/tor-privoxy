# Tor/Privoxy wrapped Mechanize and Capybara

Tor-privoxy is a Ruby Mechanize wrapper to access the web with via Tor/Privoxy
It allows to use multiple Privoxy instances, switch endpoints, switch
proxy when you get 4xx HTTP code
Useful for web robots, scanners, grabbers when accessing sites which may
ban/block you unexpectedly

## Using

The first step is to install the gem:

    gem install tor-privoxy

To use in your application:

    require 'tor-privoxy'

Create a wrapper and you get a Mechanize instance wrapped to use Tor and
which is able to use another endpoint when gets HTTP 4xx

    agent ||= TorPrivoxy::Agent.new host: '127.0.0.1', password: '', privoxy_port: 8123, control_port: 9051 do |agent|
      sleep 10
      puts "New IP is #{agent.ip}"
    end
    
And use the agent as a ususal Mechanize agent instance:
    
    agent.get "http://example.com"

### Configuration options

Configuration options are passed when creating an agent, and consists of:
 - IP/Host of machine, where Tor/Privoxy resides
 - password for Tor Control
 - a hash of Privoxy port => Tor port
 - a block which is called when agent switches to a new endpoint

### Capybara configuration
Capybara Selenium and Capybara Webkit are override if is true in the initializer

    agent ||= TorPrivoxy::Agent.new host: privoxy_port: 8123, capybara: true

## Author

Created by [Phil Pirozhkov](https://github.com/pirj)

[Origin](https://github.com/pirj/tor-privoxy)

## Future

No Mechanize dependency, ability to work with any HTTP library
Extend configuration options, allowing for fine proxy setting control
Better "ban" detection, i.e. when you get Captcha et c.
