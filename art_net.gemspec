require File.expand_path('../lib/art_net/version', __FILE__)

spec = Gem::Specification.new do |s|
  s.name = 'ruby-artnet'
  s.version = ArtNet::VERSION
  s.date = '2012-10-26'
  s.summary = 'Pure Ruby implementation of the Art-Net lighting protocol'
  s.email = "ruby-artnet@sen.cx"
  s.homepage = "http://github.com/sarahemm/ruby-artnet/"
  s.description = "Pure Ruby implementation of the Art-Net lighting protocol"
  s.has_rdoc = false
  s.rdoc_options = '--include=examples'

  # ruby -rpp -e' pp `git ls-files`.split("\n").grep(/^(doc|README)/) '
  #s.extra_rdoc_files = [
  #  "README"
  #]
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'autotest', '~> 4.4'

  s.authors = ["Sen"]

  # ruby -rpp -e' pp `git ls-files`.split("\n") '
  s.files = [
    "README.md",
    "art_net.gemspec",
    "lib/art_net/io.rb",
    "lib/art_net/node.rb",
    "lib/art_net/version.rb",
  ]
end
