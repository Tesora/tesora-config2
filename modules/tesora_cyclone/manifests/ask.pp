# == Class: tesora_cyclone::ask
#
# ask.openstack.org Q&A support website
#
class tesora_cyclone::ask (
  $db_password,
  $redis_password,
  $site_ssl_cert_file_contents,
  $site_ssl_key_file_contents,
  $site_ssl_chain_file_contents,
  $db_name                      = 'askbotdb',
  $db_user                      = 'ask',
  $redis_port                   = '6378',
  $redis_max_memory             = '512m',
  $redis_bind                   = '127.0.0.1',
  $solr_version                 = '4.10.4',
  $askbot_revision              = '06be25e5d1aa013a9a201a92db4b35b1ee1f3d32'
) {

  file { '/srv/dist':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # solr search engine
  file { '/srv/dist/solr':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/srv/dist'],
  }

  class { 'solr':
    mirror    => 'https://archive.apache.org/dist/lucene/solr',
    version   => $solr_version,
    cores     => [ 'core-default', 'core-en', 'core-zh' ],
    dist_root => '/srv/dist/solr',
    require   => File['/srv/dist/solr'],
  }

  file { '/usr/share/solr/core-en/conf/schema.xml':
    ensure  => present,
    content => template('tesora_cyclone/askbot/schema.en.xml.erb'),
    replace => true,
    owner   => 'jetty',
    group   => 'jetty',
    mode    => '0644',
    require => File['/usr/share/solr/core-zh/conf'],
  }

  file { '/usr/share/solr/core-zh/conf/schema.xml':
    ensure  => present,
    content => template('tesora_cyclone/askbot/schema.cn.xml.erb'),
    replace => true,
    owner   => 'jetty',
    group   => 'jetty',
    mode    => '0644',
    require => File['/usr/share/solr/core-en/conf'],
  }

  # deploy smartcn Chinese analyzer from solr contrib/analysys-extras
  file { "/usr/share/solr/WEB-INF/lib/lucene-analyzers-smartcn-${solr_version}.jar":
    ensure  => present,
    replace => 'no',
    source  => "/srv/dist/solr/solr-${solr_version}/contrib/analysis-extras/lucene-libs/lucene-analyzers-smartcn-${solr_version}.jar",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Exec['copy-solr'], File['/srv/dist/solr'] ],
  }

  # postgresql database
  class { 'postgresql::server': }

  postgresql::server::db { $db_name:
    user     => $db_user,
    password => postgresql_password($db_user, $db_password),
  }

  # redis cache
  class { 'redis':
    redis_port       => $redis_port,
    redis_max_memory => $redis_max_memory,
    redis_bind       => $redis_bind,
    redis_password   => $redis_password,
    version          => '2.8.4',
    before           => Class['askbot'],
  }

  # askbot site
  class { 'askbot':
    askbot_revision              => $askbot_revision,
    db_provider                  => 'pgsql',
    db_name                      => $db_name,
    db_user                      => $db_user,
    db_password                  => $db_password,
    redis_enabled                => true,
    redis_port                   => $redis_port,
    redis_max_memory             => $redis_max_memory,
    redis_bind                   => $redis_bind,
    redis_password               => $redis_password,
    custom_theme_enabled         => true,
    custom_theme_name            => 'os',
    site_name                    => 'ask.openstack.org',
    askbot_debug                 => false,
    solr_enabled                 => true,
    site_ssl_enabled             => true,
    site_ssl_cert_file           => '/etc/ssl/certs/ask.openstack.org.pem',
    site_ssl_key_file            => '/etc/ssl/private/ask.openstack.org.key',
    site_ssl_chain_file          => '/etc/ssl/certs/ask.openstack.org_ca.pem',
    site_ssl_cert_file_contents  => $site_ssl_cert_file_contents,
    site_ssl_key_file_contents   => $site_ssl_key_file_contents,
    site_ssl_chain_file_contents => $site_ssl_chain_file_contents,
  }

  # askbot-theme openstack theme
  git { 'askbot-theme':
    ensure  => present,
    path    => '/srv/askbot-site/themes',
    branch  => 'master',
    origin  => 'https://git.openstack.org/openstack-infra/askbot-theme',
    latest  => true,
    require => [
      File['/srv/askbot-site'], Package['git']
    ],
    before  => Exec['askbot-syncdb'],
    notify  => [
      Exec['theme-bundle-install-os'],
      Exec['theme-bundle-compile-os'],
      Exec['askbot-static-generate'],
    ],
  }

  askbot::theme::compass { 'os':
    require => Git['askbot-theme'],
    before  => Exec['askbot-static-generate'],
  }

  # site backup
  pgsql_backup::backup { $db_name:
    database_user     => $db_user,
    database_password => $db_password,
    require           => Postgresql::Server::Db[$db_name],
    num_backups       => '10',
  }

  include bup
  bup::site { 'rs-ord':
    backup_user   => 'bup-ask',
    backup_server => 'ci-backup-rs-ord.openstack.org',
  }

  class { '::httpd::logrotate':
    options => [
      'daily',
      'missingok',
      'rotate 7',
      'compress',
      'delaycompress',
      'notifempty',
      'create 640 root adm',
    ],
  }
}
