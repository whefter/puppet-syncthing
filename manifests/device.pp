define syncthing::device
(
  $home_path,
  $id,

  $ensure         = 'present',

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

  Augeas {
    incl    => $instance_config_xml_path,
    lens    => 'Xml.lns',
    context => "/files${instance_config_xml_path}/configuration",
    notify  => [
      Service['syncthing'],
    ],

    require => [
      Exec["create syncthing instance ${home_path}"],
    ],
  }

  if $ensure == 'present' {
    $changes = [
      "set device[#attribute/id='${id}']/#attribute/id ${id}",
      "set device[#attribute/id='${id}']/#attribute/name ${device_name}",
      "set device[#attribute/id='${id}']/#attribute/compression ${compression}",
      "set device[#attribute/id='${id}']/#attribute/introducer ${introducer}",
      "set device[#attribute/id='${id}']/#attribute/introducer ${introducer}",
    ]
  } else {
    $changes = "rm device[#attribute/id='${id}']"
  }

  augeas { "configure instance ${home_path} device ${id}":
    changes => $changes,
  }
}
