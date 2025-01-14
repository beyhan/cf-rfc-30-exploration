A sample reporitory for file based service binding experiments.

To generate file based service bindings as specified in the [RFC-0030](https://github.com/cloudfoundry/community/blob/main/toc/rfc/rfc-0030-add-support-for-file-based-service-binding.md) and currently implement in Cloud-Controller via [this pr](https://github.com/cloudfoundry/cloud_controller_ng/pull/4026/files#diff-eb20d519bac75e9dfc811b3e396413a537387de8557d0238ecf9254a816a2e00R59-R67) execute:

```
cd cloud-controller
bundle install
bundle exec ruby service_binding_files_builder.rb
```
The file based service bindings will be generated in the `service-binding-root/foo` folder. To generate file based service bindings in json encoded format execute the script with `bundle exec ruby service_binding_files_builder.rb --write_json`. The file based service bindings will be generate in the folder `service-binding-root/foo-json`.

### Use spring-cloud-bindings-client to read the bindings

Folder `./spring-cloud-bindings-client` contains an example when reading foo and foo-json with [spring-cloud-bindings](https://github.com/spring-cloud/spring-cloud-bindings):
```
cd ./spring-cloud-bindings-client
mvn exec:java -Dexec.mainClass="com.sap.test.Client"
```

Output:
```
Found 2 bindings.
./../service-binding-root/foo-json: name=foo-json, type="db", provider=null
  {arr=["a","a"], number=1, password="[\"dbsecret\"]", json_content={"a":"a"}, boolean=true, array=["a","a"], prop="[\"a\", \"a\"]", certificate="-----BEGIN CERTIFICATE-----\nblaaaa\n-----END CERTIFICATE-----", name="foo", string_property="[\"a\", \"a\"]", some_other_key="[\"0\", \"0\"]", hash={"a":"a"}}

./../service-binding-root/foo: name=foo, type=db, provider=null
  {arr=["a","a"], number=1, password=["dbsecret"], json_content={"a":"a"}, boolean=true, array=["a","a"], prop=["a", "a"], certificate=-----BEGIN CERTIFICATE-----
blaaaa
-----END CERTIFICATE-----, name=foo, string_property=["a", "a"], some_other_key=["0", "0"], hash={"a":"a"}}
```

spring-cloud-bindings client lib returns a very likely broken password for the binding foo-json. It is still json encoded and the application would have to json-decode it before passing it e.g. to the DB.

### Automatically detect original type of the bindings

You can use the client available in `client-library-ruby` to automatically detect the type of the bindings.

```
client-library-ruby
bundle install
bundle exec ruby client.rb
```
To interpret the json encoded bindings execute the client with `bundle exec ruby client.rb --read_json`. The output which you will get is following:

```
service-binding-root/arr - Array
service-binding-root/boolean - Boolean
service-binding-root/certificate - String
service-binding-root/hash - Hash
service-binding-root/json_content - Hash
service-binding-root/name - String
service-binding-root/number - Number
service-binding-root/password - String
service-binding-root/prop - String
service-binding-root/some_other_key - String
service-binding-root/type - String
```

For the current CC implementation:
```
service-binding-root/arr - Array
service-binding-root/boolean - Boolean
Error parsing file certificate: unexpected characters after the JSON document (after ) at line 1, column 1 [parse.c:703]
service-binding-root/hash - Hash
service-binding-root/json_content - Hash
Error parsing file name: expected false (after ) at line 1, column 2 [parse.c:129]
service-binding-root/number - Number
service-binding-root/password - Array
service-binding-root/prop - Array
service-binding-root/some_other_key - Array
Error parsing file type: unexpected character (after ) at line 1, column 1 [parse.c:764]
```