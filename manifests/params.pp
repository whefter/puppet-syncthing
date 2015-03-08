class syncthing::params {
  $binpath                = '/usr/bin'

  $bin                    = 'syncthing'

  $version                = $::operatingsystem ? {
    Debian        => '0.10.20',
    Ubuntu        => latest,
    default       => latest,
  }
  
  $instancespath          = '/etc/syncthing'

  $default_instances      = {}
  $default_devices        = {}
  $default_folders        = {}
  
  $daemon_uid             = 'root'
  $daemon_gid             = 'root'
  $daemon_umask           = '0002'
  $daemon_nice            = undef
  $daemon_debug           = undef
  
  $gui                    = true
  $gui_tls                = true
  $gui_address            = '0.0.0.0'
  $gui_port               = '8080'
  $gui_apikey             = undef
  $gui_user               = undef
  $gui_password           = undef
  $gui_options            = {}
  
  $instance_options       = {}
  
  $device_compression     = false
  $device_introducer      = false
  $device_options         = {}
}
