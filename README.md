# Arista Network Testing Automation (ANTA) Hackathon

__WIP__ - Documentation is not accurate anymore! Please update it !

This repository is built to support demo about how to use [Arista Network Testing Automation](https://www.anta.ninja) framework.

## Lab environment

![atd-lab-topology](./imgs/lab-topology.png)

## Provision your lab

### Lab configuration

Please follow [this documentation](./docs/provisioning.md) to build lab for the hackathon session. It is based on Arista Test Drive.

A version using devcontainer and containerlab is available under [`devcontainer` branch of this repository](https://github.com/titom73/anta-malaga/tree/devcontainer) and built by [Petr Ankudinov](https://github.com/ankudinov). It means you can run it using codespace if required.

> **Note**
> For SE Meeting, only ATD approach is supported to spend a maximum of time running tests and not debugging setups. You can use other approaches if you know what you are doing.

### Install ANTA

Please install ANTA from pypi servers:

```bash
pip install --upgrade pip
pip install --upgrade 'anta==0.11.0'
```

## Authentication

Because password is generated per lab, here is how to get it and use it with all tools provided by repository.

- Username: __arista__ (password: `atd generated password`)

```bash
export LABPASSPHRASE=`cat /home/coder/.config/code-server/config.yaml |\
    grep "password:" |\
    awk '{print $2}'`
```

If you want to not provide username and password to ANTA for each execution, you can source a file with content similar to the following snippet:

```bash
echo 'Creating default anta variables'
export ANTA_USERNAME=ansible
export ANTA_PASSWORD=${LABPASSPHRASE}
export ANTA_ENABLE=false
```

> More information about these commandes [are availble](https://www.anta.ninja/v0.11.0/cli/overview/)

## Management IPs

| Hostname | Managemnt Interface | IP Address      |
| -------- | ------------------- | --------------  |
| Spine1   | Management0         | 192.168.0.10/24 |
| Spine2   | Management0         | 192.168.0.11/24 |
| Leaf1    | Management0         | 192.168.0.12/24 |
| Leaf2    | Management0         | 192.168.0.13/24 |
| Leaf3    | Management0         | 192.168.0.14/24 |
| Leaf4    | Management0         | 192.168.0.15/24 |

## Hackathon script

Please visit [script slides](https://hackathon.anta.ninja/) to start event !

> A PDF version of slides is available on [github](https://github.com/titom73/anta-malaga/blob/gh-pages/hackathon.pdf)


## License

Repository is provided AS-IS with no maintenance and under Apache-2.0 license
