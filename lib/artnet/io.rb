require 'ipaddr'
require 'socket'
module ArtNet
  class IO
    attr_reader   :rx_data, :nodes
    attr_accessor :tx_data

    def initialize(options)
      @port = options[:port] || 6454
      @network = options[:network] || "2.0.0.0"
      @netmask = options[:netmask] || "255.255.255.0"
      @broadcast = get_broadcast_ip @network, @netmask
      @local_ip = get_local_ip @network
      @udp = UDPSocket.new
      @udp.bind "0.0.0.0", @port
      @udp_bcast = UDPSocket.new
      @udp_bcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      @rx_data = Array.new(4) { Array.new(4, [] ) }
      @tx_data = Array.new(4) { Array.new(4, Array.new(512, 0) ) }
      @nodes = Array.new
    end

    def process_events
      begin
        until !(data = @udp.recvfrom_nonblock(65535)[0]) do
          process_rx_data data
        end
      rescue Errno::EAGAIN
        # no data to process!
        return nil
      end
    end
    
    # send an ArtDmx packet for a specific universe
    # FIXME: make this able to unicast via a node instance method
    def send_update(uni, subuni)
      id = 'Art-Net'
      opcode = 0x5000 # OpPoll
      protver = 14
      seq = 0
      phy = 0
      data = @tx_data[uni][subuni]
      length = data.length
      packet_items = [id, opcode, protver, seq, phy, subuni, uni, length]
      packet_items += data
      packet = packet_items.pack "a7xvnCCCCnC#{length}"
      @udp_bcast.send packet, 0, @broadcast, @port
    end
    
    # send an ArtPoll packet
    # normal process_events calls later will then collect the results in @nodes
    def poll_nodes
      # clear any list of nodes we already know about and start fresh
      @nodes.clear
      # build a new OpPoll packet and send it out
      id = 'Art-Net'
      opcode = 0x2000 # OpPoll
      protver = 14
      @udp_bcast.send [id, opcode, protver, 0, 0].pack("a7xvnCC"), 0, @broadcast, @port
    end
    
    private 
    
    # given a network, finds the local interface IP that would be used to reach it
    def get_local_ip(network)
      UDPSocket.open do |sock|
        sock.connect network, 1
        sock.addr.last
      end
    end
    
    # given a network, returns the broadcast IP
    def get_broadcast_ip(network, mask)
      IPAddr.new(network).|(IPAddr.new(mask).~).to_s
    end
    
    def process_rx_data data
      (id, opcode, protver) = data.unpack "Z7xSn"
      raise PacketFormatError unless id == "Art-Net"
      case opcode
        when 0x2100 # OpPollReply
          node = ArtNet::Node.new
          node.ip = data.unpack("@10CCCC").join(".")
          (node.uni, node.subuni, node.mfg, node.shortname, node.longname) = data.unpack "@18CCxxxxnZ18Z64"
          @nodes << node
        when 0x5000 # OpDmx / OpOutput
          (seq, phy, subuni, uni, length) = data.unpack "@12CCCCn"
          dmxdata = data.unpack "@18C#{length}"
          @rx_data[uni][subuni][0..dmxdata.length] = dmxdata
        else
          puts "Received unknown opcode 0x#{opcode.to_s(16)}"
      end
    end
  end
  
  class PacketFormatError < RuntimeError
  end
end