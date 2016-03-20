class syncthing::repo {
  if $::syncthing::manage_repo {
    $release_key = '37C84554E7E0A261E4F76E1ED26E6ED000654A3E'

    case $::osfamily {
      'Debian': {
          include ::apt
  
          ::apt::key { $release_key:
            ensure     => present,
            key_source => 'https://syncthing.net/release-key.txt',
          }
  
          ::apt::source { 'syncthing':
            location    => 'http://apt.syncthing.net',
            release     => 'syncthing',
            repos       => 'release',
            include_src => false,
            require     => Apt::Key[$release_key],
            before      => [
              Package[$::syncthing::package_name],
            ]
          }
      }
      default: {
          fail "Unsupported OS family: ${::osfamily}"
      }
    }
  }
}
