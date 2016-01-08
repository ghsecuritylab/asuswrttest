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

<title><#Web_Title#> - <#menu5_1_1#></title>
<link rel="stylesheet" type="text/css" href="index_style.css"> 
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<link href="other.css"  rel="stylesheet" type="text/css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/md5.js"></script>
<script type="text/javascript" src="/detect.js"></script>
<script>
wan_route_x = '<% nvram_get("wan_route_x"); %>';
wan_nat_x = '<% nvram_get("wan_nat_x"); %>';
wan_proto = '<% nvram_get("wan_proto"); %>';
var wireless = [<% wl_auth_list(); %>];	// [[MAC, associated, authorized], ...]
<% login_state_hook(); %>
<% wl_get_parameter(); %>

wl_channel_list_2g = <% channel_list_2g(); %>;
wl_channel_list_5g = <% channel_list_5g(); %>;

var country = '';
if('<% nvram_get("wl_unit"); %>' == '1')
		country = '<% nvram_get("wl1_country_code"); %>';
else		
		country = '<% nvram_get("wl0_country_code"); %>';

var model_name = '<% nvram_get("productid"); %>';
var ac_model = model_name.indexOf('AC') > 0 ? true : false; 


function initial(){
	show_menu();
	load_body();

	if(ac_model){
		regen_5G_mode(document.form.wl_nmode_x,'<% nvram_get("wl_unit"); %>')		
	}
	
	genBWTable('<% nvram_get("wl_unit"); %>');	
	
	if((sw_mode == 2 || sw_mode == 4) && '<% nvram_get("wl_unit"); %>' == '<% nvram_get("wlc_band"); %>' && '<% nvram_get("wl_subunit"); %>' != '1'){
		_change_wl_unit('<% nvram_get("wl_unit"); %>');
	}

	if(band5g_support && band5g_11ac_support && document.form.wl_unit[1].selected == true){
		document.getElementById('wl_mode_desc').onclick=function(){return openHint(1, 5)};		
	}else if(band5g_support && document.form.wl_unit[1].selected == true){
		document.getElementById('wl_mode_desc').onclick=function(){return openHint(1, 4)};
	}

	// special case after modifing GuestNetwork
	if("<% nvram_get("wl_unit"); %>" == "-1" && "<% nvram_get("wl_subunit"); %>" == "-1"){
		change_wl_unit();
	}

	wl_auth_mode_change(1);
	// mbss_display_ctrl();

	if(optimizeXbox_support){
		$("wl_optimizexbox_span").style.display = "";
		document.form.wl_optimizexbox_ckb.checked = ('<% nvram_get("wl_optimizexbox"); %>' == 1) ? true : false;
	}

	document.form.wl_ssid.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_ssid"); %>');
	document.form.wl_wpa_psk.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_wpa_psk"); %>');
	document.form.wl_key1.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_key1"); %>');
	document.form.wl_key2.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_key2"); %>');
	document.form.wl_key3.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_key3"); %>');
	document.form.wl_key4.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_key4"); %>');
	document.form.wl_phrase_x.value = decodeURIComponent('<% nvram_char_to_ascii("", "wl_phrase_x"); %>');
	document.form.wl_channel.value = document.form.wl_channel_orig.value;

	if(document.form.wl_unit[0].selected == true){
		$("wl_gmode_checkbox").style.display = "";
	}

	if(document.form.wl_nmode_x.value=='1'){
		document.form.wl_gmode_check.checked = false;
		$("wl_gmode_check").disabled = true;
	}
	else{
		document.form.wl_gmode_check.checked = true;
		$("wl_gmode_check").disabled = false;
	}

	if(document.form.wl_gmode_protection.value == "auto")
		document.form.wl_gmode_check.checked = true;
	else
		document.form.wl_gmode_check.checked = false;

	if(!band5g_support)	
		$("wl_unit_field").style.display = "none";

	if(sw_mode == 2 || sw_mode == 4)
		document.form.wl_subunit.value = ('<% nvram_get("wl_unit"); %>' == '<% nvram_get("wlc_band"); %>') ? 1 : -1;
				
	change_wl_nmode(document.form.wl_nmode_x);
}

function change_wl_nmode(o){
	if(o.value=='1') /* Jerry5: to be verified */
		inputCtrl(document.form.wl_gmode_check, 0);
	else
		inputCtrl(document.form.wl_gmode_check, 1);

	/*
	// Legacy: a/b/g 
	if(o.value == "2"){ 
		document.form.wl_bw[1].selected = true;
		inputCtrl(document.form.wl_bw, 0);
		document.form.wl_bw.value = 1;
		document.form.wl_bw.disabled = 0; // commit wl_bw
	}
	// N 
	else 
		inputCtrl(document.form.wl_bw, 1);
	*/

	limit_auth_method();
	if(o.value == "3"){
		document.form.wl_wme.value = "on";
	}

	wl_chanspec_list_change();
	//nmode_limitation();
	automode_hint();
}

function genBWTable(_unit){
	cur = '<% nvram_get("wl_bw"); %>';
	var bws = new Array();
	var bwsDesc = new Array();

	if(document.form.wl_nmode_x.value == 2){
		bws = [1];
		bwsDesc = ["20 MHz"];
	}
	else if(_unit == 0){
		bws = [0, 1, 2];
		bwsDesc = ["20/40 MHz", "20 MHz", "40 MHz"];
	}
	else{
		if(document.form.preferred_lang.value == "UK"){    //use unique font-family for JP
			bws = [0, 1, 2];
			bwsDesc = ["20/40 MHz", "20 MHz", "40 MHz"];
		}
		else if (!ac_model){	//for RT-N66U SDK 6.x
			bws = [0, 1, 2];
			bwsDesc = ["20/40 MHz", "20 MHz", "40 MHz"];		
		}
		else{	
			bws = [0, 1, 2, 3];
			bwsDesc = ["20/40/80 MHz", "20 MHz", "40 MHz", "80 MHz"];
		}		
	}

	add_options_x2(document.form.wl_bw, bwsDesc, bws, cur);
	/*document.form.wl_bw.length = bws.length;
	for (var i in bws) {
		document.form.wl_bw[i] = new Option(bwsDesc[i], bws[i]);
		document.form.wl_bw[i].value = bws[i];

		if (bws[i] == cur) {
			document.form.wl_bw[i].selected = true;
		}
	}*/
	wl_chanspec_list_change();
}

function mbss_display_ctrl(){
	// generate options
	if(wl_vifnames != ""){
		for(var i=1; i<multissid_support+1; i++)
			add_options_value(document.form.wl_subunit, i, '<% nvram_get("wl_subunit"); %>');
	}	
	else
		$("wl_subunit_field").style.display = "none";

	if(document.form.wl_subunit.value != 0){
		$("wl_bw_field").style.display = "none";
		$("wl_channel_field").style.display = "none";
		$("wl_nctrlsb_field").style.display = "none";
	}
	else
		$("wl_bss_enabled_field").style.display = "none";
}

function add_options_value(o, arr, orig){
	if(orig == arr)
		add_option(o, "mbss_"+arr, arr, 1);
	else
		add_option(o, "mbss_"+arr, arr, 0);
}

function applyRule(){
	var auth_mode = document.form.wl_auth_mode_x.value;
	
	if(document.form.wl_wpa_psk.value == "<#wireless_psk_fillin#>")
		document.form.wl_wpa_psk.value = "";

	if(validForm()){
		showLoading();
		document.form.wps_config_state.value = "1";
		
		if((auth_mode == "shared" || auth_mode == "wpa" || auth_mode == "wpa2"  || auth_mode == "wpawpa2" || auth_mode == "radius" ||
				((auth_mode == "open") && !(document.form.wl_wep_x.value == "0")))
				&& document.form.wps_mode.value == "enabled")
			document.form.wps_mode.value = "disabled";
		
		if(auth_mode == "wpa" || auth_mode == "wpa2" || auth_mode == "wpawpa2" || auth_mode == "radius")
			document.form.next_page.value = "/Advanced_WSecurity_Content.asp";

		if(document.form.wl_nmode_x.value == "1" && "<% nvram_get("wl_unit"); %>" == "0")
			document.form.wl_gmode_protection.value = "off";
			
		/*  Viz 2012.08.15 seems ineeded
		inputCtrl(document.form.wl_crypto, 1);
		inputCtrl(document.form.wl_wpa_psk, 1);
		inputCtrl(document.form.wl_wep_x, 1);
		inputCtrl(document.form.wl_key, 1);
		inputCtrl(document.form.wl_key1, 1);
		inputCtrl(document.form.wl_key2, 1);
		inputCtrl(document.form.wl_key3, 1);
		inputCtrl(document.form.wl_key4, 1);
		inputCtrl(document.form.wl_phrase_x, 1);
		inputCtrl(document.form.wl_wpa_gtk_rekey, 1);*/

		if(sw_mode == 2 || sw_mode == 4)
			document.form.action_wait.value = "5";

		document.form.submit();
	}
}

function validForm(){
	var auth_mode = document.form.wl_auth_mode_x.value;
	
	if(!validate_string_ssid(document.form.wl_ssid))
		return false;
	
	if(!check_NOnly_to_GN()){
		autoFocus('wl_nmode_x');
		return false;
	}
	
	if(document.form.wl_wep_x.value != "0")
		if(!validate_wlphrase('WLANConfig11b', 'wl_phrase_x', document.form.wl_phrase_x))
			return false;	
	if(auth_mode == "psk" || auth_mode == "psk2" || auth_mode == "pskpsk2"){ //2008.08.04 lock modified
		if(!validate_psk(document.form.wl_wpa_psk))
			return false;
		
		if(!validate_range(document.form.wl_wpa_gtk_rekey, 0, 2592000))
			return false;
	}
	else if(auth_mode == "wpa" || auth_mode == "wpa2" || auth_mode == "wpawpa2"){
		if(!validate_range(document.form.wl_wpa_gtk_rekey, 0, 2592000))
			return false;
	}
	else{
		var cur_wep_key = eval('document.form.wl_key'+document.form.wl_key.value);		
		if(auth_mode != "radius" && !validate_wlkey(cur_wep_key))
			return false;
	}	
	return true;
}

function done_validating(action){
	refreshpage();
}

function validate_wlphrase(s, v, obj){
	if(!validate_string(obj)){
		is_wlphrase(s, v, obj);
		return false;
	}
	return true;
}

function disableAdvFn(){
	for(var i=18; i>=3; i--)
		$("WLgeneral").deleteRow(i);
}

function _change_wl_unit(val){
	document.form.wl_subunit.value = (val == '<% nvram_get("wlc_band"); %>') ? 1 : -1;
	change_wl_unit();
}

function checkBW(){
	if(wifilogo_support)
		return false;
 

	if(document.form.wl_chanspec.value != 0 && document.form.wl_bw.value == 0){	//Auto but set specific channel
		if(document.form.wl_chanspec.value == "165")	// channel 165 only for 20MHz
			document.form.wl_bw.selectedIndex = 1;
		else if('<% nvram_get("wl_unit"); %>' == 0 || document.form.preferred_lang.value == "UK")	//2.4GHz or UK for 40MHz
			document.form.wl_bw.selectedIndex = 2;
		else{	//5GHz for RT-N66U
			document.form.wl_bw.selectedIndex = 2;
			if (wl_channel_list_5g.getIndexByValue("165") >= 0 ) // rm option 165 if not Auto
						document.form.wl_chanspec.remove(wl_channel_list_5g.getIndexByValue("165"));			
		}
	}
}

function check_NOnly_to_GN(){
	//var gn_array_2g = [["1", "ASUS_Guest1", "psk", "tkip", "1234567890", "0", "1", "", "", "", "", "0", "off", "0"], ["1", "ASUS_Guest2", "shared", "aes", "", "1", "1", "55555", "", "", "", "0", "off", "0"], ["1", "ASUS_Guest3", "open", "aes", "", "2", "4", "", "", "", "1234567890123", "0", "off", "0"]];
	//                    Y/N        mssid      auth    asyn    wpa_psk wl_wep_x wl_key k1	k2 k3 k4                                        
	//var gn_array_5g = [["1", "ASUS_5G_Guest1", "open", "aes", "", "0", "1", "", "", "", "", "0", "off", "0"], ["0", "ASUS_5G_Guest2", "open", "aes", "", "0", "1", "", "", "", "", "0", "off", ""], ["0", "ASUS_5G_Guest3", "open", "aes", "", "0", "1", "", "", "", "", "0", "off", ""]];
	// Viz add 2012.11.05 restriction for 'N Only' mode  ( start 	
	if(document.form.wl_nmode_x.value == "1" && "<% nvram_get("wl_unit"); %>" == "1"){		//5G
			for(var i=0;i<gn_array_5g.length;i++){
					if(gn_array_5g[i][0] == "1" 
							&& (gn_array_5g[i][3] == "tkip" || gn_array_5g[i][5] == "1" || gn_array_5g[i][5] == "2")){								
								$('wl_NOnly_note').style.display = "";
								return false;
					}
			}
	}else if(document.form.wl_nmode_x.value == "1"){		//2.4G
			for(var i=0;i<gn_array_2g.length;i++){
					if(gn_array_2g[i][0] == "1" 
							&& (gn_array_2g[i][3] == "tkip" || gn_array_2g[i][5] == "1" || gn_array_2g[i][5] == "2")){
								$('wl_NOnly_note').style.display = "";
								return false;
					}
			}
	}
	$('wl_NOnly_note').style.display = "none";
	return true;
//  Viz add 2012.11.05 restriction for 'N Only' mode  ) end		
}

function regen_5G_mode(obj,flag){
	if(flag == 1){
		free_options(obj);
		obj.options[0] = new Option("<#Auto#>", 0);
		obj.options[1] = new Option("N + AC", 1);
		obj.options[2] = new Option("Legacy", 2);
	}
	
	obj.value = '<% nvram_get("wl_nmode_x"); %>';
}

function wl_chanspec_list_change(){
	var phytype = "n";
	var band = document.form.wl_unit.value;
	var bw_cap = document.form.wl_bw.value;
	var chanspecs = new Array(0);
	var cur = 0;
	var sel = 0;

	if(country == ""){
		country = prompt("The Country Code is not exist! Please enter Country Code.", "");
	}

	/* Save current chanspec */
	cur = '<% nvram_get("wl_chanspec"); %>';

	if (phytype == "a") {	// a mode
		chanspecs = new Array(0); 
	}
	else if (phytype == "n") { // n mode
		
		if (band == "1") { // ---- 5 GHz
				if(wl_channel_list_5g instanceof Array && wl_channel_list_5g != ["0"]){	//With wireless channel 5g hook or return not ["0"]
						wl_channel_list_5g = eval('<% channel_list_5g(); %>');
						
						if (bw_cap != "0" && bw_cap != "1" && wl_channel_list_5g.getIndexByValue("165") >= 0 ) // rm 165, If not [20 MHz] or not [Auto]
								wl_channel_list_5g.splice(wl_channel_list_5g.getIndexByValue("165"),1);
						
						if(bw_cap == "0"){	// [20/40/80 MHz] (auto)
								for(var i=0;i<wl_channel_list_5g.length;i++){
										if(wl_channel_list_5g[i] == "165")		//165 belong to 20MHz
												wl_channel_list_5g[i] = wl_channel_list_5g[i];
										else if(document.form.preferred_lang.value == "UK")		// auto for UK
												wl_channel_list_5g[i] = wlextchannel_fourty(wl_channel_list_5g[i]);
										else{
												if(country == "EU" && parseInt(wl_channel_list_5g[i]) >= 116 && parseInt(wl_channel_list_5g[i]) <= 140){	// belong to 40MHz	
														wl_channel_list_5g[i] = wlextchannel_fourty(wl_channel_list_5g[i]);
												}else if(country == "TW" && parseInt(wl_channel_list_5g[i]) >= 56 && parseInt(wl_channel_list_5g[i]) <= 64){	// belong to 40MHz
														wl_channel_list_5g[i] = wlextchannel_fourty(wl_channel_list_5g[i]);
												}else{																																		
														wl_channel_list_5g[i] = wlextchannel_fourty(wl_channel_list_5g[i]);
												}		
										}		
								}								
						}
						else if(bw_cap == "3"){	// [80 MHz]
								for(var i=wl_channel_list_5g.length-1;i>=0;i--){									
										if(document.form.preferred_lang.value == "UK")		// auto for UK
												wl_channel_list_5g[i] = wlextchannel_fourty(wl_channel_list_5g[i]);
										else{												
												if(country == "EU" && parseInt(wl_channel_list_5g[i]) >= 116 && parseInt(wl_channel_list_5g[i]) <= 140){	// rm 80MHz invalid channel
														wl_channel_list_5g.splice(wl_channel_list_5g.getIndexByValue(wl_channel_list_5g[i]),1);
												}else if(country == "TW" && parseInt(wl_channel_list_5g[i]) >= 56 && parseInt(wl_channel_list_5g[i]) <= 64){	// rm 80MHz invalid channel														
														wl_channel_list_5g.splice(wl_channel_list_5g.getIndexByValue(wl_channel_list_5g[i]),1);
												}else{																																																										
														wl_channel_list_5g[i] = wl_channel_list_5g[i]+"/80";
												}
										}		
								}							
								
						}
						else if(bw_cap == "2"){		// 40MHz
								for(var i=0;i<wl_channel_list_5g.length;i++){
										wl_channel_list_5g[i] = wlextchannel_fourty(wl_channel_list_5g[i]);	
								}
						}
												
						if(wl_channel_list_5g[0] != "0")
								wl_channel_list_5g.splice(0,0,"0");
								
						chanspecs = wl_channel_list_5g;	
						
				}else{	// hook failure to set chennel by static channels array
									
						if (bw_cap == "1") { // -- 20 MHz
							if (country == "Q2")
								chanspecs = new Array(0, "36", "40", "44", "48", "149", "153", "157", "161", "165");
							else if (country == "EU")
								chanspecs = new Array(0, "36", "40", "44", "48", "52", "56", "60", "64", "100", "104", "108", "112", "116", "132", "136", "140");
							else if (country == "TW")
								chanspecs = new Array(0, "56", "60", "64", "149", "153", "157", "161", "165");
							else if (country == "CN")
								chanspecs = new Array(0, "149", "153", "157", "161", "165");
							else if (country == "XX")
								chanspecs = new Array(0, "34", "36", "38", "40", "42", "44", "46", "48", "52", "56", "60", "64", "100", "104", "108", "112", "116", "120", "124", "128", "132", "136", "140", "144", "149", "153", "157", "161", "165");
							else // US
								chanspecs = new Array(0, "36", "40", "44", "48", "149", "153", "157", "161", "165");
						}					 
						else if (bw_cap == "2" || (bw_cap == "0" && document.form.preferred_lang.value == "UK")) { // -- [40 MHz] || [20/40 MHz](auto) for UK
							if (country == "Q2")
								chanspecs = new Array(0, "36l", "40u", "44l", "48u", "149l", "153u", "157l", "161u", "165");
							else if (country == "EU")
								chanspecs = new Array(0, "36l", "40u", "44l", "48u", "52l", "56u", "60l", "64u", "100l", "104u", "108l", "112u", "116l", "132l", "136u", "140l");
							else if (country == "TW")
								chanspecs = new Array(0, "60l", "64u", "149l", "153u", "157l", "161u", "165");
							else if (country == "CN")
								chanspecs = new Array(0, "149l", "153u", "157l", "161u", "165");
							else if (country == "XX")
								chanspecs = new Array(0, "36l", "40u", "44l", "48u", "52l", "56u", "60l", "64u", "100l", "104u", "108l", "112u", "116l", "120u", "124l", "128u", "132l", "136u", "140l", "144u", "149l", "153u", "157l", "161u", "165");
							else // US
								chanspecs = new Array(0, "36l", "40u", "44l", "48u", "149l", "153u", "157l", "161u", "165");
						} 
						else if (bw_cap == "3") { // -- 80 MHz
							if (country == "Q2")
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "149/80", "153/80", "157/80", "161/80");
							else if (country == "EU")
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "52/80", "56/80", "60/80", "64/80", "100/80", "104/80", "108/80", "112/80");
							else if (country == "TW")
								chanspecs = new Array(0, "149/80", "153/80", "157/80", "161/80");
							else if (country == "CN")
								chanspecs = new Array(0, "149/80", "153/80", "157/80", "161/80");
							else if (country == "XX")
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "52/80", "56/80", "60/80", "64/80", "100/80", "104/80", "108/80", "112/80", "116/80", "120/80", "124/80", "128/80", "132/80", "136/80", "140/80", "144/80", "149/80", "153/80", "157/80", "161/80");
							else // US
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "149/80", "153/80", "157/80", "161/80");	
						}
						else if (bw_cap == "0" && document.form.preferred_lang.value != "UK") { // -- [20/40/80 MHz] (Auto) for not UK
							if (country == "Q2")
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "149/80", "153/80", "157/80", "161/80", "165");
							else if (country == "EU")
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "52/80", "56/80", "60/80", "64/80", "100/80", "104/80", "108/80", "112/80", "116l", "132l", "136u", "140l");
							else if (country == "TW")
								chanspecs = new Array(0, "149/80", "153/80", "157/80", "161/80", "165");
							else if (country == "CN")
								chanspecs = new Array(0, "149/80", "153/80", "157/80", "161/80", "165");
							else if (country == "XX")
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "52/80", "56/80", "60/80", "64/80", "100/80", "104/80", "108/80", "112/80", "116/80", "120/80", "124/80", "128/80", "132/80", "136/80", "140/80", "144/80", "149/80", "153/80", "157/80", "161/80", "165");
							else // US
								chanspecs = new Array(0, "36/80", "40/80", "44/80", "48/80", "149/80", "153/80", "157/80", "161/80", "165");
						} 
						else { // ...
								chanspecs = [0];
						}
						
				}
		} 
		else if (band == "0") { // - 2.4 GHz
				
				if(wl_channel_list_2g instanceof Array && wl_channel_list_2g != ["0"]){	//With wireless channel 2.4g hook or return ["0"]
						wl_channel_list_2g = eval('<% channel_list_2g(); %>');
						
						if(bw_cap == "2" || bw_cap == "0") { // -- [40 MHz]  | [20/40 MHz]
							
							  if(wl_channel_list_2g.length == 14){		//1~14
										for(var j=0; j<9; j++){
												wl_channel_list_2g[j] = wl_channel_list_2g[j] + "l";
										}
										for(var k=9; k<14; k++){
												wl_channel_list_2g[k] = wl_channel_list_2g[k] + "u";
										}
										
										//add coexistence extension channel
										wl_channel_list_2g.splice(9,0,"9u");
										wl_channel_list_2g.splice(8,0,"8u");
										wl_channel_list_2g.splice(7,0,"7u");
										wl_channel_list_2g.splice(6,0,"6u");
										wl_channel_list_2g.splice(5,0,"5u");
								
								}
								else if(wl_channel_list_2g.length == 13){		//1~13
										for(var j=0; j<9; j++){
												wl_channel_list_2g[j] = wl_channel_list_2g[j] + "l";
										}
										for(var k=9; k<13; k++){
												wl_channel_list_2g[k] = wl_channel_list_2g[k] + "u";
										}
										
										//add coexistence extension channel
										wl_channel_list_2g.splice(9,0,"9u");
										wl_channel_list_2g.splice(8,0,"8u");
										wl_channel_list_2g.splice(7,0,"7u");
										wl_channel_list_2g.splice(6,0,"6u");
										wl_channel_list_2g.splice(5,0,"5u");
								
								}
								else if(wl_channel_list_2g.length == 11){		//1~11
										for(var j=0; j<7; j++){
												wl_channel_list_2g[j] = wl_channel_list_2g[j] + "l";
										}
										for(var k=7; k<11; k++){
												wl_channel_list_2g[k] = wl_channel_list_2g[k] + "u";
										}
										
										//add coexistence extension channel
										wl_channel_list_2g.splice(7,0,"7u");
										wl_channel_list_2g.splice(6,0,"6u");
										wl_channel_list_2g.splice(5,0,"5u");
																				 
								}						
						}
						
						if(wl_channel_list_2g[0] != "0")
								wl_channel_list_2g.splice(0,0,"0");
								
						chanspecs = wl_channel_list_2g;
						
				}else{
				
						if (bw_cap == "1") { // -- 20 MHz
							if (country == "Q2")
								chanspecs = new Array(0, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11");
							else if (country == "EU")
								chanspecs = new Array(0, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13");
							else if (country == "TW")
								chanspecs = new Array(0, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11");
							else if (country == "CN")
								chanspecs = new Array(0, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13");
							else if (country == "XX")
								chanspecs = new Array(0, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14");
							else // US
								chanspecs = new Array(0, "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11");
						} 
						else if (bw_cap == "2" || bw_cap == "0") { // -- 40 MHz
							if (country == "Q2")
								chanspecs = new Array(0, "1l", "2l", "3l", "4l", "5l", "5u", "6l", "6u", "7l", "7u", "8u", "9u", "10u", "11u");
							else if (country == "EU")
								chanspecs = new Array(0, "1l", "2l", "3l", "4l", "5l", "5u", "6l", "6u", "7l", "7u", "8l", "8u", "9l", "9u", "10u", "11u", "12u", "13u");
							else if (country == "TW")
								chanspecs = new Array(0, "1l", "2l", "3l", "4l", "5l", "5u", "6l", "6u", "7l", "7u", "8u", "9u", "10u", "11u");
							else if (country == "CN")
								chanspecs = new Array(0, "1l", "2l", "3l", "4l", "5l", "5u", "6l", "6u", "7l", "7u", "8l", "8u", "9l", "9u", "10u", "11u", "12u", "13u");
							else if (country == "XX")
								chanspecs = new Array(0, "1l", "2l", "3l", "4l", "5l", "5u", "6l", "6u", "7l", "7u", "8l", "8u", "9l", "9u", "10u", "11u", "12u", "13u", "14u");
							else // US
								chanspecs = new Array(0, "1l", "2l", "3l", "4l", "5l", "5u", "6l", "6u", "7l", "7u", "8u", "9u", "10u", "11u");
						}
						else { // ...
							chanspecs = [0];
						}
				}		
		}
	} 
	else { // b/g mode 
		chanspecs = new Array(0);
	}

	/* displaying chanspec even if the BW is auto.
	if(chanspecs[0] == 0 && chanspecs.length == 1)
		document.form.wl_chanspec.parentNode.parentNode.style.display = "none";
	else
		document.form.wl_chanspec.parentNode.parentNode.style.display = "";
	*/

	/* Reconstruct channel array from new chanspecs */
	document.form.wl_chanspec.length = chanspecs.length;
	for (var i in chanspecs){
		if (chanspecs[i] == 0){
			document.form.wl_chanspec[i] = new Option("<#Auto#>", chanspecs[i]);
		}
		else{
			if(band == "1")
				document.form.wl_chanspec[i] = new Option(chanspecs[i].toString().replace("/80", "").replace("u", "").replace("l", ""), chanspecs[i]);
			else
				document.form.wl_chanspec[i] = new Option(chanspecs[i].toString(), chanspecs[i]);
		}

		document.form.wl_chanspec[i].value = chanspecs[i];
		if (chanspecs[i] == cur && bw_cap == '<% nvram_get("wl_bw"); %>') {
			document.form.wl_chanspec[i].selected = true;
			sel = 1;
		}
	}

	if (sel == 0 && document.form.wl_chanspec.length > 0)
		document.form.wl_chanspec[0].selected = true;
}


function wlextchannel_fourty(v){
		var tmp_wl_channel_5g = "";
		if(v > 144){
				tmp_wl_channel_5g = v - 1;
				if(tmp_wl_channel_5g%8 == 0)
						v = v + "u";
				else		
						v = v + "l";
		}else{
				if(v%8 == 0)
						v = v + "u";
				else		
						v = v + "l";											
		}
		return v;
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<div id="hiddenMask" class="popup_bg">
	<table cellpadding="4" cellspacing="0" id="dr_sweet_advise" class="dr_sweet_advise" align="center">
		<tr>
		<td>
			<div class="drword" id="drword"><#Main_alert_proceeding_desc4#> <#Main_alert_proceeding_desc1#>...
				<br/>
				<br/>
		    </div>
		  <div class="drImg"><img src="images/alertImg.png"></div>
			<div style="height:70px; "></div>
		</td>
		</tr>
	</table>
<!--[if lte IE 6.5]><iframe class="hackiframe"></iframe><![endif]-->
</div>

<iframe name="hidden_frame" id="hidden_frame" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" action="/start_apply2.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="wan_route_x" value="<% nvram_get("wan_route_x"); %>">
<input type="hidden" name="wan_nat_x" value="<% nvram_get("wan_nat_x"); %>">

<input type="hidden" name="current_page" value="Advanced_Wireless_Content.asp">
<input type="hidden" name="next_page" value="Advanced_Wireless_Content.asp">
<input type="hidden" name="next_host" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply_new">
<input type="hidden" name="action_script" value="restart_wireless">
<input type="hidden" name="action_wait" value="10">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="wl_country_code" value="<% nvram_get("wl0_country_code"); %>" disabled>
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="wps_mode" value="<% nvram_get("wps_mode"); %>">
<input type="hidden" name="wps_config_state" value="<% nvram_get("wps_config_state"); %>">
<input type="hidden" name="wl_ssid_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_ssid"); %>">
<input type="hidden" name="wlc_ure_ssid_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wlc_ure_ssid"); %>" disabled>
<input type="hidden" name="wl_wpa_psk_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_wpa_psk"); %>">
<input type="hidden" name="wl_key1_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_key1"); %>">
<input type="hidden" name="wl_key2_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_key2"); %>">
<input type="hidden" name="wl_key3_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_key3"); %>">
<input type="hidden" name="wl_key4_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_key4"); %>">
<input type="hidden" name="wl_phrase_x_org" value="<% nvram_char_to_ascii("WLANConfig11b", "wl_phrase_x"); %>">
<input type="hidden" maxlength="15" size="15" name="x_RegulatoryDomain" value="<% nvram_get("x_RegulatoryDomain"); %>" readonly="1">
<input type="hidden" name="wl_gmode_protection" value="<% nvram_get("wl_gmode_protection"); %>">
<input type="hidden" name="wl_wme" value="<% nvram_get("wl_wme"); %>">
<input type="hidden" name="wl_mode_x" value="<% nvram_get("wl_mode_x"); %>">
<input type="hidden" name="wl_nmode" value="<% nvram_get("wl_nmode"); %>">
<input type="hidden" name="wl_nctrlsb_old" value="<% nvram_get("wl_nctrlsb"); %>">
<input type="hidden" name="wl_key_type" value='<% nvram_get("wl_key_type"); %>'> <!--Lock Add 2009.03.10 for ralink platform-->
<input type="hidden" name="wl_channel_orig" value='<% nvram_get("wl_channel"); %>'>
<input type="hidden" name="wl_wep_x_orig" value='<% nvram_get("wl_wep_x"); %>'>
<input type="hidden" name="wl_optimizexbox" value='<% nvram_get("wl_optimizexbox"); %>'>
<input type="hidden" name="wl_subunit" value='-1'>

<table class="content" align="center" cellpadding="0" cellspacing="0">
  <tr>
	<td width="17">&nbsp;</td>
	
	<!--=====Beginning of Main Menu=====-->
	<td valign="top" width="202">
	  <div id="mainMenu"></div>
	  <div id="subMenu"></div>
	</td>
	
	<td valign="top">
	  <div id="tabMenu" class="submenuBlock"></div>

<!--===================================Beginning of Main Content===========================================-->
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
  <tr>
	<td align="left" valign="top" >
	  <table width="760px" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">
		<tbody>
		<tr>
		  <td bgcolor="#4D595D" valign="top">
		  <div>&nbsp;</div>
		  <div class="formfonttitle"><#menu5_1#> - <#menu5_1_1#></div>
      <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
      <div class="formfontdesc"><#adv_wl_desc#></div>
		
			<table width="99%" border="1" align="center" cellpadding="4" cellspacing="0" id="WLgeneral" class="FormTable">

				<tr id="wl_unit_field">
					<th><#Interface#></th>
					<td>
						<select name="wl_unit" class="input_option" onChange="_change_wl_unit(this.value);">
							<option class="content_input_fd" value="0" <% nvram_match("wl_unit", "0","selected"); %>>2.4GHz</option>
							<option class="content_input_fd" value="1" <% nvram_match("wl_unit", "1","selected"); %>>5GHz</option>
						</select>			
					</td>
		  	</tr>

				<!--tr id="wl_subunit_field" style="display:none">
					<th>Multiple SSID index</th>
					<td>
						<select name="wl_subunit" class="input_option" onChange="change_wl_unit();">
							<option class="content_input_fd" value="0" <% nvram_match("wl_subunit", "0","selected"); %>>Primary</option>
						</select>			
						<select id="wl_bss_enabled_field" name="wl_bss_enabled" class="input_option" onChange="mbss_switch();">
							<option class="content_input_fd" value="0" <% nvram_match("wl_bss_enabled", "0","selected"); %>><#WLANConfig11b_WirelessCtrl_buttonname#></option>
							<option class="content_input_fd" value="1" <% nvram_match("wl_bss_enabled", "1","selected"); %>><#WLANConfig11b_WirelessCtrl_button1name#></option>
						</select>			
					</td>
		  	</tr-->

				<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 1);"><#WLANConfig11b_SSID_itemname#></a></th>
					<td>
						<input type="text" maxlength="32" class="input_32_table" id="wl_ssid" name="wl_ssid" value="<% nvram_get("wl_ssid"); %>" onkeypress="return is_string(this, event)">
					</td>
		  	</tr>
			  
				<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 2);"><#WLANConfig11b_x_BlockBCSSID_itemname#></a></th>
					<td>
						<input type="radio" value="1" name="wl_closed" class="input" onClick="return change_common_radio(this, 'WLANConfig11b', 'wl_closed', '1')" <% nvram_match("wl_closed", "1", "checked"); %>><#checkbox_Yes#>
						<input type="radio" value="0" name="wl_closed" class="input" onClick="return change_common_radio(this, 'WLANConfig11b', 'wl_closed', '0')" <% nvram_match("wl_closed", "0", "checked"); %>><#checkbox_No#>
					</td>
				</tr>
					  
			  <tr>
					<th><a id="wl_mode_desc" class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 4);"><#WLANConfig11b_x_Mode_itemname#></a></th>
					<td>									
						<select name="wl_nmode_x" class="input_option" onChange="change_wl_nmode(this);check_NOnly_to_GN();">
							<option value="0" <% nvram_match("wl_nmode_x", "0","selected"); %>><#Auto#></option>
							<option value="1" <% nvram_match("wl_nmode_x", "1","selected"); %>>N Only</option>
							<option value="2" <% nvram_match("wl_nmode_x", "2","selected"); %>>Legacy</option>
						</select>
						<span id="wl_optimizexbox_span" style="display:none"><input type="checkbox" name="wl_optimizexbox_ckb" id="wl_optimizexbox_ckb" value="<% nvram_get("wl_optimizexbox"); %>" onclick="document.form.wl_optimizexbox.value=(this.checked==true)?1:0;"> Optimized for Xbox</input></span>
						<span id="wl_gmode_checkbox" style="display:none;"><input type="checkbox" name="wl_gmode_check" id="wl_gmode_check" value="" onClick="wl_gmode_protection_check();"> b/g Protection</input></span>
						<span id="wl_nmode_x_hint" style="display:none;"><br><#WLANConfig11n_automode_limition_hint#><br></span>
						<span id="wl_NOnly_note" style="display:none;"><br>* [N + AC] is not compatible with current guest network authentication method(TKIP or WEP),  Please go to <a id="gn_link" href="/Guest_network.asp?af=wl_NOnly_note" target="_blank" style="color:#FFCC00;font-family:Lucida Console;text-decoration:underline;">guest network</a> and change the authentication method.</span>
					</td>
			  </tr>

			 	<tr id="wl_bw_field">
			   	<th><#WLANConfig11b_ChannelBW_itemname#></th>
			   	<td>				    			
						<select name="wl_bw" class="input_option" onChange="wl_chanspec_list_change();">
							<option class="content_input_fd" value="0" <% nvram_match("wl_bw", "0","selected"); %>>20 MHz</option>
							<option class="content_input_fd" value="1" <% nvram_match("wl_bw", "1","selected"); %>>20/40 MHz</option>
							<option class="content_input_fd" value="2" <% nvram_match("wl_bw", "2","selected"); %>>40 MHz</option>
						</select>				
			   	</td>
			 	</tr>

				<!-- a/b/g/n channel -->			  
				<tr id="wl_channel_field" style="display:none">
					<th><a id="wl_channel_select" class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 3);"><#WLANConfig11b_Channel_itemname#></a></th>
					<td>
				 		<select name="wl_channel" class="input_option" onChange="insertExtChannelOption();" disabled>
				 		</select>
					</td>
			  </tr>
				<!-- ac channel -->			  
				<tr>
					<th><a id="wl_channel_select" class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 3);"><#WLANConfig11b_Channel_itemname#></a></th>
					<td>
				 		<select name="wl_chanspec" class="input_option" onChange="checkBW();"></select>
					</td>
			  </tr>
		  	<!-- end -->

			  <tr id="wl_nctrlsb_field" style="display:none">
			  	<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 15);"><#WLANConfig11b_EChannel_itemname#></a></th>
		   		<td>
					<select name="wl_nctrlsb" class="input_option" disabled>
						<option value="lower" <% nvram_match("wl_nctrlsb", "lower", "selected"); %>>lower</option>
						<option value="upper"<% nvram_match("wl_nctrlsb", "upper", "selected"); %>>upper</option>
					</select>
					</td>
		  	</tr>
			  
			  <tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 5);"><#WLANConfig11b_AuthenticationMethod_itemname#></a></th>
					<td>
				  		<select name="wl_auth_mode_x" class="input_option" onChange="authentication_method_change(this);">
							<option value="open"    <% nvram_match("wl_auth_mode_x", "open",   "selected"); %>>Open System</option>
							<option value="shared"  <% nvram_match("wl_auth_mode_x", "shared", "selected"); %>>Shared Key</option>
							<option value="psk"     <% nvram_match("wl_auth_mode_x", "psk",    "selected"); %>>WPA-Personal</option>
							<option value="psk2"    <% nvram_match("wl_auth_mode_x", "psk2",   "selected"); %>>WPA2-Personal</option>
							<option value="pskpsk2" <% nvram_match("wl_auth_mode_x", "pskpsk2","selected"); %>>WPA-Auto-Personal</option>
							<option value="wpa"     <% nvram_match("wl_auth_mode_x", "wpa",    "selected"); %>>WPA-Enterprise</option>
							<option value="wpa2"    <% nvram_match("wl_auth_mode_x", "wpa2",   "selected"); %>>WPA2-Enterprise</option>
							<option value="wpawpa2" <% nvram_match("wl_auth_mode_x", "wpawpa2","selected"); %>>WPA-Auto-Enterprise</option>
							<option value="radius"  <% nvram_match("wl_auth_mode_x", "radius", "selected"); %>>Radius with 802.1x</option>
				  		</select>
					</td>
			  	</tr>
			  	
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 6);"><#WLANConfig11b_WPAType_itemname#></a></th>
					<td>		
				  		<select name="wl_crypto" class="input_option">
								<option value="aes" <% nvram_match("wl_crypto", "aes", "selected"); %>>AES</option>
								<option value="tkip+aes" <% nvram_match("wl_crypto", "tkip+aes", "selected"); %>>TKIP+AES</option>
				  		</select>
					</td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 7);"><#WLANConfig11b_x_PSKKey_itemname#></a></th>
					<td>
				  		<input type="text" name="wl_wpa_psk" maxlength="64" class="input_32_table" value="<% nvram_get("wl_wpa_psk"); %>">
					</td>
			  	</tr>
			  		  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 9);"><#WLANConfig11b_WEPType_itemname#></a></th>
					<td>
				  		<select name="wl_wep_x" class="input_option" onChange="wep_encryption_change(this);">
								<option value="0" <% nvram_match("wl_wep_x", "0", "selected"); %>><#wl_securitylevel_0#></option>
								<option value="1" <% nvram_match("wl_wep_x", "1", "selected"); %>>WEP-64bits</option>
								<option value="2" <% nvram_match("wl_wep_x", "2", "selected"); %>>WEP-128bits</option>
				  		</select>
				  		<span name="key_des"></span>
					</td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 10);"><#WLANConfig11b_WEPDefaultKey_itemname#></a></th>
					<td>		
				  		<select name="wl_key" class="input_option"  onChange="wep_key_index_change(this);">
							<option value="1" <% nvram_match("wl_key", "1","selected"); %>>1</option>
							<option value="2" <% nvram_match("wl_key", "2","selected"); %>>2</option>
							<option value="3" <% nvram_match("wl_key", "3","selected"); %>>3</option>
							<option value="4" <% nvram_match("wl_key", "4","selected"); %>>4</option>
				  		</select>
					</td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 18);"><#WLANConfig11b_WEPKey1_itemname#></th>
					<td><input type="text" name="wl_key1" id="wl_key1" maxlength="32" class="input_32_table" value="<% nvram_get("wl_key1"); %>" onKeyUp="return change_wlkey(this, 'WLANConfig11b');"></td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 18);"><#WLANConfig11b_WEPKey2_itemname#></th>
					<td><input type="text" name="wl_key2" id="wl_key2" maxlength="32" class="input_32_table" value="<% nvram_get("wl_key2"); %>" onKeyUp="return change_wlkey(this, 'WLANConfig11b');"></td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 18);"><#WLANConfig11b_WEPKey3_itemname#></th>
					<td><input type="text" name="wl_key3" id="wl_key3" maxlength="32" class="input_32_table" value="<% nvram_get("wl_key3"); %>" onKeyUp="return change_wlkey(this, 'WLANConfig11b');"></td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 18);"><#WLANConfig11b_WEPKey4_itemname#></th>
					<td><input type="text" name="wl_key4" id="wl_key4" maxlength="32" class="input_32_table" value="<% nvram_get("wl_key4"); %>" onKeyUp="return change_wlkey(this, 'WLANConfig11b');"></td>
		  		</tr>

			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 8);"><#WLANConfig11b_x_Phrase_itemname#></a></th>
					<td>
				  		<input type="text" name="wl_phrase_x" maxlength="64" class="input_32_table" value="<% nvram_get("wl_phrase_x"); %>" onKeyUp="return is_wlphrase('WLANConfig11b', 'wl_phrase_x', this);">
					</td>
			  	</tr>
			  
			  	<tr>
					<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(0, 11);"><#WLANConfig11b_x_Rekey_itemname#></a></th>
					<td><input type="text" maxlength="7" name="wl_wpa_gtk_rekey" class="input_6_table"  value="<% nvram_get("wl_wpa_gtk_rekey"); %>" onKeyPress="return is_number(this,event);"></td>
			  	</tr>
		  	</table>
			  
				<div class="apply_gen">
					<input type="button" id="applyButton" class="button_gen" value="<#CTL_apply#>" onclick="applyRule();">
				</div>			  	
			  	
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
	
	<td width="10" align="center" valign="top"></td>
  </tr>
</table>

<div id="footer"></div>
</body>
</html>
