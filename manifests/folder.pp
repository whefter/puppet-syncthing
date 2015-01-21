define syncthing::folder
(
  $ensure           = 'present',
  $home_path,
  
  $id,
  
  $path,
  $ro               = 'false',
  $rescanIntervalS  = '60',
  $ignorePerms      = 'false',
  
  $options          = {},
)
{
  $instance_config_xml_path = "${home_path}/config.xml"
  
  if $ensure == 'present' {
    $changes = parseyaml( template('syncthing/config_folder-changes.yaml.erb') )
  } else {
    $changes = "rm folder[#attribute/id='${id}']"
  }

  augeas { "configure instance ${home_path} folder ${id}": 
    incl       => $instance_config_xml_path,
    lens       => 'Xml.lns',
    context    => "/files${instance_config_xml_path}/configuration",
    changes    => $changes,
    
    notify      => [
      Service['syncthing'],
    ],
  }
}