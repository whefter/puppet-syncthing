define syncthing::folder_device
(
  $home_path,

  $folder_id,
  $device_id,

  $ensure           = 'present',
)
{
  if ! defined(Class['syncthing']) {
    fail('You must include the syncthing base class before using any syncthing defined resources')
  }

  $instance_config_xml_path = "${home_path}/config.xml"

  if $ensure == 'present' {
    $changes = "set folder[#attribute/id='${folder_id}']/device/#attribute/id ${device_id}"
  } else {
    $changes = "rm folder[#attribute/id='${folder_id}']/device[#attribute/id='${device_id}']"
  }

  augeas { "configure instance ${home_path} folder ${folder_id} device ${device_id}":
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
