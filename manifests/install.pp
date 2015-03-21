class syncthing::install {
  $download_url = strip(template('syncthing/download_url.erb'))
  $basename     = regsubst(inline_template('<%- require "uri" -%><%= File.basename(URI.parse(@download_url).path) %>'), '(-v\d+\.\d+\.\d+)[\w\.]+$', '\1', '')
    
  case $::osfamily {
    Debian: {
      file { $::syncthing::store_path:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }->
      exec { 'download and unpack syncthing':
        cwd     => $::syncthing::store_path,
        path    => $::path,
        command => "wget -O - ${download_url} | tar xzf -",
        creates => "${::syncthing::store_path}/${basename}",
      }->
      file { "${::syncthing::binpath}/${::syncthing::bin}":
        ensure => link,
        target => "${::syncthing::store_path}/${basename}/syncthing",
      }
    }
    default: {
        fail "Unsupported OS family: ${::osfamily}"
    }
  }

}
