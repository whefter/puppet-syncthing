# Resource: syncthing::address
#
# This resource adds address entry to specified device in config.xml
define syncthing::address
(
  $home_path,
  $device_id,
  $address,

  $ensure = 'present',
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
        notify => [
      Service['syncthing'],
    ],

    require => [
      Class['syncthing'],
    ],
  }

  if $ensure == 'present' {

    # Add first element with top padding
    augeas { "create address ${address} for device ${device_id} in instance ${home_path}":
      changes => [
        "set device[#attribute/id='${device_id}']/#text[1] '\n        '",
        "ins address after device[#attribute/id='${device_id}']/#text[last()]",
        "set device[#attribute/id='${device_id}']/address[last()]/#text '${address}'",
        "ins #text after device[#attribute/id='${device_id}']/address[last()]",
        "set device[#attribute/id='${device_id}']/address[last()]/following-sibling::#text[1] '\n        '",
      ],
      onlyif => "match device[#attribute/id='${device_id}']/address size == 0",
    }

    # Add additional element
    augeas { "create additional address ${address} for device ${device_id} in instance ${home_path}":
      changes => [
        "ins address after device[#attribute/id='${device_id}']/address[last()]",
        "set device[#attribute/id='${device_id}']/address[last()]/#text '${address}'",
        "ins #text before device[#attribute/id='${device_id}']/address[last()]",
        "set device[#attribute/id='${device_id}']/address[last()]/preceding-sibling::#text[1] '        '",
      ],
      onlyif => "match device[#attribute/id='${device_id}']/address[#text='${address}'] size == 0",
      require => Augeas["create address ${address} for device ${device_id} in instance ${home_path}"],
    }

    # Set up proper bottom padding
    augeas { "create bottom padding for address ${address} for device ${device_id} in instance ${home_path}":
      changes => [
        "set device[#attribute/id='${device_id}']/#text[last()] '    '",
      ],
      onlyif => "match device[#attribute/id='${device_id}']/address size > 0",
      require => Augeas["create additional address ${address} for device ${device_id} in instance ${home_path}"],
    }

  } else {

    # Remove element
    augeas { "remove address ${address} for device ${device_id} in instance ${home_path}":
      changes => [
      "rm device[#attribute/id='${device_id}']/address[#text='${address}']/following-sibling::#text[1]",
      "rm device[#attribute/id='${device_id}']/address[#text='${address}']",
      ],
    }

    # Remove all paddings if there is no more address element
    augeas { "remove padding for device ${device_id} in instance ${home_path}":
      changes => "rm device[#attribute/id='${device_id}']/#text",
      onlyif  => "match device[#attribute/id='${device_id}']/address size == 0",
      require => Augeas["create bottom padding for address ${address} for device ${device_id} in instance ${home_path}"],
    }

    # Set up prosper bottom padding after removing element
    augeas { "create bottom padding for address ${address} for device ${device_id} in instance ${home_path}":
      changes => [
        "set device[#attribute/id='${device_id}']/#text[last()] '    '",
      ],
      onlyif => "match device[#attribute/id='${device_id}']/address size > 0",
      require => Augeas["remove address ${address} for device ${device_id} in instance ${home_path}"],
    }

  }

}
