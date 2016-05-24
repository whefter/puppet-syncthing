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

  syncthing::element{ "set device ${device_id} address ${address} in instance ${home_path}":
    ensure         => $ensure,
    home_path      => $home_path,
    element        => 'address',
    value          => $address,
    parent_element => 'device',
    parent_id      => $device_id,
  }
}
