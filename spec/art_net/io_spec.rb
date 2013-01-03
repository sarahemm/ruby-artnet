require 'spec_helper'

describe ArtNet::IO do

  it "sets up an connection " do
    @udp_recieve = mock('UDPSocket', :bind => true)
    @udp_recieve.should_receive(:bind).with("0.0.0.0", 6454)

    UDPSocket.should_receive(:new).once.and_return(@udp_recieve)

    @udp_broadcast = mock('UDPSocket', :bind => true)
    @udp_broadcast.should_receive(:setsockopt).with(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    UDPSocket.should_receive(:new).once.and_return(@udp_broadcast)

    subject
  end

end
