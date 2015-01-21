define syncthing::device
(
  $home_path,
  
  $id,
  
  $device_name    = $name,
  $ensure         = 'present',
  $compression,
  $introducer,
  $address        = 'dynamic',
  
  $options        = {},
  
  $folders        = {},
)
{
  $instance_config_xml_path = "${home_path}/config.xml"
  
  if $ensure == 'present' {
    $changes = parseyaml( template('syncthing/config_device-changes.yaml.erb') )
  } else {
    $changes = "rm device[#attribute/id='${id}']"
  }

  augeas { "configure instance ${home_path} device ${id}": 
    incl       => $instance_config_xml_path,
    lens       => 'Xml.lns',
    context    => "/files${instance_config_xml_path}/configuration",
    changes    => $changes,
    
    notify      => [
      Service['syncthing'],
    ],
  }
  
  create_resources( ::syncthing::folder, $folders )
}