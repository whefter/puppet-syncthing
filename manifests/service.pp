class syncthing::service {
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }

  if ($::syncthing::service_type == 'initd') {
    file { '/etc/default/syncthing':
      content => template('syncthing/default.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0744',
    }

    file { $::syncthing::instancespath:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { '/etc/init.d/syncthing':
      content => template('syncthing/init.d.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => [
        File['/etc/default/syncthing'],
        File[$::syncthing::instancespath],
      ],
    }
  } else {
    file { '/etc/default/syncthing':
      ensure => absent,
    }

    file { '/etc/init.d/syncthing':
      ensure => absent,
    }
  }

#  if ($::syncthing::service_type == 'systemd') {
#  } else {
#  }

#  service { 'syncthing':
#    ensure  => running,
#    enable  => true,
#    require => [
#      File['/etc/init.d/syncthing']
#    ],
#  }
}
