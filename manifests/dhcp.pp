# Class: trd::netsrv
#
# set up network services (DHCP, DNS) for a local TRD network
#
# Parameters:
#   $first_parameter:
#       description
#
# Actions:
#   - 
#
# Requires:
#   - 
#
# Sample Usage:
#
class network::dhcp (
  $network,
  $netmask,
  $gateway,
  $nameservers,
  $interfaces,
  $hosts,
  $extraconf = {},
  $dnsdomain = undef
)
{

  class { 'dhcp':
    service_ensure => running,
    dnsdomain => $dnsdomain,
    #dnsdomain      => [
    #                   'trd.local',
    #                   #'10.55.44.in-addr.arpa',
    #                   ],
    nameservers  => $nameservers,
    #ntpservers   => ['us.pool.ntp.org'],
    interfaces   => $interfaces,
    #dnsupdatekey => '/etc/bind/keys.d/rndc.key',
    #dnskeyname   => 'rndc-key',
    #require      => Bind::Key['rndc-key'],
    #pxeserver    => '10.0.1.50', 
    #pxefilename  => 'pxelinux.0',
    #omapi_port   => 7911,
    dhcp_conf_fragments => $extraconf,
  }

  # create the subnet declaration
  dhcp::pool { 'trd.local':
    network => $network,
    mask    => $netmask,
    #range   => '10.99.0.240 10.99.0.250',
    gateway => $gateway,
  }

  # create DHCP entries for all hosts that have a MAC
  $dhcphosts = $hosts.filter |$h| { $h['mac'] != undef }
  $dhcphosts.each | $h | {
    dhcp::host { $h['name']: mac => $h['mac'], ip => $h['ip'] }
  }
  
}



# Local Variables:
#   mode: puppet
#     puppet-indent-level: 4
#     indent-tabs-mode: nil
# End:
