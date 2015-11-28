define syncthing::instance
(
  $home_path,

  $ensure             = 'present',

  $daemon_uid         = $::syncthing::daemon_uid,
  $daemon_gid         = $::syncthing::daemon_gid,
  $daemon_umask       = $::syncthing::daemon_umask,
  $daemon_nice        = $::syncthing::daemon_nice,
  $daemon_debug       = $::syncthing::daemon_debug,

  $gui                = $::syncthing::gui,
  $gui_tls            = $::syncthing::gui_tls,
  $gui_address        = $::syncthing::gui_address,
  $gui_port           = $::syncthing::gui_port,
  $gui_apikey         = $::syncthing::gui_apikey,
  $gui_user           = $::syncthing::gui_user,
  $gui_password       = $::syncthing::gui_password,
  $gui_password_salt  = $::syncthing::gui_password_salt,
  $gui_options        = $::syncthing::gui_options,

  $options            = $::syncthing::instance_options,
)
{
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }

  validate_bool($gui)
  validate_hash($gui_options)
  validate_hash($options)
  
  if $gui_password_salt {
    validate_string($gui_password_salt)
  }

#  if $gui_password and !$gui_password_salt {
#    fail("When specifying a GUI password, a salt must be supplied (or else your instance will restart on every puppet run.")
#  }

  $instance_config_path     = "${syncthing::instancespath}/${name}.conf"
  $instance_config_xml_path = "${home_path}/config.xml"

  if $ensure == 'present' {
    file { $instance_config_path:
      content => template('syncthing/instance.conf.erb'),
      owner   => $daemon_uid,
      group   => $daemon_gid,
      mode    => '0600',

      notify  => [
        Service['syncthing'],
      ],
    }

    exec { "create syncthing instance ${name} home":
      path     => $::path,
      command  => "su - ${daemon_uid} -c \"${syncthing::binpath} -generate \\\"${home_path}\\\"\"",
      creates  => $instance_config_xml_path,
      provider => shell,

      notify   => [
        Service['syncthing'],
      ],

      require  => [
        Class['::syncthing::install'],
      ],
    }

    if $gui_password_salt {
      $gui_password_hashed = bcrypt($gui_password, $gui_password_salt)
    } else {
      $gui_password_hashed = undef
    }

    $changes = parseyaml( template('syncthing/config-changes.yaml.erb') )

    #notify { 'debug': message => $changes }

    augeas { "syncthing ${name} basic config":
      incl    => $instance_config_xml_path,
      lens    => 'Xml.lns',
      context => "/files${instance_config_xml_path}/configuration",
      changes => $changes,

      require => [
        Exec["create syncthing instance ${name} home"],
      ],

      notify  => [
        Service['syncthing'],
      ],
    }
  } else {
    file { [$home_path, $instance_config_path]:
      ensure => absent,

      notify => [
        Service['syncthing'],
      ],
    }
  }
}
