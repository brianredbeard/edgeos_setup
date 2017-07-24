# aws_vpnconfig.py

## About
`aws_vpnconfig` is a utility for generating the following configurations
snippets related to the configuration of a point to point VPN with AWS:

  - NAT configuration
  - IPSEC
    - Encapsulating Security Payload (ESP) settings
    - Internet Key Exchange (IKE) Settings
  - Virtual Tunnel Interfaces
  - Peer configurations
  - Relevant static routes
  
## Usage

As this utility uses the [`boto3`][boto3] Python library users will need
to comply with it's configuration idioms.  As such the following environment
variables should be used:

### Authentication

User authentication can be configured through the following combinations:

Option 1 ("traditional" AWS Configration):
  - `AWS_ACCESS_KEY`
  - `AWS_SECRET_ACCESS_KEY`

Option 2 (AWS Profiles):
  - `AWS_PROFILE`

Option 3 (AWS Session Tokens):
  - `AWS_ACCESS_KEY`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_SESSION_TOKEN`

### Region configuration

The desired region is configured using the `AWS_DEFAULT_REGION` environment
variable.

## Example Usage:

```
$ AWS_PROFILE=coreosinc AWS_DEFAULT_REGION=us-west-1 ./aws_vpnconfig.py

set vpn ipsec auto-firewall-nat-exclude enable

set vpn ipsec esp-group aws-vpc compression disable
set vpn ipsec esp-group aws-vpc lifetime 3600
set vpn ipsec esp-group aws-vpc mode tunnel
set vpn ipsec esp-group aws-vpc pfs enable
set vpn ipsec esp-group aws-vpc proposal 1 encryption aes128
set vpn ipsec esp-group aws-vpc proposal 1 hash sha1

set vpn ipsec ike-group aws-vpc dead-peer-detection action restart
set vpn ipsec ike-group aws-vpc dead-peer-detection 10
set vpn ipsec ike-group aws-vpc dead-peer-detection timeout 30
set vpn ipsec ike-group aws-vpc ikev2-reauth no
set vpn ipsec ike-group aws-vpc key-exchange ikev1
set vpn ipsec ike-group aws-vpc lifetime 28800
set vpn ipsec ike-group aws-vpc proposal 1 dh-group 2
set vpn ipsec ike-group aws-vpc proposal 1 encryption aes128
set vpn ipsec ike-group aws-vpc proposal 1 hash sha1

set interfaces vti vti0 address 169.254.6.82/30
set interfaces vti vti0 description 'AWS dev-office-sfo'
set interfaces vti vti0 mtu 1379

set vpn ipsec site-to-site peer 128.66.23.45 authentication mode pre-shared-secret
set vpn ipsec site-to-site peer 128.66.23.45 authentication pre-shared-secret maengoo8xain6OhHahcofie1SohMeek
set vpn ipsec site-to-site peer 128.66.23.45 connection-type initiate
set vpn ipsec site-to-site peer 128.66.23.45 description 'AWS dev-office-sfo'
set vpn ipsec site-to-site peer 128.66.23.45 ike-group aws-vpc
set vpn ipsec site-to-site peer 128.66.23.45 ikev2-reauth inherit
set vpn ipsec site-to-site peer 128.66.23.45 local-address 203.0.113.25
set vpn ipsec site-to-site peer 128.66.23.45 vti bind vti0
set vpn ipsec site-to-site peer 128.66.23.45 vti ips-group aws-vpc

set interfaces vti vti1 address 169.254.6.206/30
set interfaces vti vti1 description 'AWS dev-office-nyc'
set interfaces vti vti1 mtu 1379

set vpn ipsec site-to-site peer 128.66.81.21 authentication mode pre-shared-secret
set vpn ipsec site-to-site peer 128.66.81.21 authentication pre-shared-secret TeeDiex5foo6zoeBoodaiDo6Fopoo5o
set vpn ipsec site-to-site peer 128.66.81.21 connection-type initiate
set vpn ipsec site-to-site peer 128.66.81.21 description 'AWS dev-office-nyc'
set vpn ipsec site-to-site peer 128.66.81.21 ike-group aws-vpc
set vpn ipsec site-to-site peer 128.66.81.21 ikev2-reauth inherit
set vpn ipsec site-to-site peer 128.66.81.21 local-address 198.51.100.50
set vpn ipsec site-to-site peer 128.66.81.21 vti bind vti1
set vpn ipsec site-to-site peer 128.66.81.21 vti ips-group aws-vpc

set interfaces vti vti2 address 169.254.12.98/30
set interfaces vti vti2 description 'AWS prod-office-sfo'
set interfaces vti vti2 mtu 1379

set vpn ipsec site-to-site peer 128.66.1.0 authentication mode pre-shared-secret
set vpn ipsec site-to-site peer 128.66.1.0 authentication pre-shared-secret vei4bai1Eir3aejeidoi3ooB7em9OPh
set vpn ipsec site-to-site peer 128.66.1.0 connection-type initiate
set vpn ipsec site-to-site peer 128.66.1.0 description 'AWS prod-office-sfo'
set vpn ipsec site-to-site peer 128.66.1.0 ike-group aws-vpc
set vpn ipsec site-to-site peer 128.66.1.0 ikev2-reauth inherit
set vpn ipsec site-to-site peer 128.66.1.0 local-address 203.0.113.25
set vpn ipsec site-to-site peer 128.66.1.0 vti bind vti2
set vpn ipsec site-to-site peer 128.66.1.0 vti ips-group aws-vpc

set interfaces vti vti3 address 169.254.13.14/30
set interfaces vti vti3 description 'AWS prod-office-nyc'
set interfaces vti vti3 mtu 1379

set vpn ipsec site-to-site peer 128.66.217.198 authentication mode pre-shared-secret
set vpn ipsec site-to-site peer 128.66.217.198 authentication pre-shared-secret mech8queoQuaih3zish8eiLoo3me8ah
set vpn ipsec site-to-site peer 128.66.217.198 connection-type initiate
set vpn ipsec site-to-site peer 128.66.217.198 description 'AWS prod-office-nyc'
set vpn ipsec site-to-site peer 128.66.217.198 ike-group aws-vpc
set vpn ipsec site-to-site peer 128.66.217.198 ikev2-reauth inherit
set vpn ipsec site-to-site peer 128.66.217.198 local-address 198.51.100.50
set vpn ipsec site-to-site peer 128.66.217.198 vti bind vti3
set vpn ipsec site-to-site peer 128.66.217.198 vti ips-group aws-vpc
```
