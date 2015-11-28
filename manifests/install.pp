class syncthing::install {
  package { 'syncthing':
    ensure  => $::syncthing::version,
  }
}
