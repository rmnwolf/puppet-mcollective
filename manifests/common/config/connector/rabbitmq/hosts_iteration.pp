# private define
# $name will be an index into the $mcollective::middleware_hosts_real array + 1
define mcollective::common::config::connector::rabbitmq::hosts_iteration {
  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.host":
    value => $mcollective::middleware_hosts_real[$name - 1], # puppet array 0-based
  }

  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.port":
    value => $mcollective::middleware_port,
  }

  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.user":
    value => $mcollective::middleware_user_real,
  }

  mcollective::common::setting { "plugin.rabbitmq.pool.${name}.password":
    value => $mcollective::middleware_password_real,
  }

  if $mcollective::middleware_ssl {
    mcollective::common::setting { "plugin.rabbitmq.pool.${name}.ssl":
      value => 1,
    }

    mcollective::common::setting { "plugin.rabbitmq.pool.${name}.ssl.ca":
      value => '/etc/mcollective/ca.pem',
    }

    mcollective::common::setting { "plugin.rabbitmq.pool.${name}.ssl.fallback":
      value => 0,
    }
  }
}
