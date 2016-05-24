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

  validate_re($compression, '^(metadata|always|never)$')
  validate_bool($introducer)

  unless empty($options) {
    warning('DEPRECATION: $options parameter support will be removed in future release. Please use syncthing::address class instead.')
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
      before => Syncthing::Address["${id}:${address}"],
    }

    $options.each | $option, $value | {
      ::syncthing::element { "set device ${id} option ${option} in instance ${home_path}":
        home_path      => $home_path,
        parent_element => 'device',
        parent_id      => $id,
        element        => $option,
        value          => $value,
        require        => [
          Augeas["update device ${id} in instance ${home_path}"],
          Augeas["create device ${id} in instance ${home_path}"],
        ],
      }
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

  ::syncthing::address{ "${id}:${address}":
    home_path => $home_path,
    device_id => $id,
    address   => $address,
    ensure    => $ensure,
  }

}
