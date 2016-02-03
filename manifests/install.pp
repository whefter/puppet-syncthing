class syncthing::install {
  package { $::syncthing::package_name:
    ensure  => $::syncthing::version,
  }
}
