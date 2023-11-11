---
marp: true
theme: default
class: invert
author: French Funky Coders
# size 16:9 1280px 720px
size: 16:9
paginate: true
math: mathjax
# backgroundImage: "linear-gradient(to bottom, #1e3744, #301B29)"
style: |
    :root {
      background: #ffffff;
    }
    h1 {
      font-size: 50px;
      color: #5087b9;
    }

    img[alt~="custom"] {
      float: right;
    }
    .columns {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 1rem;
    }
    footer {
      #font-family: Brush Script MT;
      color: #5087b9;
      font-size: 10px;
    }
    section {
      color: #000000;
      font-size: 14px;
    }
    section::after {
      font-family: Brush Script MT;
      font-size: 14px;
    }
    code {
      color: #FFFFFF;
    }
---
# Introduction to ANTA

<!-- Do not add page number on this slide -->
<!--
_paginate: false
-->

<style scoped>section {font-size: 28px;}</style>



---
# Objectives and pre-requisites

<!-- Add footer starting from this slide -->
<!--
footer: 'Arista EMEA ANTA Hackathon - 2023'
-->

## Pre-requisite: Object Oriented Programming
- [Python OOP Tutorial 1: Classes and Instances](https://www.youtube.com/watch?v=ZDa-Z5JzLYM)
- [Python OOP Tutorial 2: Class Variables](https://www.youtube.com/watch?v=BJ-VvGyQxho)
- [Python OOP Tutorial 4: Inheritance](https://www.youtube.com/watch?v=RSl87lqOXDE)

## Objectives
- Know how to **use ANTA** to perform NRFU testing
- Get familiar with **ANTA test development**
- Understand and **leverage object-oriented programming** with Python

## Not covered
- Asynchronous programming
- Developing within the ANTA framework

---
# ANTA in a Nutshell

### ANTA stands for Arista Network Testing Automation
  - Open-Source project developed under Apache License
  - Driven by AS, SE and Solution Engineer community
### Use cases
  - Automate NRFU (Network Ready For Use) test on a preproduction network
  - Automate tests on a live network (periodically or on demand)
  - Execute tests as part of a CI pipeline
### Python only
  - No mandatory cumbersome framework
  - Easier troubleshooting
  - Fast and efficient using asyncio
### Easy setup
  - `pip install anta`
  - Docker image: `ghcr.io/arista-netdevops-community/anta`

---
# ANTA CLI

![anta nrfu](https://raw.githubusercontent.com/arista-netdevops-community/anta/main/docs/imgs/anta-nrfu.svg)

```
$ anta --help
Usage: anta [OPTIONS] COMMAND [ARGS]...

  Arista Network Test Automation (ANTA) CLI

Commands:
  debug  Debug commands for building ANTA
  exec   Execute commands to inventory devices
  get    Get data from/to ANTA
  nrfu   Run NRFU against inventory devices
```

ANTA framework needs 2 important inputs from the user to run: a [**device inventory** and a **test catalog**](https://www.anta.ninja/main/usage-inventory-catalog/)

> Useful tip: use environement variables and a file to define the numerous ANTA options. Eventually use https://direnv.net/.

---
# ANTA Device Inventory

The device inventory lists all the devices on which ANTA can perform network tests. ANTA **requires eAPI to be enabled** on the devices.

```yaml
anta_inventory:
  hosts:
  - host: 10.100.164.103
    name: spine1
    tags: ['spine']
  - host: ld004.lon.aristanetworks.com
    name: spine2
    tags: ['spine']
  - host: cal008.lon.aristanetworks.com
    name: leaf1
    port: 80
    tags: ['leaf']
```

What is possible to do when defining a device?
- Specify IP or a resolvable `host`, specify another eAPI `port` than 443
- Give a `name` alias
- Assign `tags` to devices

---
# ANTA Test Catalog

The ANTA test catalog defines the tests to be loaded, their inputs and tags.

```yaml
anta.tests.connectivity:
  - VerifyReachability:
      hosts:
        - source: Management0
          destination: 1.1.1.1
          vrf: MGMT
        - source: Management0
          destination: 8.8.8.8
          vrf: MGMT
anta.tests.system:
  - VerifyUptime:
      minimum: 10
  - VerifyReloadCause:
  - VerifyCoredump:
  - VerifyAgentLogs:
anta.tests.mlag:
  - VerifyMlagStatus:
      filters:
        tags: ['leaf']
```

Q: What are the tests available in ANTA?
A: Refer to the [API Documentation](https://www.anta.ninja/main/api/tests/) or this [test catalog example](https://github.com/arista-netdevops-community/anta/blob/main/examples/tests.yaml).

Q: What is the purpose of tags?
A: Run a subset of the test catalog on tagged devices. Refer to [the documentation](https://www.anta.ninja/main/cli/tag-management/) for more details.

---
# Developing tests with ANTA

> To go into more details, refer to [this documentation](https://www.anta.ninja/v0.11.0/advanced_usages/custom-tests/)

ANTA provides an abstract class [AntaTest](https://www.anta.ninja/v0.11.0/api/models/#anta.models.AntaTest). This class does the heavy lifting and provide the logic to define, collect and test data. A test in ANTA is an implementation of **AntaTest** where mandatory **class variables** and at least a **method** need to be defined:

``` python
from anta.models import AntaTest, AntaCommand


class VerifyTemperature(AntaTest):
    """
    This test verifies if the device temperature is within acceptable limits.

    Expected Results:
      * success: The test will pass if the device temperature is currently OK: 'temperatureOk'.
      * failure: The test will fail if the device temperature is NOT OK.
    """

    name = "VerifyTemperature"
    description = "Verifies if the device temperature is within the acceptable range."
    categories = ["hardware"]
    commands = [AntaCommand(command="show system environment temperature", ofmt="json")]

    @AntaTest.anta_test
    def test(self) -> None:
        command_output = self.instance_commands[0].json_output
        temperature_status = command_output["systemStatus"] if "systemStatus" in command_output.keys() else ""
        if temperature_status == "temperatureOk":
            self.result.is_success()
        else:
            self.result.is_failure(f"Device temperature exceeds acceptable limits. Current system status: '{temperature_status}'")
```

Let's review step by step how this test has been written.

---
# Developing tests with ANTA

``` python
class VerifyTemperature(AntaTest):
    name = "VerifyTemperature"
    description = "Verifies if the device temperature is within the acceptable range."
    categories = ["hardware"]
    commands = [AntaCommand(command="show system environment temperature", ofmt="json")]
```

### Mandatory class attributes
- `name` (`str`): Name of the test. Used during reporting.
- `description` (`str`): A human readable description of your test.
- `categories` (`list[str]`): A list of categories in which the test belongs.
- `commands` (`list[Union[AntaTemplate, AntaCommand]]`): A list of command to collect from devices. This list __must__ be a list of [AntaCommand](../api/models.md#anta.models.AntaCommand) or [AntaTemplate](../api/models.md#anta.models.AntaTemplate) instances.

### Define an `AntaCommand` object
```python
AntaCommand(
    command="<EOS command to run>",
    ofmt="<eAPI output - json or text - default is json>",
    version="<eAPI version - valid values are 1 or “latest” - default is “latest”>",
    revision="<eAPI revision of the command. Valid values are 1 to 99. Revision has precedence over version>"
)
```
Rendering [AntaTemplate](../api/models.md#anta.models.AntaTemplate) instances will be discussed later.

---
# Developing tests with ANTA

``` python
class VerifyTemperature(AntaTest):
    @AntaTest.anta_test
    def test(self) -> None:
        command_output = self.instance_commands[0].json_output
        temperature_status = command_output["systemStatus"] if "systemStatus" in command_output.keys() else ""
        if temperature_status == "temperatureOk":
            self.result.is_success()
        else:
            self.result.is_failure(f"Device temperature exceeds acceptable limits. Current system status: '{temperature_status}'")
```

### Coding the test
[test(self) -> None](../api/models.md#anta.models.AntaTest.test) is an abstract method that must be implemented. It contains the test logic that can access the collected command outputs using the `instance_commands` instance attribute and __must__ set the `result` instance attribute accordingly. It must be implemented using the `AntaTest.anta_test` decorator that provides logging and will collect commands before executing the `test()` method.
> Useful tip: when coding this method, use `<EOS command> | json` in EOS CLI to see the JSON output of the command to being parsed

**That's it! We've just reviwed a simple test in ANTA.**

---
# Fun with ANTA

<!-- Do not add page number on this slide -->
<!--
_paginate: false
_footer: ''
-->

<style scoped>section {font-size: 28px;}</style>

```ANTA Hackathon Script```

![bg left fit](imgs/intro-anta-hackathon.jpeg)

---

# Introduction

![bg right:33%](imgs/pexels-suzy-hazelwood-1226398.jpg)

- This hackathon is split into 3 sections. Each section takes around 20 minutes to complete. But it can takes more time if you are running it on your own.
- Work in team, only one submission per team
- Repository is available at [titom73/anta-malaga](https://github.com/titom73/anta-malaga)
- An Arista Test Drive is required.
- Ask questions at any time!
- Google Chat: [#anta-field](https://chat.google.com/room/AAAAN780xDU?cls=7) on Google Chat

---

# Context

Your customer told you their servers can’t reach ressources and they configure servers and fabric with LACP

You don’t have access to configuration of devices and you need to identify his issue.

Test your fabric to check:
- If all BGP sessions are UP and established.
- If all interfaces are UP and do not have error or drop counters.
- EVPN family is configured.

![bg right:33%](imgs/context.jpeg)

---

# Stage #1

1. Create an ANTA inventory from scratch
2. Create an ANTA test catalog from the test plan
3. Is there any issue on the fabric?

__That’s all folks!__

Use your brain and RTFM:
- [Use Inventory & Catalog](https://www.anta.ninja/v0.11.0/usage-inventory-catalog/)
- [ANTA CLI overview](https://www.anta.ninja/v0.11.0/cli/overview/)
- [Get Inventory Information](https://www.anta.ninja/v0.11.0/cli/get-inventory-information/)
- [ANTA Tests catalog](https://www.anta.ninja/v0.11.0/api/tests/)

![bg left](imgs/ant-chrono-3.jpeg)

---

# Stage #2

Now, you have seen that PortChannel4 is down

Develop a test to check LACP status:

- Check `PortChannel` is in `collecting` mode
- Check `PortChannel` is in `distributing` mode

## Tips

- Use `pip install -e .`
- Develop your tests under `./anta_custom/<your_file>.py`
- Your test will be available with `anta_customer.<your_file>.<your_test>`
- [Test development example](https://github.com/titom73/atd-anta-demo/tree/main/docs)

![bg right:33%](imgs/ant-chrono.jpeg)

---

# Stage #3

Traffic is still not passing correctly. Check that all connected routes are correctly installed in routing table. You should have at least 3 connected routes installed in VRF `Tenant_A_OP_Zone`

Develop a test based on `AntaTemplate` to validate number of connected routes in VRFs:

- Test __must__ use [`anta.models.AntaTemplate`](https://www.anta.ninja/v0.11.0/api/models/#template-definition)
- VRF name is an template input for your test.
- Run ANTA to check routes status and fix configuration in EOS.

![bg left:40%](imgs/anta-chrono-02.jpeg)

---

# Stage #4

You can now build additional tests to make your customer happier with his Arista Fabric.

__Stage is yours !__

![bg right:60%](imgs/ant-staging.jpeg)

---

# Conclusion

- How do you think you can use ANTA in the field ?
- What key feature is missing for customer’s usage ?

![bg left](imgs/conclusion.jpeg)

---

<!-- # Thank you ! -->

<!-- Do not add page number on this slide -->
<!--
_paginate: false
-->

<style scoped>section {font-size: 28px;}</style>

![bg center fit](imgs/ant-thank-you.jpeg)
