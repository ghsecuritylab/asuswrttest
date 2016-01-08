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
	fromDHCPLease: <% dhcpLeaseMacList(); %>,
	staticList: decodeURIComponent('<% nvram_char_to_ascii("", "dhcp_staticlist"); %>').replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	fromNetworkmapd: '<% get_client_detail_info(); %>'.replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	fromBWDPI: '<% bwdpi_device_info(); %>'.replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	wlList_2g: [<% wl_sta_list_2g(); %>],
	wlList_5g: [<% wl_sta_list_5g(); %>],
	wlList_5g_2: [<% wl_sta_list_5g_2(); %>],
	qosRuleList: decodeURIComponent('<% nvram_char_to_ascii("", "qos_rulelist"); %>').replace(/&#62/g, ">").replace(/&#60/g, "<").split('<'),
	init: true
}

var totalClientNum = {
	online: 0,
	wireless: 0,
	wired: 0,
	wireless_ifnames: [],
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
	this.isWL = 0; // 0: wired, 1: 2.4GHz, 2: 5GHz/5GHz-1 3:5GHz-2.
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
	this.ipMethod = "Static";
}

var wirelessList = cookie.get("wireless_list");
var wirelessListArray = new Array();

var clientList = new Array(0);
function genClientList(){
	leaseArray = {hostname: [], mac: []};
	for(var i = 0; i < originData.fromDHCPLease.length; i += 1) {
		var dhcpMac = originData.fromDHCPLease[i][0].toUpperCase();
		var dhcpName = decodeURIComponent(originData.fromDHCPLease[i][1]);
		if(dhcpMac != "") {
			leaseArray.mac.push(dhcpMac);
			leaseArray.hostname.push(dhcpName);
		}
	}

	clientList = [];
	totalClientNum.wireless = 0;
	for(var i=0; i<wl_nband_title.length; i++) totalClientNum.wireless_ifnames[i] = 0;

	//initial wirelessListArray
	if(wirelessList != null && wirelessList != "") {
		var wirelessList_row = wirelessList.split("<");
		for(var i = 0; i < wirelessList_row.length; i += 1) {
			var wirelessList_col = wirelessList_row[i].split(">");
			wirelessListArray[wirelessList_col[0]] = "No";
		}
	}

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

		if(!thisClientMacAddr){
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

		if(originData.wlList_2g[i][1] == "Yes") {
			clientList[thisClientMacAddr].rssi = originData.wlList_2g[i][3];
			clientList[thisClientMacAddr].isWL = 1;

			totalClientNum.wireless++;
			totalClientNum.wireless_ifnames[clientList[thisClientMacAddr].isWL-1]++;
			wirelessListArray[thisClientMacAddr] = originData.wlList_2g[i][1];
		} 
	}

	for(var i=0; i<originData.wlList_5g.length; i++){
		var thisClientMacAddr = (typeof originData.wlList_5g[i][0] == "undefined") ? false : originData.wlList_5g[i][0].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(originData.wlList_5g[i][1] == "Yes") {
			clientList[thisClientMacAddr].rssi = originData.wlList_5g[i][3];
			clientList[thisClientMacAddr].isWL = 2;
		
			totalClientNum.wireless++;
			totalClientNum.wireless_ifnames[clientList[thisClientMacAddr].isWL-1]++;
			wirelessListArray[thisClientMacAddr] = originData.wlList_5g[i][1];
		}
	}

	for(var i=0; i<originData.wlList_5g_2.length; i++){
		var thisClientMacAddr = (typeof originData.wlList_5g_2[i][0] == "undefined") ? false : originData.wlList_5g_2[i][0].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(originData.wlList_5g_2[i][1] == "Yes") {
			clientList[thisClientMacAddr].rssi = originData.wlList_5g_2[i][3];
			clientList[thisClientMacAddr].isWL = 3;

			totalClientNum.wireless++;
			totalClientNum.wireless_ifnames[clientList[thisClientMacAddr].isWL-1]++;
			wirelessListArray[thisClientMacAddr] = originData.wlList_5g_2[i][1];
		}
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

	for(var i = 0; i < leaseArray.mac.length; i += 1) {
		if(typeof clientList[leaseArray.mac[i]] != "undefined"){
			clientList[leaseArray.mac[i]].ipMethod = "DHCP";
		}
	}

	for(var i=0; i<originData.staticList.length; i++){
		if('<% nvram_get("dhcp_static_x"); %>' == "0") break;

		var thisClient = originData.staticList[i].split(">");
		var thisClientMacAddr = (typeof thisClient[0] == "undefined") ? false : thisClient[0].toUpperCase();

		if(!thisClientMacAddr || typeof clientList[thisClientMacAddr] == "undefined"){
			continue;
		}

		if(typeof clientList[thisClientMacAddr] != "undefined"){
			if(clientList[thisClientMacAddr].ipMethod == "DHCP") {
				if(clientList[thisClientMacAddr].ip == thisClient[1] || clientList[thisClientMacAddr].ip == "offline")
					clientList[thisClientMacAddr].ipMethod = "Manual";
			}
		}
	}

	wirelessList = "";
	Object.keys(wirelessListArray).forEach(function(key) {
		if(key != "") {
			var clientMac = key
			var clientMacState = wirelessListArray[key];
			wirelessList +=  "<" + clientMac + ">" + clientMacState;
			if(typeof clientList[clientMac] != "undefined" && clientList[clientMac].isWL > 0) {
				var wirelessOnline = (clientMacState.split(">")[0] == "Yes") ? true : false;
				//If wireless device in sleep mode, but still connect to router. The wireless log still be connected in but in fromNetworkmapd not assigned to IP
				if(clientList[clientMac].ip == "offline") {
					clientList[clientMac].isOnline = false;
					totalClientNum.wireless--;
					totalClientNum.wireless_ifnames[clientList[clientMac].isWL-1]--;
				}
				else { //If wireless device offline, but the device value not delete in fromNetworkmapd in real time, so need update the totalClientNum
					if(clientList[clientMac].isOnline && !wirelessOnline) { 
						totalClientNum.online--;
					}
					clientList[clientMac].isOnline = wirelessOnline;
				}
			}
		}
	});
	cookie.set("wireless_list", wirelessList, 30);
	totalClientNum.wired = parseInt(totalClientNum.online - totalClientNum.wireless);
}

//Initialize client list obj immediately
genClientList();

function getUploadIcon(clientMac) {
	var result = "NoIcon";
	$j.ajax({
		url: '/ajax_uploadicon.asp?clientmac=' + clientMac,
		async: false,
		dataType: 'script',
		error: function(xhr){
			setTimeout("getUploadIcon('" + clientMac + "');", 1000);
		},
		success: function(response){
			result = upload_icon;
		}
	});
	return result
}

function getUploadIconCount() {
	var count = 0;
	$j.ajax({
		url: '/ajax_uploadicon.asp',
		async: false,
		dataType: 'script',
		error: function(xhr){
			setTimeout("getUploadIconCount();", 1000);
		},
		success: function(response){
			count = upload_icon_count;
		}
	});
	return count
}

function getUploadIconList() {
	var list = "";
	$j.ajax({
		url: '/ajax_uploadicon.asp',
		async: false,
		dataType: 'script',
		error: function(xhr){
			setTimeout("getUploadIconList();", 1000);
		},
		success: function(response){
			list = upload_icon_list;
		}
	});
	return list
}
