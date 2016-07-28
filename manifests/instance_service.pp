define syncthing::instance_service
(
  $instance_name = $name,
) {
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }
  
  exec { "restart syncthing instance ${instance_name}":
    command     => "/usr/sbin/service syncthing restart \"${instance_name}\"",
    provider    => shell,
    refreshonly => true,
    tag         => [
      'syncthing_instance_service_restart',
    ],
  }
  
  exec { "start syncthing instance ${instance_name}":
    command     => "/usr/sbin/service syncthing start \"${instance_name}\"",
    provider    => shell,
    refreshonly => true,
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
