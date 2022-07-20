# TODO chuck this on to SSH in paramiko or something
from jinja2 import Template

c8000v_t = Template("""
crypto ikev2 proposal AzIKProp1
  encryption aes-cbc-256 aes-cbc-128 3des
  integrity sha1
  group 2


crypto ikev2 policy AzIKPol1
  proposal AzIKProp1
  dpd 10 30


crypto ikev2 keyring AzK1
 peer {{ vgw_ip }}
  address {{ vgw_ip }}
  pre-shared-key 4v3ry53cr371p53c5h4r3dk3y
 !
!

!
crypto ikev2 profile AzKP1
 match address local interface GigabitEthernet1
 match identity remote address {{ vgw_ip }} 255.255.255.255
 authentication remote pre-share
 authentication local pre-share
 keyring local AzK1


crypto ipsec transform-set T1 esp-aes 256 esp-sha-hmac
 mode tunnel

crypto ipsec profile P1
 set transform-set T1
 set ikev2-profile AzKP1


interface Tunnel1
vrf forwarding 1
 ip address {{ tunnel_ip }} {{ tunnel_mask }}
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination  {{ vgw_ip }}
 tunnel protection ipsec profile P1


vrf definition 1
 rd {{ bgp_as }}:1
 !
 address-family ipv4
 exit-address-family


interface Loopback1
 vrf forwarding 1
 ip address {{ bgp_loopback_ip }} 255.255.255.255



router bgp {{ bgp_as }}
 bgp log-neighbor-changes
 !
 address-family ipv4
 exit-address-family
 !
 address-family ipv4 vrf 1
  neighbor {{ vgw_bgp_ip }} remote-as 65515
  neighbor {{ vgw_bgp_ip }} ebgp-multihop 8
  neighbor {{ vgw_bgp_ip }} update-source Loopback1
  neighbor {{ vgw_bgp_ip }} activate
 exit-address-family
""")

