class syncthing::install_package { 
  package { $::syncthing::package_name:
   ensure  => $::syncthing::package_version,
  }
  
  Package[$::syncthing::package_name] ~> Exec <| tag == 'syncthing_package_instance_service' and tag == 'syncthing_instance_service_restart' |>
}
