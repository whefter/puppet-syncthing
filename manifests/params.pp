class syncthing::params {
  $bin                    = 'syncthing'
  $store_path             = '/usr/local/share/syncthing'
  $binpath                = '/usr/local/bin'
  $instancespath          = '/etc/syncthing'

  # These three variables are required to detect/build the correct download URL
  # $version can be set to latest and the download URL will be detected
  # using the Github API.
  $version                = 'latest'
  $architecture           = $::architecture ? {
    /64$/       => 'amd64',
    /86$/       => '386',
    /^arm/      => 'arm',
    default     => $::architecture,
  }
  $kernel                 = $::kernel ? {
    /^(L|l)inux$/       => 'linux',
    default             => $::kernel,
  }

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
