# chef-teamcity-cookbook

Gives you the ability to create TeamCity server/agent

## Supported Platforms

* CentOS 6.5

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
</table>

## Usage

### chef-teamcity::default

Include `chef-teamcity` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[chef-teamcity::server]"
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
