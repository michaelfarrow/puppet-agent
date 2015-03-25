class agent {

	if $agentfqdn != '' {
		$cond_agentfqdn = $agentfqdn
	} else {
		$cond_agentfqdn = $fqdn
	}

	if $masterfqdn != '' {
		$cond_masterfqdn = $masterfqdn
	} else {
		$cond_masterfqdn = $fqdn
	}

	if $agentenvironment != '' {
		$cond_environment = $agentenvironment
	} else {
		$cond_environment = $environment
	}

	host { "${hostname}":
		ensure       => absent,
	} ->

	host { "${::cond_agentfqdn}":
		ensure       => present,
		ip           => '127.0.1.1',
		host_aliases => [ $::hostname, 'localhost' ],
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

}
