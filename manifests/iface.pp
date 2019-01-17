# Definition: network_if_base
#
# This definition is private, i.e. it is not intended to be called directly
# by users.  It can be used to write out the following device files:
#  /etc/sysconfig/networking-scripts/ifcfg-eth
#  /etc/sysconfig/networking-scripts/ifcfg-eth:alias
#  /etc/sysconfig/networking-scripts/ifcfg-bond(master)
#
# Parameters:
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $macaddress   - required
#   $gateway      - optional
#   $bootproto    - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $isalias      - optional
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#
# Actions:
#   Performs 'ifup/ifdown $name' after any changes to the ifcfg file.
#
# Requires:
#
# Sample Usage:
#
# TODO:
#   METRIC=
#   HOTPLUG=yes|no
#   USERCTL=yes|no
#   WINDOW=
#   SCOPE=
#   SRCADDR=
#   NOZEROCONF=yes
#   PERSISTENT_DHCLIENT=yes|no|1|0
#   DHCPRELEASE=yes|no|1|0
#   DHCLIENT_IGNORE_GATEWAY=yes|no|1|0
#   LINKDELAY=
#   REORDER_HDR=yes|no
#
define network::iface (
  $ensure,
  $ipaddress,
  $netmask,
  $macaddress,
  $gateway = '',
  $bootproto = 'none',
  $mtu = '',
  $ethtool_opts = '',
  #$peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = ''
)
{
  # Validate our booleans
  #validate_bool($peerdns)
  # Validate our regular expressions

  #$states = [ '^up$', '^down$' ]
  #validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  $interface = $name

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 != '' {
    if $dns1 == '' {
      $dns1_real = $dns2
      $dns2_real = ''
    } else {
      $dns1_real = $dns1
      $dns2_real = $dns2
    }
  } else {
    $dns1_real = $dns1
    $dns2_real = $dns2
  }

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-eth.erb'),
  }

  case $ensure {
    'up': {
      exec { "ifup-${interface}":
        command     => "/sbin/ifdown ${interface}; /sbin/ifup ${interface}",
        subscribe   => File["ifcfg-${interface}"],
        refreshonly => true,
      }
    }

    'down': {
      exec { "ifdown-${interface}":
        command     => "/sbin/ifdown ${interface}",
        subscribe   => File["ifcfg-${interface}"],
        refreshonly => true,
      }
    }
    default: {}
  }

} # define network::iface


# Local Variables:
#   mode: puppet
#     puppet-indent-level: 4
#     indent-tabs-mode: nil
# End:
