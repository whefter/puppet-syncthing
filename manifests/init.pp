class syncthing
(
  $bin                = $::syncthing::params::bin,
  $binpath            = $::syncthing::params::binpath,
  $store_path         = $::syncthing::params::store_path,
  $instancespath      = $::syncthing::params::instancespath,
  $architecture       = $::syncthing::params::architecture,
  $version            = $::syncthing::params::version,
  $kernel             = $::syncthing::params::kernel,
  
  $instances          = $::syncthing::params::default_instances,
  $devices            = $::syncthing::params::default_devices,
  $folders            = $::syncthing::params::default_folders,
  
  $daemon_uid         = $::syncthing::params::daemon_uid,
  $daemon_gid         = $::syncthing::params::daemon_gid,
  $daemon_umask       = $::syncthing::params::daemon_umask,
  $daemon_nice        = $::syncthing::params::daemon_nice,
  $daemon_debug       = $::syncthing::params::daemon_debug,
  $gui                = $::syncthing::params::gui,
  $gui_tls            = $::syncthing::params::gui_tls,
  $gui_address        = $::syncthing::params::gui_address,
  $gui_port           = $::syncthing::params::gui_port,
  $gui_apikey         = $::syncthing::params::gui_apikey,
  $gui_user           = $::syncthing::params::gui_user,
  $gui_password       = $::syncthing::params::gui_password,
  $gui_options        = $::syncthing::params::gui_options,
  $instance_options   = $::syncthing::params::instance_options,
  
  $device_compression = $::syncthing::params::device_compression,
  $device_introducer  = $::syncthing::params::device_introducer,
  $device_options     = $::syncthing::params::device_options,
)
inherits syncthing::params
{
  class { '::syncthing::install': } ->
  class { '::syncthing::service': }
  
  create_resources( ::syncthing::instance,  $instances )
  create_resources( ::syncthing::device,    $devices )
  create_resources( ::syncthing::folder,    $folders )
}