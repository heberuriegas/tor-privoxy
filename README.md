# Tor/Privoxy wrapped Mechanize and Capybara

tor-privoxy is a Ruby Mechanize wrapper for accessing the web via Tor/Privoxy.
It allows multiple Privoxy instances, switching endpoints, and switching the
proxy when you get an HTTP 4xx error code.
It is useful for web robots, scanners, and scrapers when accessing sites which may
ban/block you unexpectedly

## Using

The first step is to install the gem:

    gem install tor-privoxy

To use in your application:

    require 'tor-privoxy'

To get a Mechanize instance wrapped to use Tor and able to use another endpoint when it encounters an HTTP 4xx code:

    agent = TorPrivoxy::Agent.new host: '127.0.0.1', password: '', privoxy_port: 8118, control_port: 9051 do |agent|
      sleep 10
      puts "New IP is #{agent.ip}"
    end

Passing block is optional:

    agent = TorPrivoxy::Agent.new host: '127.0.0.1', password: '', privoxy_port: 8118, control_port: 9051

You can pass multiple privoxy hosts:

    agent = TorPrivoxy::Agent.new [{ host: '127.0.0.1', password: '', privoxy_port: 8118, control_port: 9051 }, { host: '127.0.0.2', password: '', privoxy_port: 8118, control_port: 9051 }]

The hash is in format proxyport => torcontrolport. Yes, you may provide as many as you want, but I don't have an idea why I initially did it like so.

And use the agent as a usual Mechanize agent instance:

    agent.get "http://example.com"

### Configuration options

Configuration options are passed when creating an agent and consist of:

- IP/Host of machine where Tor/Privoxy resides
- password for Tor Control
- a hash of Privoxy port => Tor port
- a block which is called when agent switches to a new endpoint

### Capybara configuration

Capybara Selenium and Capybara Webkit are override if is true in the initializer

    agent ||= TorPrivoxy::Agent.new host: '127.0.0.1', password: '', control: 8118 => 9051, capybara: true

## Author

Created by [Phil Pirozhkov](https://github.com/pirj)

[Origin](https://github.com/pirj/tor-privoxy)

## Future

- No Mechanize dependency, ability to work with any HTTP library
- Extend configuration options, allowing for fine proxy setting control
- Better "ban" detection, e.g. Captcha, etc.
