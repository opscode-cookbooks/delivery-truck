# `delivery-truck`
`delivery-truck` is a Chef Delivery build_cookbook for continuously delivering
Chef cookbooks.

_This is alpha stage software, and is in a state of perpetual change. Use at your own risk!_

To quickly get started you just need to set `delivery-truck` to
be your build cookbook in your `.delivery/config.json`.

```
{
  "version": "2",
  "build_cookbook": {
    "name": "delivery-truck",
    "git": "https://github.com/chef-cookbooks/delivery-truck.git"
  }
}
```

## Customizing Behavior using `.delivery/config.json`
The behavior of the `delivery-truck` cookbook phase recipes can be easily
controlled by specifying certain values in your `.delivery/config.json` file.
The control these values offer you is limited and not meant as a method to
drastically alter the way the recipe functions.

### lint
The `lint` phase will execute [foodcritic](http://foodcritic.io) but you can specify
which rules you would like to follow directly from your `config.json`.

* `ignore_rules` - Provide a list of foodcritic rules you would like to ignore.
* `only_rules` - Explictly state which foodcritic rules you would like to run.
Any other rules except these will be ignored.

```json
{
  "version": "2",
  "build_cookbook": {
    "name": "delivery-truck",
    "git": "https://github.com/chef-cookbooks/delivery-truck.git"
  },
  "delivery-truck": {
    "lint": {
      "foodcritic": {
        "ignore_rules": ["FC001"],
        "only_rules": ["FC002"]
      }
    }
  }
}
```

### quality
The `quality` phase can execute integration/functional tests that are appropriate for your cookbook. Currently, we support running [Test Kitchen](http://kitchen.ci) using the [kitchen-ec2 driver](https://github.com/test-kitchen/kitchen-ec2).

In order to enable this functionality, perform the following prerequisite steps:

* Add the following items to the appropriate data bag as specified in the [Handling Secrets](#handling-secrets-alpha) section 

    *delivery-secrets <ent>-<org>-<project> encrypted data bag item*
    ```json
    {
      "id": "<ent>-<org>-<project>",
      "ec2": {
        "access_key": "<ec2-access-key>",
        "secret_key": "<ec2-private-key>",
        "keypair_name": "<ec2-keypair-name>",
        "private_key": "<JSON-compatible-ec2-keypair-private-key-content>"
       }
     }
    ```
    You can convert the private key content to a JSON-compatible string with a command like this: `ruby -e 'require "json"; puts File.read("<path-to-ec2-private-key>").to_json'`


* Create a .kitchen-ec2.yml file in the root of your repo that has all of the required information needed by the [kitchen-ec2 driver](https://github.com/test-kitchen/kitchen-ec2) driver. delivery-truck will expose the following ENV variabls for use by kitchen:
  * `KITCHEN_INSTANCE_NAME` - set to the `<project name>-<change-id>` values provided by [delivery-cli](https://github.com/chef/delivery-cli#change-details)
  * `KITCHEN_EC2_SSH_KEY_PATH` - path to the SSH private key created from the delivery-secrets data bag

    These variables may be used in the .kitchen-ec2.yml like so:

    ```yaml
      driver:
        Name: <%= ENV['KITCHEN_INSTANCE_NAME'] || 'test kitchen instance' %>
    transport:
      ssh_key: <%= ENV['KITCHEN_EC2_SSH_KEY_PATH'] %>
    ```

### publish
From the `publish` phase you can quickly and easily deploy cookbooks to
your Chef Server, Supermarket Server and your entire project to a Github account.

* `chef_server` - Set to true/false depending on whether you would like to
upload any modified cookbooks to the Chef Server associated with Delivery.
* `supermarket` - Specify the Supermarket Server you would like to use to
share any modified cookbooks.
* `github` - Specify the Github repository you would like to push your project
to. In order to work you must create a shared secrets data bag item (see "Handling
Secrets" below) with a key named github with the value being a
[deploy key](https://developer.github.com/guides/managing-deploy-keys/) with
access to that repo.
* `git` - Same as `github` but for Open Source Git Servers. (The data bag item
should have a key named git)

```json
{
  "version": "2",
  "build_cookbook": {
    "name": "delivery-truck",
    "git": "https://github.com/chef-cookbooks/delivery-truck.git"
  },
  "delivery-truck": {
    "publish": {
      "chef_server": true,
      "supermarket": "https://supermarket.chef.io",
      "github": "<org>/<project>",
      "git": "ssh://git@stash:2222/<project-name>/<repo-name>"
    }
  }
}
```

*example data bag*
```json
{
  "id": "<your ID here>",
  "github": "<private key>",
  "git": "<private key>"
}
```

## Skipped Phases
The following phases have no content and can be skipped: functional,
quality, security and smoke.

```json
{
  "version": "2",
  "build_cookbook": {
    "name": "delivery-truck",
    "git": "https://github.com/chef-cookbooks/delivery-truck.git"
  },
  "skip_phases": [
    "functional",
    "quality",
    "security",
    "smoke"
  ]
}
```

## Depends on delivery-truck
If you would like to enjoy all the functionalities that `delivery-truck` provides
on you own build cookbook you need to add it into your `metadata.rb`

```
name             'build_cookbook'
maintainer       'The Authors'
maintainer_email 'you@example.com'
license          'all_rights'
description      'Installs/Configures build'
long_description 'Installs/Configures build'
version          '0.1.0'

depends 'delivery-truck'

```

Additionally `delivery-truck` depends on `delivery-sugar` so you need to add
them both to your `Berksfile`

```
source "https://supermarket.chef.io"

metadata

cookbook 'delivery-truck', github: 'chef-cookbooks/delivery-truck'
cookbook 'delivery-sugar', github: 'chef-cookbooks/delivery-sugar'

```

## Handling Secrets (ALPHA)
This cookbook implements a rudimentary approach to handling secrets. This process
is largely out of band from Chef Delivery for the time being.

`delivery-truck` will look for secrets in the `delivery-secrets` data bag on the
Delivery Chef Server. It will expect to find an item in that data bag named
`<ent>-<org>-<project>`. For example, this cookbook is kept in the
'Delivery-Build-Cookbooks' org of the 'chef' enterprise so it's data bag name is
`chef-Delivery-Build-Cookbooks-delivery-truck`.

This cookbook expects this data bag item to be encrypted with the same
encrypted_data_bag_secret that is on your builders. You will need to ensure that
the data bag is available on the Chef Server before you run this cookbook for
the first time otherwise it will fail.

To get this data bag you can use the DSL `get_project_secrets` to get the
contents of the data bag.

```
my_secrets = get_project_secrets
puts my_secrets['id'] # chef-Delivery-Build-Cookbooks-delivery-truck
```

## License & Authors
- Author:: Tom Duffield (<tom@chef.io>)
- Author:: Salim Afiune (<afiunes@chef.io>)

```text
Copyright:: 2015 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
