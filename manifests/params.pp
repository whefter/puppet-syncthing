class syncthing::params {
  $binpath                     = '/usr/bin/syncthing'
  $instancespath               = '/etc/syncthing'

  $package_version             = 'latest'

  $manage_repo                 = true
  $package_name                = 'syncthing'

  $default_instances           = {}
  $default_devices             = {}
  $default_folders             = {}

  $create_home_path            = false

  $daemon_uid                  = 'root'
  $daemon_gid                  = 'root'
  $daemon_umask                = '0002'
  $daemon_nice                 = undef
  $daemon_debug                = undef

  $gui                         = true
  $gui_tls                     = true
  $gui_address                 = '0.0.0.0'
  $gui_port                    = '8080'
  $gui_apikey                  = undef
  $gui_user                    = undef
  $gui_password                = undef
  $gui_password_salt           = undef
  $gui_options                 = {}

  $defaultGlobalAnnounceServer = $::syncthing::params::defaultGlobalAnnounceServer

  $instance_options            = {}

  $device_compression          = false
  $device_introducer           = false
  $device_options              = {}
}
