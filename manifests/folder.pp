define syncthing::folder
(
  $home_path,
  $path,
  
  $ensure           = 'present',
  
  $id               = $name,
  
  $ro               = false,
  $rescanIntervalS  = '60',
  $ignorePerms      = false,
  
  $options          = {},
  
  # This is a hash containing pairs such as 'id' => 'absent/present'
  $devices          = {},
)
{
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }
  
  $instance_config_xml_path = "${home_path}/config.xml"
  
  if $ensure == 'present' {
    $changes = parseyaml( template('syncthing/config_folder-changes.yaml.erb') )
  } else {
    $changes = "rm folder[#attribute/id='${id}']"
  }

  augeas { "configure instance ${home_path} folder ${id}":
    incl    => $instance_config_xml_path,
    lens    => 'Xml.lns',
    context => "/files${instance_config_xml_path}/configuration",
    changes => $changes,
    
    notify  => [
      Service['syncthing'],
    ],
    
    require => [
      Class['syncthing'],
    ],
  }
}
