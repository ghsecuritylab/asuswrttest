﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title><#Web_Title#> - <#menu5_1_2#></title>
<link rel="stylesheet" type="text/css" href="index_style.css"> 
<link rel="stylesheet" type="text/css" href="form_style.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/ajax.js"></script>
<script type="text/javascript" src="/detect.js"></script>
<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script>
var $j = jQuery.noConflict();
</script>
<script>
wan_route_x = '<% nvram_get("wan_route_x"); %>';
wan_nat_x = '<% nvram_get("wan_nat_x"); %>';
wan_proto = '<% nvram_get("wan_proto"); %>';
<% login_state_hook(); %>
<% wl_get_parameter(); %>

var wireless = [<% wl_auth_list(); %>];	// [[MAC, associated, authorized], ...]
var wsc_config_state_old = '<% nvram_get("wsc_config_state"); %>';
var wps_enable_old = '<% nvram_get("wps_enable"); %>';
var wl_wps_mode_old = '<% nvram_get("wl_wps_mode"); %>';
var secs;
var timerID = null;
var timerRunning = false;
var timeout = 2000;
var delay = 1000;

function reject_wps(auth_mode, wep){
	return (auth_mode == "open" && wep != "0") || auth_mode == "shared" || auth_mode == "psk" || auth_mode == "wpa" || auth_mode == "wpa2" || auth_mode == "wpawpa2" || auth_mode == "radius";
}

function get_band_str(band){
	if(band == 0)
		return "2.4GHz";
	else if(band == 1)
		return "5GHz";
	return "";
}

function initial(){
	show_menu();

	if(!band5g_support){
		$("wps_band_tr").style.display = "none";
		
	}else{										//Dual band
		$("wps_band_tr").style.display = "";
		if(!wps_multiband_support || document.form.wps_multiband.value == "0") {
			$("wps_band_word").innerHTML = get_band_str(document.form.wps_band.value);
		}

		if (wps_multiband_support && document.form.wps_multiband.value == "1"){
			var rej0 = reject_wps(document.form.wl0_auth_mode_x.value, document.form.wl0_wep_x.value);
			var rej1 = reject_wps(document.form.wl1_auth_mode_x.value, document.form.wl1_wep_x.value);
			band0 = get_band_str(0);
			band1 = get_band_str(1);
			if (rej0)
				band0 = "<del>" + band0 + "</del>";
			if (rej1)
				band1 = "<del>" + band1 + "</del>";
			$("wps_band_word").innerHTML = band0 + " / " + band1;
		}
	}
	
	if(!ValidateChecksum(document.form.wps_sta_pin.value) || document.form.wps_sta_pin.value == "00000000"){
		document.form.wps_method[0].checked = true;
		changemethod(0);
	}
	else{
		document.form.wps_method[1].checked = true;		
		changemethod(1);
	}

	loadXML();
	$('WPS_hideSSID_hint').innerHTML = "<#FW_note#> " + Untranslated.WPS_hideSSID_hint;
	if("<% nvram_get("wl_closed"); %>" == 1){
		$('WPS_hideSSID_hint').style.display = "";	
	}	
}

function SwitchBand(){
	if(wps_enable_old == "0"){
		var wps_band = document.form.wps_band.value;
		var wps_multiband = document.form.wps_multiband.value;
		if (!wps_multiband_support){
			if(document.form.wps_band.value == "1")
				document.form.wps_band.value = 0;
			else
				document.form.wps_band.value = 1;
		}

		// wps_multiband, wps_band: result
		// 0, 0: 2.4GHz
		// 0, 1: 5GHz
		// 1, X: 2.4GHz + 5GHz
		if (wps_multiband_support){
			if (wps_multiband == "1"){
				document.form.wps_multiband.value = 0;
				document.form.wps_band.value = 0;
			}
			else if (wps_multiband == "0" && wps_band == "0"){
				document.form.wps_multiband.value = 0;
				document.form.wps_band.value = 1;
			}
			else if (wps_multiband == "0" && wps_band == "1"){
				document.form.wps_multiband.value = 1;
				document.form.wps_band.value = 0;
			}
		}
	}
	else{
		$("wps_band_hint").innerHTML = "* <#WLANConfig11b_x_WPSband_hint#>";
		return false;
	}

	FormActions("apply.cgi", "change_wps_unit", "", "");
	document.form.target = "";
	document.form.submit();
	applyRule();
}

function done_validating(action){
	refreshpage();
}

function applyRule(){
	showLoading();
	stopFlag = 1;
	document.form.submit();
}

function enableWPS(){
	document.form.action_script.value = "restart_wireless";
	document.form.action_mode.value = "apply_new";
	document.form.action_wait.value = "3";
	applyRule();
}

function configCommand(){
	if(document.form.wps_method[1].checked == true){
		if(PIN_PBC_Check()){
			FormActions("apply.cgi", "wps_apply", "", "");
			document.form.target = "";
			applyRule();
		}
	}
	else{
		document.form.wps_sta_pin.value = "00000000";
		FormActions("apply.cgi", "wps_apply", "", "");
		document.form.target = "";
		applyRule();
	}
}

function resetWPS(){
	showLoading(5);
	FormActions("apply.cgi", "wps_reset", "", "5");
	document.form.submit();
	setTimeout('location.href=location.href;', 5000);
}

function resetTimer()
{
	if (stopFlag == 1)
	{
		stopFlag = 0;
		InitializeTimer();
	}
}

function ValidateChecksum(PIN){
	var accum = 0;

	accum += 3 * (parseInt(PIN / 10000000) % 10);
	accum += 1 * (parseInt(PIN / 1000000) % 10);
	accum += 3 * (parseInt(PIN / 100000) % 10);
	accum += 1 * (parseInt(PIN / 10000) % 10);
	accum += 3 * (parseInt(PIN / 1000) % 10);
	accum += 1 * (parseInt(PIN / 100) % 10);
	accum += 3 * (parseInt(PIN / 10) % 10);
	accum += 1 * (parseInt(PIN / 1) % 10);

	return ((accum % 10) == 0);
}

function PIN_PBC_Check(){
	if(document.form.wps_sta_pin.value != ""){
		if(document.form.wps_sta_pin.value.length != 8 || !ValidateChecksum(document.form.wps_sta_pin.value)){
			alert("<#JS_InvalidPIN#>");
			document.form.wps_sta_pin.focus();
			document.form.wps_sta_pin.select();
			return false;
		}
	}	
	
	return true;
}

function InitializeTimer()
{
	if(!wps_multiband_support && reject_wps(document.form.wl_auth_mode_x.value, document.form.wl_wep_x.value))
		return;
	else if(wps_multiband_support &&
		(reject_wps(document.form.wl0_auth_mode_x.value, document.form.wl0_wep_x.value) ||
		 reject_wps(document.form.wl1_auth_mode_x.value, document.form.wl1_wep_x.value)))
		return;
	
	msecs = timeout;
	StopTheClock();
	StartTheTimer();
}

function StopTheClock()
{
	if(timerRunning)
		clearTimeout(timerID);
	timerRunning = false;
}

function StartTheTimer(){
	if(msecs == 0){
		StopTheClock();
		
		if(stopFlag == 1)
			return;
		
		updateWPS();
		msecs = timeout;
		StartTheTimer();
	}
	else{
		msecs = msecs-500;
		timerRunning = true;
		timerID = setTimeout("StartTheTimer();", delay);
	}
}

function updateWPS(){
	var ie = window.ActiveXObject;

	if (ie)
		makeRequest_ie('/WPS_info.asp');
	else
		makeRequest('/WPS_info.asp');
}

function loadXML(){
	updateWPS();
	InitializeTimer();
}

function refresh_wpsinfo(xmldoc){
	var wpss = xmldoc.getElementsByTagName("wps");
	if(wpss == null || wpss[0] == null){
		if (confirm('<#JS_badconnection#>'))
			;
		else
			stopFlag=1;
		
		return;
	}
	
	if (!wps_multiband_support){
		var wps_infos = wpss[0].getElementsByTagName("wps_info");
		show_wsc_status(wps_infos);
	}
	else if (wps_multiband_support && document.form.wps_multiband.value == "0"){
		var wps_infos;
		if (document.form.wps_band.value == "0")
			wps_infos = wpss[0].getElementsByTagName("wps_info0");
		else
			wps_infos = wpss[0].getElementsByTagName("wps_info1");
		show_wsc_status(wps_infos);
	}
	else{
		var wps_infos0 = wpss[0].getElementsByTagName("wps_info0");
		var wps_infos1 = wpss[0].getElementsByTagName("wps_info1");
		show_wsc_status2(wps_infos0, wps_infos1);
	}
}

function show_wsc_status(wps_infos){
	var wep;

	if (document.form.wps_band.value == "0")
		wep = document.form.wl0_wep_x.value
	else
		wep = document.form.wl1_wep_x.value
	// enable button
	if(wps_enable_old == "1"){
		$("wps_enable_word").innerHTML = "<#btn_Enabled#>";
		$("enableWPSbtn").value = "<#btn_disable#>";
		$("switchWPSbtn").style.display = "none";
	}
	else{
		$("wps_enable_word").innerHTML = "<#btn_Disabled#>"
		$("enableWPSbtn").value = "<#WLANConfig11b_WirelessCtrl_button1name#>";

		if(wps_infos[12].firstChild.nodeValue == 0){
			$("wps_band_word").innerHTML = "2.4GHz";
		}
		else if(wps_infos[12].firstChild.nodeValue == 1){
			$("wps_band_word").innerHTML = "5GHz";
		}	
		$("switchWPSbtn").style.display = "";
	}

	if (reject_wps(wps_infos[11].firstChild.nodeValue, wep)){
		$("wps_enable_hint").innerHTML = "<#WPS_weptkip_hint#><br><#wsc_mode_hint1#> <a style='color:#FC0; text-decoration: underline; font-family:Lucida Console;cursor:pointer;' onclick=\"_change_wl_unit_status(" + wps_infos[12].firstChild.nodeValue + ");\"><#menu5_1_1#></a> <#wsc_mode_hint2#>"
		$("wps_state_tr").style.display = "none";
		$("devicePIN_tr").style.display = "none";
		$("wpsmethod_tr").style.display = "none";
		if (wps_multiband_support)
			$("wps_band_word").innerHTML = "<del>" + $("wps_band_word").innerHTML + "</del>";

		return;
	}

	//$("wps_enable_block").style.display = "";
	
	// WPS status
	if(wps_enable_old == "0"){
		$("wps_state_tr").style.display = "";
		$("wps_state_td").innerHTML = "Not used";
		$("WPSConnTble").style.display = "none";
		$("wpsDesc").style.display = "none";
	}
	else{
		$("wps_state_tr").style.display = "";
		$("wps_state_td").innerHTML = wps_infos[0].firstChild.nodeValue;
		$("WPSConnTble").style.display = "";
		$("wpsDesc").style.display = "";
	}
	
	// device's PIN code
	$("devicePIN_tr").style.display = "";
	$("devicePIN").value = wps_infos[7].firstChild.nodeValue;
	
	// the input of the client's PIN code
	$("wpsmethod_tr").style.display = "";
	if(wps_enable_old == "1"){
		inputCtrl(document.form.wps_sta_pin, 1);
		if(wps_infos[1].firstChild.nodeValue == "Yes")
			$("Reset_OOB").style.display = "";
		else
			$("Reset_OOB").style.display = "none";
	}
	else{
		inputCtrl(document.form.wps_sta_pin, 0);
		$("Reset_OOB").style.display = "none";
	}
	
	// show connecting btn
	/*
	if(wps_infos[0].firstChild.nodeValue == "Idle" || wps_infos[0].firstChild.nodeValue == "Configured"){
		show_method = 1;
	}
	else if(Rawifi_support){ //ralink solutions
		var wpsState = wps_infos[0].firstChild.nodeValue;
		if(wpsState.search("Received M") != -1 || wpsState.search("Send M") != -1 || wpsState == "Success")
			show_method = 1;
	}

	if(show_method == 1) {
		$("addEnrolleebtn_client").style.display = "";
		$("WPSConnTble").style.display = "";
		$("wpsDesc").style.display = "";
		document.form.wps_sta_pin.focus();
	}
	else{
		$("addEnrolleebtn_client").style.display = "none";
		$("WPSConnTble").style.display = "none";
		$("wpsDesc").style.display = "none";
	}
	*/

	if(wps_infos[0].firstChild.nodeValue == "Start WPS Process")
		$("wps_pin_hint").style.display = "inline";
	else
		$("wps_pin_hint").style.display = "none";
	

	if(wps_infos[1].firstChild.nodeValue == "No")
		$("wps_config_td").innerHTML = "No";
	else
		$("wps_config_td").innerHTML = "Yes";
}

function show_wsc_status2(wps_infos0, wps_infos1){
	var rej0 = reject_wps(wps_infos0[11].firstChild.nodeValue, document.form.wl0_wep_x.value);
	var rej1 = reject_wps(wps_infos1[11].firstChild.nodeValue, document.form.wl1_wep_x.value);
	// enable button
	if(wps_enable_old == "1"){
		$("wps_enable_word").innerHTML = "<#btn_Enabled#>";
		$("enableWPSbtn").value = "<#btn_disable#>";
		$("switchWPSbtn").style.display = "none";
	}
	else{
		$("wps_enable_word").innerHTML = "<#btn_Disabled#>"
		$("enableWPSbtn").value = "<#WLANConfig11b_WirelessCtrl_button1name#>";

		band0 = get_band_str(wps_infos0[12].firstChild.nodeValue);
		band1 = get_band_str(wps_infos1[12].firstChild.nodeValue);

		if (rej0)
			band0 = "<del>" + band0 + "</del>";
		if (rej1)
			band1 = "<del>" + band1 + "</del>";
		$("wps_band_word").innerHTML = band0 + " / " + band1;
		$("switchWPSbtn").style.display = "";
	}

	if(rej0 || rej1){
		var band_link = "";
		if(rej0)
			band_link += "<a style='color:#FC0; text-decoration: underline; font-family:Lucida Console;cursor:pointer;' onclick=\"_change_wl_unit_status(0);\"><#menu5_1_1#> " + get_band_str(wps_infos0[12].firstChild.nodeValue) + "</a> ";
		if(rej1)
			band_link += "<a style='color:#FC0; text-decoration: underline; font-family:Lucida Console;cursor:pointer;' onclick=\"_change_wl_unit_status(1);\"><#menu5_1_1#> " + get_band_str(wps_infos1[12].firstChild.nodeValue) + "</a> ";

		$("wps_enable_hint").innerHTML = "<#WPS_weptkip_hint#><br><#wsc_mode_hint1#> " + band_link + " <#wsc_mode_hint2#>";

		if (rej0 && rej1){
			$("wps_state_tr").style.display = "none";
			$("devicePIN_tr").style.display = "none";
			$("wpsmethod_tr").style.display = "none";
			return;
		}
	}

	// WPS status
	if(wps_enable_old == "0"){
		$("wps_state_tr").style.display = "";
		if (!wps_multiband_support || document.form.wps_multiband.value == "0")
			$("wps_state_td").innerHTML = "Not used";
		else
			$("wps_state_td").innerHTML = "Not used / Not used";
		$("WPSConnTble").style.display = "none";
		$("wpsDesc").style.display = "none";
	}
	else{
		$("wps_state_tr").style.display = "";
		$("wps_state_td").innerHTML = wps_infos0[0].firstChild.nodeValue + " / " + wps_infos1[0].firstChild.nodeValue ;
		$("WPSConnTble").style.display = "";
		$("wpsDesc").style.display = "";
	}

	// device's PIN code
	$("devicePIN_tr").style.display = "";
	$("devicePIN").value = wps_infos0[7].firstChild.nodeValue;

	// the input of the client's PIN code
	$("wpsmethod_tr").style.display = "";
	if(wps_enable_old == "1"){
		inputCtrl(document.form.wps_sta_pin, 1);
		if(wps_infos0[1].firstChild.nodeValue == "Yes" || wps_infos1[1].firstChild.nodeValue == "Yes")
			$("Reset_OOB").style.display = "";
		else
			$("Reset_OOB").style.display = "none";
	}
	else{
		inputCtrl(document.form.wps_sta_pin, 0);
		$("Reset_OOB").style.display = "none";
	}

	if(wps_infos0[0].firstChild.nodeValue == "Start WPS Process" || wps_infos1[0].firstChild.nodeValue == "Start WPS Process")
		$("wps_pin_hint").style.display = "inline";
	else
		$("wps_pin_hint").style.display = "none";

	band0 = "Yes"
	if(wps_infos0[1].firstChild.nodeValue == "No")
		band0 = "No"

	band1 = "Yes"
	if(wps_infos1[1].firstChild.nodeValue == "No")
		band1 = "No"

	$("wps_config_td").innerHTML = band0 + " / " + band1;
}

function changemethod(wpsmethod){
	if(wpsmethod == 0){
		$("starBtn").style.marginTop = "9px";
		$("wps_sta_pin").style.display = "none";
	}
	else{
		$("starBtn").style.marginTop = "5px";
		$("wps_sta_pin").style.display = "";
	}
}

function _change_wl_unit_status(__unit){
	document.titleForm.current_page.value = "Advanced_Wireless_Content.asp?af=wl_auth_mode_x";
	document.titleForm.next_page.value = "Advanced_Wireless_Content.asp?af=wl_auth_mode_x";
	change_wl_unit_status(__unit);
}
</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="POST" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>		
		<td valign="top" width="202">
		<div  id="mainMenu"></div>
		<div  id="subMenu"></div>	
		</td>
		<td valign="top">
	<div id="tabMenu" class="submenuBlock"></div>
		<!--===================================Beginning of Main Content===========================================-->
<input type="hidden" name="current_page" value="Advanced_WWPS_Content.asp">
<input type="hidden" name="next_page" value="Advanced_WWPS_Content.asp">
<input type="hidden" name="next_host" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="3">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="wps_enable" value="<% nvram_get("wps_enable"); %>">
<input type="hidden" name="wl_wps_mode" value="<% nvram_get("wl_wps_mode"); %>" disabled>
<input type="hidden" name="wl_auth_mode_x" value="<% nvram_get("wl_auth_mode_x"); %>">
<input type="hidden" name="wl_wep_x" value="<% nvram_get("wl_wep_x"); %>">
<input type="hidden" name="wps_band" value="<% nvram_get("wps_band"); %>">
<input type="hidden" name="wl_crypto" value="<% nvram_get("wl_crypto"); %>">
<input type="hidden" name="wps_multiband" value="<% nvram_get("wps_multiband"); %>">
<input type="hidden" name="wl0_auth_mode_x" value="<% nvram_get("wl0_auth_mode_x"); %>">
<input type="hidden" name="wl0_wep_x" value="<% nvram_get("wl0_wep_x"); %>">
<input type="hidden" name="wl1_auth_mode_x" value="<% nvram_get("wl1_auth_mode_x"); %>">
<input type="hidden" name="wl1_wep_x" value="<% nvram_get("wl1_wep_x"); %>">

<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="top" >
		
<table width="760px" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">

	<tbody>
	<tr>
		  <td bgcolor="#4D595D" valign="top"  >
		  <div>&nbsp;</div>
		  <div class="formfonttitle"><#menu5_1#> - <#menu5_1_2#></div>
		  <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
		  <div class="formfontdesc"><#WLANConfig11b_display6_sectiondesc#></div>
		  <div id="WPS_hideSSID_hint" class="formfontdesc" style="display:none;color:#FFCC00;"></div>		  

		<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"  class="FormTable">
			<tr>
			  	<th width="30%"><a class="hintstyle" href="javascript:void(0);" onClick="openHint(13,1);"><#WLANConfig11b_x_WPS_itemname#></a></th>
			  	<td>
			    	<div id="wps_enable_block" style="display:none;">
			    		<span style="color:#FFF;" id="wps_enable_word">&nbsp;&nbsp;</span>
			    		<input type="button" name="enableWPSbtn" id="enableWPSbtn" value="" class="button_gen" onClick="enableWPS();">
			    		<br>
			    	</div>
						
			    	<div class="left" style="width: 94px;" id="radio_wps_enable"></div>
						<div class="clear"></div>					
						<script type="text/javascript">
							$j('#radio_wps_enable').iphoneSwitch('<% nvram_get("wps_enable"); %>', 
								 function() {
									document.form.wps_enable.value = "1";
									enableWPS();
								 },
								 function() {
									document.form.wps_enable.value = "0";
									enableWPS();
								 },
								 {
									switch_on_container_path: '/switcherplugin/iphone_switch_container_off.png'
								 }
							);
						</script>
						<span id="wps_enable_hint"></span>
		  	  </td>
			</tr>
			
			<tr id="wps_band_tr">
				<th width="30%"><a class="hintstyle" href="javascript:void(0);" onclick="openHint(13,5);"><#Current_band#></th>
				
				<td>
						<span class="devicepin" style="color:#FFF;" id="wps_band_word"></span>&nbsp;&nbsp;
						<input type="button" class="button_gen_long" name="switchWPSbtn" id="switchWPSbtn" value="<#Switch_band#>" class="button" onClick="SwitchBand();">
						<br><span id="wps_band_hint"></span>
		  	</td>
			</tr>
			
			<tr id="wps_state_tr">
				<th><#PPPConnection_x_WANLink_itemname#></th>
				<td width="300">
					<span id="wps_state_td" style="margin-left:5px;"></span>
					<img id="wps_pin_hint" style="display:none;" src="images/InternetScan.gif" />
				</td>
			</tr>

			<tr>
				<th>Configured</th>
				<td>
					<div style="margin-left:-10px">
						<table ><tr>
							<td style="border:0px;" >
								<div class="devicepin" style="color:#FFF;" id="wps_config_td"></div>
							</td>
							<td style="border:0px">
								<input class="button_gen" type="button" onClick="resetWPS();" id="Reset_OOB" name="Reset_OOB" value="<#CTL_Reset_OOB#>" style="padding:0 0.3em 0 0.3em;" >
							</td>
						</tr></table>
					</div>
				</td>
			</tr>
			
			<tr id="devicePIN_tr">
			  <th>
			  	<span id="devicePIN_name"><a class="hintstyle" href="javascript:void(0);" onclick="openHint(13,4);"><#WLANConfig11b_x_DevicePIN_itemname#></a></span>			  
			  </th>
			  <td>
			  	<input type="text" name="devicePIN" id="devicePIN" value="" class="input_15_table" readonly="1" style="float:left;"></input>
			  </td>
			</tr>
		</table>

		<table id="WPSConnTble" width="100%" border="1" align="center" cellpadding="4" cellspacing="0"  class="FormTable" style="display:none;">	

			<div  class="formfontdesc" style="width:97%;padding-bottom:10px;padding-top:10px;display:none;" id="wpsDesc">
				<#WPS_add_client#>
			</div>
			
			<tr id="wpsmethod_tr">
				<th>
			  	<span id="wps_method"><a class="hintstyle" href="javascript:void(0);" onclick="openHint(13,2);">WPS Method</a></span>
			  </th>
			  <td>
					<input type="radio" name="wps_method" onclick="changemethod(0);" value="0">Push Button
					<input type="radio" name="wps_method" onclick="changemethod(1);" value="1"><#WLANConfig11b_x_WPSPIN_itemname#>
			  	<input type="text" name="wps_sta_pin" id="wps_sta_pin" value="" size="8" maxlength="8" class="input_15_table">
				  <div id="starBtn" style="margin-top:10px;"><input class="button_gen" type="button" style="margin-left:5px;" onClick="configCommand();" id="addEnrolleebtn_client" name="addEnrolleebtn"  value="<#wps_start_btn#>"></div>
				</td>
			</tr>

		</table>

	  </td>
	</tr>
</tbody>	
</table>		
					
		</td>
</form>
		

        </tr>
      </table>	
		<!--===================================Ending of Main Content===========================================-->		
	</td>
		
    <td width="10" align="center" valign="top">&nbsp;</td>
	</tr>
</table>

<div id="footer"></div>
</body>
</html>
