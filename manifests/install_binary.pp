define syncthing::install_binary
(
  $path,
  $version,
  $user,
  $group,
) {
  $kernel = downcase($::kernel) ? {
    'linux' => 'linux',
    default => 'linux',
  }
  # $facts['os']['architecture']
  $architecture = downcase($::architecture) ? {
    'amd64'  => 'amd64',
    'x86_64' => 'amd64',
    'x86'    => '386',
    '386'    => '386',
    'i386'   => '386',
    default  => '386',
  }

  $download_url = strip(template('syncthing/download_url.erb'))
  $basename = regsubst(inline_template('<%- require "uri" -%><%= File.basename(URI.parse(@download_url).path) %>'), '(-v\d+\.\d+\.\d+)[\w\.]+$', '\1', '')

#  notify { "${path}_${download_url}": message => length($download_url)}

  exec { "create binary folder for ${name}":
    command => "mkdir -p \"${path}\"",
    path    => $::path,
    user    => $user,
    creates => $path,
  }
  ->
  file { $path:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0770',
  }

  if length($download_url) > 0 {
    exec { "download and unpack syncthing for ${name}":
      cwd     => $path,
      path    => $::path,
      user    => $user,
      command => "wget -O - ${download_url} | tar xzf - --strip-components=1",
      creates => "${path}/syncthing",
      require => [
        File[$path],
      ],
    }
  } else {
    notify { "No download URL returned for syncthing binary for path ${path}. Perhaps the requested version is too old or there was an issue with the request to Github.": }
  }
}
