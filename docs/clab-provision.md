# Containerlab Provisioning

> **Warning**
> This documentation is containerlab oriented and assume you know what you are doing
> After that, you will need to provision your anta runner like for [ATD on your own](./provisioning.md)

## Get cEOS

```bash
pip install --upgrade eos-downloader

# configure your Arista token
export ARISTA_TOKEN="xxxxx"

# Download cEOS
ardl get eos --image-type cEOS -l -rtype \M --import-docker
```

Today, it will take `4.30.3M` which is the default version in containerlab topology. If it is different version, run containerlab with `EOS_VERSION:=<YOUR EOS VERSIOn>`

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
