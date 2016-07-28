define syncthing::install_binary
(
  $path,
  $version,
  $user,
  $group,
) {
  $kernel = downcase($facts['kernel']) ? {
    'linux' => 'linux',
    default => 'linux',
  }
  # $facts['os']['architecture']
  $architecture = downcase($facts['architecture']) ? {
    'amd64'  => 'amd64',
    'x86_64' => 'amd64',
    'x86'    => '386',
    '386'    => '386',
    'i386'   => '386',
    default  => '386',
  }

  $download_url = strip(template('syncthing/download_url.erb'))
  $basename = regsubst(inline_template('<%- require "uri" -%><%= File.basename(URI.parse(@download_url).path) %>'), '(-v\d+\.\d+\.\d+)[\w\.]+$', '\1', '')

#  notify { $download_url: }

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
  ->
  exec { "download and unpack syncthing for ${name}":
    cwd     => $path,
    path    => $::path,
    user    => $daemon_uid,
    command => "wget -O - ${download_url} | tar xzf - --strip-components=1",
#    creates => "${path}/${basename}",
    creates => "${path}/syncthing",
  }
#   ->
#  file { "${path}/syncthing":
#    ensure => link,
#    owner  => $user,
#    group  => $group,
#    target => "${path}/${basename}/syncthing",
#  }
}
