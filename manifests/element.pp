# Resource: syncthing::element
#
# This is private class, which is used to add elements to XML file
define syncthing::element
(
  $home_path,
  $element,
  $parent_element,
  $parent_id,
  $value,

  $ensure = 'present',
)
{

  # Private class checking
  assert_private("Use of private class ${name} by ${caller_module_name}")

  # Hacky indent definition
  $indent_1 = '    '
  $indent_2 = '        '

  $instance_config_xml_path = "${home_path}/config.xml"

  Augeas {
    incl    => $instance_config_xml_path,
    lens    => 'Xml.lns',
    context => "/files${instance_config_xml_path}/configuration",
    #    notify => [
    #  Service['syncthing'],
    #],

    require => [
      Exec["create syncthing instance ${home_path}"],
    ],
  }

  if $ensure == 'present' {

    # Add first element with top padding
    augeas { "create ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}":
      changes => [
        "set ${parent_element}[#attribute/id='${parent_id}']/#text[1] '\n${indent_2}'",
        "ins ${element} after ${parent_element}[#attribute/id='${parent_id}']/#text[last()]",
        "set ${parent_element}[#attribute/id='${parent_id}']/${element}[last()]/#text '${value}'",
        "ins #text after ${parent_element}[#attribute/id='${parent_id}']/${element}[last()]",
        "set ${parent_element}[#attribute/id='${parent_id}']/${element}[last()]/following-sibling::#text[1] '\n${indent_2}'",
      ],
      onlyif => "match ${parent_element}[#attribute/id='${parent_id}']/*[label() != '#attribute'] size == 0",
    }

    # Add additional element
    augeas { "create additional ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}":
      changes => [
        "ins ${element} after ${parent_element}[#attribute/id='${parent_id}']/#text[last()]/preceding-sibling::*[1]",
        "set ${parent_element}[#attribute/id='${parent_id}']/${element}[last()]/#text '${value}'",
        "ins #text before ${parent_element}[#attribute/id='${parent_id}']/${element}[last()]",
        "set ${parent_element}[#attribute/id='${parent_id}']/${element}[last()]/preceding-sibling::#text[1] '${indent_2}'",
      ],
      onlyif => "match ${parent_element}[#attribute/id='${parent_id}']/${element}[#text='${value}'] size == 0",
      require => Augeas["create ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}"],
    }

    # Set up proper bottom padding
    augeas { "create bottom padding for ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}":
      changes => [
        "set ${parent_element}[#attribute/id='${parent_id}']/#text[last()] '${indent_1}'",
      ],
      onlyif => "match ${parent_element}[#attribute/id='${parent_id}']/*[label() != '#attribute'] size > 0",
      require => Augeas["create additional ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}"],
    }

  } else {

    # Remove element
    augeas { "remove ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}":
      changes => [
      "rm ${parent_element}[#attribute/id='${parent_id}']/${element}[#text='${value}']/following-sibling::#text[1]",
      "rm ${parent_element}[#attribute/id='${parent_id}']/${element}[#text='${value}']",
      ],
    }

    # Remove all paddings if there is no more elements
    augeas { "remove padding for ${parent_element} ${parent_id} in instance ${home_path}":
      changes => "rm ${parent_element}[#attribute/id='${parent_id}']/#text",
      onlyif  => "match ${parent_element}[#attribute/id='${parent_id}']/*[label() != '#attribute'] size == 1",
      require => Augeas["create bottom padding for ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}"],
    }

    # Set up prosper bottom padding after removing element
    augeas { "create bottom padding for ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}":
      changes => [
        "set ${parent_element}[#attribute/id='${parent_id}']/#text[last()] '${indent_1}'",
      ],
      onlyif => "match ${parent_element}[#attribute/id='${parent_id}']/*[label() != '#attribute'] size > 0",
      require => Augeas["remove ${element} ${value} for ${parent_element} ${parent_id} in instance ${home_path}"],
    }

  }

}
