class github-pages {
    $as_vagrant = 'sudo -u vagrant -H bash -l -c'
    
	package {'ruby':
		ensure  => 'installed',
		require => Class['system-update'],
        notify => Exec['install-rvm'],
	}
    
    exec {'gpg-signature':
        command => "${as_vagrant} 'gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3'",
        notify => Exec['install-rvm'],
    }
    
    exec {'install-rvm': 
        command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable --ruby'",
        require => [Package['curl'], Exec['gpg-signature']],
        notify => Exec['update-ruby'],
    }
    
    exec {'update-ruby':
        command => "${as_vagrant} 'rvm install 2.0.0 --autolibs=enabled && rvm --fuzzy alias create default 2.0.0'",
        #onlyif => 'type rvm | head -1 | grep -c \'rvm is a function\' | wc -l',
        require => Exec['install-rvm'],
        notify => Exec['install-bundler'],
    }
    
    exec {'install-bundler':
        command => "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'",
        onlyif => 'dpkg -l | grep -c ruby | wc -l',
		require => [Package['ruby'], Exec['update-ruby']],
    }
    
    file {'/vagrant/Gemfile':
        source  => 'puppet:///modules/github-pages/Gemfile',
		require => Package['ruby'],
    }
}
