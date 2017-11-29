####################################
# Global configuration
####################################

$nodeName = 'icinga2-elastic' # TODO: Hiera.
$hostOnlyIP = '192.168.33.7'
$hostOnlyFQDN = 'icinga2x-elastic.vagrant.demo.icinga.com'

$elasticRepoVersion = '5.x'
$kibanaVersion = '5.3.1'
$icingabeatVersion = '1.1.0'
$icingabeatDashboardsChecksum = '9c98cf4341cbcf6d4419258ebcc2121c3dede020'
# keep this in sync with the icingabeat dashboard ids!
# http://192.168.33.7:5601/app/kibana#/dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426
$kibanaDefaultAppId = 'dashboard/720f2f20-0979-11e7-a4dd-e96fa284b426'

$elasticsearchListenIP = 'localhost'
$elasticsearchListenPort = '9200'

####################################
# Setup
####################################

class { '::profiles::base::system': }
->
class { '::profiles::base::mysql': }
->
class { '::profiles::base::apache': }
->
class { '::profiles::base::java': }
->
class { '::profiles::icinga::icinga2':
  features => [ "elasticsearch" ]
}
->
class { '::profiles::icinga::icingaweb2':
  icingaweb2_listen_ip => $hostOnlyIP,
  icingaweb2_fqdn => $hostOnlyFQDN,
  modules => {
    "elasticsearch" => {
      "listen_ip"   => $elasticsearchListenIP,
      "listen_port" => $elasticsearchListenPort
    }
  }
}
->
class { '::profiles::elastic::elasticsearch':
  repo_version => $elasticRepoVersion,
}
->
class { '::profiles::elastic::kibana':
  repo_version => $elasticRepoVersion,
  kibana_revision => "${kibanaVersion}-1",
  kibana_host => '127.0.0.1',
  kibana_port => 5601,
  kibana_default_app_id => $kibanaDefaultAppId
}
->
class { '::profiles::elastic::httpproxy':
  listen_ip => $hostOnlyIP,
  node_name => $nodeName
}
->
class { '::profiles::elastic::filebeat':
}
->
class { '::profiles::elastic::icingabeat':
  icingabeat_version => $icingabeatVersion,
  icingabeat_dashboards_checksum => $icingabeatDashboardsChecksum,
  kibana_version => $kibanaVersion
}

