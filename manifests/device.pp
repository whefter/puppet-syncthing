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

    augeas { "update device ${id} in instance ${home_path}":
      changes => [
        "set device[#attribute/id='${id}']/#attribute/name ${device_name}",
        "set device[#attribute/id='${id}']/#attribute/compression ${compression}",
        "set device[#attribute/id='${id}']/#attribute/introducer ${introducer}",
      ],
      onlyif => "match device[#attribute/id='${id}'] size > 0",
    }

    augeas { "create device ${id} in instance ${home_path}":
      changes => [
        "ins #text after device[last()]",
        "set device[last()]/following-sibling::#text[1] '    '",
        "ins device after device[last()]/following-sibling::#text[1]",
        "set device[last()]/#attribute/id ${id}",
        "set device[#attribute/id='${id}']/#attribute/name ${device_name}",
        "set device[#attribute/id='${id}']/#attribute/compression ${compression}",
        "set device[#attribute/id='${id}']/#attribute/introducer ${introducer}",
      ],
      onlyif => "match device[#attribute/id='${id}'] size == 0",
    }

  } else {

    augeas { "remove device ${id} in instance ${home_path}":
      changes => [
        "rm device[#attribute/id='${id}']/preceding-sibling::#text[1]",
        "rm device[#attribute/id='${id}']",
      ],
      onlyif => "match device[#attribute/id='${id}'] size > 0",
    }

  }

}
