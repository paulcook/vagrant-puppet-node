$project_dir = 'mass_matrix'
$db_names = ['mass_matrix_development','mass_matrix_test']

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

include stdlib

# Update the system before starting with ruby etc
class { 'apt':
  always_apt_update => true,
}

package { ['python-software-properties']:
  ensure  => 'installed',
  require => Class['apt'],
}

$sysPackages = [ 'build-essential', 'git', 'vim', 'libxml2','libxml2-dev','libxslt1-dev','nodejs']

package { $sysPackages:
  ensure => "installed",
  require => Class['apt'],
}

class { 'apache':
  mpm_module => 'worker',
  require => Class['apt'],
}

user { 'vagrant':
  ensure => present,
}

# Exec { environment => ["rvmsudo_secure_path=1"] }

 # Install RVM and some gems then passenger/apache
class { 'rvm':
  version => '1.25.33',
  require => Class['apache'],
}

rvm::system_user { vagrant: }

rvm_system_ruby {
  'ruby-2.1.5':
    ensure => present,
    require => Class['rvm::system'],
    default_use => true;
}

rvm_gem {
  'ruby-2.1.5/bundler':
    ensure => latest,
    require => Rvm_system_ruby['ruby-2.1.5'];
}

class {
  'rvm::passenger::apache':
    version => '4.0.57',
    ruby_version => 'ruby-2.1.5';
}

include '::mongodb::server'
