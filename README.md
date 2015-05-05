# chef-teamcity-cookbook

Gives you the ability to create TeamCity server/agent

## Supported Platforms

* CentOS 6.5
* Redhat 6.5
* Windows (agent only)

## Depends

* java
* git
* mercurial
* subversion

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['teamcity']['version']</tt></td>
    <td>String</td>
    <td>The version of TeamCity.</td>
    <td><tt>8.1.5</tt></td>
  </tr> 
   <tr>
    <td><tt>['teamcity']['username']</tt></td>
    <td>String</td>
    <td>The username that TeamCity will be running under.</td>
    <td><tt>teamcity</tt></td>
    </tr> 
  <tr>
    <td><tt>['teamcity']['password']</tt></td>
    <td>String</td>
    <td>The password that TeamCity will be running under.</td>
    <td></td>
  </tr> 
  <tr>
    <td><tt>['teamcity']['group']</tt></td>
    <td>String</td>
    <td>The group that TeamCity will be running under.</td>
    <td><tt>teamcity</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['service_name']</tt></td>
    <td>String</td>
    <td>The service name of TeamCity.</td>
    <td><tt>teamcity</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['server']['backup']</tt></td>
    <td>String</td>
    <td>The URI of the TeamCity backup.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['server']['database']['username']</tt></td>
    <td>String</td>
    <td>The database user name.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['server']['database']['password']</tt></td>
    <td>String</td>
    <td>The database password.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['server']['database']['connection_url']</tt></td>
    <td>String</td>
    <td>The JDBC connection URL.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['server']['database']['jar']</tt></td>
    <td>String</td>
    <td>The URI of the database JAR file.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['name']</tt></td>
    <td>String</td>
    <td>The agent name.</td>
    <td><tt></tt></td>
  </tr>
    <tr>
    <td><tt>['teamcity']['agent']['server_uri']</tt></td>
    <td>String</td>
    <td>The URI of the TeamCity server.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['own_address']</tt></td>
    <td>String</td>
    <td>The IP address of the TeamCity agent.</td>
    <td><tt>nil (will be set automatically)</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['port']</tt></td>
    <td>String</td>
    <td>The The port to use for the teamcity agent.</td>
    <td><tt>9090</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['authorization_token']</tt></td>
    <td>String</td>
    <td>The authorization token for the agent to be authorized on the teamcity server.</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['system_properties']</tt></td>
    <td>String</td>
    <td>Build Script Properties.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['env_properties']</tt></td>
    <td>String</td>
    <td>Environment Variables.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['work_dir']</tt></td>
    <td>String</td>
    <td>The work directory of the teamcity agent.</td>
    <td><tt>windows: C:/teamcity/work || linux: ../work</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['temp_dir']</tt></td>
    <td>String</td>
    <td>The temp directory of the teamcity agent.</td>
    <td><tt>windows: C:/teamcity/temp || linux: ../temp</tt></td>
  </tr>
  <tr>
    <td><tt>['teamcity']['agent']['system_dir']</tt></td>
    <td>String</td>
    <td>The main directory of the teamcity agent.</td>
    <td><tt>windows: C:/teamcity || linux: ../system</tt></td>
  </tr>
</table>

## Usage

### chef-teamcity::server

Include `chef-teamcity` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef-teamcity::server]"
  ]
}
```

### chef-teamcity::agent

Include `chef-teamcity` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef-teamcity::agent]"
  ]
}
```

## License and Authors

- Author:: Alex Falkowski (<alexrfalkowski@gmail.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
