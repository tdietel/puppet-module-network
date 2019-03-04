# Class: network::dns
#
# Install a DNS server using bind
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
class network::dns (
  $srvip,
  $srvname,
  $domain,
  $rdomain,
  $network,
  #$netmask,
  #$gateway,
  $nameservers,
  #$interfaces,
  $hosts,
  #$dnsdomain = undef
)
{
  include bind

  #notice($network)

  # determine the domain name for reverse lookups
  #$rdomain = "${network.split('\.')[0,3].reverse().join(".")}.in-addr.arpa"
  #notice($rdomain)

  $arecords = $hosts.filter |$h| { $h['ip'] != undef }
  $cnames   = $hosts.filter |$h| { $h['cname'] != undef }

  
  bind::server::conf { '/etc/named.conf':
    listen_on_addr    => [ $srvip ],
    #listen_on_v6_addr => [ ],
    forwarders        => $nameservers,
    #allow_query       => [ 'localnets' ],
    allow_query       => [ 'any' ],

    dnssec_enable     => 'no',
    dnssec_validation => 'no',
    dnssec_lookaside  => 'auto',
    
    zones             => {
      $domain  => [ 'type master', "file \"$domain\"" ], 
      #$rdomain => [ 'type master', "file \"$rdomain\"" ], 
    },
  }

  bind::server::file { $domain:
    content => template("network/dns-zone.erb")
  }

  
}





# Local Variables:
#   mode: puppet
#     puppet-indent-level: 4
#     indent-tabs-mode: nil
# End:
