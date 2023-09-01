/**
 * My first spec file
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		// setup the entire test bundle here
		variables.ip = new ip();
		//do not load range to speed up performance
		ip.setLoadRange( false );
	}

	function afterAll(){
		// do cleanup here
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		/**
		 * describe() starts a suite group of spec tests. It is the main BDD construct.
		 * You can also use the aliases: story(), feature(), scenario(), given(), when()
		 * to create fluent chains of human-readable expressions.
		 *
		 * Arguments:
		 *
		 * @title    Required: The title of the suite, Usually how you want to name the desired behavior
		 * @body     Required: A closure that will resemble the tests to execute.
		 * @labels   The list or array of labels this suite group belongs to
		 * @asyncAll If you want to parallelize the execution of the defined specs in this suite group.
		 * @skip     A flag that tells TestBox to skip this suite group from testing if true
		 * @focused A flag that tells TestBox to only run this suite and no other
		 */
		describe( "A spec", () => {

			/**
			 * --------------------------------------------------------------------------
			 * Runs before each spec in THIS suite group or nested groups
			 * --------------------------------------------------------------------------
			 */
			beforeEach( () => {

			} );

			/**
			 * --------------------------------------------------------------------------
			 * Runs after each spec in THIS suite group or nested groups
			 * --------------------------------------------------------------------------
			 */
			afterEach( () => {
				ip.setLoadRange(false);
			} );

			/**
			 * it() describes a spec to test. Usually the title is prefixed with the suite name to create an expression.
			 * You can also use the aliases: then() to create fluent chains of human-readable expressions.
			 *
			 * Arguments:
			 *
			 * @title  The title of this spec
			 * @body   The closure that represents the test
			 * @labels The list or array of labels this spec belongs to
			 * @skip   A flag or a closure that tells TestBox to skip this spec test from testing if true. If this is a closure it must return boolean.
			 * @data   A struct of data you would like to bind into the spec so it can be later passed into the executing body function
			 * @focused A flag that tells TestBox to only run this spec and no other
			 */
			it( "can load an address with CIDR format", () => {
				var address = ip.v4('192.168.0.1/24');
				expect( address ).toBeInstanceOf( 'ipv4' );
			} );

			it( "can load an address with subnet mask", () => {
				var address = ip.v4('192.168.0.1', '255.255.255.0');
				expect( address ).toBeInstanceOf( 'ipv4' );
			} );

			it( "can load an ip and retrieve a memento with correct keys", () => {
				var address = ip.v4('192.168.0.1/24');
				var m = address.toMemento();
				expect( m ).toBeTypeOf( 'struct' );
				expect( m ).toHaveKey( 'address' );
				expect( m ).toHaveKey( 'numHosts' );
				expect( m ).toHaveKey( 'prefixLength' );
				expect( m ).toHaveKey( 'broadcastAddress' );
				expect( m ).toHaveKey( 'networkAddress' );
				expect( m ).toHaveKey( 'subnetMask' );
				expect( m ).toHaveKey( 'cidrSignature' );
				expect( m ).toHaveKey( 'firstAddress' );
				expect( m ).toHaveKey( 'lastAddress' );
				expect( m ).toHaveKey( 'binary' );
				expect( m ).toHaveKey( 'ipDecimal' );
				expect( m ).toHaveKey( 'networkDecimal' );
				expect( m ).toHaveKey( 'broadcastDecimal' );
				expect( m ).notToHaveKey( 'ipAddresses' );
			} );

			it( "can load an address with ip ranges", () => {
				ip.setLoadRange(true);
				var address = ip.v4('192.168.0.1/24');
				var m = address.toMemento();
				expect( m ).toBeTypeOf( 'struct' );
				expect( m ).toHaveKey( 'ipAddresses' );
			} );

			it( "can correctly load 192.168.0.1/24", () => {
				var address = ip.v4('192.168.0.1/24');
				expect( address.getAddress() ).toBe( '192.168.0.1' );
				expect( address.getNumHosts() ).toBe( 254 );
				expect( address.getPrefixLength() ).toBe( 24 );
				expect( address.getBroadcastAddress() ).toBe( '192.168.0.255' );
				expect( address.getNetworkAddress() ).toBe( '192.168.0.0' );
				expect( address.getSubnetMask() ).toBe( '255.255.255.0' );
				expect( address.getCidrSignature() ).toBe( '192.168.0.1/24' );
				expect( address.getFirstAddress() ).toBe( '192.168.0.1' );
				expect( address.getLastAddress() ).toBe( '192.168.0.254' );
				expect( address.getBinary() ).toBe( '11000000101010000000000000000001' );
				expect( address.getIpDecimal() ).toBe( 3232235521 );
				expect( address.getNetworkDecimal() ).toBe( 3232235520 );
				expect( address.getBroadcastDecimal() ).toBe( 3232235775 );
			} );

			it( "can correctly load 72.14.192.100 with mask 255.255.192.0", () => {
				var address = ip.v4('72.14.192.100', '255.255.192.0');
				var m = address.toMemento();
				expect( m.address ).toBe( '72.14.192.100' );
				expect( m.numHosts ).toBe( 16382 );
				expect( m.prefixLength ).toBe( 18 );
				expect( m.broadcastAddress ).toBe( '72.14.255.255' );
				expect( m.networkAddress ).toBe( '72.14.192.0' );
				expect( m.subnetMask ).toBe( '255.255.192.0' );
				expect( m.cidrSignature ).toBe( '72.14.192.100/18' );
				expect( m.firstAddress ).toBe( '72.14.192.1' );
				expect( m.lastAddress ).toBe( '72.14.255.254' );
				expect( m.binary ).toBe( '01001000000011101100000001100100' );
				expect( m.ipDecimal ).toBe( 1208926308 );
				expect( m.networkDecimal ).toBe( 1208926208 );
				expect( m.broadcastDecimal ).toBe( 1208942591 );
			} );

			it( "can correctly load 127.0.0.1/32", () => {
				var address = ip.v4('127.0.0.1/32');
				var m = address.toMemento();
				expect( m.address ).toBe( '127.0.0.1' );
				expect( m.numHosts ).toBe( 1 );
				expect( m.prefixLength ).toBe( 32 );
				expect( m.broadcastAddress ).toBe( '127.0.0.1' );
				expect( m.networkAddress ).toBe( '127.0.0.1' );
				expect( m.subnetMask ).toBe( '255.255.255.255' );
				expect( m.cidrSignature ).toBe( '127.0.0.1/32' );
				expect( m.firstAddress ).toBe( '127.0.0.1' );
				expect( m.lastAddress ).toBe( '127.0.0.1' );
				expect( m.binary ).toBe( '01111111000000000000000000000001' );
				expect( m.ipDecimal ).toBe( 2130706433 );
				expect( m.networkDecimal ).toBe( 2130706433 );
				expect( m.broadcastDecimal ).toBe( 2130706433 );
			} );	

			it( "can correctly load 255.255.255.255 with mask 128.0.0.0", () => {
				var address = ip.v4('255.255.255.255', '128.0.0.0');
				var m = address.toMemento();
				expect( m.address ).toBe( '255.255.255.255' );
				expect( m.numHosts ).toBe( 2147483646 );
				expect( m.prefixLength ).toBe( 1 );
				expect( m.broadcastAddress ).toBe( '255.255.255.255' );
				expect( m.networkAddress ).toBe( '128.0.0.0' );
				expect( m.subnetMask ).toBe( '128.0.0.0' );
				expect( m.cidrSignature ).toBe( '255.255.255.255/1' );
				expect( m.firstAddress ).toBe( '128.0.0.1' );
				expect( m.lastAddress ).toBe( '255.255.255.254' );
				expect( m.binary ).toBe( '11111111111111111111111111111111' );
				expect( m.ipDecimal ).toBe( 4294967295 );
				expect( m.networkDecimal ).toBe( 2147483648 );
				expect( m.broadcastDecimal ).toBe( 4294967295 );
			} );

			it( "can correctly load address ranges for 172.17.0.1/29", () => {
				ip.setLoadRange(true);
				var address = ip.v4('172.17.0.1/29');
				var m = address.toMemento();
				expect( m ).toHaveKey( 'ipAddresses' )
				expect( m.ipAddresses ).toHaveLength( 8 );
				expect( m.ipAddresses ).toInclude( '172.17.0.0' );
				expect( m.ipAddresses ).toInclude( '172.17.0.1' );
				expect( m.ipAddresses ).toInclude( '172.17.0.2' );
				expect( m.ipAddresses ).toInclude( '172.17.0.3' );
				expect( m.ipAddresses ).toInclude( '172.17.0.4' );
				expect( m.ipAddresses ).toInclude( '172.17.0.5' );
				expect( m.ipAddresses ).toInclude( '172.17.0.6' );
				expect( m.ipAddresses ).toInclude( '172.17.0.7' );
			} );	


			it( "can can throw with invalid ip address", () => {
				expect( function(){ 
					var address = ip.v4('1922.168.0.1/24');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('-1.168.0.1/24');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('192.168.0/24');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('192.168.0.1.1/24');
				} ).toThrow();					
			} );	

			it( "can can throw with invalid cidr prefix", () => {
				expect( function(){ 
					var address = ip.v4('192.168.0.1/-1');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('192.168.0.1/33');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('192.168.0.1/A');
				} ).toThrow();								
			} );

			it( "can can throw with invalid subnet mask", () => {
				expect( function(){ 
					var address = ip.v4('192.168.0.1', '192.168.0.1');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('192.168.0.1', '255.255.255');
				} ).toThrow();

				expect( function(){ 
					var address = ip.v4('192.168.0.1', '255.255.255.255.255');
				} ).toThrow();								
			} );			

		} );
	}

	private function isLucee(){
		return ( structKeyExists( server, "lucee" ) );
	}

}
