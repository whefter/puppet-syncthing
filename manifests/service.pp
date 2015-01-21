class syncthing::service
(
  
)
{
  file { '/etc/default/syncthing':
    content     => template('syncthing/default.erb'),
    owner       => 'root',
    group       => 'root',
    mode        => '0744',
  }
    
  file { $syncthing::instancespath:
    ensure      => directory,
    owner       => 'root',
    group       => 'root',
    mode        => '0755',
  }
    
  file { '/etc/init.d/syncthing':
    content     => template('syncthing/init.d.erb'),
    owner       => 'root',
    group       => 'root',
    mode        => '0755',
    
    require     => [
		  File['/etc/default/syncthing'],
		  File[$syncthing::instancespath],
		],
  }
  
  service { 'syncthing':
    ensure  => running,
    
    require => [
      File['/etc/init.d/syncthing']
    ],
  }
  
}