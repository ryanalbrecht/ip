component accessors="true" {

	property name="ip";
	property name="subnetMask";
	property name="networkAddress";
	property name="broadcastAddress";
	property name="prefixLength";
	property name='ipBuffer';
	property name='subnetMaskBuffer';
	property name="networkBuffer";
	property name="broadcastBuffer";
	property name="hostMaskBuffer";
	property name="numHosts";
	property name="firstAddress";
	property name="lastAddress";
	property name="cidrSignature";
	property name="binary";
	property name="ipDecimal";
	property name="networkDecimal";
	property name="broadcastDecimal";

	this.cidrRegex = '^(([01]?\d?\d|2[0-4]\d|25[0-5])\.){3}([01]?\d?\d|2[0-4]\d|25[0-5])\/(\d{1}|[0-2]{1}\d{1}|3[0-2])$';
	this.ipRegex = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';
	this.maskRegex = '^(((255\.){3}(255|254|252|248|240|224|192|128|0+))|((255\.){2}(255|254|252|248|240|224|192|128|0+)\.0)|((255\.)(255|254|252|248|240|224|192|128|0+)(\.0+){2})|((255|254|252|248|240|224|192|128|0+)(\.0+){3}))$';

	function init(required string ip, string mask, boolean loadRange = true){
		variables.loadRange = loadRange;
		variables.ipBuffer = [];
		variables.subnetMaskBuffer = [];

		//check if ip is cidr
		if( isCidr( arguments.ip ) ){
			var split = listToArray(arguments.ip, '/');
			variables.ip = split[1];
			variables.prefixLength = split[2];
			variables.subnetMask = subnetMaskFromPrefixLength(variables.prefixLength).toList('.');
		} else {
			//check if ip is valid
			if( !isIp(arguments.ip) ){
				throw("The provided ip address '#arguments.ip#' is not valid");
			}

			//check if subnetMask is valid
			if( !isMask(arguments.mask) ){
				throw("The provided subnet mask '#arguments.mask#' is not valid");
			}

			variables.ip = arguments.ip;
			variables.subnetMask = arguments.mask;
			variables.prefixLength = prefixLengthFromSubnetMask(variables.subnetMask);
		}

		variables.ipBuffer = listToArray(variables.ip,'.');
		variables.subnetMaskBuffer = listToArray(variables.subnetMask,'.');
		variables.networkBuffer = calcNetworkBuffer(variables.ipBuffer, variables.subnetMaskBuffer); 		
		variables.broadcastBuffer = calcBroadcastBuffer(variables.ipBuffer, variables.subnetMaskBuffer);
		variables.hostMaskBuffer = calcHostMaskBuffer(variables.subnetMaskBuffer);
		variables.networkAddress = arrayToList(variables.networkBuffer, '.');
		variables.broadcastAddress = arrayToList(variables.broadcastBuffer, '.');
		variables.cidrSignature = '#variables.ip#/#variables.prefixLength#';
		variables.ipDecimal = bufferToDec(variables.ipBuffer);
		variables.networkDecimal = bufferToDec(variables.networkBuffer);
		variables.broadcastDecimal = bufferToDec(variables.broadcastBuffer);
		variables.ipAddresses = [];

		//binary
		variables.binary = variables.ipBuffer.reduce( (r,v,i)=>{
			var bin = decToBin(v)
			return r & pad(bin, '0', 8);
		}, '');

		if(variables.prefixLength eq 32){
			variables.firstAddress = variables.ip
			variables.lastAddress = variables.ip
			variables.numHosts = 1;
		} else {
			//first address
			var tempBuffer = duplicate(variables.networkBuffer);
			tempBuffer[4] = tempBuffer[4] + 1;
			variables.firstAddress = tempBuffer.toList('.');

			//last address
			var tempBuffer = duplicate(variables.broadcastBuffer);
			tempBuffer[4] = tempBuffer[4] - 1;
			variables.lastAddress = tempBuffer.toList('.');

			//ip address range
			if(variables.loadRange){
				for( i = networkDecimal; i <= broadcastDecimal; i++){
					variables.ipAddresses.append( decToIp(i) );
				}			
			}

			//num hosts 
			variables.numHosts = (2 ^ (32-variables.prefixLength) ) - 2;
		}

	}


	function isInRange(required string ip){
		if( !isIp(arguments.ip) ){
			throw("The provided ip address '#arguments.ip#' is not valid");
		}

		var ipBuffer = ipToDec(arguments.ip);
		var ipDec = bufferToDec(local.ipBuffer);
		return ( ipDec >= variables.networkDecimal ) AND ( ipDec <= variables.broadcastDecimal );
	}

	function toMemento(){
		var s = structNew('Ordered');
		s['address'] = variables.ip;
		s['numHosts'] = variables.numHosts;
		s['prefixLength'] = variables.prefixLength;
		s['broadcastAddress'] = variables.broadcastAddress;
		s['networkAddress'] = variables.networkAddress;
		s['subnetMask'] = variables.subnetMask;
		s['cidrSignature'] = variables.cidrSignature;
		s['firstAddress'] = variables.firstAddress;
		s['lastAddress'] = variables.lastAddress;
		s['binary'] = variables.binary;
		s['ipDecimal'] = variables.ipDecimal;
		s['networkDecimal'] = variables.networkDecimal;
		s['broadcastDecimal'] = variables.broadcastDecimal;

		if(variables.loadRange){
			s['ipAddresses'] = variables.ipAddresses;		
		}

		return s;
	}

	function getAddress(){
		return variables.ip;
	}

	// UTILITY FUNCTIONS	

	private function calcHostMaskBuffer(required array maskBuffer){
		//set all host bits to 1;
		return maskBuffer
			.map( (v) => 255 - v ) //calc host mask
	}

	private function calcNetworkBuffer(required array ipBuffer, required array maskBuffer){
		//set all host bits to 0
		return ipBuffer.map( (v,i) => {
			return bitAnd(v, maskBuffer[i] );
		} );
	}

	private function calcBroadcastBuffer(required array ipBuffer, required array maskBuffer){
		//set all host bits to 1;
		return calcHostMaskBuffer(arguments.maskBuffer)
			.map( (v,i) => {
				return bitOr(v, ipBuffer[i] );
			} );
	}

	private function subnetMaskFromPrefixLength(required length){
		var bytes = ['','','',''];

		for(i=1; i<=4; i++){
			for(x=1; x<=8; x++){
				bytes[i] &= arguments.length > 0 ? '1' : '0';
				arguments.length--;
			}
		}

		var mask = bytes
			.map( (oct) => binToDec(oct,2) )

		return mask;
	}

	private function prefixLengthFromSubnetMask(required mask){
		var length = listToArray(arguments.mask, '.')
			.map( (oct) => decToBin(oct) )
			.toList('')
			.replace('0', '', 'all')
			.len()

		return length;
	}

	private function isCidr(required ip){
		return isValid(type='regex', value=arguments.ip, pattern=this.cidrRegex);
	}

	private function isIp(required ip){
		return isValid(type='regex', value=arguments.ip, pattern=this.ipRegex);
	}

	private function isMask(required ip){
		return isValid(type='regex', value=arguments.ip, pattern=this.maskRegex);
	}	

	private function binToDec(required string binary){
		return createObject( 'Java', 'java.math.BigInteger' ).init(binary,2);
		//return inputBaseN(arguments.binary, 2);
	}

	private function decToBin(required numeric decimal){
		return createObject( 'Java', 'java.math.BigInteger' ).init(arguments.decimal).toString( 2 );
		//return formatBaseN(arguments.decimal, 2);
	}

	private function bufferToDec(required array buffer){
		return arguments.buffer[1] * 256 ^ 3 
			+ arguments.buffer[2] * 256 ^ 2 
			+ arguments.buffer[3] * 256 ^ 1 
			+ arguments.buffer[4] * 256 ^ 0;
	}

	private function ipToDec(required string ip){
		return bufferToDec( listToArray(arguments.ip, '.') ) 
	}

	function decToIp(required numeric dec){
		var bin = pad( decToBin(arguments.dec), '0', 32);
		var o1 = mid(bin, 1, 8);
		var o2 = mid(bin, 9, 8);
		var o3 = mid(bin, 17, 8);
		var o4 = mid(bin, 25, 8);
		return '#binToDec(o1)#.#binToDec(o2)#.#binToDec(o3)#.#binToDec(o4)#';
	}	

	//false for left pad, true for right pad
	private function pad( string str, string char, numeric num, boolean dir = false ){
		arguments.char = char & '';
		var len = str.len();
		var padChars = repeatString(char, num-len);
		return !dir ? padChars & str : str & padChars;
	}

}