
# ip - A handy internet protocol address helper

This ip package will help you retrieve info for a given ip and subnet. Currently only supports ipv4. This package is written in vanilla cfml and requires no depencies

## License

I dont know about licenses, do whatever you want.

## Instructions

Just drop into your **modules** folder or use the box-cli to install

`box install ip`

## Models

The module registers the following mapping in WireBox: `ip@ip`. Which is the class you will use to parse ip addresses and subnets. Currently this class supports one method, with two signatures.

* `v4( ipAddress, subnetmask )` - Parse ip address with a given subnet mask
* `v4( cidrString )` - Parse cidr signature.

E.g.
```js
//wirebox style
var ip = getInstance('ip@ip');

//vanilla style
var ip = new my.models.ip.ip();
```

This returned value is an object which you can use to retrieve information for the given subetnet.

Below is example along with all the methods available to you:

```js
// instation:
var ip = getInstance('ip@ip');

// you can disable loading all available addresses to speed up performance for large subnets, by default this is true
ip.setLoadRange(false);
ip.setLoadRange(true);

//load subnet
var subnet = ip.v4('192.168.0.1/24');  // or ip.v4('192.168.0.1','255.255.255.0')

// available getters
subnet.getAddress()             // 192.168.0.1
subnet.getNumHosts()            // 254
subnet.getPrefixLength()        // 24
subnet.getBroadcastAddress()    // 192.168.0.255
subnet.getNetworkAddress()      // 192.168.0.0
subnet.getSubnetMask()          // 255.255.255.0
subnet.getCidrSignature()       // 192.168.0.1/24
subnet.getFirstAddress()        // 192.168.0.1
subnet.getLastAddress()         // 192.168.0.254
subnet.getBinary()              // 11000000101010000000000000000001
subnet.getIpDecimal()           // 3232235521
subnet.getNetworkDecimal()      // 3232235520
subnet.getBroadcastDecimal()    // 3232235775
subnet.getAddressses()          // A struct containing all available addresses           

// utility functions
var isInRange = subnet.isInRange('192.168.0.4'); //true
var isInRange = subnet.isInRange('192.168.2.9'); //false

// can return a struct with all the above information of the subnet
var memento = subnet.toMemento();

/*
    memento = {
      "address": "192.168.0.1",
      "numHosts": 254,
      "prefixLength": 24,
      "broadcastAddress": "192.168.0.255",
      "networkAddress": "192.168.0.0",
      "subnetMask": "255.255.255.0",
      "cidrSignature": "192.168.0.1/24",
      "firstAddress": "192.168.0.1",
      "lastAddress": "192.168.0.254",
      "binary": "11000000101010000000000000000001",
      "ipDecimal": 3232235521,
      "networkDecimal": 3232235520,
      "broadcastDecimal": 3232235775,
      "ipAddresses": [
        "192.168.0.0",
        "192.168.0.1",
        "192.168.0.2",
        ...
        "192.168.0.254",
        "192.168.0.255"
      ]
    }
*/

```