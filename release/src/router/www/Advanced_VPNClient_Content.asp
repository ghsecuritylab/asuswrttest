﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title><#Web_Title#> - VPN Client Settings</title>
<link rel="stylesheet" type="text/css" href="index_style.css"> 
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<style type="text/css">
.contentM_qis{
	position:absolute;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	z-index:200;
	background-color:#2B373B;
	display:none;
	margin-left: 30%;
	margin-top: 10px;
	width:650px;
}
.contentM_qis_manual{
	position:absolute;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	z-index:200;
	background-color:#2B373B;
	margin-left: -30px;
	margin-left: -100px \9; 
	margin-top:-400px;
	width:740px;
	box-shadow: 3px 3px 10px #000;
}

.QISform_wireless{
	width:600px;
	font-size:12px;
	color:#FFFFFF;
	margin-top:10px;
	*margin-left:10px;
}

.QISform_wireless thead{
	font-size:15px;
	line-height:20px;
	color:#FFFFFF;	
}

.QISform_wireless th{
	padding-left:10px;
	*padding-left:30px;
	font-size:12px;
	font-weight:bolder;
	color: #FFFFFF;
	text-align:left; 
}

.description_down{
	margin-top:10px;
	margin-left:10px;
	padding-left:5px;
	font-weight:bold;
	line-height:140%;
	color:#ffffff;	
}
</style>
<script>
var $j = jQuery.noConflict();

var vpnc_clientlist = decodeURIComponent('<% nvram_char_to_ascii("","vpnc_clientlist"); %>');
var vpnc_clientlist_array_ori = '<% nvram_char_to_ascii("","vpnc_clientlist"); %>';
var vpnc_clientlist_array = decodeURIComponent(vpnc_clientlist_array_ori);
var vpnc_appendix_array = decodeURIComponent('<% nvram_char_to_ascii("", "vpnc_appendix"); %>');
var vpnc_pptp_options_x_list_array = decodeURIComponent('<% nvram_char_to_ascii("", "vpnc_pptp_options_x_list"); %>');
var overlib_str0 = new Array();	//Viz add 2013.04 for record longer VPN client username/pwd
var overlib_str1 = new Array();	//Viz add 2013.04 for record longer VPN client username/pwd
var restart_vpncall_flag = 0; //Viz add 2014.04 for Edit Connecting rule then restart_vpncall

function initial(){
	show_menu();
	show_vpnc_rulelist();
}

function Add_profile(){
	document.form.vpnc_des_edit.value = "";
	document.form.vpnc_svr_edit.value = "";
	document.form.vpnc_account_edit.value = "";
	document.form.vpnc_pwd_edit.value = "";
	document.form.selPPTPOption.value = "auto";
	document.form.vpnc_auto_conn_edit[1].checked = true;
	document.vpnclientForm.vpnc_openvpn_des.value = "";
	document.vpnclientForm.vpnc_openvpn_username.value = "";
	document.vpnclientForm.vpnc_openvpn_pwd.value = "";
	document.vpnclientForm.vpn_clientx_eas_edit[1].checked = true;
	document.vpnclientForm.file.value = "";
	document.openvpnCAForm.file.value = "";
	document.getElementById("cbManualImport").checked = false;
	manualImport(false);
	tabclickhandler(0);
	$("cancelBtn").style.display = "";
	$("cancelBtn_openvpn").style.display = "";
	document.getElementById("pptpcTitle").style.display = "";
	document.getElementById("l2tpcTitle").style.display = "";
	document.getElementById("opencTitle").style.display = "";	
	$j("#openvpnc_setting").fadeIn(300);

	if (!openvpnd_support){
		document.getElementById('opencTitle').style.display = "none";
	}else{
		check_openvpn_in_list();
	}
}

function cancel_add_rule(){
	restart_vpncall_flag = 0;
	idx_tmp = "";
	$j("#openvpnc_setting_openvpn").fadeOut(1);
	$j("#openvpnc_setting").fadeOut(300);
}

function get_vpnc_appendix_auto_conn(idx){
	var orig_array = vpnc_appendix_array;
	var orig_value = orig_array.split("<")[idx];
	if(orig_value == 1)
		return true;
	else
		return false;
}

function addRow_Group(upper, flag, idx){
	document.openvpnManualForm.vpn_crt_client1_ca.disabled = true;
	document.openvpnManualForm.vpn_crt_client1_crt.disabled = true;
	document.openvpnManualForm.vpn_crt_client1_key.disabled = true;
	document.openvpnManualForm.vpn_crt_client1_static.disabled = true;
	document.openvpnManualForm.vpn_crt_client1_crl.disabled = true;
	idx = parseInt(idx);
	if(idx >= 0){		//idx: edit row		
		var table_id = "vpnc_clientlist_table";
		var rule_num = $(table_id).rows.length;
		var item_num = $(table_id).rows[0].cells.length;		
		if(flag == 'PPTP' || flag == 'L2TP'){
			description_obj = document.form.vpnc_des_edit;
			type_obj = document.form.vpnc_type;			
			server_obj = document.form.vpnc_svr_edit;
			username_obj = document.form.vpnc_account_edit;
			password_obj = document.form.vpnc_pwd_edit;
			auto_conn_obj = document.form.vpnc_auto_conn_edit[0];	
		}else{	//OpenVPN: openvpn
			description_obj = document.vpnclientForm.vpnc_openvpn_des;
			type_obj = document.vpnclientForm.vpnc_type;
			server_obj = document.vpnclientForm.vpnc_openvpn_unit_edit;	// vpn_client_unit: 1 or 2
			username_obj = document.vpnclientForm.vpnc_openvpn_username;
			password_obj = document.vpnclientForm.vpnc_openvpn_pwd;
			auto_conn_obj = document.vpnclientForm.vpn_clientx_eas_edit[0];					
		}
		
		if(validForm(flag)){
			var vpnc_clientlist_row = vpnc_clientlist_array.split('<');
			duplicateCheck.tmpIdx = "";
			duplicateCheck.saveTotmpIdx(idx);
			duplicateCheck.tmpStr = "";
			duplicateCheck.saveToTmpStr(type_obj, 0);
			duplicateCheck.saveToTmpStr(server_obj, 0);
			duplicateCheck.saveToTmpStr(username_obj, 0);
			duplicateCheck.saveToTmpStr(password_obj, 0);
			if(duplicateCheck.isDuplicate()){
				username_obj.focus();
				username_obj.select();
				alert("<#JS_duplicate#>")
				return false;
			}
					
			vpnc_clientlist_row[idx] = description_obj.value+">"+type_obj.value+">"+server_obj.value+">"+username_obj.value+">"+password_obj.value;						
			vpnc_clientlist_array = vpnc_clientlist_row.join("<");		
			if(vpnc_appendix_array == ""){
				re_fill_empty_auto_conn(idx, auto_conn_obj);		//idx: NaN=Add i=edit row
			}else{		//add orr edit vpnc_appendix
				edit_auto_conn(idx, auto_conn_obj);
			}	

			//edit vpnc_pptp_options_x_list			
			if(vpnc_pptp_options_x_list_array == "") {
				//idx: NaN=Add i=edit row
				vpnc_pptp_options_x_list_array = reFillEmptyPPTPOPtion(idx, document.form.selPPTPOption.value, vpnc_clientlist_array); 
			}
			else {
				vpnc_pptp_options_x_list_array = handlePPTPOPtion(idx, document.form.selPPTPOption.value, vpnc_clientlist_array);
			}

			document.vpnclientForm.vpnc_pptp_options_x_list.value = vpnc_pptp_options_x_list_array;
			document.form.vpnc_pptp_options_x_list.value = vpnc_pptp_options_x_list_array;					
			show_vpnc_rulelist();
			if(restart_vpncall_flag == 1){	//restart_vpncall
				var vpnc_clientlist_row = vpnc_clientlist_array.split('<');
				var vpnc_clientlist_col = vpnc_clientlist_row[idx].split('>');
				for(var j=0; j<vpnc_clientlist_col.length; j++){
					if(j == 0){
						document.form.vpnc_des_edit.value = vpnc_clientlist_col[0];
					}
					else if(j ==1){
						if(vpnc_clientlist_col[1] == "PPTP")
							document.form.vpnc_proto.value = "pptp";
						else if(vpnc_clientlist_col[1] == "L2TP")
							document.form.vpnc_proto.value = "l2tp";
						else	//OpenVPN
							document.form.vpnc_proto.value = "openvpn";
					} 
					else if(j ==2){
						if(vpnc_clientlist_col[1] == "OpenVPN")
							document.form.vpn_client_unit.value = 1;	//1, 2
						else
							document.form.vpnc_heartbeat_x.value = vpnc_clientlist_col[2];
					} 
					else if(j ==3){
						if(vpnc_clientlist_col[1] == "OpenVPN")
							document.form.vpn_client1_username.value = vpnc_clientlist_col[3];
						else
							document.form.vpnc_pppoe_username.value = vpnc_clientlist_col[3];
					} 
					else if(j ==4){
						if(vpnc_clientlist_col[1] == "OpenVPN")				
							document.form.vpn_client1_password.value = vpnc_clientlist_col[4];
						else	
							document.form.vpnc_pppoe_passwd.value = vpnc_clientlist_col[4];
					} 
				}
						
				// renew auto_conn
				var auto_conn_obj_value = "";
				if(auto_conn_obj.checked == true)
					auto_conn_obj_value = 1;
				else
					auto_conn_obj_value = 0;	
					
				if(vpnc_clientlist_col[1] != "OpenVPN"){				
					document.form.vpnc_auto_conn.value = auto_conn_obj_value;
				}	
				else{
					if(auto_conn_obj_value == 1)
						document.form.vpn_clientx_eas.value += document.form.vpn_client_unit.value+",";
					else
						document.form.vpn_clientx_eas.value = document.form.vpn_clientx_eas.value.replace(document.form.vpn_client_unit.value+",", "");
				}

				// update vpnc_pptp_options_x
				ocument.form.vpnc_pptp_options_x.value = "";
				if(vpnc_clientlist_col[1] == "PPTP" && document.form.selPPTPOption.value != "auto") {
					document.form.vpnc_pptp_options_x.value = document.form.selPPTPOption.value;
				}

				document.form.vpnc_clientlist.value = vpnc_clientlist_array;	
				document.getElementById("vpnc_clientlist_table").rows[idx].cells[0].innerHTML = "-";
				document.getElementById("vpnc_clientlist_table").rows[idx].cells[5].innerHTML = "<img src='/images/InternetScan.gif'>";
				document.form.submit();	
			}
			else{
				document.vpnclientForm.vpnc_clientlist.value = vpnc_clientlist_row.join("<");
				document.vpnclientForm.submit();		
			}
			
			cancel_add_rule();
		}	
	}
	else{	//Add Rule			
		var rule_num = document.getElementById("vpnc_clientlist_table").rows.length;
		var item_num = document.getElementById("vpnc_clientlist_table").rows[0].cells.length;		
		if(rule_num >= upper){
			alert("<#JS_itemlimit1#> " + upper + " <#JS_itemlimit2#>");
			return false;	
		}	

		if(flag == 'PPTP' || flag == 'L2TP'){
			type_obj = document.form.vpnc_type;
			description_obj = document.form.vpnc_des_edit;
			server_obj = document.form.vpnc_svr_edit;
			username_obj = document.form.vpnc_account_edit;
			password_obj = document.form.vpnc_pwd_edit;
			auto_conn_obj = document.form.vpnc_auto_conn_edit[0];
		}else{	//OpenVPN: openvpn
			description_obj = document.vpnclientForm.vpnc_openvpn_des;
			type_obj = document.vpnclientForm.vpnc_type;
			server_obj = document.vpnclientForm.vpnc_openvpn_unit_edit;	// vpn_client_unit: 1 or 2
			username_obj = document.vpnclientForm.vpnc_openvpn_username;
			password_obj = document.vpnclientForm.vpnc_openvpn_pwd;
			auto_conn_obj = document.vpnclientForm.vpn_clientx_eas_edit[0];
		}
		
		if(validForm(flag)){
			duplicateCheck.tmpStr = "";
			duplicateCheck.saveToTmpStr(type_obj, 0);
			duplicateCheck.saveToTmpStr(server_obj, 0);
			duplicateCheck.saveToTmpStr(username_obj, 0);
			duplicateCheck.saveToTmpStr(password_obj, 0);
			if(duplicateCheck.isDuplicate()){
				alert("<#JS_duplicate#>")
				return false;
			}

			addRow(description_obj ,1);
			addRow(type_obj, 0);
			addRow(server_obj, 0);
			addRow(username_obj, 0);
			addRow(password_obj, 0);
			if(vpnc_clientlist_array.charAt(0) == "<")	//rempve the 1st "<"
				vpnc_clientlist_array = vpnc_clientlist_array.substr(1,vpnc_clientlist_array.length);
				
			if(vpnc_appendix_array == ""){
				re_fill_empty_auto_conn(idx, auto_conn_obj);		//idx: 0=Add i=edit row
			}else{		//add orr edit vpnc_appendix
				edit_auto_conn(idx, auto_conn_obj);				
			}	

			//add vpnc_pptp_options_x_list
			if(vpnc_pptp_options_x_list_array == "") {		//idx: NaN=Add i=edit row
				vpnc_pptp_options_x_list_array = reFillEmptyPPTPOPtion(idx, document.form.selPPTPOption.value, vpnc_clientlist_array);
			}
			else{
				vpnc_pptp_options_x_list_array = handlePPTPOPtion(idx, document.form.selPPTPOption.value, vpnc_clientlist_array);
			}

			show_vpnc_rulelist();
			cancel_add_rule();	
			document.vpnclientForm.vpnc_pptp_options_x_list.value = vpnc_pptp_options_x_list_array;
			document.vpnclientForm.vpnc_clientlist.value = vpnc_clientlist_array;
			document.vpnclientForm.submit();			
		}				
	}	
}

function reFillEmptyPPTPOPtion(idx, objValue, vpncClientList) {
	var finalPPTPOptionsList = "";
	var currentVPNCList = vpncClientList;
	var currentVPNCListNum = currentVPNCList.split("<").length;
	if(idx >= 0){ 
		for(var i = 0; i < currentVPNCListNum; i += 1){
			if(i == idx){
				finalPPTPOptionsList += "<" + objValue;
			}
			else{
				finalPPTPOptionsList += "<auto";
			}
		}
	}
	else{ //add
		for(var i = 1; i < currentVPNCListNum; i += 1) {
			finalPPTPOptionsList += "<auto";
		}
		
		finalPPTPOptionsList += "<" + objValue;
	}
	
	return finalPPTPOptionsList;
}

function handlePPTPOPtion(idx, objValue, vpncClientList) {
	var finalPPTPOptionsList = "";
	var currentVPNCList = vpncClientList;
	var currentVPNCListNum = currentVPNCList.split("<").length;
	var origPPTPOptionsList = vpnc_pptp_options_x_list_array;
	var origPPTPOptionsListArray = origPPTPOptionsList.split("<");
	var origPPTPOptionsListArrayNum = origPPTPOptionsListArray.length;
	if(idx >= 0){ //edit
		for(var i = 0; i < currentVPNCListNum; i += 1) {
			if(i == idx) {
				if(objValue == "") {
					finalPPTPOptionsList += "<auto";
				}
				else {
					finalPPTPOptionsList += "<" + objValue;
				}
			}
			else {
				if(origPPTPOptionsListArray[i + 1] == "undefined") {
					finalPPTPOptionsList += "<auto";
				}
				else {
					finalPPTPOptionsList += "<" +  origPPTPOptionsListArray[i + 1];
				}
			}
		}
	}
	else{ //add
		for(var i = 1; i < currentVPNCListNum; i += 1){
			if(origPPTPOptionsListArray[i] == "undefined"){
				finalPPTPOptionsList += "<auto";
			}
			else{
				finalPPTPOptionsList += "<" + origPPTPOptionsListArray[i];
			}
		}
		
		finalPPTPOptionsList += "<" + objValue;
	}
	
	return finalPPTPOptionsList;
}

function re_fill_empty_auto_conn(idx, obj){
	var obj_value = "";
	var temp_value = "";
	var rules_num = vpnc_clientlist_array.split("<").length;	
	if(obj.checked == true)
		obj_value = 1;
	else
		obj_value = 0;	

	if(idx >= 0){	//row edit	//The 1st time set vpnc_appendix
		for(var i=0;i<rules_num;i++){
			if(i == idx)
				temp_value += "<"+obj_value;
			else	
				temp_value += "<0";
		}
	}
	else{		//NaN, Add rule		//The 1st time set vpnc_appendix
		for(var i=0;i<rules_num-1;i++){
			temp_value += "<0";
		}	
			
		temp_value += "<"+obj_value;			
	}
		
	if(temp_value.charAt(0) == "<")	//rempve the 1st "<"
		temp_value = temp_value.substr(1,temp_value.length);
		
	vpnc_appendix_array = temp_value;
	document.vpnclientForm.vpnc_appendix.value = vpnc_appendix_array;	//for OpenVPN Edit/Add
	document.form.vpnc_appendix.value = vpnc_appendix_array;						//for PPTP/L2TP Edit/Add
}

function edit_auto_conn(idx, obj){	
	var obj_value = "";
	var temp_value = "";		
	var rules_num = vpnc_clientlist_array.split("<").length;
	var rules_auto_conn_orig = vpnc_appendix_array;
	var rules_auto_conn_array = rules_auto_conn_orig.split("<");
	if(obj.checked == true)
		obj_value = 1;
	else
		obj_value = 0;		
			
	if(idx >= 0){	//row edit	//Update vpnc_appendix		
		for(var j=0;j<rules_num;j++){
			if(idx == j)
				temp_value += "<"+obj_value;			
			else		
				temp_value += "<"+rules_auto_conn_array[j];
		}
	}
	else{		//NaN, Add rule		//Update vpnc_appendix
		temp_value += rules_auto_conn_orig;
		temp_value += "<"+obj_value;
	}
		
	if(temp_value.charAt(0) == "<")	//rempve the 1st "<"
		temp_value = temp_value.substr(1,temp_value.length);
		
	vpnc_appendix_array = temp_value;
	document.vpnclientForm.vpnc_appendix.value = vpnc_appendix_array;
	document.form.vpnc_appendix.value = vpnc_appendix_array;
}

var duplicateCheck = {
	tmpIdx: "",
	saveTotmpIdx: function(obj){
		this.tmpIdx = obj;	
	},	
	tmpStr: "",
	saveToTmpStr: function(obj, head){	
		if(head != 1)
			this.tmpStr += ">" /*&#62*/

		this.tmpStr += obj.value;
	},
	isDuplicate: function(){
		var vpnc_clientlist_row = vpnc_clientlist_array.split('<');		
		var index_del = parseInt(this.tmpIdx);
		for(var i=0; i<vpnc_clientlist_row.length; i++){		
			if(index_del == "" && index_del != 0){
				if(vpnc_clientlist_row[i].search(this.tmpStr) >= 0){
					return true;	
				}
			}
			else if(i != index_del){
				if(vpnc_clientlist_row[i].search(this.tmpStr) >= 0){
					return true;	
				}		
			}
		}
		
		return false;		
	}
}

function addRow(obj, head){
	if(head == 1)
		vpnc_clientlist_array += "<" /*&#60*/
	else
		vpnc_clientlist_array += ">" /*&#62*/

	vpnc_clientlist_array += obj.value;
}

function validForm(mode){
	if(mode == "PPTP" || mode == "L2TP"){
		valid_des = document.form.vpnc_des_edit;
		valid_server = document.form.vpnc_svr_edit;
		valid_username = document.form.vpnc_account_edit;
		valid_password = document.form.vpnc_pwd_edit;

		if(valid_des.value==""){
			alert("<#JS_fieldblank#>");
			valid_des.focus();
			return false;		
		}else if(!Block_chars(valid_des, ["*", "+", "|", ":", "?", "<", ">", ",", ".", "/", ";", "[", "]", "\\", "=", "\"" ])){
			return false;		
		}

		if(valid_server.value==""){
			alert("<#JS_fieldblank#>");
			valid_server.focus();
			return false;
		}
		else{
			var isIPAddr = valid_server.value.replace(/\./g,"");
			var re = /^[0-9]+$/;
			if(!re.test(isIPAddr)) { //DDNS
				if(!Block_chars(valid_server, ["<", ">"])) {
					return false;
				}		
			}	
			else { // IP
				if(!validator.isLegalIP(valid_server,"")) {
					return false;
				}
			}
		}

		if(valid_username.value==""){
			alert("<#JS_fieldblank#>");
			valid_username.focus();
			return false;
		}else if(!Block_chars(valid_username, ["<", ">"])){
			return false;		
		}

		if(valid_password.value==""){
			alert("<#JS_fieldblank#>");
			valid_password.focus();
			return false;
		}else if(!Block_chars(valid_password, ["<", ">"])){
			return false;		
		}
		
		if(!document.form.vpnc_auto_conn_edit[0].checked && !document.form.vpnc_auto_conn_edit[1].checked)
			document.form.vpnc_auto_conn_edit[1].checked = true;
	
	
	}
	else{		//OpenVPN
		valid_des = document.vpnclientForm.vpnc_openvpn_des;
		valid_username = document.vpnclientForm.vpnc_openvpn_username;
		valid_password = document.vpnclientForm.vpnc_openvpn_pwd;
		if(valid_des.value == ""){
			alert("<#JS_fieldblank#>");
			valid_des.focus();
			return false;		
		}
		else if(!Block_chars(valid_des, ["*", "+", "|", ":", "?", "<", ">", ",", ".", "/", ";", "[", "]", "\\", "=", "\"" ])){
			return false;		
		}
		
		if(valid_username.value != "" && !Block_chars(valid_username, ["<", ">"])){
			return false;		
		}

		if(valid_password.value != "" && !Block_chars(valid_password, ["<", ">"])){
			return false;		
		}
		
		if(!document.vpnclientForm.vpn_clientx_eas_edit[0].checked && !document.vpnclientForm.vpn_clientx_eas_edit[1].checked)
			document.vpnclientForm.vpn_clientx_eas_edit[1].checked = true;
	}	
	
	return true;
}

var save_flag;	//type of Saving profile
function tabclickhandler(_type){
	document.getElementById('pptpcTitle').className = "vpnClientTitle_td_unclick";
	document.getElementById('l2tpcTitle').className = "vpnClientTitle_td_unclick";
	document.getElementById('opencTitle').className = "vpnClientTitle_td_unclick";
	if(_type == 0){
		save_flag = "PPTP";
		document.form.vpnc_type.value = "PPTP";
		document.vpnclientForm.vpnc_type.value = "PPTP";
		document.getElementById('pptpcTitle').className = "vpnClientTitle_td_click";
		document.getElementById('openvpnc_simple').style.display = "none"; 
		document.getElementById('openvpnc_setting_openvpn').style.display = "none";		
		document.getElementById('trPPTPOptions').style.display = "";
	}
	else if(_type == 1){
		save_flag = "L2TP";
		document.form.vpnc_type.value = "L2TP";
		document.vpnclientForm.vpnc_type.value = "L2TP";
		document.getElementById('l2tpcTitle').className = "vpnClientTitle_td_click";
		document.getElementById('openvpnc_simple').style.display = "none"; 
		document.getElementById('openvpnc_setting_openvpn').style.display = "none";  
		document.getElementById('trPPTPOptions').style.display = "none";  
	}
	else if(_type == 2){
		save_flag = "OpenVPN";				
		document.form.vpnc_type.value = "OpenVPN";
		document.vpnclientForm.vpnc_type.value = "OpenVPN";
		document.getElementById('opencTitle').className = "vpnClientTitle_td_click";
		document.getElementById('openvpnc_simple').style.display = "block"; 
		document.getElementById('openvpnc_setting_openvpn').style.display = "block";  		
		document.getElementById('trPPTPOptions').style.display = "none";		
		document.getElementById('openvpnc_setting_openvpn').style.marginTop = "-703px";		
	}
}

function show_vpnc_rulelist(){	
	var vpnc_clientlist_row = vpnc_clientlist_array.split('<');		
	var code = "";
	code +='<table style="margin-bottom:30px;" width="98%" border="1" align="center" cellpadding="4" cellspacing="0" class="list_table" id="vpnc_clientlist_table">';
	if(vpnc_clientlist_array == "")
		code +='<tr><td style="color:#FC0;" colspan="6"><#IPConnection_VSList_Norule#></td></tr>';
	else{
		for(var i=0; i<vpnc_clientlist_row.length; i++){
			overlib_str0[i] = "";
			overlib_str1[i] = "";
			code +='<tr id="row'+i+'">';
			var vpnc_clientlist_col = vpnc_clientlist_row[i].split('>');
			if(vpnc_clientlist_col[1] == "OpenVPN"){
				if(vpnc_proto == "openvpn"){	//matched connecting rule, because openvpn only unit 1 for now.
					if(vpnc_state_t == 2)	//connected
						code +='<td width="10%"><img src="/images/checked_parentctrl.png" style="width:25px;"></td>';
					else if(vpnc_state_t == 1)	//connecting
						code +='<td width="10%"><img src="/images/InternetScan.gif"></td>';
					else		//Stop connection
						code +='<td width="10%"><img src="/images/button-close2.png" style="width:25px;"></td>';
				}
				else
					code +='<td width="10%">-</td>';
			}
			else{
				if( vpnc_clientlist_col[1] == document.form.vpnc_proto.value.toUpperCase() 
				 && vpnc_clientlist_col[2] == document.form.vpnc_heartbeat_x.value
				 && vpnc_clientlist_col[3] == document.form.vpnc_pppoe_username.value){		//matched connecting rule
					if(vpnc_state_t == 0 || vpnc_state_t ==1) // Initial or Connecting
						code +='<td width="10%"><img src="/images/InternetScan.gif"></td>';
					else if(vpnc_state_t == 2) // Connected
						code +='<td width="10%"><img src="/images/checked_parentctrl.png" style="width:25px;"></td>';
					else // Stop connection
						code +='<td width="10%"><img src="/images/button-close2.png" style="width:25px;"></td>';
				}
				else{
					code +='<td width="10%">-</td>';
				}	
			}

			for(var j=0; j<vpnc_clientlist_col.length; j++){
				if(j == 0){
					if(vpnc_clientlist_col[0].length >28){						
						overlib_str0[i] += vpnc_clientlist_col[0];							
						vpnc_clientlist_col[0]=vpnc_clientlist_col[0].substring(0, 25)+"...";							
						code +='<td title="'+overlib_str0[i]+'">'+ vpnc_clientlist_col[0] +'</td>';
					}else{
						code +='<td>'+ vpnc_clientlist_col[0] +'</td>';					
					}
				}
				else if(j == 1){
					code += '<td width="15%">'+ vpnc_clientlist_col[1] +'</td>';
				}
			}

			// EDIT
		 	code += '<td width="10%"><input class="edit_btn" type="button" onclick="Edit_Row(this, \'vpnc\');" value=""/></td>';
			if(vpnc_clientlist_col[1] == "OpenVPN"){ 
				if(vpnc_proto == "openvpn"){	//OpenVPN is connecting
					code += '<td width="10%"><input class="remove_btn" type="button" onclick="del_Row(this, \'vpnc_enable\');" value=""/></td>';
					code += '<td width="25%"><input class="button_gen" type="button" onClick="connect_Row(this, \'disconnect\');" id="disonnect_btn" value="Deactivate" style="padding:0 0.3em 0 0.3em;" >';
				}
				else{			//OpenVPN is not connecting
					code += '<td width="10%"><input class="remove_btn" type="button" onclick="del_Row(this, \'vpnc\');" value=""/></td>';
					code += '<td width="25%"><input class="button_gen" type="button" onClick="connect_Row(this, \'vpnc\');" id="Connect_btn" name="Connect_btn" value="Activate" style="padding:0 0.3em 0 0.3em;" >';
				}
			}
			else{
				if( vpnc_clientlist_col[1] == document.form.vpnc_proto.value.toUpperCase() 
				 && vpnc_clientlist_col[2] == document.form.vpnc_heartbeat_x.value 
				 && vpnc_clientlist_col[3] == document.form.vpnc_pppoe_username.value){		// This rule is connecting
					code += '<td width="10%"><input class="remove_btn" type="button" onclick="del_Row(this, \'vpnc_enable\');" value=""/></td>';
					code += '<td width="25%"><input class="button_gen" type="button" onClick="connect_Row(this, \'disconnect\');" id="disonnect_btn" value="Deactivate" style="padding:0 0.3em 0 0.3em;" >';
				}
				else{		// This rule is not connecting
					code += '<td width="10%"><input class="remove_btn" type="button" onclick="del_Row(this, \'vpnc\');" value=""/></td>';
					code += '<td width="25%"><input class="button_gen" type="button" onClick="connect_Row(this, \'vpnc\');" id="Connect_btn" name="Connect_btn" value="Activate" style="padding:0 0.3em 0 0.3em;" >';
				}
			}
		}
	}
	
	code +='</table>';
	$("vpnc_clientlist_Block").innerHTML = code;		
}
 
function check_openvpn_in_list(){		//Choose vpn_client_unit 1 or 2
	document.getElementById('opencTitle').style.display = "";
	if(vpnc_clientlist_array.split("OpenVPN").length >= 2){	// already 1 openvpn
		document.getElementById('opencTitle').style.display = "none";
	}else if(vpnc_clientlist_array.split('OpenVPN>1') == 2){
		document.vpnclientForm.vpnc_openvpn_unit_edit.value = 2;
	}else if(vpnc_clientlist_array.split('OpenVPN>2') == 2){
		document.vpnclientForm.vpnc_openvpn_unit_edit.value = 1;
	}else{
		document.vpnclientForm.vpnc_openvpn_unit_edit.value = 1;
	}
}

function connect_Row(rowdata, flag){
	var idx = rowdata.parentNode.parentNode.rowIndex;
	var vpnc_clientlist_row = vpnc_clientlist_array.split('<');
	var vpnc_clientlist_col = vpnc_clientlist_row[idx].split('>');
	if(flag == "disconnect"){
		if(vpnc_clientlist_col[1] == "OpenVPN"){
			document.form.vpnc_proto.value = "disable";
			document.form.vpn_client_unit.value = vpnc_clientlist_col[2];
			document.form.vpn_client1_username.value = "";
			document.form.vpn_client1_password.value = "";
			document.form.vpn_clientx_eas.value = document.form.vpn_clientx_eas.value.replace(vpnc_clientlist_col[2]+",", "");
		}else{ //pptp/l2tp
			document.form.vpnc_proto.value = "disable";
			document.form.vpnc_heartbeat_x.value = "";
			document.form.vpnc_pppoe_username.value = "";
			document.form.vpnc_pppoe_passwd.value = "";
			document.form.vpnc_auto_conn.value = "0";
			if(vpnc_clientlist_col[1] == "PPTP") {
				document.form.vpnc_pptp_options_x.value = "";
			}
		}			
	}
	else{		//"vpnc" making connection
		for(var j=0; j<vpnc_clientlist_col.length; j++){
			if(j == 0){
				document.form.vpnc_des_edit.value = vpnc_clientlist_col[0];
			}
			else if(j ==1){
				if(vpnc_clientlist_col[1] == "PPTP")
					document.form.vpnc_proto.value = "pptp";
				else if(vpnc_clientlist_col[1] == "L2TP")
					document.form.vpnc_proto.value = "l2tp";
				else	//OpenVPN
					document.form.vpnc_proto.value = "openvpn";
			} 
			else if(j ==2){
				if(vpnc_clientlist_col[1] == "OpenVPN")
					document.form.vpn_client_unit.value = 1;	//1, 2
				else
					document.form.vpnc_heartbeat_x.value = vpnc_clientlist_col[2];
			} 
			else if(j ==3){
				if(vpnc_clientlist_col[1] == "OpenVPN")
					document.form.vpn_client1_username.value = vpnc_clientlist_col[3];
				else
					document.form.vpnc_pppoe_username.value = vpnc_clientlist_col[3];
			} 
			else if(j ==4){
				if(vpnc_clientlist_col[1] == "OpenVPN")				
					document.form.vpn_client1_password.value = vpnc_clientlist_col[4];
				else	
					document.form.vpnc_pppoe_passwd.value = vpnc_clientlist_col[4];
			} 
		}
								
		// renew auto_conn
		var rules_auto_conn_orig = vpnc_appendix_array;
		if(rules_auto_conn_orig != ""){		//vpnc_appendix exist
			var rules_auto_conn_array = rules_auto_conn_orig.split("<");
			var set_auto_conn = rules_auto_conn_array[idx];																
			if(vpnc_clientlist_col[1] != "OpenVPN")	{			
				document.form.vpnc_auto_conn.value = set_auto_conn;
			}	
			else{	// openvpn
				if(set_auto_conn == 1)
					document.form.vpn_clientx_eas.value += vpnc_clientlist_col[2]+",";
			}
		}
		else{		//vpnc_appendix is empty
			if(vpnc_clientlist_col[1] != "OpenVPN")				
				document.form.vpnc_auto_conn.value = "";
			else	
				document.form.vpn_clientx_eas.value = "";			
		}			

		//handle vpnc_pptp_options_x
		if(vpnc_clientlist_col[1] == "PPTP"){
			var origPPTPOptionsList = vpnc_pptp_options_x_list_array;
			if(origPPTPOptionsList != ""){
				var origPPTPOptionsListArray = origPPTPOptionsList.split("<");
				var setPPTPOption = origPPTPOptionsListArray[idx + 1];
				document.form.vpnc_pptp_options_x.value = "";
				if(setPPTPOption != "auto" && setPPTPOption != "undefined") {
					document.form.vpnc_pptp_options_x.value = setPPTPOption;
				}	
			}
			else{
				document.form.vpnc_pptp_options_x.value = "";
			}
		}
	}

	document.form.vpnc_appendix.value = vpnc_appendix_array;
	document.form.vpnc_pptp_options_x_list.value = vpnc_pptp_options_x_list_array;
	document.form.vpnc_clientlist.value = vpnc_clientlist_array;	
	rowdata.parentNode.innerHTML = "<img src='/images/InternetScan.gif'>";
	document.form.submit();	
}
var idx_tmp = "";
function Edit_Row(rowdata, flag){
	$("cancelBtn").style.display = "";
	$("cancelBtn_openvpn").style.display = "";
	idx_tmp = rowdata.parentNode.parentNode.rowIndex; //update idx
	var idx = rowdata.parentNode.parentNode.rowIndex;
	if(document.getElementById("vpnc_clientlist_table").rows[idx].cells[0].innerHTML != "-")
		restart_vpncall_flag = 1;
	var vpnc_clientlist_row = vpnc_clientlist_array.split('<');
	var vpnc_clientlist_col = vpnc_clientlist_row[idx].split('>');
	var auto_conn_obj_checked = get_vpnc_appendix_auto_conn(idx);
	//get idx of PPTP option value
	var pptpOptionValue = "";
	var origPPTPOptionsList = vpnc_pptp_options_x_list_array;			
	if(idx >= 0){
		var origPPTPOptionsListArray = origPPTPOptionsList.split("<");
		if(origPPTPOptionsListArray.length == 1) { //avoid vpnc_pptp_options_x_list is null
			pptpOptionValue = "auto";
		}
		else{
			if(origPPTPOptionsListArray[idx + 1] == "undefined"){
				pptpOptionValue = "auto";
			}
			else{
				pptpOptionValue = origPPTPOptionsListArray[idx + 1];
			}
			
		}
	}
	else{	//default is auto
		pptpOptionValue = "auto";
	}
	
	document.form.selPPTPOption.value = pptpOptionValue;
	if(vpnc_clientlist_col[1] == "OpenVPN"){
		document.vpnclientForm.vpnc_openvpn_des.value = vpnc_clientlist_col[0];
		document.vpnclientForm.vpnc_openvpn_username.value = vpnc_clientlist_col[3];
		document.vpnclientForm.vpnc_openvpn_pwd.value = vpnc_clientlist_col[4];	
		if(auto_conn_obj_checked)
			document.vpnclientForm.vpn_clientx_eas_edit[0].checked = true;
		else
			document.vpnclientForm.vpn_clientx_eas_edit[1].checked = true;		
				
		tabclickhandler(2);
		document.getElementById("caFiled").style.display = "";
		document.getElementById("manualFiled").style.display = "";
		document.getElementById('importOvpnFile').style.display = ""; 
		document.getElementById('loadingicon').style.display = "none"; 
		document.getElementById("cbManualImport").checked = false;
		manualImport(false);
	}
	else{
		for(var j=0; j<vpnc_clientlist_col.length; j++){
			if(j == 0){
				document.form.vpnc_des_edit.value = vpnc_clientlist_col[0];
			}
			else if(j == 1){
				if(vpnc_clientlist_col[1] == "PPTP")
					tabclickhandler(0);
				else if(vpnc_clientlist_col[1] == "L2TP")
					tabclickhandler(1);
				else
					tabclickhandler(2);
			} 
			else if(j == 2){
				document.form.vpnc_svr_edit.value = vpnc_clientlist_col[2];
			} 
			else if(j == 3){
				document.form.vpnc_account_edit.value = vpnc_clientlist_col[3];
			} 
			else if(j == 4){
				document.form.vpnc_pwd_edit.value = vpnc_clientlist_col[4];
			} 
		}
		
		if(auto_conn_obj_checked)
			document.form.vpnc_auto_conn_edit[0].checked = true;
		else	
			document.form.vpnc_auto_conn_edit[1].checked = true;		
	}

	$j("#openvpnc_setting").fadeIn(300);
	if(vpnc_clientlist_col[1] == "PPTP"){
		document.getElementById("pptpcTitle").style.display = "";
		document.getElementById("l2tpcTitle").style.display = "none";
		document.getElementById("opencTitle").style.display = "none";
		document.getElementById("trPPTPOptions").style.display = "";
	}else if(vpnc_clientlist_col[1] == "L2TP"){
		document.getElementById("pptpcTitle").style.display = "none";
		document.getElementById("l2tpcTitle").style.display = "";
		document.getElementById("opencTitle").style.display = "none";
		document.getElementById("trPPTPOptions").style.display = "none";
	}else if(vpnc_clientlist_col[1] == "OpenVPN"){
		document.getElementById("pptpcTitle").style.display = "none";
		document.getElementById("l2tpcTitle").style.display = "none";
		document.getElementById("opencTitle").style.display = "";
		document.getElementById("trPPTPOptions").style.display = "none";
	}	
}

function del_Row(rowdata, flag){
	var idx = rowdata.parentNode.parentNode.rowIndex;
	$("vpnc_clientlist_table").deleteRow(idx);
	var vpnc_clientlist_value = "";
	var vpnc_clientlist_row = vpnc_clientlist_array.split('<');	
	var vpnc_clientlist_col_delete = vpnc_clientlist_row[idx].split('>');
	for(k=0; k<vpnc_clientlist_row.length; k++){
		if(k != idx){				
			vpnc_clientlist_value += "<"+vpnc_clientlist_row[k];
		}
	}
	
	if(vpnc_clientlist_value.charAt(0) == "<")	//remove the 1st "<"
		vpnc_clientlist_value = vpnc_clientlist_value.substr(1,vpnc_clientlist_value.length);		
	
	vpnc_clientlist_array = vpnc_clientlist_value;		
	if(vpnc_clientlist_array == "")
		show_vpnc_rulelist();
			
	//Update vpnc_appendix
	var vpnc_appendix_value = "";
	var rules_auto_conn_orig = vpnc_appendix_array;
	var rules_auto_conn_array = rules_auto_conn_orig.split("<");
	for(var m=0; m<rules_auto_conn_array.length; m++){
		if(m != idx){	//save exist items
			vpnc_appendix_value += "<"+rules_auto_conn_array[m];
		}
	}
	
	if(vpnc_appendix_value.charAt(0) == "<")	//remove the 1st "<"
		vpnc_appendix_value = vpnc_appendix_value.substr(1,vpnc_appendix_value.length);	

	vpnc_appendix_array = vpnc_appendix_value;
	document.vpnclientForm.vpnc_appendix.value = vpnc_appendix_array;
	//del vpnc_pptp_options_x_list
	var tempPPTPOptionsValue = "";
	var origPPTPOptionsList = vpnc_pptp_options_x_list_array;
	var origPPTPOptionsListArray = origPPTPOptionsList.split("<");
	var origPPTPOptionsListArrayNum = origPPTPOptionsListArray.length;
	for(var index = 0; index < origPPTPOptionsListArrayNum; index += 1) {
		if(index != (idx + 1)) {	//save exist items
			tempPPTPOptionsValue += "<"+ origPPTPOptionsListArray[index];
		}
	}
	
	if(tempPPTPOptionsValue.charAt(0) == "<") {	//remove the 1st "<"
		tempPPTPOptionsValue = tempPPTPOptionsValue.substr(1,tempPPTPOptionsValue.length);
	}
	
	vpnc_pptp_options_x_list_array = tempPPTPOptionsValue;
	document.vpnclientForm.vpnc_pptp_options_x_list.value = vpnc_pptp_options_x_list_array;
	if(flag == "vpnc_enable"){	//remove connecting rule.
		document.vpnclientForm.vpnc_proto.value = "disable";
		document.vpnclientForm.vpnc_proto.disabled = false;
		document.vpnclientForm.action = "/start_apply.htm";
		document.vpnclientForm.enctype = "application/x-www-form-urlencoded";
  		document.vpnclientForm.encoding = "application/x-www-form-urlencoded";
		document.vpnclientForm.action_script.value = "restart_vpncall";
		if("<% nvram_get("vpnc_proto"); %>" == "openvpn")					
			document.vpnclientForm.vpn_clientx_eas.value = "";
		else
			document.vpnclientForm.vpnc_auto_conn.value = "";		
	}

	document.vpnclientForm.vpnc_clientlist.value = vpnc_clientlist_array;
	document.vpnclientForm.submit();
}

function ImportOvpn(){
	document.getElementById('importOvpnFile').style.display = "none"; 
	document.getElementById('loadingicon').style.display = ""; 
	document.vpnclientForm.action = "vpnupload.cgi";
	document.vpnclientForm.enctype = "multipart/form-data";
	document.vpnclientForm.encoding = "multipart/form-data";
	document.vpnclientForm.submit();
	setTimeout("ovpnFileChecker();",2000);
}

function manualImport(_flag){
	if(_flag){
		document.getElementById("caFiled").style.display = "";
		document.getElementById("manualFiled").style.display = "";
	}
	else{
		document.getElementById("caFiled").style.display = "none";
		document.getElementById("manualFiled").style.display = "none";
	}
}

var vpn_upload_state = "init";
function ovpnFileChecker(){
	document.getElementById("importOvpnFile").innerHTML = "<#Main_alert_proceeding_desc3#>";
	document.getElementById("manualCRList").style.color = "#FFF";
	document.getElementById("manualStatic").style.color = "#FFF";
	document.getElementById("manualKey").style.color = "#FFF";
	document.getElementById("manualCert").style.color = "#FFF";
	document.getElementById("manualCa").style.color = "#FFF";
	$j.ajax({
		url: '/ajax_openvpn_server.asp',
		dataType: 'script',
		timeout: 1500,
		error: function(xhr){
			setTimeout("ovpnFileChecker();",1000);
		},	
		success: function(){
			document.getElementById('importOvpnFile').style.display = "";
			document.getElementById('loadingicon').style.display = "none";
			document.getElementById('importCA').style.display = "";
			document.getElementById('loadingiconCA').style.display = "none";
			if(vpn_upload_state == "init"){
				setTimeout("ovpnFileChecker();",1000);
			}
			else{
				document.getElementById('edit_vpn_crt_client1_ca').innerHTML = vpn_crt_client1_ca;
				document.getElementById('edit_vpn_crt_client1_crt').innerHTML = vpn_crt_client1_crt;
				document.getElementById('edit_vpn_crt_client1_key').innerHTML = vpn_crt_client1_key;
				document.getElementById('edit_vpn_crt_client1_static').innerHTML = vpn_crt_client1_static;
				document.getElementById('edit_vpn_crt_client1_crl').innerHTML = vpn_crt_client1_crl;
				var vpn_upload_state_tmp = "";
				vpn_upload_state_tmp = parseInt(vpn_upload_state) - 16;
				if(vpn_upload_state_tmp > -1){
					document.getElementById("importOvpnFile").innerHTML += ", Lack of Certificate Revocation List(Optional)";
					document.getElementById("manualCRList").style.color = "#FC0";
					vpn_upload_state = vpn_upload_state_tmp;
				}
					
				vpn_upload_state_tmp = parseInt(vpn_upload_state) - 8;
				if(vpn_upload_state_tmp > -1){
					document.getElementById("importOvpnFile").innerHTML += ", Lack of Static Key(Optional)";
					document.getElementById("manualStatic").style.color = "#FC0";
					vpn_upload_state = vpn_upload_state_tmp;
				}				

				vpn_upload_state_tmp = parseInt(vpn_upload_state) - 4;
				if(vpn_upload_state_tmp > -1){
					document.getElementById("importOvpnFile").innerHTML += ", Lack of Client Key!";
					document.getElementById("manualKey").style.color = "#FC0";
					vpn_upload_state = vpn_upload_state_tmp;
				}

				vpn_upload_state_tmp = parseInt(vpn_upload_state) - 2;
				if(vpn_upload_state_tmp > -1){
					document.getElementById("importOvpnFile").innerHTML += ", Lack of Client Certificate";
					document.getElementById("manualCert").style.color = "#FC0";
					vpn_upload_state = vpn_upload_state_tmp;
				}

				vpn_upload_state_tmp = parseInt(vpn_upload_state) - 1;
				if(vpn_upload_state_tmp > -1){
					document.getElementById("importOvpnFile").innerHTML += ", Lack of Certificate Authority";
					document.getElementById("manualCa").style.color = "#FC0";
				}
			}
		}
	});
}

var vpn_upload_state = "init";
function cancel_Key_panel(){
	document.getElementById("manualFiled_panel").style.display = "none";
}

function saveManual(){
	document.openvpnManualForm.vpn_crt_client1_ca.value = document.getElementById('edit_vpn_crt_client1_ca').value;
	document.openvpnManualForm.vpn_crt_client1_crt.value = document.getElementById('edit_vpn_crt_client1_crt').value;
	document.openvpnManualForm.vpn_crt_client1_key.value = document.getElementById('edit_vpn_crt_client1_key').value;
	document.openvpnManualForm.vpn_crt_client1_static.value = document.getElementById('edit_vpn_crt_client1_static').value;
	document.openvpnManualForm.vpn_crt_client1_crl.value = document.getElementById('edit_vpn_crt_client1_crl').value;
	document.openvpnManualForm.vpn_crt_client1_ca.disabled = false;
	document.openvpnManualForm.vpn_crt_client1_crt.disabled = false;
	document.openvpnManualForm.vpn_crt_client1_key.disabled = false;
	document.openvpnManualForm.vpn_crt_client1_static.disabled = false;
	document.openvpnManualForm.vpn_crt_client1_crl.disabled = false;
	document.openvpnManualForm.submit();
	cancel_Key_panel();
}

function startImportCA(){
	document.getElementById('importCA').style.display = "";
	document.getElementById('loadingiconCA').style.display = "";
	setTimeout('ovpnFileChecker();',2000);
	document.openvpnCAForm.submit();
}

function addOpenvpnProfile(){
	document.vpnclientForm.action = "/start_apply.htm";
	document.vpnclientForm.enctype = "application/x-www-form-urlencoded";
	document.vpnclientForm.encoding = "application/x-www-form-urlencoded";
	addRow_Group(10, save_flag, idx_tmp);
}
</script>
</head>

<body onload="initial();" onunload="unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="restart_vpncall">
<input type="hidden" name="action_wait" value="3">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpnc_pppoe_username" value="<% nvram_get("vpnc_pppoe_username"); %>">
<input type="hidden" name="vpnc_pppoe_passwd" value="<% nvram_get("vpnc_pppoe_passwd"); %>">
<input type="hidden" name="vpnc_heartbeat_x" value="<% nvram_get("vpnc_heartbeat_x"); %>">
<input type="hidden" name="vpnc_dnsenable_x" value="1">
<input type="hidden" name="vpnc_proto" value="<% nvram_get("vpnc_proto"); %>">
<input type="hidden" name="vpnc_clientlist" value='<% nvram_get("vpnc_clientlist"); %>'>
<input type="hidden" name="vpnc_type" value="PPTP">
<input type="hidden" name="vpnc_auto_conn" value="">
<input type="hidden" name="vpn_client_unit" value="1">
<input type="hidden" name="vpn_client1_username" value="<% nvram_get("vpn_client1_username"); %>">
<input type="hidden" name="vpn_client1_password" value="<% nvram_get("vpn_client1_password"); %>">
<input type="hidden" name="vpn_clientx_eas" value="<% nvram_get("vpn_clientx_eas"); %>">
<input type="hidden" name="vpnc_appendix" value="<% nvram_get("vpnc_appendix"); %>">
<input type="hidden" name="vpnc_pptp_options_x" value="<% nvram_get("vpnc_pptp_options_x"); %>">
<input type="hidden" name="vpnc_pptp_options_x_list" value="<% nvram_get("vpnc_pptp_options_x_list"); %>">
<div id="openvpnc_setting"  class="contentM_qis" style="box-shadow: 1px 5px 10px #000;">
	<table class="QISform_wireless" border=0 align="center" cellpadding="5" cellspacing="0">
		<tr style="height:32px;">
			<td>		
				<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" class="vpnClientTitle">
					<tr>
			  		<td width="33%" align="center" id="pptpcTitle" onclick="tabclickhandler(0);">PPTP</td>
			  		<td width="33%" align="center" id="l2tpcTitle" onclick="tabclickhandler(1);">L2TP</td>
			  		<td width="33%" align="center" id="opencTitle" onclick="tabclickhandler(2);">OpenVPN</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<!---- vpnc_pptp/l2tp start  ---->
				<div>
				<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable">
			 		<tr>
						<th><#IPConnection_autofwDesc_itemname#></th>
					  <td>
					  	<input type="text" maxlength="64" name="vpnc_des_edit" value="" class="input_32_table" style="float:left;"></input>
					  </td>
					</tr>  		
					<tr>
						<th><#BOP_isp_heart_item#></th>
						<td>
							<input type="text" maxlength="64" name="vpnc_svr_edit" value="" class="input_32_table" style="float:left;"></input>
						</td>
					</tr>  		
					<tr>
						<th><#PPPConnection_UserName_itemname#></th>
						<td>
							<input type="text" maxlength="64" name="vpnc_account_edit" value="" class="input_32_table" style="float:left;"></input>
						</td>
					</tr>  		
					<tr>
						<th><#PPPConnection_Password_itemname#></th>
						<td>
							<input type="text" maxlength="64" name="vpnc_pwd_edit" value="" class="input_32_table" style="float:left;"></input>
						</td>
					</tr>  
					<tr>
						<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(14,2);"><#CTL_reconnection#></a></th>
						<td>
					  		<input type="radio" value="1" name="vpnc_auto_conn_edit" class="content_input_fd"><#checkbox_Yes#>
				  			<input type="radio" value="0" name="vpnc_auto_conn_edit" class="content_input_fd"><#checkbox_No#>
						</td>
					</tr>				
					<tr id="trPPTPOptions">
						<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,17);"><#PPPConnection_x_PPTPOptions_itemname#></a></th>
						<td>
							<select name="selPPTPOption" class="input_option">
								<option value="auto"><#Auto#></option>
								<option value="-mppc"><#No_Encryp#></option>
								<option value="+mppe-40">MPPE 40</option>
								<option value="+mppe-128">MPPE 128</option>
							</select>
						</td>	
					</tr>		 
		 		</table>
		 		</div>
		 		<!---- vpnc_pptp/l2tp end  ---->		 			 	
			</td>
		</tr>
	</table>		
	<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
		<input class="button_gen" type="button" onclick="cancel_add_rule();" id="cancelBtn" value="<#CTL_Cancel#>">
		<input class="button_gen" type="button" onclick="addRow_Group(10,save_flag, idx_tmp);" value="<#CTL_ok#>">	
	</div>	
      <!--===================================Ending of openvpnc setting Content===========================================-->			
</div>
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
		<table width="95%" border="0" align="left" cellpadding="0" cellspacing="0" class="FormTitle" id="FormTitle">
  		<tr>
    		<td bgcolor="#4D595D" valign="top">
    			<table width="760px" border="0" cellpadding="4" cellspacing="0">
					<tr>
						<td bgcolor="#4D595D" valign="top">
							<div>&nbsp;</div>
							<div class="formfonttitle">VPN - VPN Client</div>
							<div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
							<div class="formfontdesc">
								<#vpnc_desc1#><br>
								<#vpnc_desc2#><br>
								<#vpnc_desc3#><br><br>		
								<#vpnc_step#>
								<ol>
									<li><#vpnc_step1#>
									<li><#vpnc_step2#>
									<li><#vpnc_step3#>
								</ol>
							</div>
						</td>		
        			</tr>						
        			<tr>
          				<td>
							<table width="98%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable_table">
								<thead>
									<tr>
										<td colspan="6" id="VPNServerList" style="border-right:none;height:22px;"><#BOP_isp_VPN_list#> <span id="rules_limit" style="color:#FFFFFF"></span></td>
									</tr>
								</thead>			
									<tr>
										<th width="10%" style="height:30px;"><#PPPConnection_x_WANLink_itemname#></th>
										<th><div><#IPConnection_autofwDesc_itemname#></div></th>
										<th width="15%"><div><#QIS_internet_vpn_type#></div></th>
										<th width="10%"><div><#pvccfg_edit#></div></th>
										<th width="10%"><div><#CTL_del#></div></th>
										<th width="25%"><div><#Connecting#></div></th>
									</tr>											
							</table>          					
							<div id="vpnc_clientlist_Block"></div>
							<div class="apply_gen">
								<input class="button_gen" onclick="Add_profile()" type="button" value="Add profile">
							</div>
          				</td>
        			</tr>        			
      			</table>
			</td>  
      	</tr>
		</table>
		<!--===================================End of Main Content===========================================-->
		</td>		
	</tr>
</table>
</form>
<!---- vpnc_OpenVPN start  ---->
<form method="post" name="vpnclientForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpnc_clientlist" value='<% nvram_get("vpnc_clientlist"); %>'>
<input type="hidden" name="vpn_upload_type" value="ovpn">
<input type="hidden" name="vpn_upload_unit" value="1">
<input type="hidden" name="vpnc_openvpn_unit_edit" value="1">
<input type="hidden" name="vpnc_type" value="PPTP">
<input type="hidden" name="vpnc_proto" value="<% nvram_get("vpnc_proto"); %>" disabled>
<input type="hidden" name="vpn_clientx_eas" value="<% nvram_get("vpn_clientx_eas"); %>">
<input type="hidden" name="vpnc_auto_conn" value="<% nvram_get("vpnc_auto_conn"); %>">
<input type="hidden" name="vpnc_appendix" value="<% nvram_get("vpnc_appendix"); %>">
<input type="hidden" name="vpnc_pptp_options_x_list" value="<% nvram_get("vpnc_pptp_options_x_list"); %>">
<div id="openvpnc_setting_openvpn" class="contentM_qis" style="margin-top:-720px;box-shadow: 1px 9px 10px -4px #000;"> 
	<table class="QISform_wireless" border=0 align="center" cellpadding="5" cellspacing="0" style="margin-top:3px;">
		<tr>
			<td>
		 		<div id="openvpnc_simple">
		 			<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable">
		 				<tr>
							<th><#IPConnection_autofwDesc_itemname#></th>
							<td>
								<input type="text" maxlength="64" name="vpnc_openvpn_des" value="" class="input_32_table" style="float:left;"></input>
							</td>
						</tr>  			
						<tr>
							<th><#PPPConnection_UserName_itemname#> (option)</th>
							<td>
								<input type="text" maxlength="64" name="vpnc_openvpn_username" value="" class="input_32_table" style="float:left;"></input>
							</td>
						</tr>  
						<tr>
							<th><#PPPConnection_Password_itemname#> (option)</th>
							<td>
								<input type="text" maxlength="64" name="vpnc_openvpn_pwd" value="" class="input_32_table" style="float:left;"></input>
							</td>
						</tr>  		  			
						<tr>
							<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(14,2);"><#CTL_reconnection#></a></th>
							<td>
								<input type="radio" value="1" name="vpn_clientx_eas_edit" class="content_input_fd"><#checkbox_Yes#>
								<input type="radio" value="0" name="vpn_clientx_eas_edit" class="content_input_fd"><#checkbox_No#>
							</td>
						</tr>		  				  			
						<tr>
							<th><#vpn_openvpnc_importovpn#></th>
							<td>
								<input type="file" name="file" class="input" style="color:#FC0;*color:#000;"><br>
								<input class="button_gen" onclick="ImportOvpn();" type="button" value="<#CTL_upload#>" />
								<img id="loadingicon" style="margin-left:5px;display:none;" src="/images/InternetScan.gif">
								<span id="importOvpnFile" style="display:none;"><#Main_alert_proceeding_desc3#></span>
							</td>
						</tr> 
					</table> 	
</form>	 			
			 		<br>
					<div style="color:#FC0;margin-bottom: 10px;">
						<input type="checkbox" id="cbManualImport" class="input" onclick="manualImport(this.checked)"><#vpn_openvpnc_manual#>
					</div>
					
<form method="post" name="openvpnCAForm" action="vpnupload.cgi" target="hidden_frame" enctype="multipart/form-data">
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpn_upload_type" value="ca">
<input type="hidden" name="vpn_upload_unit" value="1">
					<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable" id="caFiled" style="display:none">
					<tr>
						<th><#vpn_openvpnc_importCA#></th>
						<td>								
							<input type="file" name="file" class="input" style="color:#FC0;*color:#000;"><br>
							<input id="importCA" class="button_gen" onclick="startImportCA();" type="button" value="<#CTL_upload#>" />
							<img id="loadingiconCA" style="margin-left:5px;display:none;" src="/images/InternetScan.gif">	
						</td>
					</tr> 
					</table>
</form>				
<form method="post" name="openvpnCertForm" action="vpnupload.cgi" target="hidden_frame" enctype="multipart/form-data">												
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpn_upload_type" value="cert">
<input type="hidden" name="vpn_upload_unit" value="1">
					<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable" id="certFiled" style="display:none">
						<tr>
							<th>Import Cert file</th>
							<td>
								<input type="file" name="file" class="input" style="color:#FC0;*color:#000;"><br>
								<input class="button_gen" onclick="setTimeout('ovpnFileChecker();',2000);document.openvpnCertForm.submit();" type="button" value="<#CTL_upload#>" />					  		
							</td>
						</tr> 					
					</table>
</form>
<form method="post" name="openvpnKeyForm" action="vpnupload.cgi" target="hidden_frame" enctype="multipart/form-data">						
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpn_upload_type" value="key">
<input type="hidden" name="vpn_upload_unit" value="1">
					<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable" style="display:none">					
						<tr>
							<th>Import Key file</th>
							<td>
								<input type="file" name="file" class="input" style="color:#FC0;*color:#000;"><br>
								<input class="button_gen" onclick="setTimeout('ovpnFileChecker();',2000);document.openvpnKeyForm.submit();" type="button" value="<#CTL_upload#>" />
							</td>
						</tr> 					
					</table>
</form>
<form method="post" name="openvpnStaticForm" action="vpnupload.cgi" target="hidden_frame" enctype="multipart/form-data">			
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpn_upload_type" value="static">
<input type="hidden" name="vpn_upload_unit" value="1">
					<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable" id="staticFiled" style="display:none">	
						<tr>
							<th>Import Static file</th>
							<td>
								<input type="file" name="file" class="input" style="color:#FC0;*color:#000;"><br>
								<input class="button_gen" onclick="setTimeout('ovpnFileChecker();',2000);document.openvpnStaticForm.submit();" type="button" value="<#CTL_upload#>" />					  		
							</td>
						</tr> 
						
					</table>
</form>
					<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable" id="manualFiled" style="display:none">
						<tr>
							<th><#Manual_Setting_btn#></th>
							<td>
		  					<input class="button_gen" onclick="document.getElementById('manualFiled_panel').style.display='';" type="button" value="<#pvccfg_edit#>">
					  	</td>
						</tr> 
					</table>
<form method="post" name="openvpnManualForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="next_page" value="Advanced_VPNClient_Content.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="flag" value="background">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="saveNvram">
<input type="hidden" name="action_wait" value="1">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="vpn_upload_unit" value="1">
<input type="hidden" name="vpn_crt_client1_ca" value="<% nvram_clean_get("vpn_crt_client1_ca"); %>" disabled>
<input type="hidden" name="vpn_crt_client1_crt" value="<% nvram_clean_get("vpn_crt_client1_crt"); %>" disabled>
<input type="hidden" name="vpn_crt_client1_key" value="<% nvram_clean_get("vpn_crt_client1_key"); %>" disabled>
<input type="hidden" name="vpn_crt_client1_static" value="<% nvram_clean_get("vpn_crt_client1_static"); %>" disabled>
<input type="hidden" name="vpn_crt_client1_crl" value="<% nvram_clean_get("vpn_crt_client1_crl"); %>" disabled>
					<div id="manualFiled_panel" class="contentM_qis_manual" style="display:none">
						<table class="QISform_wireless" border=0 align="center" cellpadding="5" cellspacing="0">											
							<tr>
								<td valign="top">
					     		<table class="QISform_wireless" border=0 align="center" cellpadding="5" cellspacing="0">
					         		<tr>
					         			<td>
											<div class="description_down"><#vpn_openvpn_Keys_Cert#></div>
										</td>		
									</tr>
									<tr>
										<td>
											<div style="margin-left:30px; margin-top:10px;">
												<p><#vpn_openvpn_KC_Edit1#> <span style="color:#FC0;">----- BEGIN xxx ----- </span>/<span style="color:#FC0;"> ----- END xxx -----</span> <#vpn_openvpn_KC_Edit2#>
												<p><#vpn_openvpn_KC_Limit#>
											</div>													
											<div style="margin:5px;*margin-left:-5px;"><img style="width: 700px; height: 2px;" src="/images/New_ui/export/line_export.png"></div>
										</td>	
									</tr>
									<tr>
										<td valign="top">
											<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable">
												<tr>
													<th id="manualCa">Certificate Authority</th>
													<td>
														<textarea rows="8" class="textarea_ssh_table" id="edit_vpn_crt_client1_ca" name="edit_vpn_crt_client1_ca" cols="65" maxlength="2999"><% nvram_clean_get("vpn_crt_client1_ca"); %></textarea>
													</td>
												</tr>
												<tr>
													<th id="manualCert">Client Certificate</th>
													<td>
														<textarea rows="8" class="textarea_ssh_table" id="edit_vpn_crt_client1_crt" name="edit_vpn_crt_client1_crt" cols="65" maxlength="2999"><% nvram_clean_get("vpn_crt_client1_crt"); %></textarea>
													</td>
												</tr>
												<tr>
													<th id="manualKey">Client Key</th>
													<td>
														<textarea rows="8" class="textarea_ssh_table" id="edit_vpn_crt_client1_key" name="edit_vpn_crt_client1_key" cols="65" maxlength="2999"><% nvram_clean_get("vpn_crt_client1_key"); %></textarea>
													</td>
												</tr>
												<tr>
													<th id="manualStatic">Static Key (Optional)</th>
													<td>
														<textarea rows="8" class="textarea_ssh_table" id="edit_vpn_crt_client1_static" name="edit_vpn_crt_client1_static" cols="65" maxlength="2999"><% nvram_clean_get("vpn_crt_client1_static"); %></textarea>
													</td>
												</tr>
												<tr>
													<th id="manualCRList">Certificate Revocation List (Optional)</th>
													<td>
														<textarea rows="8" class="textarea_ssh_table" id="edit_vpn_crt_client1_crl" name="edit_vpn_crt_client1_crl" cols="65" maxlength="2999"><% nvram_clean_get("vpn_crt_client1_crl"); %></textarea>
													</td>
												</tr>
											</table>
								  		</td>
								  	</tr>				
					  			</table>
									<div style="margin-top:5px;width:100%;text-align:center;">
										<input class="button_gen" type="button" onclick="cancel_Key_panel();" value="<#CTL_Cancel#>">
										<input class="button_gen" type="button" onclick="saveManual();" value="<#CTL_onlysave#>">	
									</div>					
								</td>
					  		</tr>
						</table>	
</form>					  
					</div>
				</div>
			</td>
		</tr>
	</table>
	<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
		<input class="button_gen" type="button" onclick="cancel_add_rule();" id="cancelBtn_openvpn" value="<#CTL_Cancel#>">
		<input class="button_gen" onclick='addOpenvpnProfile();' type="button" value="<#CTL_ok#>">
	</div>	
      <!--===================================Ending of openvpn setting Content===========================================-->			
</div>
<div id="footer"></div>
</body>
</html>
