class syncthing::params {
  $binpath                = '/usr/bin/syncthing'
  $instancespath          = '/etc/syncthing'

  $version                = 'latest'
  
  $manage_repo            = true

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
  $gui_password_salt      = undef
  $gui_options            = {}

  $instance_options       = {}

  $device_compression     = false
  $device_introducer      = false
  $device_options         = {}
}
