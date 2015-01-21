define syncthing::instance
(
  $daemon_uid,
  $daemon_gid,
  $daemon_umask       = '0002',
  $daemon_nice        = undef,
  $daemon_debug       = undef,
  
  $home_path,
  
  $gui                = true,
  $gui_tls            = true,
  $gui_address        = '0.0.0.0',
  $gui_port           = '8080',
  $gui_apikey         = undef,
  $gui_user           = undef,
  $gui_password       = undef,
  $gui_options        = {},
  
  $options            = {},
  
  $devices            = {},
  
  $folders            = {},
)
{
  validate_bool($gui)
  
  $instance_config_path     = "${syncthing::instancespath}/${name}.conf"
  $instance_config_xml_path = "${home_path}/config.xml"
 
  file { $instance_config_path:
    content     => template('syncthing/instance.conf.erb'),
    owner       => $daemon_uid,
    group       => $daemon_gid,
    mode        => '0600',
    
    notify      => [
      Service['syncthing'],
    ],
  }
  
  exec { "create syncthing ${name} instance home":
    path        => $::path,
    command     => "su - ${daemon_uid} -c \"${syncthing::binpath}/${syncthing::bin} -generate \\\"${home_path}\\\"\"",
    creates     => $instance_config_xml_path,
    #user        => $daemon_uid,
    provider    => shell,
    
    notify      => [
      Service['syncthing'],
    ],
  }

  $changes = parseyaml( template('syncthing/config-changes.yaml.erb') )
  #$changes          = $changes_template['changes']
  
  notify { 'debug': message => $changes }
  
  augeas { "syncthing ${name} basic config":
	  incl       => $instance_config_xml_path,
	  lens       => 'Xml.lns',
	  context    => "/files${instance_config_xml_path}/configuration",
	  changes    => $changes,
	  
	  require    => [
	    Exec["create syncthing ${name} instance home"],
	  ],
    
    notify      => [
      Service['syncthing'],
    ],
  }
  
  create_resources( ::syncthing::device, $devices )
  create_resources( ::syncthing::folder, $folders )
}