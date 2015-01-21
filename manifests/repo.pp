class syncthing::repo
(
  
)
{
  include ::apt
  
  case $::operatingsystem {
      Debian: {
          # No repo for Debian so far
#          apt::source { 'syncthing':
#              location            => 'http://ppa.launchpad.net/ytvwld/syncthing/ubuntu',
#              release             => $::lsbdistcodename,
#              release             => 'trusty',
#              repos               => 'main',
#              required_packages   => 'debian-keyring debian-archive-keyring',
#              key                 => '980B9063',
#              key_server          => 'pgp.mit.edu',
#              include_src         => false,
#          }
      }
      Ubuntu: {
          apt::ppa { 'ppa:ytvwld/syncthing': }
      }
      default: {
          fail "Unsupported Operating System: ${::operatingsystem}"
      }
  }
  
  Class['::syncthing::repo'] -> Class['::syncthing::install']
}