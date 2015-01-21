class syncthing
(
  $binpath        = '/usr/bin/syncthing',
  $bin            = 'syncthing',
  #$package        =
  $version        = '0.10.20',
  
  $instancespath  = '/etc/syncthing',
  
  $instances      = {},
)
{
  class { '::syncthing::repo': }
  ->
  class { '::syncthing::install': }
  ->
  class { '::syncthing::service': }
  
  create_resources( ::syncthing::instance, $instances )
}