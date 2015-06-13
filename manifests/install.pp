class syncthing::install {
  case $::osfamily {
    'Debian': {
        include ::apt

        ::apt::key { '00654A3E':
          ensure     => present,
          key_source => 'https://syncthing.net/release-key.txt',
        }

        ::apt::source { 'syncthing':
          location    => 'http://apt.syncthing.net',
          release     => 'syncthing',
          repos       => 'release',
          include_src => false,
          require     => Apt::Key['00654A3E'],
        }

        package { 'syncthing':
          ensure  => $::syncthing::version,
          require => Apt::Source['syncthing'],
        }
    }
    default: {
        fail "Unsupported OS family: ${::osfamily}"
    }
  }

}
