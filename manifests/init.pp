class agent {

	if $::agentfqdn != '' {
		$cond_agentfqdn = $::agentfqdn
	} else {
		$cond_agentfqdn = $::fqdn
	}

	if $::masterfqdn != '' {
		$cond_masterfqdn = $::masterfqdn
	} else {
		$cond_masterfqdn = $::fqdn
	}

	if $agentenvironment != '' {
		$cond_environment = $agentenvironment
	} else {
		$cond_environment = $environment
	}

	$cond_fqdn_parts = split($cond_agentfqdn, '[.]')
	$cond_hostname = $cond_fqdn_parts[0]

	if $hostname != $cond_hostname {
		host { "${hostname}":
			ensure => absent,
			before => Host["${cond_agentfqdn}"],
		}
	}

	host { "${cond_agentfqdn}":
		ensure       => present,
		ip           => '127.0.1.1',
		host_aliases => [ $cond_hostname, 'localhost' ],
	} ->

	class { 'puppet':
		environment => $cond_environment,
		report      => true,
		pluginsync  => true,
		agent       => 'running',
		server      => $cond_masterfqdn
	}

	concat::fragment{'puppet_conf_agent_splay':
		target  => 'puppet_conf',
		content => "  splay = true\n",
		order   => '21',
	}

	Ini_setting {
		ensure     => present,
		path       => "/etc/puppet/puppet.conf",
	}

	ini_setting { 'ensure no templatedir':
		ensure     => absent,
		section    => 'main',
		setting    => 'templatedir',
		before     => Class['puppet'],
	}

	ini_setting { "set agent certname":
		ensure    => present,
		section   => "agent",
		setting   => "certname",
		value     => $cond_agentfqdn,
		require   => Package["puppet"],
	}
	
}
