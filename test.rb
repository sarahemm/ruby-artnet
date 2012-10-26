#!/usr/bin/ruby

require 'socket'
require 'ipaddr'
require 'lib/artnet/io.rb'
require 'lib/artnet/node.rb'

# temporary test script used to test things as they're being built
# will be replaced with real tests :)
artnet = ArtNet::IO.new :network => "10.0.0.0", :netmask => "255.0.0.0"
artnet.poll_nodes
artnet.tx_data[0][1][5] = 255
while(true) do
  artnet.process_events
  artnet.send_update 0, 1
  #puts artnet.rx_data[0][0][0]
  #puts "Seeing #{artnet.nodes.length} node(s) on the network:"
  #artnet.nodes.each do |node|
  #  puts "#{node.ip}\t#{node.shortname}\t#{node.longname}"
  #end
  sleep 0.1
end