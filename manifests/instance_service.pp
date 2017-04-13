define syncthing::instance_service
(
  $ensure        = 'present',
  $instance_name = $name,
  $daemon        = undef,
  $daemon_uid    = undef,
  $home_path     = undef,

  # These are only relevant for initd services
  $configpath    = undef,
  $daemon_gid    = undef,
  $daemon_umask  = undef,
  $daemon_debug  = undef,
  $daemon_nice   = undef,
) {
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }

  if ($::syncthing::service_type == 'initd') {
    if ($ensure == 'present') {
      file { $configpath:
        content => template('syncthing/instance.conf.erb'),
        owner   => $daemon_uid,
        group   => $daemon_gid,
        mode    => '0600',

        before  => [
          Exec["start syncthing instance ${name}"],
        ],
        notify  => [
          Exec["restart syncthing instance ${name}"],
        ],
      }

      exec { "restart syncthing instance ${instance_name}":
        command     => "/usr/sbin/service syncthing restart \"${instance_name}\"",
        provider    => shell,
        refreshonly => true,
        before      => [
          Exec["start syncthing instance ${name}"],
        ],
        tag         => [
          'syncthing_instance_service_restart',
        ],
      }

      exec { "start syncthing instance ${instance_name}":
        command     => "/usr/sbin/service syncthing start \"${instance_name}\"",
        provider    => shell,
        unless      => "/usr/sbin/service syncthing status \"${instance_name}\"",
        # Ensure service is always started
        # refreshonly => true,
        tag         => [
          'syncthing_instance_service_start',
        ],
      }

      exec { "stop syncthing instance ${instance_name}":
        command     => "/usr/sbin/service syncthing stop \"${instance_name}\"",
        provider    => shell,
        refreshonly => true,
        tag         => [
          'syncthing_instance_service_stop',
        ],
      }
    } elsif ($ensure == 'absent') {
      file { $configpath:
        ensure => absent,
      }
      ->
      exec { "stop syncthing instance ${instance_name}":
        command  => "/usr/sbin/service syncthing stop \"${instance_name}\"",
        provider => shell,
      }
    }
  }

  if ($::syncthing::service_type == 'systemd') {
    if ($ensure == 'present') {
      file { "/etc/systemd/system/syncthing@${daemon_uid}.service":
        content => template('syncthing/systemd.service.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => [
          Exec["reload systemd daemons after instance ${instance_name} modifications"],
        ],
      }
    
      exec { "enable systemd service for ${instance_name}":
        command  => "/bin/systemctl enable syncthing@${daemon_uid}",
        provider => shell,
        unless   => "/bin/systemctl is-enabled syncthing@${daemon_uid}",
        require  => [
          File["/etc/systemd/system/syncthing@${daemon_uid}.service"],
        ],
        notify   => [
          Exec["reload systemd daemons after instance ${instance_name} modifications"],
        ],
      }

      exec { "reload systemd daemons after instance ${instance_name} modifications":
        command     => "/bin/systemctl daemon-reload",
        provider    => shell,
        refreshonly => true,
        notify      => [
          Exec["restart syncthing instance ${instance_name}"],
        ],
      }

      exec { "restart syncthing instance ${instance_name}":
        command     => "/usr/sbin/service syncthing@${daemon_uid} restart",
        provider    => shell,
        refreshonly => true,
        before      => [
          Exec["start syncthing instance ${name}"],
        ],
        tag         => [
          'syncthing_instance_service_restart',
        ],
        require     => [
          File["/etc/systemd/system/syncthing@${daemon_uid}.service"],
          Exec["reload systemd daemons after instance ${instance_name} modifications"],
        ],
      }

      exec { "start syncthing instance ${instance_name}":
        command     => "/usr/sbin/service syncthing@${daemon_uid} start",
        provider    => shell,
        unless      => "/bin/systemctl is-active syncthing@${daemon_uid}",
        # Ensure service is always starting
        # refreshonly => true,
        tag         => [
          'syncthing_instance_service_start',
        ],
        require     => [
          File["/etc/systemd/system/syncthing@${daemon_uid}.service"],
          Exec["reload systemd daemons after instance ${instance_name} modifications"],
        ],
      }

      exec { "stop syncthing instance ${instance_name}":
        command     => "/usr/sbin/service syncthing@${daemon_uid} stop",
        provider    => shell,
        refreshonly => true,
        tag         => [
          'syncthing_instance_service_stop',
        ],
        require     => [
          File["/etc/systemd/system/syncthing@${daemon_uid}.service"],
          Exec["reload systemd daemons after instance ${instance_name} modifications"],
        ],
      }
    } elsif ($ensure == 'absent') {      
      exec { "stop syncthing instance ${instance_name}":
        command  => "/usr/sbin/service syncthing stop syncthing@${daemon_uid}",
        provider => shell,
      }
      ->
      exec { "enable systemd service for ${instance_name}":
        command  => "/bin/systemctl disable syncthing@${daemon_uid}",
        provider => shell,
      }
      ->
      file { "/etc/systemd/system/syncthing@${daemon_uid}.service":
        ensure => 'absent',
      }
    }
  } else {
    exec { "disable systemd service for ${instance_name}":
      command  => "/bin/systemctl disable syncthing@${daemon_uid}",
      provider => shell,
      onlyif   => "[ -e /bin/systemctl ] && /bin/systemctl is-enabled syncthing@${daemon_uid}",
      before   => [
        File["/etc/systemd/system/syncthing@${daemon_uid}.service"],
      ],
    }

    file { "/etc/systemd/system/syncthing@${daemon_uid}.service":
      ensure  => absent,
      require => [
        Exec["disable systemd service for ${instance_name}"],
      ],
    }
  }

#  service { "syncthing ${instance_name}":
#    name    => 'syncthing',
#    ensure  => running,
#    enable  => true,
#    start   => "service syncthing start ${instance_name}",
#    stop    => "service syncthing stop ${instance_name}",
#    restart => "service syncthing restart ${instance_name}",
#    status  => "service syncthing status ${instance_name}",
#    
#    require => [
#      File['/etc/init.d/syncthing'],
#    ],
#  }
}
