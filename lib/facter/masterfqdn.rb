Facter.add("masterfqdn") do
	setcode do
		Facter::Core::Execution.exec('cat /etc/puppet/master_conf 2> /dev/null')
	end
end