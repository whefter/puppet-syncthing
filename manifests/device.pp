define syncthing::device
(
  $ensure         = 'present',
  
  $home_path,
  $id,
  
  $device_name    = $name,
  $compression    = $::syncthing::device_compression,
  $introducer     = $::syncthing::device_introducer,
  $address        = 'dynamic',
  
  $options        = $::syncthing::device_options,
)
{
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }
  
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
    
    require     => [
      Class['syncthing'],
    ],
  }
  
  create_resources( ::syncthing::folder, $folders )
}