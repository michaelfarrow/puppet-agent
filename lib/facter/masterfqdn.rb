Facter.add("masterfqdn") do
	setcode do
		Facter::Core::Execution.exec('[[ -f /etc/puppet/master_conf ]] && cat /etc/puppet/master_conf')
	end
end