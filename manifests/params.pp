class syncthing::params {
  $binpath                = '/usr/bin/syncthing'
  $instancespath          = '/etc/syncthing'

  $package_version        = 'latest'

  $manage_repo            = true
  $package_name           = 'syncthing'

  $default_instances      = {}
  $default_devices        = {}
  $default_folders        = {}

  $create_home_path       = true

  # Determine service provider to manage files for
  # Perhaps we can make use of the service_provider fact?
  if ($::service_provider) {
    if ($::service_provider == 'systemd') {
      $service_type = 'systemd'
    } elsif ($::service_provider == 'upstart') {
      $service_type = 'initd'
    }
  }

  # No service_provider fact or no useful answer (https://tickets.puppetlabs.com/browse/PUP-6065)
  # Guess.
  if (!$service_type) {
    if ($::operatingsystem == 'Ubuntu') {
      if ($::lsbmajdistrelease + 0 >= 15) {
        $service_type = 'systemd'
      } else {
        $service_type = 'initd'
      }
    } elsif ($::operatingsystem == 'Debian') {
      if ($::lsbmajdistrelease + 0 >= 8) {
        $service_type = 'systemd'
      } else {
        $service_type = 'initd'
      }
    }
  }


  $daemon_uid             = 'root'

  # These will only be used when $service_type is "initd"
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
