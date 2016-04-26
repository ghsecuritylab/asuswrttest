﻿/* Plugin */
var isJsonChanged = function(objNew, objOld){
	for(var i in objOld){	
		if(typeof objOld[i] == "object"){
			if(objNew[i].join() != objOld[i].join()){
				return true;
			}
		}
		else{
			if(typeof objNew[i] == "undefined" || objOld[i] != objNew[i]){
				return true;				
			}
		}
	}

    return false;
};

function convType(str){
	if(str.length == 0)
		return 0;

	var siganature = [[], ["win", "pc"], [], [], ["nas", "storage"], ["cam"], [], 
					  ["ps", "play station", "playstation"], ["xbox"], ["android", "htc"], 
					  ["iphone", "ipad", "ipod", "ios"], ["appletv", "apple tv"], [], 
					  ["nb"], ["mac", "mbp", "mba", "apple"]];

	for(var i=0; i<siganature.length; i++){
		for(var j=0; j<siganature[i].length; j++){
			if(str.toString().toLowerCase().search(siganature[i][j].toString().toLowerCase()) != -1){
				return i;
				break;
			}
		}
	}

	return 0;
}

<% login_state_hook(); %>
/* End */

/* get client info form dhcp lease log */
var leaseArray = {
	hostname: [],
	mac: []
};

(function(){
	if(parent.sw_mode == 1){
		var xmlHttp = new XMLHttpRequest();
		if(!xmlHttp) return false;

		xmlHttp.onreadystatechange = function(){
			if(xmlHttp.readyState == 4 && xmlHttp.status == 200){
				var dhcpleaseXML = xmlHttp.responseXML.getElementsByTagName("dhcplease");
				var leaseMac = dhcpleaseXML[0].getElementsByTagName("mac");
				for(var i=0; i<leaseMac.length-1; i++){
					leaseArray.mac.push(leaseMac[i].childNodes[0].nodeValue.split("value=")[1].toUpperCase());
					leaseArray.hostname.push(
						dhcpleaseXML[0]
							.getElementsByTagName("hostname")[i]
							.childNodes[0].nodeValue
							.split("value=")[1]
							.replace("*", leaseArray.mac[leaseArray.mac.length-1])
					);
				}
				genClientList();
			}
		};

		xmlHttp.open('GET', "/getdhcpLeaseInfo.xml", true);
		xmlHttp.send(null);
	}
})();

var retHostName = function(_mac){
	return leaseArray.hostname[leaseArray.mac.indexOf(_mac.toUpperCase())] || _mac;
}
/* end */

var networkmap_fullscan = '<% nvram_get("networkmap_fullscan"); %>';
var fromNetworkmapdCache = '<% nvram_get("client_info_tmp"); %>'.replace(/&#62/g, ">").replace(/&#60/g, "<").split('<');

var originDataTmp;
var originData = {
	customList: decodeURIComponent('<% nvram_char_to_ascii("", "custom_clientlist"); %>').replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	asusDevice: decodeURIComponent('<% nvram_char_to_ascii("", "asus_device_list"); %>').replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	fromDHCPLease: '',
	staticList: decodeURIComponent('<% nvram_char_to_ascii("", "dhcp_staticlist"); %>').replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	fromNetworkmapd: '<% get_client_detail_info(); %>'.replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	fromBWDPI: '<% bwdpi_device_info(); %>'.replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	wlList_2g: [<% wl_sta_list_2g(); %>],
	wlList_5g: [<% wl_sta_list_5g(); %>],
	qosRuleList: decodeURIComponent('<% nvram_char_to_ascii("", "qos_rulelist"); %>').replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	init: true
}

var totalClientNum = {
	online: 0,
	wireless: 0,
	wired: 0
}

var setClientAttr = function(){
	this.type = "";
	this.name = "";
	this.ip = "offline";
	this.mac = "";
	this.from = "";
	this.macRepeat = 1;
	this.group = "";
	this.dpiType = "";
	this.rssi = "";
	this.ssid = "";
	this.isWL = 0; // 0: wired, 1: 2.4GHz, 2: 5GHz.
	this.qosLevel = "";
	this.curTx = "";
	this.curRx = "";
	this.totalTx = "";
	this.totalRx = "";
	this.callback = "";
	this.keeparp = "";
	this.isGateway = false;
	this.isWebServer = false;
	this.isPrinter = false;
	this.isITunes = false;
	this.isASUS = false;
	this.isLogin = false;
	this.isOnline = false;
	this.isStaticIP = false;
}

var clientList = new Array(0);
function genClientList(){
	clientList = [];
	totalClientNum.wireless = 0;

	if(fromNetworkmapdCache.length > 1 && networkmap_fullscan == 1)
		originData.fromNetworkmapd = fromNetworkmapdCache;

	for(var i=0; i<originData.asusDevice.length; i++){
		var thisClient = originData.asusDevice[i].split(">");
		var thisClientMacAddr = (typeof thisClient[3] == "undefined") ? false : thisClient[3].toUpperCase();

		if(!thisClientMacAddr || thisClient[2] == '<% nvram_get("lan_ipaddr"); %>'){
			continue;
		}

		if(typeof clientList[thisClientMacAddr] == "undefined"){
			clientList.push(thisClientMacAddr);
			clientList[thisClientMacAddr] = new setClientAttr();
			clientList[thisClientMacAddr].from = "asusDevice";
		}
		else{
			if(clientList[thisClientMacAddr].from == "asusDevice")
				clientList[thisClientMacAddr].macRepeat++;
			else
				clientList[thisClientMacAddr].from = "asusDevice";
		}
		
		clientList[thisClientMacAddr].type = thisClient[0];
		clientList[thisClientMacAddr].name = thisClient[1];
		clientList[thisClientMacAddr].ip = thisClient[2];
		clientList[thisClientMacAddr].mac = thisClient[3];
		clientList[thisClientMacAddr].isGateway = (thisClient[2] == '<% nvram_get("lan_ipaddr"); %>') ? true : false;
		clientList[thisClientMacAddr].isWebServer = true;
		clientList[thisClientMacAddr].isPrinter = thisClient[5];
		clientList[thisClientMacAddr].isITunes = thisClient[6];
		clientList[thisClientMacAddr].ssid = thisClient[7];
		clientList[thisClientMacAddr].isASUS = true;
	}

	totalClientNum.online = parseInt(originData.fromNetworkmapd.length - 1);
	for(var i=0; i<originData.fromNetworkmapd.length; i++){
		var thisClient = originData.fromNetworkmapd[i].split(">");
		var thisClientMacAddr = (typeof thisClient[3] == "undefined") ? false : thisClient[3].toUpperCase();

		if(!thisClientMacAddr){
			continue;
		}

		if(typeof clientList[thisClientMacAddr] == "undefined"){
			clientList.push(thisClientMacAddr);
			clientList[thisClientMacAddr] = new setClientAttr();
			clientList[thisClientMacAddr].from = "networkmapd";
		}
		else{
			if(clientList[thisClientMacAddr].from == "networkmapd")
				clientList[thisClientMacAddr].macRepeat++;
			else
				clientList[thisClientMacAddr].from = "networkmapd";
		}

		if(clientList[thisClientMacAddr].type == "")
			clientList[thisClientMacAddr].type = thisClient[0];
		
		clientList[thisClientMacAddr].ip = thisClient[2];
		clientList[thisClientMacAddr].mac = thisClient[3];

		if(clientList[thisClientMacAddr].name == ""){
			clientList[thisClientMacAddr].name = (thisClient[1] != "") ? thisClient[1].trim() : retHostName(clientList[thisClientMacAddr].mac);
		}

		if(clientList[thisClientMacAddr].name != clientList[thisClientMacAddr].mac){
			clientList[thisClientMacAddr].type = convType(clientList[thisClientMacAddr].name);
		}

		clientList[thisClientMacAddr].isGateway = (thisClient[2] == '<% nvram_get("lan_ipaddr"); %>') ? true : false;
		clientList[thisClientMacAddr].isWebServer = (thisClient[4] == 0) ? false : true;
		clientList[thisClientMacAddr].isPrinter = (thisClient[5] == 0) ? false : true;
		clientList[thisClientMacAddr].isITunes = (thisClient[6] == 0) ? false : true;
		clientList[thisClientMacAddr].isOnline = true;
	}

	for(var i=0; i<originData.fromBWDPI.length; i++){
		var thisClient = originData.fromBWDPI[i].split(">");
		var thisClientMacAddr = (typeof thisClient[0] == "undefined") ? false : thisClient[0].toUpperCase();

		if(typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(thisClient[1] != ""){
			clientList[thisClientMacAddr].name = thisClient[1];
			clientList[thisClientMacAddr].type = convType(thisClient[1]);
		}

		if(thisClient[2] != ""){
			clientList[thisClientMacAddr].dpiType = thisClient[2];
			clientList[thisClientMacAddr].type = convType(thisClient[2]);			
		}
	}

	for(var i=0; i<originData.customList.length; i++){
		var thisClient = originData.customList[i].split(">");
		var thisClientMacAddr = (typeof thisClient[1] == "undefined") ? false : thisClient[1].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(typeof clientList[thisClientMacAddr] == "undefined"){
			clientList.push(thisClientMacAddr);
			clientList[thisClientMacAddr] = new setClientAttr();
			clientList[thisClientMacAddr].from = "customList";
		}

		clientList[thisClientMacAddr].name = thisClient[0];
		clientList[thisClientMacAddr].mac = thisClient[1];
		clientList[thisClientMacAddr].group = thisClient[2];
		clientList[thisClientMacAddr].type = thisClient[3];
		clientList[thisClientMacAddr].callback = thisClient[4];
	}

	for(var i=0; i<originData.wlList_2g.length; i++){
		var thisClientMacAddr = (typeof originData.wlList_2g[i][0] == "undefined") ? false : originData.wlList_2g[i][0].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		clientList[thisClientMacAddr].rssi = originData.wlList_2g[i][3];
		clientList[thisClientMacAddr].isWL = 1;
		totalClientNum.wireless++;
	}

	for(var i=0; i<originData.wlList_5g.length; i++){
		var thisClientMacAddr = (typeof originData.wlList_5g[i][0] == "undefined") ? false : originData.wlList_5g[i][0].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		clientList[thisClientMacAddr].rssi = originData.wlList_5g[i][3];
		clientList[thisClientMacAddr].isWL = 2;
		totalClientNum.wireless++;
	}


	if(typeof login_mac_str == "function"){
		var thisClientMacAddr = (typeof login_mac_str == "undefined") ? false : login_mac_str().toUpperCase();

		if(typeof clientList[thisClientMacAddr] != "undefined"){
			clientList[thisClientMacAddr].isLogin = true;
		}
	}

	for(var i=0; i<originData.qosRuleList.length; i++){
		var thisClient = originData.qosRuleList[i].split(">");
		var thisClientMacAddr = (typeof thisClient[1] == "undefined") ? false : thisClient[1].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(typeof clientList[thisClientMacAddr] != "undefined"){
			clientList[thisClientMacAddr].qosLevel = thisClient[5];
		}
	}

	for(var i=0; i<originData.staticList.length; i++){
		var thisClient = originData.staticList[i].split(">");
		var thisClientMacAddr = (typeof thisClient[0] == "undefined") ? false : thisClient[0].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(typeof clientList[thisClientMacAddr] != "undefined"){
			clientList[thisClientMacAddr].isStaticIP = true;
		}
	}

	totalClientNum.wired = parseInt(totalClientNum.online - totalClientNum.wireless);
}
