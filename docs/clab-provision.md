# Containerlab Provisioning

> **Warning**
> This documentation is containerlab oriented and assume you know what you are doing
> After that, you will need to provision your anta runner like for [ATD on your own](./provisioning.md)

> **Note**
> This containerlab topology uses `192.168.0.0/24` as management network to match Arista Test Drive IP addressing.
> If this network overlaps with another one on your server, you will need to manually update the `anta.clab.yml` topology file

## Get cEOS

```bash
pip install --upgrade eos-downloader

# configure your Arista token
export ARISTA_TOKEN="xxxxx"

# Download cEOS
ardl get eos --image-type cEOS -l -rtype \M --import-docker
```

Today, it will take `4.30.3M` which is the default version in containerlab topology. If it is different version, run containerlab with `EOS_VERSION:=<YOUR EOS VERSIOn>`

## Add a user configuration to AVD

The user configuration is missing from the AVD intended configuration as it is configured with static configlets in Arista Test Drive.

Add the following to `atd-inventory/group_vars/ATD_FABRIC.yml`:

```yaml
# Local users
local_users:
  # Define a new user, which is called "ansible"
  - name: ansible
    privilege: 15
    role: network-admin
    # Password set to "ansible". Same string as the device generates when configuring a username.
    sha512_password: $6$7u4j1rkb3VELgcZE$EJt2Qff8kd/TapRoci0XaIZsL4tFzgq1YZBLD9c6f/knXzvcYY0NcMKndZeCv0T268knGKhOEwZAxqKjlMm920
```

Run the playbook `atd-inventory/playbooks/atd-fabric-build.yml`.

## Containerlab topology

```bash
cd atd-inventory

sudo containerlab deploy

+---+------------------------------+--------------+---------------------+-------+---------+-----------------+
| # |             Name             | Container ID |        Image        | Kind  |  State  |  IPv4 Address   |
+---+------------------------------+--------------+---------------------+-------+---------+-----------------+
| 1 | clab-anta-hackathon-graphite | ad713d37dbcf | netreplica/graphite | linux | running | 192.168.0.2/24  |
| 2 | clab-anta-hackathon-host1    | 27b293919829 | arista/ceos:4.30.3M | ceos  | running | 192.168.0.16/24 |
| 3 | clab-anta-hackathon-host2    | f2def1bc53c3 | arista/ceos:4.30.3M | ceos  | running | 192.168.0.17/24 |
| 4 | clab-anta-hackathon-leaf1    | e3ebae978dc8 | arista/ceos:4.30.3M | ceos  | running | 192.168.0.12/24 |
| 5 | clab-anta-hackathon-leaf2    | 0611c734d57b | arista/ceos:4.30.3M | ceos  | running | 192.168.0.13/24 |
| 6 | clab-anta-hackathon-leaf3    | c2118da1787b | arista/ceos:4.30.3M | ceos  | running | 192.168.0.14/24 |
| 7 | clab-anta-hackathon-leaf4    | daaf4cec1854 | arista/ceos:4.30.3M | ceos  | running | 192.168.0.15/24 |
| 8 | clab-anta-hackathon-spine1   | ea5e6a3b5574 | arista/ceos:4.30.3M | ceos  | running | 192.168.0.10/24 |
| 9 | clab-anta-hackathon-spine2   | 108414764d53 | arista/ceos:4.30.3M | ceos  | running | 192.168.0.11/24 |
+---+------------------------------+--------------+---------------------+-------+---------+-----------------+
```

Now enjoy !
