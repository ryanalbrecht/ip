component {

	function init(){
		variables.loadRange = true;
	}

	function v4(required string ip, string mask){
		arguments.loadRange = variables.loadRange;
		return new ipv4( argumentCollection = arguments );
	}


	function v6(required ip, numeric prefix){
		return new ipv6( );
	}


	function setLoadRange(required boolean loadRange){
		variables.loadRange = arguments.loadRange;
	}

}