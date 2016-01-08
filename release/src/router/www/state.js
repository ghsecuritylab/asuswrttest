﻿//For operation mode;
var sw_mode = '<% nvram_get("sw_mode"); %>';
if(sw_mode == 3 && '<% nvram_get("wlc_psta"); %>' == 1)
	sw_mode = 4;
var productid = '<#Web_Title2#>';
var based_modelid = '<% nvram_get("productid"); %>';
var hw_ver = '<% nvram_get("hardware_version"); %>';
var uptimeStr = "<% uptime(); %>";
var timezone = uptimeStr.substring(26,31);
var boottime = parseInt(uptimeStr.substring(32,42));
var newformat_systime = uptimeStr.substring(8,11) + " " + uptimeStr.substring(5,7) + " " + uptimeStr.substring(17,25) + " " + uptimeStr.substring(12,16);  //Ex format: Jun 23 10:33:31 2008
var systime_millsec = Date.parse(newformat_systime); // millsec from system
var JS_timeObj = new Date(); // 1970.1.1
var wan_route_x = "";
var wan_nat_x = "";
var wan_proto = "";
var test_page = 0;
var testEventID = "";
var httpd_dir = "/cifs1"
var isFromWAN = false;
var svc_ready = '<% nvram_get("svc_ready"); %>';
if((location.hostname.search('<% nvram_get("lan_ipaddr"); %>') == -1) && (location.hostname.search('router.asus') == -1)){
	isFromWAN = true;
}

// parsing rc_support
var rc_support = "<% nvram_get("rc_support"); %>";
function isSupport(_ptn){
	return (rc_support.search(_ptn) == -1) ? false : true;
}

var wl_vifnames = "<% nvram_get("wl_vifnames"); %>";
var dbwww_support = false; 
var wifilogo_support = isSupport("WIFI_LOGO"); 
var band2g_support = isSupport("2.4G"); 
var band5g_support = isSupport("5G");
var live_update_support = isSupport("update"); 
var cooler_support = isSupport("fanctrl"); 
var power_support = isSupport("pwrctrl"); 
var repeater_support = isSupport("repeater"); 
var psta_support = isSupport("psta");
var wl6_support = isSupport("wl6");
var Rawifi_support = isSupport("rawifi");
var SwitchCtrl_support = isSupport("switchctrl");
var dsl_support = isSupport("dsl");
var dualWAN_support = isSupport("dualwan");
var ruisp_support = isSupport("ruisp");

var multissid_support = rc_support.search("mssid");
if(sw_mode == 2 || sw_mode == 4)
	multissid_support = -1;
if(multissid_support != -1)
	multissid_support = wl_vifnames.split(" ").length;

var no5gmssid_support = isSupport("no5gmssid");
var wifi_hw_sw_support = isSupport("wifi_hw_sw");
var wifi_tog_btn_support = isSupport("wifi_tog_btn");
var usb_support = isSupport("usb"); 
var printer_support = isSupport("printer"); 
var appbase_support = isSupport("appbase");
var appnet_support = isSupport("appnet");
var media_support = isSupport(" media");
var nomedia_support = isSupport("nomedia");
var cloudsync_support = isSupport("cloudsync"); 
var yadns_support = isSupport("yadns"); 
var manualstb_support = isSupport("manual_stb"); 
var wps_multiband_support = isSupport("wps_multiband");

//MODELDEP : DSL-N55U、DSL-N55U-B、RT-N56U
if(based_modelid == "DSL-N55U" || based_modelid == "DSL-N55U-B" || based_modelid == "RT-N56U")
	var aicloudipk_support = true;
else
	var aicloudipk_support = false;

var modem_support = isSupport("modem"); 
var IPv6_support = isSupport("ipv6"); 
var ParentalCtrl2_support = isSupport("PARENTAL2");
var ParentalCtrl_support = isSupport("PARENTAL "); 
var pptpd_support = isSupport("pptpd"); 
var openvpnd_support = isSupport("openvpnd"); 
var WebDav_support = isSupport("webdav"); 
var HTTPS_support = isSupport("HTTPS"); 
var nodm_support = isSupport("nodm"); 
var wimax_support = isSupport("wimax");
var downsize_4m_support = isSupport("sfp4m");
var downsize_8m_support = isSupport("sfp8m");
var hwmodeSwitch_support = isSupport("swmode_switch");
var diskUtility_support = isSupport("diskutility");
var networkTool_support = true;
var band5g_11ac_support = isSupport("11AC");
var optimizeXbox_support = isSupport("optimize_xbox");
var spectrum_support = isSupport("spectrum");
var mediareview_support = '<% nvram_get("wlopmode"); %>' == 7 ? true : false;
var userRSSI_support = isSupport("user_low_rssi");

var localAP_support = true;
if(sw_mode == 4)
	localAP_support = false;

var rrsut_support = false;
if(based_modelid == "RT-AC56U" || based_modelid == "RT-AC68U" || based_modelid == "RT-AC66U" || based_modelid == "RT-N66U") // MODELDEP
	rrsut_support = true;

var QISWIZARD = "QIS_wizard.htm";
// Todo: Support repeater mode
if(isMobile() && sw_mode != 2 && !dsl_support)
	QISWIZARD = "QIS_wizard_m.htm";

// for detect if the status of the machine is changed. {
var wanstate = -1;
var wansbstate = -1;
var wanauxstate = -1;
var stopFlag = 0;

var gn_array_2g = <% wl_get_guestnetwork("0"); %>;
var gn_array_5g = <% wl_get_guestnetwork("1"); %>;

<% available_disk_names_and_sizes(); %>
<% disk_pool_mapping_info(); %>

var wan_line_state = "<% nvram_get("dsltmp_adslsyncsts"); %>";
var wlan0_radio_flag = "<% nvram_get("wl0_radio"); %>";
var wlan1_radio_flag = "<% nvram_get("wl1_radio"); %>";

//for high power model
var auto_channel = '<% nvram_get("AUTO_CHANNEL"); %>';
var is_high_power = auto_channel ? true : false;

function change_wl_unit_status(_unit){
	if(sw_mode == 2 || sw_mode == 4) return false;
	
	document.titleForm.wl_unit.disabled = false;
	document.titleForm.wl_unit.value = _unit;
	if(document.titleForm.current_page.value == "")
		document.titleForm.current_page.value = "Advanced_Wireless_Content.asp";
	if(document.titleForm.next_page.value == "")
		document.titleForm.next_page.value = "Advanced_Wireless_Content.asp";
	document.titleForm.action_mode.value = "change_wl_unit";
	document.titleForm.action = "apply.cgi";
	document.titleForm.target = "";
	document.titleForm.submit();
}

var banner_code, menu_code="", menu1_code="", menu2_code="", tab_code="", footer_code;
function show_banner(L3){// L3 = The third Level of Menu
	var banner_code = "";	

	// creat a hidden iframe to cache offline page
	banner_code +='<iframe width="0" height="0" frameborder="0" scrolling="no" src="/manifest.asp"></iframe>';

	banner_code +='<form method="post" name="titleForm" id="titleForm" action="/start_apply.htm" target="hidden_frame">\n';
	banner_code +='<input type="hidden" name="next_page" value="">\n';
	banner_code +='<input type="hidden" name="current_page" value="">\n';
	banner_code +='<input type="hidden" name="action_mode" value="apply">\n';
	banner_code +='<input type="hidden" name="action_script" value="">\n';
	banner_code +='<input type="hidden" name="action_wait" value="5">\n';
	banner_code +='<input type="hidden" name="wl_unit" value="" disabled>\n';
	banner_code +='<input type="hidden" name="wl_subunit" value="-1" disabled>\n';
	banner_code +='<input type="hidden" name="preferred_lang" value="<% nvram_get("preferred_lang"); %>">\n';
	banner_code +='<input type="hidden" name="flag" value="">\n';
	banner_code +='</form>\n';

	banner_code +='<form method="post" name="diskForm_title" action="/device-map/safely_remove_disk.asp" target="hidden_frame">\n';
	banner_code +='<input type="hidden" name="disk" value="">\n';
	banner_code +='</form>\n';

	banner_code +='<form method="post" name="internetForm_title" action="/start_apply2.htm" target="hidden_frame">\n';
	banner_code +='<input type="hidden" name="current_page" value="/index.asp">\n';
	banner_code +='<input type="hidden" name="next_page" value="/index.asp">\n';
	banner_code +='<input type="hidden" name="action_mode" value="apply">\n';
	banner_code +='<input type="hidden" name="action_script" value="restart_wan_if">\n';
	banner_code +='<input type="hidden" name="action_wait" value="5">\n';
	banner_code +='<input type="hidden" name="wan_enable" value="<% nvram_get("wan_enable"); %>">\n';
	banner_code +='<input type="hidden" name="wan_unit" value="<% get_wan_unit(); %>">\n';
	banner_code +='</form>\n';

	banner_code +='<div class="banner1" align="center"><img src="images/New_ui/asustitle.png" width="218" height="54" align="left">\n';
	banner_code +='<div style="margin-top:13px;margin-left:-90px;*margin-top:0px;*margin-left:0px;" align="center"><span id="modelName_top" onclick="this.focus();" class="modelName_top"><#Web_Title2#></span></div>';

	// logout, reboot
	banner_code +='<a href="javascript:logout();"><div style="margin-top:13px;margin-left:25px; *width:136px;" class="titlebtn" align="center"><span><#t1Logout#></span></div></a>\n';
	banner_code +='<a href="javascript:reboot();"><div style="margin-top:13px;margin-left:0px;*width:136px;" class="titlebtn" align="center"><span><#BTN_REBOOT#></span></div></a>\n';

	// language
	banner_code +='<ul class="navigation"><a href="#">';
	banner_code +='<% shown_language_css(); %>';
	banner_code +='</a></ul>';

	banner_code +='</div>\n';
	banner_code +='<table width="998" border="0" align="center" cellpadding="0" cellspacing="0" class="statusBar">\n';
	banner_code +='<tr>\n';
	banner_code +='<td background="images/New_ui/midup_bg.png" height="179" valign="top"><table width="764" border="0" cellpadding="0" cellspacing="0" height="35px" style="margin-left:230px;">\n';
	banner_code +='<tbody><tr>\n';
 	banner_code +='<td valign="center" class="titledown" width="auto">';

	// dsl does not support operation mode
	if (!dsl_support) {
		banner_code +='<span style="font-family:Verdana, Arial, Helvetica, sans-serif;"><#menu5_6_1_title#>:</sapn><span class="title_link" style="text-decoration: none;" id="op_link"><a href="/Advanced_OperationMode_Content.asp" style="color:white"><span id="sw_mode_span" style="text-decoration: underline;"></span></a></span>\n';
	}
	banner_code +='<span style="font-family:Verdana, Arial, Helvetica, sans-serif;"><#General_x_FirmwareVersion_itemname#></sapn><a href="/Advanced_FirmwareUpgrade_Content.asp" style="color:white;"><span id="firmver" class="title_link"></span></a>\n';
	banner_code +='<span style="font-family:Verdana, Arial, Helvetica, sans-serif;" id="ssidTitle">SSID:</sapn>';
	banner_code +='<span onclick="change_wl_unit_status(0)" id="elliptic_ssid_2g" class="title_link"></span>';
	banner_code +='<span onclick="change_wl_unit_status(1)" id="elliptic_ssid_5g" style="margin-left:-5px;" class="title_link"></span>\n';
	banner_code +='</td>\n';

	if(wifi_hw_sw_support)
		banner_code +='<td width="30"><div id="wifi_hw_sw_status" class="wifihwswstatusoff"></div></td>\n';

	if(cooler_support)
		banner_code +='<td width="30"><div id="cooler_status" class="" style="display:none;"></div></td>\n';

	if(multissid_support != -1)
		banner_code +='<td width="30"><div id="guestnetwork_status" class="guestnetworkstatusoff"></div></td>\n';

	if(dsl_support)
		banner_code +='<td width="30"><div id="adsl_line_status" class="linestatusdown"></div></td>\n';

	if(sw_mode != 3)
		banner_code +='<td width="30"><div id="connect_status" class="connectstatusoff"></div></td>\n';

	if(usb_support)
		banner_code +='<td width="30"><div id="usb_status"></div></td>\n';
	
	if(printer_support)
		banner_code +='<td width="30"><div id="printer_status" class="printstatusoff"></div></td>\n';

	banner_code +='<td width="17"></td>\n';
	banner_code +='</tr></tbody></table></td></tr></table>\n';

	$("TopBanner").innerHTML = banner_code;

	show_loading_obj();	
	show_top_status();
	updateStatus_AJAX();
}

//Level 3 Tab
var tabtitle = new Array();
tabtitle[0] = new Array("", "<#menu5_1_1#>", "<#menu5_1_2#>", "<#menu5_1_3#>", "<#menu5_1_4#>", "<#menu5_1_5#>", "<#menu5_1_6#>");
tabtitle[1] = new Array("", "<#menu5_2_1#>", "<#menu5_2_2#>", "<#menu5_2_3#>", "IPTV", "Switch Control");
tabtitle[2] = new Array("", "<#menu5_3_1#>", "<#dualwan#>", "<#menu5_3_3#>", "<#menu5_3_4#>", "<#menu5_3_5#>", "<#menu5_3_6#>", "<#NAT_passthrough_itemname#>", "<#menu5_4_4#>");
tabtitle[3] = new Array("", "<#UPnPMediaServer#>", "<#menu5_4_1#>", "<#menu5_4_2#>", "<#menu5_4_3#>");
tabtitle[4] = new Array("", "IPv6");
tabtitle[5] = new Array("", "<#BOP_isp_heart_item#>", "<#vpn_Adv#>", "VPN Status");
tabtitle[6] = new Array("", "<#menu5_1_1#>", "<#menu5_5_2#>", "<#menu5_5_5#>", "<#menu5_5_3#>", "<#menu5_5_4#>");
tabtitle[7] = new Array("", "<#menu5_6_1#>", "<#menu5_6_2#>", "<#menu5_6_3#>", "<#menu5_6_4#>", "Performance tuning", "<#menu_dsl_setting#>");
tabtitle[8] = new Array("", "<#menu5_7_2#>", "<#menu5_7_4#>", "<#menu5_7_3#>", "IPv6", "<#menu5_7_6#>", "<#menu5_7_5#>", "<#menu_dsl_log#>", "Spectrum", "Connections");
tabtitle[9] = new Array("", "Network Analysis", "Netstat", "Wake on LAN");
tabtitle[10] = new Array("", "QoS", "<#traffic_monitor#>");
tabtitle[11] = new Array("", "<#Parental_Control#>", "<#YandexDNS#>");

var tablink = new Array();
tablink[0] = new Array("", "Advanced_Wireless_Content.asp", "Advanced_WWPS_Content.asp", "Advanced_WMode_Content.asp", "Advanced_ACL_Content.asp", "Advanced_WSecurity_Content.asp", "Advanced_WAdvanced_Content.asp");
tablink[1] = new Array("", "Advanced_LAN_Content.asp", "Advanced_DHCP_Content.asp", "Advanced_GWStaticRoute_Content.asp", "Advanced_IPTV_Content.asp", "Advanced_SwitchCtrl_Content.asp");
tablink[2] = new Array("", "Advanced_WAN_Content.asp", "Advanced_WANPort_Content.asp", "Advanced_PortTrigger_Content.asp", "Advanced_VirtualServer_Content.asp", "Advanced_Exposed_Content.asp", "Advanced_ASUSDDNS_Content.asp", "Advanced_NATPassThrough_Content.asp", "Advanced_Modem_Content.asp");
tablink[3] = new Array("", "mediaserver.asp", "Advanced_AiDisk_samba.asp", "Advanced_AiDisk_ftp.asp", "Advanced_AiDisk_others.asp");
tablink[4] = new Array("", "Advanced_IPv6_Content.asp");
tablink[5] = new Array("", "Advanced_PPTP_Content.asp", "Advanced_PPTPAdvanced_Content.asp", "Advanced_VPNStatus.asp", "Main_Ping_Content.asp", "Main_Netstat_Content.asp", "Main_Traceroute_Content.asp");
tablink[6] = new Array("", "Advanced_BasicFirewall_Content.asp", "Advanced_URLFilter_Content.asp", "Advanced_KeywordFilter_Content.asp","Advanced_MACFilter_Content.asp", "Advanced_Firewall_Content.asp");
tablink[7] = new Array("", "Advanced_OperationMode_Content.asp", "Advanced_System_Content.asp", "Advanced_FirmwareUpgrade_Content.asp", "Advanced_SettingBackup_Content.asp", "Advanced_PerformanceTuning_Content.asp", "Advanced_ADSL_Content.asp");
tablink[8] = new Array("", "Main_LogStatus_Content.asp", "Main_WStatus_Content.asp", "Main_DHCPStatus_Content.asp", "Main_IPV6Status_Content.asp", "Main_RouteStatus_Content.asp", "Main_IPTStatus_Content.asp", "Main_AdslStatus_Content.asp", "Main_Spectrum_Content.asp", "Main_ConnStatus_Content.asp");
tablink[9] = new Array("", "Main_Analysis_Content.asp", "Main_Netstat_Content.asp", "Main_WOL_Content.asp");
tablink[10] = new Array("", "QoS_EZQoS.asp", "Main_TrafficMonitor_realtime.asp", "Main_TrafficMonitor_last24.asp", "Main_TrafficMonitor_daily.asp", "Advanced_QOSUserPrio_Content.asp", "Advanced_QOSUserRules_Content.asp");
tablink[11] = new Array("", "ParentalControl.asp", "YandexDNS.asp");

//Level 2 Menu
menuL2_title = new Array("", "<#menu5_1#>", "<#menu5_2#>", "<#menu5_3#>", "<#menu5_4#>", "IPv6", "<#BOP_isp_heart_item#>", "<#menu5_5#>", "<#menu5_6#>", "<#System_Log#>", "<#Network_Tools#>");
menuL2_link  = new Array("", tablink[0][1], tablink[1][1], tablink[2][1], tablink[3][1], tablink[4][1], tablink[5][1], tablink[6][1], tablink[7][1], tablink[8][1], tablink[9][1]);

//Level 1 Menu
menuL1_title = new Array("", "<#menu1#>", "<#Guest_Network#>", "<#Menu_TrafficManager#>", "<#Parental_Control#>", "<#Menu_usb_application#>", "AiCloud", "<#menu5#>");
menuL1_link = new Array("", "index.asp", "Guest_network.asp", "QoS_EZQoS.asp", "ParentalControl.asp", "APP_Installation.asp", "cloud_main.asp", "");
var calculate_height = menuL1_link.length+tablink.length-2;

var traffic_L1_dx = 3;
var traffic_L2_dx = 11;

function remove_url(){
	remove_menu_item(2, "Advanced_Modem_Content.asp");
	
	if('<% nvram_get("start_aicloud"); %>' == '0')
		menuL1_link[6] = "cloud__main.asp"

	if(!networkTool_support){
		menuL2_title[10] = "";
		menuL2_link[10] = "";
	}

	if(downsize_4m_support) {
		remove_menu_item(8, "Main_ConnStatus_Content.asp");
		remove_menu_item(10, "Main_TrafficMonitor_realtime.asp");		
	}
	
	if(downsize_8m_support) {
		//remove_menu_item(8, "Main_ConnStatus_Content.asp");
	}	

	if(!dsl_support) {
		remove_menu_item(7, "Advanced_ADSL_Content.asp");
		remove_menu_item(8, "Main_AdslStatus_Content.asp");
		remove_menu_item(8, "Main_Spectrum_Content.asp");
	}
	else {
		menuL2_link[3] = "Advanced_DSL_Content.asp";

		//no_op_mode
		remove_menu_item(7, "Advanced_OperationMode_Content.asp");
		
		if(!spectrum_support)		// not to support Spectrum page.
			remove_menu_item(8, "Main_Spectrum_Content.asp");
	}

	if(hwmodeSwitch_support){
		remove_menu_item(7, "Advanced_OperationMode_Content.asp");		
	}

	if(WebDav_support) {
		tabtitle[3][2] = "<#menu5_4_1#> / Cloud Disk";
	}
	
	if(!cloudsync_support && !aicloudipk_support){
		menuL1_title[6] = "";
		menuL1_link[6] = "";
	}
		
	if(sw_mode == 2 || sw_mode == 4){
		// Guest Network
		menuL1_title[2] ="";
		menuL1_link[2] ="";
		// Traffic Manager
		menuL1_title[3] ="";
		menuL1_link[3] ="";
		// Parental Ctrl
		menuL1_title[4] ="";
		menuL1_link[4] ="";				
		// AiCloud
		menuL1_title[6] ="";
		menuL1_link[6] ="";				
		// Wireless
		if(sw_mode == 4){
			menuL2_title[1]="";
			menuL2_link[1]="";
		}
		else if(sw_mode == 2){
			if(userRSSI_support){
				remove_menu_item(0, "Advanced_Wireless_Content.asp");
				remove_menu_item(0, "Advanced_WWPS_Content.asp");
				remove_menu_item(0, "Advanced_WMode_Content.asp");								
				remove_menu_item(0, "Advanced_ACL_Content.asp");
				remove_menu_item(0, "Advanced_WSecurity_Content.asp");
			}
			else{
				menuL2_title[1]="";
				menuL2_link[1]="";
			}
		}
		// WAN
		menuL2_title[3]="";
		menuL2_link[3]="";	
		// LAN
		remove_menu_item(1, "Advanced_DHCP_Content.asp");
		remove_menu_item(1, "Advanced_GWStaticRoute_Content.asp");
		remove_menu_item(1, "Advanced_IPTV_Content.asp");								
		remove_menu_item(1, "Advanced_SwitchCtrl_Content.asp");
		// VPN
		menuL2_title[5]="";
		menuL2_link[5]="";
		//IPv6
		menuL2_title[6]="";
		menuL2_link[6]="";
		// Firewall		
		menuL2_title[7]="";
		menuL2_link[7]="";
		// Log
		remove_menu_item(8, "Main_DHCPStatus_Content.asp");
		remove_menu_item(8, "Main_IPV6Status_Content.asp");
		remove_menu_item(8, "Main_RouteStatus_Content.asp");
		remove_menu_item(8, "Main_IPTStatus_Content.asp");
		remove_menu_item(8, "Main_ConnStatus_Content.asp");
	}
	else if(sw_mode == 3){
		// Traffic Manager
		menuL1_title[3] ="";
		menuL1_link[3] ="";		
		// Parental Ctrl
		menuL1_title[4] ="";
		menuL1_link[4] ="";
		// AiCloud
		menuL1_title[6] ="";
		menuL1_link[6] ="";

		// Wireless
		remove_menu_item(0, "Advanced_WWPS_Content.asp");
		// WAN
		menuL2_title[3]="";
		menuL2_link[3]="";
		// LAN
		remove_menu_item(1, "Advanced_DHCP_Content.asp");
		remove_menu_item(1, "Advanced_GWStaticRoute_Content.asp");
		remove_menu_item(1, "Advanced_IPTV_Content.asp");
		remove_menu_item(1, "Advanced_SwitchCtrl_Content.asp");
		// VPN
		menuL2_title[5]="";
		menuL2_link[5]="";
		// IPv6
		menuL2_title[6]="";
		menuL2_link[6]="";
		// Firewall		
		menuL2_title[7]="";
		menuL2_link[7]="";
		// Log
		remove_menu_item(8, "Main_DHCPStatus_Content.asp");
		remove_menu_item(8, "Main_IPV6Status_Content.asp");
		remove_menu_item(8, "Main_RouteStatus_Content.asp");
		remove_menu_item(8, "Main_IPTStatus_Content.asp");
		remove_menu_item(8, "Main_ConnStatus_Content.asp");										
	}
	
	if(!dualWAN_support){
		remove_menu_item(2, "Advanced_WANPort_Content.asp");
		if (dsl_support) {
			tablink[2][1] = "Advanced_DSL_Content.asp";
		}
	}
	else{
		var dualwan_pri_if = '<% nvram_get("wans_dualwan"); %>'.split(" ");
		if(dualwan_pri_if == 'lan') tablink[2][1] = "Advanced_WAN_Content.asp";
		else if(dualwan_pri_if == 'wan') tablink[2][1] = "Advanced_WAN_Content.asp";
		else if(dualwan_pri_if == 'usb') tablink[2][1] = "Advanced_Modem_Content.asp";
		else if(dualwan_pri_if == 'dsl') tablink[2][1] = "Advanced_DSL_Content.asp";
	}

	if(!media_support){
		tabtitle[3].splice(1, 1);
		tablink[3].splice(1, 1);	
	}

	if(!cooler_support){
		remove_menu_item(7, "Advanced_PerformanceTuning_Content.asp");
	}

	if(!ParentalCtrl2_support && !yadns_support){
		menuL1_title[4]="";
		menuL1_link[4]="";
	}
	else if(!ParentalCtrl2_support && yadns_support){
		remove_menu_item(11, "ParentalControl.asp");
		menuL1_link[4]="YandexDNS.asp";
	}
	else if(ParentalCtrl2_support && !yadns_support){
		remove_menu_item(11, "YandexDNS.asp");
	}
	
	if(!ParentalCtrl_support)
		remove_menu_item(6, "Advanced_MACFilter_Content.asp");

	if(!IPv6_support){
		menuL2_title[5] = "";
		menuL2_link[5] = "";
		remove_menu_item(8, "Main_IPV6Status_Content.asp");		
	}
	
	if(multissid_support == -1){
		menuL1_title[2]="";
		menuL1_link[2]="";
	}

	if(!usb_support){
		menuL1_title[5]="";
		menuL1_link[5]="";
	}

	if(!pptpd_support){
		remove_menu_item(5, "Advanced_PPTP_Content.asp");
		if(!openvpnd_support){
			menuL2_title[6] = "";
			menuL2_link[6] = "";
		}
	}	
	
	if(!SwitchCtrl_support){
		remove_menu_item(1, "Advanced_SwitchCtrl_Content.asp");		
	}
}

function remove_menu_item(L2, remove_url){
	var dx;
	for(var i = 0; i < tablink[L2].length; i++){
		dx = tablink[L2].getIndexByValue(remove_url);
		if(dx == -1)	//If not match, pass it
			return false;
		else if(dx == 1) //If the url to be removed is the 1st tablink then replace by next tablink 
			menuL2_link.splice(L2+1, 1, tablink[L2][2]);

		tabtitle[L2].splice(dx, 1);
		tablink[L2].splice(dx, 1);
		break;
	}
}

Array.prototype.getIndexByValue = function(value){
	var index = -1;
	for(var i=0; i<this.length; i++){
		if (this[i] == value){
			index = i;
			break;
		}
	}
	return index;
}

Array.prototype.getIndexByValue2D = function(value){
	for(var i=0; i<this.length; i++){
		if(this[i].getIndexByValue(value) != -1){
			return [i, this[i].getIndexByValue(value)]; // return [1-D_index, 2-D_index];
		}
	}
	return -1;
}

var current_url = location.pathname.substring(location.pathname.lastIndexOf('/') + 1);
function show_menu(){
	var L1 = 0, L2 = 0, L3 = 0;
	if(current_url == "") current_url = "index.asp";
	if (dualWAN_support) {
		var wans_dualwan_orig = '<% nvram_get("wans_dualwan"); %>';		
		// fix dualwan showmenu
		if(current_url == "Advanced_DSL_Content.asp") current_url = "Advanced_WAN_Content.asp";
		if(current_url == "Advanced_Modem_Content.asp") current_url = "Advanced_WAN_Content.asp";
	}

	remove_url();
	// calculate L1, L2, L3.
	for(var i = 1; i < menuL1_link.length; i++){
		if(current_url == menuL1_link[i]){
			L1 = i;
			break;
		}
		else
			L1 = menuL1_link.length;
	}
	if(L1 == menuL1_link.length){
		for(var j = 0; j < tablink.length; j++){
			for(var k = 1; k < tablink[j].length; k++){
				if(current_url == tablink[j][k]){
					L2 = j+1;
					L3 = k;
					break;
				}
			}
		}
	}

	// special case for Traffic Manager
	if(L1 == traffic_L1_dx || L2 == traffic_L2_dx){
		if(current_url.indexOf("Main_TrafficMonitor_") == 0){
			L1 = traffic_L1_dx; 
			L2 = traffic_L2_dx; 
			L3 = 2;
		}
		else if(current_url.indexOf("ParentalControl") == 0){
			L1 = traffic_L1_dx; 
			L2 = traffic_L2_dx; 
			L3 = 3;
		}
		else if(current_url.indexOf("cloud") == 0){
			L1 = traffic_L1_dx; 
			L2 = traffic_L2_dx; 
			L3 = 1;
		}
		else{
			L1 = traffic_L1_dx; 
			L2 = traffic_L2_dx; 
			L3 = 1;
		}
	}
	//end

	// cloud
	if(current_url.indexOf("cloud") == 0)
		L1 = 6;

	if(current_url.indexOf("ParentalControl") == 0){
		if(ParentalCtrl2_support && yadns_support){
			traffic_L1_dx = 4;
			traffic_L2_dx = 12;
			L1 = traffic_L1_dx;	
			L2 = traffic_L2_dx;
			L3 = 1;
		}	
	}	
	
	if(current_url.indexOf("YandexDNS") == 0){
		if(ParentalCtrl2_support && yadns_support){
			traffic_L1_dx = 4;
			traffic_L2_dx = 12;
			L1 = traffic_L1_dx;	
			L2 = traffic_L2_dx;
			L3 = 2;
		}	
	}
	
	show_banner(L3);
	show_footer();
	browser_compatibility();	
	show_selected_language();
	autoFocus('<% get_parameter("af"); %>');

	// QIS wizard
	if(sw_mode == 2){
		menu1_code += '<div class="m_qis_r" style="margin-top:-170px;cursor:pointer;" onclick="go_setting(\'/'+ QISWIZARD +'?flag=sitesurvey\');"><table><tr><td><div id="index_img0"></div></td><td><div><#QIS#></div></td></tr></table></div>\n';
	}else if(sw_mode == 3){
		menu1_code += '<div class="m_qis_r" style="margin-top:-170px;cursor:pointer;" onclick="go_setting(\''+ QISWIZARD +'?flag=lanip\');"><table><tr><td><div id="index_img0"></div></td><td><div><#QIS#></div></td></tr></table></div>\n'; 	
	}else if(sw_mode == 4){
		menu1_code += '<div class="m_qis_r" style="margin-top:-170px;cursor:pointer;" onclick="go_setting(\'/'+ QISWIZARD +'?flag=sitesurvey_mb\');"><table><tr><td><div id="index_img0"></div></td><td><div><#QIS#></div></td></tr></table></div>\n';
	}else{
		menu1_code += '<div class="m_qis_r" style="margin-top:-170px;cursor:pointer;" onclick="go_setting(\''+ QISWIZARD +'?flag=detect\');"><table><tr><td><div id="index_img0"></div></td><td><div><#QIS#></div></td></tr></table></div>\n';
	}	

	// Feature
	menu1_code += '<div class="m0_r" style="margin-top:10px;" id="option0"><table width="192px" height="37px"><tr><td><#menu5_1_1#></td></tr></table></div>\n';
	for(i = 1; i <= menuL1_title.length-2; i++){
		if(menuL1_title[i] == ""){
			calculate_height--;
			continue;
		}
		else if(L1 == i && (L2 <= 0 || L2 == traffic_L2_dx)){
		  //menu1_code += '<div class="m'+i+'_r" id="option'+i+'">'+'<table><tr><td><img border="0" width="50px" height="50px" src="images/New_ui/icon_index_'+i+'.png" style="margin-top:-3px;"/></td><td><div style="width:120px;">'+menuL1_title[i]+'</div></td></tr></table></div>\n';
		  menu1_code += '<div class="m'+i+'_r" id="option'+i+'">'+'<table><tr><td><div id="index_img'+i+'"></div></td><td><div id="menu_string'+i+'" style="width:120px;">'+menuL1_title[i]+'</div></td></tr></table></div>\n';
		}
		else{
		  menu1_code += '<div class="menu" id="option'+i+'" onclick="location.href=\''+menuL1_link[i]+'\'" style="cursor:pointer;"><table><tr><td><div id="index_img'+i+'"></div></td><td><div id="menu_string" style="width:120px;">'+menuL1_title[i]+'</div></td></tr></table></div>\n';
		}
	}
	menu1_code += '<div class="m0_r" style="margin-top:10px;" id="option0">'+'<table width="192px" height="37px"><tr><td><#menu5#></td></tr></table></div>\n'; 	
	$("mainMenu").innerHTML = menu1_code;

	// Advanced
	if(L2 != -1){ 
		for(var i = 1; i < menuL2_title.length; ++i){
			if(menuL2_link[i] == "Advanced_Wireless_Content.asp" && "<% nvram_get("wl_subunit"); %>" != "0" && "<% nvram_get("wl_subunit"); %>" != "-1")
				menuL2_link[i] = "javascript:change_wl_unit_status(" + <% nvram_get("wl_unit"); %> + ");";
			if(menuL2_title[i] == "" || i == 4){
				calculate_height--;
				continue;
			}
			else if(L2 == i){
				//menu2_code += '<div class="m'+i+'_r" id="option'+i+'">'+'<table><tr><td><img border="0" width="50px" height="50px" src="images/New_ui/icon_menu_'+i+'.png" style="margin-top:-3px;"/></td><td><div style="width:120px;">'+menuL2_title[i]+'</div></td></tr></table></div>\n';
				menu2_code += '<div class="m'+i+'_r" id="option'+i+'">'+'<table><tr><td><div id="menu_img'+i+'"></div></td><td><div id="option_str1" style="width:120px;">'+menuL2_title[i]+'</div></td></tr></table></div>\n';
			}else{				
				menu2_code += '<div class="menu" id="option'+i+'" onclick="location.href=\''+menuL2_link[i]+'\'" style="cursor:pointer;"><table><tr><td><div id="menu_img'+i+'"></div></td><td><div id="option_str1" style="width:120px;">'+menuL2_title[i]+'</div></td></tr></table></div>\n';
			}	
		}
	}
	$("subMenu").innerHTML = menu2_code;

	// Tabs
	if(L3){
		if(L2 == traffic_L2_dx){ // if tm
			tab_code = '<table border="0" cellspacing="0" cellpadding="0"><tr>\n';
			for(var i=1; i < tabtitle[traffic_L2_dx-1].length; ++i){
				if(tabtitle[traffic_L2_dx-1][i] == "")
					continue;
				else if(L3 == i)
					tab_code += '<td><div class="tabclick"><span>'+ tabtitle[traffic_L2_dx-1][i] +'</span></div></td>';
				else
					tab_code += '<td><a href="' + tablink[traffic_L2_dx-1][i] + '"><div class="tab"><span>'+ tabtitle[traffic_L2_dx-1][i] +'</span></div></a></td>';
			}
			tab_code += '</tr></table>\n';		
		}
		else{
			tab_code = '<table border="0" cellspacing="0" cellpadding="0"><tr>\n';
			for(var i=1; i < tabtitle[L2-1].length; ++i){
				if(tabtitle[L2-1][i] == "")
					continue;
				else if(L3 == i)
					tab_code += '<td><div class="tabclick"><span><table><tbody><tr><td>'+tabtitle[L2-1][i]+'</td></tr></tbody></table></span></div></td>';
				else
					tab_code += '<td><div class="tab"onclick="location.href=\''+tablink[L2-1][i]+'\'" style="cursor:pointer;"><span><table><tbody><tr><td>'+tabtitle[L2-1][i]+'</td></tr></tbody></table></span></div></td>';
			}
			tab_code += '</tr></table>\n';		
		}

		$("tabMenu").innerHTML = tab_code;
	}

	if(current_url == "index.asp" || current_url == "")
		cal_height();
	else
		setTimeout('cal_height();', 1);
}

function addOnlineHelp(obj, keywordArray){
	var faqLang = {
		EN : "en",
		TW : "en",
		CN : "en",
		CZ : "en",
		PL : "en",
		RU : "en",
		DE : "en",
		FR : "en",
		TR : "en",
		TH : "en",
		MS : "en",
		NO : "en",
		FI : "en",
		DA : "en",
		SV : "en",
		BR : "en",
		JP : "en",
		ES : "en",
		IT : "en",
		UK : "en",
		HU : "en",
		RO : "en"
	}

	// exception start
	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "download" 
			&& (keywordArray[2] == "master" || keywordArray[2] == "tool")){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "ez" && keywordArray[2] == "printer"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "lpr"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "mac" && keywordArray[1] == "lpr"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "monopoly" && keywordArray[1] == "mode"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "IPv6"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "VPN"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "DMZ"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "set" && keywordArray[1] == "up" && keywordArray[2] == "specific" && keywordArray[3] == "IP" && keywordArray[4] == "addresses"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";		
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "port" && keywordArray[2] == "forwarding"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";		
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "port" && keywordArray[2] == "trigger"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.ES = "es-es";		
	
	}else	if(keywordArray[0] == "UPnP"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "hard" && keywordArray[2] == "disk" 
		&& keywordArray[3] == "USB"){

	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "Traffic" && keywordArray[2] == "Monitor"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";		
	
	}else	if(keywordArray[0] == "ASUSWRT" && keywordArray[1] == "samba" && keywordArray[2] == "Windows"
			&& keywordArray[3] == "network" && keywordArray[4] == "place"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "samba"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	
	}else	if(keywordArray[0] == "WOL" && keywordArray[1] == "wake" && keywordArray[2] == "on"
			&& keywordArray[3] == "lan"){
	
	}else	if(keywordArray[0] == "WOL" && keywordArray[1] == "BIOS"){
		faqLang.TW = "zh-tw";
		faqLang.CN = "zh-cn";
		faqLang.FR = "fr-fr";
		faqLang.ES = "es-es";
	}		
	// exception end	
	

	if(obj){
		obj.href = "http://support.asus.com/search.aspx?SLanguage=";
		obj.href += faqLang.<% nvram_get("preferred_lang"); %>;
		obj.href += "&keyword=";
		for(var i=0; i<keywordArray.length; i++){
			obj.href += keywordArray[i];
			obj.href += "%20";
		}
	}
}

function Block_chars(obj, keywordArray){
	// bolck ascii code 32~126 first
	var invalid_char = "";		
	for(var i = 0; i < obj.value.length; ++i){
		if(obj.value.charCodeAt(i) < '32' || obj.value.charCodeAt(i) > '126'){
			invalid_char += obj.value.charAt(i);
		}
	}
	if(invalid_char != ""){
		alert('<#JS_validstr2#>" '+ invalid_char +'" !');
		obj.focus();
		return false;
	}

	// check if char in the specified array
	if(obj.value){
		for(var i=0; i<keywordArray.length; i++){
				if( obj.value.indexOf(keywordArray[i]) >= 0){						
					alert(keywordArray+ " are invalid characters.");
					obj.focus();
					return false;
				}	
		}
	}
	
	return true;
}

function cal_height(){
	var tableClientHeight;
	var optionHeight = 52;
	var manualOffSet = 25;
	var table_height = Math.round(optionHeight*calculate_height - manualOffSet*calculate_height/14 - $("tabMenu").clientHeight);	
	if(navigator.appName.indexOf("Microsoft") < 0)
		var contentObj = document.getElementsByClassName("content");
	else
		var contentObj = getElementsByClassName_iefix("table", "content");

	if($("FormTitle") && current_url.indexOf("Advanced_AiDisk_ftp") != 0 && current_url.indexOf("Advanced_AiDisk_samba") != 0 && current_url.indexOf("QoS_EZQoS") != 0){
		table_height = table_height + 24;
		$("FormTitle").style.height = table_height + "px";
		tableClientHeight = $("FormTitle").clientHeight;
	}
	// index.asp
	else if($("NM_table")){
		var statusPageHeight = 720;
		if(table_height < 740)
			table_height = 740;
		$("NM_table").style.height = table_height + "px";

		var root = document.compatMode == 'BackCompat' ? document.body : document.documentElement;
		var isVerticalScrollbar = root.scrollHeight > root.clientHeight;
		if(!isVerticalScrollbar)
			$("NM_table_div").style.marginTop = (table_height - statusPageHeight)/2 + "px";

		tableClientHeight = $("NM_table").clientHeight;
	}
	// aidisk.asp
	else if($("AiDiskFormTitle")){
		table_height = table_height + 24;
		$("AiDiskFormTitle").style.height = table_height + "px";
		tableClientHeight = $("AiDiskFormTitle").clientHeight;
	}
	// APP Install
	else if($("applist_table")){
		if(sw_mode == 2 || sw_mode == 3 || sw_mode == 4)
				table_height = table_height + 120;				
		else
				table_height = table_height + 40;	//2
		$("applist_table").style.height = table_height + "px";		
		tableClientHeight = $("applist_table").clientHeight;
		
		if(navigator.appName.indexOf("Microsoft") >= 0)
						contentObj[0].style.height = contentObj[0].clientHeight + 18 + "px";
	}
	// PrinterServ
	else if($("printerServer_table")){
		if(sw_mode == 2 || sw_mode == 4)
				table_height = table_height + 90;
		else
				table_height = table_height + 2;
		$("printerServer_table").style.height = table_height + "px";		
		tableClientHeight = $("printerServer_table").clientHeight;
		
		if(navigator.appName.indexOf("Microsoft") >= 0)
						contentObj[0].style.height = contentObj[0].clientHeight + 18 + "px";
	}	

	/*// overflow
	var isOverflow = parseInt(tableClientHeight) - parseInt(table_height);
	if(isOverflow >= 0){
		if(current_url.indexOf("Main_TrafficMonitor_realtime") == 0 && navigator.appName.indexOf("Microsoft") < 0)
			contentObj[0].style.height = contentObj[0].clientHeight + 45 + "px";
		else
			contentObj[0].style.height = contentObj[0].clientHeight + 19 + "px";	
	}*/
}

function show_footer(){
	footer_code = '<div align="center" class="bottom-image"></div>\n';
	footer_code +='<div align="center" class="copyright"><#footer_copyright_desc#></div><br>';

	// FAQ searching bar{
	footer_code += '<div style="margin-top:-75px;margin-left:205px;"><table width="765px" border="0" align="center" cellpadding="0" cellspacing="0"><tr>';
	footer_code += '<td width="20" align="right"><div id="bottom_help_icon" style="margin-right:3px;"></div></td><td width="100" id="bottom_help_title" align="left">Help & Support</td>';

	if(based_modelid =="RT-N12" || hw_ver.search("RTN12") != -1){	//MODELDEP : RT-N12
		if( hw_ver.search("RTN12HP") != -1){	//RT-N12HP
				footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12HP" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12HP" target="_blank">Utility</a></td>';
		}else if(hw_ver.search("RTN12B1") != -1){ //RT-N12B1
				footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12%20(VER.B1)" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12%20(VER.B1)" target="_blank">Utility</a></td>';
		}else if(hw_ver.search("RTN12C1") != -1){ //RT-N12C1
				footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12%20(VER.C1)" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12%20(VER.C1)" target="_blank">Utility</a></td>';
		}else if(hw_ver.search("RTN12D1") != -1){ //RT-N12D1
				footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12%20(VER.D1)" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N12%20(VER.D1)" target="_blank">Utility</a></td>';
		}else{	//RT-N12
				footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="<#bottom_Link#>" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="<#bottom_Link#>" target="_blank">Utility</a></td>';
		}
	}
	else	if(productid == "RT-N66U"){	//MODELDEP : RT-N66U
		footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N66U%20(VER.B1)" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=RT-N66U%20(VER.B1)" target="_blank">Utility</a></td>';
	}
	else if(productid == "DSL-N55U-B"){	//MODELDEP : DSL-N55U-B
		footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=DSL-N55U%20(VER.B1)" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="http://support.asus.com/download.aspx?SLanguage=en&m=DSL-N55U%20(VER.B1)" target="_blank">Utility</a></td>';
	}
	else{
		footer_code += '<td width="200" id="bottom_help_link" align="left">&nbsp&nbsp<a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="<#bottom_Link#>" target="_blank">Manual</a> | <a style="font-weight: bolder;text-decoration:underline;cursor:pointer;" href="<#bottom_Link#>" target="_blank">Utility</a></td>';	
	}			

	footer_code += '<td width="390" id="bottom_help_FAQ" align="right" style="font-family:Arial, Helvetica, sans-serif;">FAQ&nbsp&nbsp<input type="text" id="FAQ_input" name="FAQ_input" class="input_FAQ_table" maxlength="40"></td>';
	footer_code += '<td width="30" align="left"><div id="bottom_help_FAQ_icon" class="bottom_help_FAQ_icon" style="cursor:pointer;margin-left:3px;" target="_blank" onClick="search_supportsite();"></div></td>';
	footer_code += '</tr></table></div>\n';
	//}

	$("footer").innerHTML = footer_code;
	flash_button();
}

function search_supportsite(obj){
	var faqLang = {
		EN : "en",
		TW : "zh-tw",
		CN : "zh-cn",
		BR : "en",		
		CZ : "en",
		DA : "en",
		DE : "en",		
		ES : "es-es",
		FI : "en",
		FR : "fr-fr",
		IT : "en",
		JP : "en",				
		MS : "en",
		NO : "en",
		PL : "en",
		RU : "en",
		SV : "en",
		TH : "en",
		TR : "en",		
		UK : "en"
	}	
	
		var keywordArray = $("FAQ_input").value.split(" ");
		var faq_href;
		faq_href = "http://support.asus.com/search.aspx?SLanguage=";
		faq_href += faqLang.<% nvram_get("preferred_lang"); %>;
		faq_href += "&keyword=";
		for(var i=0; i<keywordArray.length; i++){
			faq_href += keywordArray[i];
			faq_href += "%20";
		}
		window.open(faq_href);
}

var isFirefox = navigator.userAgent.search("Firefox") > -1;
var isOpera = navigator.userAgent.search("Opera") > -1;
var isIE8 = navigator.userAgent.search("MSIE 8") > -1; 
var isiOS = navigator.userAgent.search("iP") > -1; 
function browser_compatibility(){
	var obj_inputBtn;

	if((isFirefox || isOpera) && document.getElementById("FormTitle")){
		document.getElementById("FormTitle").className = "FormTitle_firefox";
		if(current_url.indexOf("Guest_network") == 0)
			document.getElementById("FormTitle").style.marginTop = "-140px";	
		if(current_url.indexOf("ParentalControl") == 0 && !yadns_support)
			document.getElementById("FormTitle").style.marginTop = "-140px";				
	}

	if(isiOS){
		/* language options */
		document.body.addEventListener("touchstart", mouseClick, false);

		obj_inputBtn = document.getElementsByClassName("button_gen");
		for(var i=0; i<obj_inputBtn.length; i++){
			obj_inputBtn[i].addEventListener('touchstart', function(){this.className = 'button_gen_touch';}, false);
			obj_inputBtn[i].addEventListener('touchend', function(){this.className = 'button_gen';}, false);
		}
		obj_inputBtn = document.getElementsByClassName("button_gen_long");
		for(var i=0; i<obj_inputBtn.length; i++){
			obj_inputBtn[i].addEventListener('touchstart', function(){this.className = 'button_gen_long_touch';}, false);
			obj_inputBtn[i].addEventListener('touchend', function(){this.className = 'button_gen_long';}, false);
		}
	}
}	

var mouseClick = function(){
	var e = document.createEvent('MouseEvent');
	e.initEvent('click', false, false);
	document.getElementById("modelName_top").dispatchEvent(e);
}

function show_top_status(){
	if(!localAP_support){
		document.getElementById("ssidTitle").style.display = "none";
	}

	var ssid_status_2g =  decodeURIComponent('<% nvram_char_to_ascii("WLANConfig11b", "wl0_ssid"); %>');
	var ssid_status_5g =  decodeURIComponent('<% nvram_char_to_ascii("WLANConfig11b", "wl1_ssid"); %>');

	if(!band2g_support)
		ssid_status_2g = "";

	if(!band5g_support)
		ssid_status_5g = "";

	if(sw_mode == 4){
		if('<% nvram_get("wlc_band"); %>' == '0'){
			$("elliptic_ssid_2g").style.display = "none";
			$("elliptic_ssid_5g").style.marginLeft = "";
		}
		else
			$("elliptic_ssid_5g").style.display = "none";

		$('elliptic_ssid_2g').style.textDecoration="none";
		$('elliptic_ssid_2g').style.cursor="auto";
		$('elliptic_ssid_5g').style.textDecoration="none";
		$('elliptic_ssid_5g').style.cursor="auto";
	}
	else if(sw_mode == 2){
		if('<% nvram_get("wlc_band"); %>' == '0')
			ssid_status_2g =  decodeURIComponent('<% nvram_char_to_ascii("WLANConfig11b", "wl0.1_ssid"); %>');
		else
			ssid_status_5g =  decodeURIComponent('<% nvram_char_to_ascii("WLANConfig11b", "wl1.1_ssid"); %>');

		$('elliptic_ssid_2g').style.textDecoration="none";
		$('elliptic_ssid_2g').style.cursor="auto";
		$('elliptic_ssid_5g').style.textDecoration="none";
		$('elliptic_ssid_5g').style.cursor="auto";
	}

	if(!isFirefox){
		$("elliptic_ssid_2g").innerText = ssid_status_2g;
		$("elliptic_ssid_5g").innerText = ssid_status_5g;	
	}
	else{
		$("elliptic_ssid_2g").textContent = ssid_status_2g;
		$("elliptic_ssid_5g").textContent = ssid_status_5g;	
	}

  var swpjverno = '<% nvram_get("swpjverno"); %>';
  var buildno = '<% nvram_get("buildno"); %>';
  var firmver = '<% nvram_get("firmver"); %>'
	var extendno = '<% nvram_get("extendno"); %>';
	if(extendno == "") extendno="0";

  if(swpjverno == ''){
		showtext($("firmver"), firmver + "." + buildno + '_' + extendno.split("-g")[0]);
	}
  else{
		showtext($("firmver"), swpjverno + '_' + extendno);
  }
	
	// no_op_mode
	if (!dsl_support) {
		if(sw_mode == "1")  // Show operation mode in banner, Viz 2011.11
			$("sw_mode_span").innerHTML = "<#wireless_router#>";
		else if(sw_mode == "2")
			$("sw_mode_span").innerHTML = "<#OP_RE_item#>";
		else if(sw_mode == "3")
			$("sw_mode_span").innerHTML = "<#OP_AP_item#>";
		else if(sw_mode == "4")
			$("sw_mode_span").innerHTML = "Media bridge";
		else
			$("sw_mode_span").innerHTML = "Unknown";	

		if(hwmodeSwitch_support){	
			$("op_link").innerHTML = $("sw_mode_span").innerHTML;	
			$("op_link").style.cursor= "auto";			
		}
	}
}

function go_setting(page){
		location.href = page;
}

function go_setting_parent(page){
		parent.location.href = page;
}

function show_time(){	
	JS_timeObj.setTime(systime_millsec); // Add millsec to it.	
	JS_timeObj3 = JS_timeObj.toString();	
	JS_timeObj3 = checkTime(JS_timeObj.getHours()) + ":" +
				  			checkTime(JS_timeObj.getMinutes()) + ":" +
				  			checkTime(JS_timeObj.getSeconds());
	$('systemtime').innerHTML ="<a href='/Advanced_System_Content.asp'>" + JS_timeObj3 + "</a>";
	systime_millsec += 1000;		
	
	stime_ID = setTimeout("show_time();", 1000);
}

function checkTime(i)
{
if (i<10) 
  {i="0" + i}
  return i
}

function show_loading_obj(){
	var obj = $("Loading");
	var code = "";
	
	code +='<table cellpadding="5" cellspacing="0" id="loadingBlock" class="loadingBlock" align="center">\n';
	code +='<tr>\n';
	code +='<td width="20%" height="80" align="center"><img src="/images/loading.gif"></td>\n';
	code +='<td><span id="proceeding_main_txt"><#Main_alert_proceeding_desc4#></span><span id="proceeding_txt" style="color:#FFFFCC;"></span></td>\n';
	code +='</tr>\n';
	code +='</table>\n';
	code +='<!--[if lte IE 6.5]><iframe class="hackiframe"></iframe><![endif]-->\n';
	
	obj.innerHTML = code;
}

var nav;

if(navigator.appName == 'Netscape')
	nav = true;
else{
	nav = false;
	document.onkeydown = MicrosoftEventHandler_KeyDown;
}

function MicrosoftEventHandler_KeyDown(){
	return true;
}

// display selected language in language bar, Viz modified at 2013/03/22
function show_selected_language(){
	switch($("preferred_lang").value){
		case 'EN':{
			$('selected_lang').innerHTML = "English";
			break;
		}
		case 'CN':{
			$('selected_lang').innerHTML = "简体中文";
			break;
		}	
		case 'TW':{
			$('selected_lang').innerHTML = "繁體中文";
			break;
		}
		case 'BR':{
			$('selected_lang').innerHTML = "Portuguese(Brazil)&nbsp&nbsp";
			break;
		}
		case 'CZ':{
			$('selected_lang').innerHTML = "Česky";
			break;
		}
		case 'DA':{
			$('selected_lang').innerHTML = "Dansk";
			break;
		}	
		case 'DE':{
			$('selected_lang').innerHTML = "Deutsch";
			break;
		}
		case 'ES':{
			$('selected_lang').innerHTML = "Español";
			break;
		}
		case 'FI':{
			$('selected_lang').innerHTML = "Suomi";
			break;
		}
		case 'FR':{
			$('selected_lang').innerHTML = "Français";
			break;
		}
		case 'HU':{
			$('selected_lang').innerHTML = "Hungarian";
			break;
		}
		case 'IT':{
			$('selected_lang').innerHTML = "Italiano";
			break;
		}		
		case 'JP':{
			$('selected_lang').innerHTML = "日本語";
			break;
		}
		case 'MS':{
			$('selected_lang').innerHTML = "Malay";
			break;
		}
		case 'NO':{
			$('selected_lang').innerHTML = "Norsk";
			break;
		}
		case 'PL':{
			$('selected_lang').innerHTML = "Polski";
			break;
		}
		case 'RO':{
			$('selected_lang').innerHTML = "Romanian";
			break;
		}
		case 'RU':{
			$('selected_lang').innerHTML = "Pусский";
			break;
		}
		case 'SV':{
			$('selected_lang').innerHTML = "Svensk";
			break;
		}		
		case 'TH':{
			$('selected_lang').innerHTML = "ไทย";
			break;
		}			
		case 'TR':{
			$('selected_lang').innerHTML = "Türkçe";
			break;
		}	
		case 'UK':{
			$('selected_lang').innerHTML = "Ukrainian";
			break;
		}		
	}
}

function submit_language(obj){
	//if($("select_lang").value != $("preferred_lang").value){
	if(obj.id != $("preferred_lang").value){
		showLoading();
		
		with(document.titleForm){
			action = "/start_apply.htm";
			
			if(location.pathname == "/")
				current_page.value = "/index.asp";
			else
				current_page.value = location.pathname;
				
			preferred_lang.value = obj.id;
			//preferred_lang.value = $("select_lang").value;
			flag.value = "set_language";
			
			submit();
		}
	}
	else
		alert("No change LANGUAGE!");
}

function change_language(){
	if($("select_lang").value != $("preferred_lang").value)
		$("change_lang_btn").disabled = false;
	else
		$("change_lang_btn").disabled = true;
}

function logout(){
	if(confirm('<#JS_logout#>')){
		setTimeout('location = "Logout.asp";', 1);
	}
}

function reboot(){
	if(confirm("<#Main_content_Login_Item7#>")){
		if(document.form.current_page){
			if(document.form.current_page.value.indexOf("Advanced_FirmwareUpgrade_Content")>=0
		  	 || document.form.current_page.value.indexOf("Advanced_SettingBackup_Content")>=0)
					document.form.removeAttribute('enctype');
		}

		FormActions("apply.cgi", "reboot", "", "<% get_default_reboot_time(); %>");
		document.form.submit();
	}
}

function kb_to_gb(kilobytes){
	if(typeof(kilobytes) == "string" && kilobytes.length == 0)
		return 0;
	
	return (kilobytes*1024)/(1024*1024*1024);
}

function simpleNum(num){
	if(typeof(num) == "string" && num.length == 0)
		return 0;
	
	return parseInt(kb_to_gb(num)*1000)/1000;
}

function simpleNum2(num){
	if(typeof(num) == "string" && num.length == 0)
		return 0;
	
	return parseInt(num*1000)/1000;
}

function simpleNum3(num){
	if(typeof(num) == "string" && num.length == 0)
		return 0;
	
	return parseInt(num)/1024;
}

function $(){
	var elements = new Array();
	
	for(var i = 0; i < arguments.length; ++i){
		var element = arguments[i];
		if(typeof element == 'string')
			element = document.getElementById(element);
		
		if(arguments.length == 1)
			return element;
		
		elements.push(element);
	}
	
	return elements;
}

function getElementsByName_iefix(tag, name){
	var tagObjs = document.getElementsByTagName(tag);
	var objsName;
	var targetObjs = new Array();
	var targetObjs_length;
	
	if(!(typeof(name) == "string" && name.length > 0))
		return [];
	
	for(var i = 0, targetObjs_length = 0; i < tagObjs.length; ++i){
		objsName = tagObjs[i].getAttribute("name");
		
		if(objsName && objsName.indexOf(name) == 0){
			targetObjs[targetObjs_length] = tagObjs[i];
			++targetObjs_length;
		}
	}
	
	return targetObjs;
}

function getElementsByClassName_iefix(tag, name){
	var tagObjs = document.getElementsByTagName(tag);
	var objsName;
	var targetObjs = new Array();
	var targetObjs_length;
	
	if(!(typeof(name) == "string" && name.length > 0))
		return [];
	
	for(var i = 0, targetObjs_length = 0; i < tagObjs.length; ++i){
		if(navigator.appName == 'Netscape')
			objsName = tagObjs[i].getAttribute("class");
		else
			objsName = tagObjs[i].getAttribute("className");
		
		if(objsName == name){
			targetObjs[targetObjs_length] = tagObjs[i];
			++targetObjs_length;
		}
	}
	
	return targetObjs;
}

function showtext(obj, str){
	if(obj)
		obj.innerHTML = str;//*/
}

function showhtmlspace(ori_str){
	var str = "", head, tail_num;
	
	head = ori_str;
	while((tail_num = head.indexOf(" ")) >= 0){
		str += head.substring(0, tail_num);
		str += "&nbsp;";
		
		head = head.substr(tail_num+1, head.length-(tail_num+1));
	}
	str += head;
	
	return str;
}

function showhtmland(ori_str){
	var str = "", head, tail_num;
	
	head = ori_str;
	while((tail_num = head.indexOf("&")) >= 0){
		str += head.substring(0, tail_num);
		str += "&amp;";
		
		head = head.substr(tail_num+1, head.length-(tail_num+1));
	}
	str += head;
	
	return str;
}

// A dummy function which just returns its argument. This was needed for localization purpose
function translate(str){
	return str;
}

function trim(val){
	val = val+'';
	for (var startIndex=0;startIndex<val.length && val.substring(startIndex,startIndex+1) == ' ';startIndex++);
	for (var endIndex=val.length-1; endIndex>startIndex && val.substring(endIndex,endIndex+1) == ' ';endIndex--);
	return val.substring(startIndex,endIndex+1);
}

function IEKey(){
	return event.keyCode;
}

function NSKey(){
	return event.which;
}

function is_string(o, event){
	keyPressed = event.keyCode ? event.keyCode : event.which;

	if(keyPressed >= 0 && keyPressed <= 126)
		return true;
	else{
		alert('<#JS_validchar#>');
		return false;
	}	
}

function validate_string(string_obj, flag){
	if(string_obj.value.charAt(0) == '"'){
		if(flag != "noalert")
			alert('<#JS_validstr1#> ["]');
		
		string_obj.value = "";
		string_obj.focus();
		
		return false;
	}
	else{
		invalid_char = "";
		
		for(var i = 0; i < string_obj.value.length; ++i){
			if(string_obj.value.charAt(i) < ' ' || string_obj.value.charAt(i) > '~'){
				invalid_char = invalid_char+string_obj.value.charAt(i);
			}
		}
		
		if(invalid_char != ""){
			if(flag != "noalert")
				alert("<#JS_validstr2#> '"+invalid_char+"' !");
			string_obj.value = "";
			string_obj.focus();
			
			return false;
		}
	}
	
	return true;
}

function validate_hex(obj){
	var obj_value = obj.value
	var re = new RegExp("[^a-fA-F0-9]+","gi");
	
	if(re.test(obj_value))
		return false;
	else
		return true;
}

function validate_psk(psk_obj){
	var psk_length = psk_obj.value.length;
	
	if(psk_length < 8){
		alert("<#JS_passzero#>");
		psk_obj.value = "00000000";
		psk_obj.focus();
		psk_obj.select();
		
		return false;
	}
	
	if(psk_length > 64){
		alert("<#JS_passzero#>");
		psk_obj.focus();
		psk_obj.select();
		
		return false;
	}
	
	if(psk_length >= 8 && psk_length <= 63 && !validate_string(psk_obj)){
		alert("<#JS_PSK64Hex#>");
		psk_obj.focus();
		psk_obj.select();
		
		return false;
	}
	
	if(psk_length == 64 && !validate_hex(psk_obj)){
		alert("<#JS_PSK64Hex#>");
		psk_obj.focus();
		psk_obj.select();
		
		return false;
	}
	
	return true;
}

function validate_wlkey(key_obj){
	var wep_type = document.form.wl_wep_x.value;
	var iscurrect = true;
	var str = "<#JS_wepkey#>";

	if(wep_type == "0")
		iscurrect = true;	// do nothing
	else if(wep_type == "1"){
		if(key_obj.value.length == 5 && validate_string(key_obj)){
			document.form.wl_key_type.value = 1; /*Lock Add 11.25 for ralink platform*/
			iscurrect = true;
		}
		else if(key_obj.value.length == 10 && validate_hex(key_obj)){
			document.form.wl_key_type.value = 0; /*Lock Add 11.25 for ralink platform*/
			iscurrect = true;
		}
		else{
			str += "(<#WLANConfig11b_WEPKey_itemtype1#>)";
			
			iscurrect = false;
		}
	}
	else if(wep_type == "2"){
		if(key_obj.value.length == 13 && validate_string(key_obj)){
			document.form.wl_key_type.value = 1; /*Lock Add 11.25 for ralink platform*/
			iscurrect = true;
		}
		else if(key_obj.value.length == 26 && validate_hex(key_obj)){
			document.form.wl_key_type.value = 0; /*Lock Add 11.25 for ralink platform*/
			iscurrect = true;
		}
		else{
			str += "(<#WLANConfig11b_WEPKey_itemtype2#>)";
			
			iscurrect = false;
		}
	}
	else{
		alert("System error!");
		iscurrect = false;
	}
	
	if(iscurrect == false){
		alert(str);
		
		key_obj.focus();
		key_obj.select();
	}
	
	return iscurrect;
}

function validate_ssidchar(ch){
	if(ch >= 32 && ch <= 126)
		return false;
	
	return true;
}

function validate_account(string_obj, flag){
	var invalid_char = "";

	if(string_obj.value.charAt(0) == ' '){
		if(flag != "noalert")
			alert('<#JS_validstr1#> [  ]');

		string_obj.value = "";
		string_obj.focus();

		if(flag != "noalert")
			return false;
		else
			return '<#JS_validstr1#> [&nbsp;&nbsp;&nbsp;]';
	}
	else if(string_obj.value.charAt(0) == '-'){
		if(flag != "noalert")
			alert('<#JS_validstr1#> [-]');

		string_obj.value = "";
		string_obj.focus();

		if(flag != "noalert")
			return false;
		else
			return '<#JS_validstr1#> [-]';
	}

	for(var i = 0; i < string_obj.value.length; ++i){
		if(validate_ssidchar(string_obj.value.charCodeAt(i))){
			invalid_char = invalid_char+string_obj.value.charAt(i);
		}	
		
		if(string_obj.value.charAt(i) == '"'
				||  string_obj.value.charAt(i) == '/'
				||  string_obj.value.charAt(i) == '\\'
				||  string_obj.value.charAt(i) == '['
				||  string_obj.value.charAt(i) == ']'
				||  string_obj.value.charAt(i) == ':'
				||  string_obj.value.charAt(i) == ';'
				||  string_obj.value.charAt(i) == '|'
				||  string_obj.value.charAt(i) == '='
				||  string_obj.value.charAt(i) == ','
				||  string_obj.value.charAt(i) == '+'
				||  string_obj.value.charAt(i) == '*'
				||  string_obj.value.charAt(i) == '?'
				||  string_obj.value.charAt(i) == '<'
				||  string_obj.value.charAt(i) == '>'
				||  string_obj.value.charAt(i) == '@'
				||  string_obj.value.charAt(i) == ' '
				){
			invalid_char = invalid_char+string_obj.value.charAt(i);
		}
	}

	if(invalid_char != ""){
		if(flag != "noalert")
			alert("<#JS_validstr2#> ' "+invalid_char+" ' !");

		string_obj.value = "";
		string_obj.focus();

		if(flag != "noalert")
			return false;
		else
			return "<#JS_validstr2#> ' "+invalid_char+" ' !";
	}

	if(flag != "noalert")
		return true;
	else
		return "";
}

function checkDuplicateName(newname, targetArray){
	var existing_string = targetArray.join(',');
	existing_string = ","+existing_string+",";
	var newstr = ","+trim(newname)+",";
	
	var re = new RegExp(newstr, "gi");
	var matchArray = existing_string.match(re);
	
	if(matchArray != null)
		return true;
	else
		return false;
}

function alert_error_msg(error_msg){
	alert(error_msg);
	refreshpage();
}

function refreshpage(seconds){
	if(typeof(seconds) == "number")
		setTimeout("refreshpage()", seconds*1000);
	else
		location.href = location.href;
}

function hideLinkTag(){
	if(document.all){
		var tagObjs = document.all.tags("a");
		
		for(var i = 0; i < tagObjs.length; ++i)
			tagObjs(i).outerHTML = tagObjs(i).outerHTML.replace(">"," hidefocus=true>");
	}
}

function buttonOver(o){	//Lockchou 1206 modified
	o.style.color = "#FFFFFF";
	o.style.background = "url(/images/bgaibutton.gif) #ACCCE1";
	o.style.cursor = "hand";
}

function buttonOut(o){	//Lockchou 1206 modified
	o.style.color = "#000000";
	o.style.background = "url(/images/bgaibutton0.gif) #ACCCE1";
}

function flash_button(){
	if(navigator.appName.indexOf("Microsoft") < 0)
		return;
	
	var btnObj = getElementsByClassName_iefix("input", "button");
	
	for(var i = 0; i < btnObj.length; ++i){
		btnObj[i].onmouseover = function(){
				buttonOver(this);
			};
		
		btnObj[i].onmouseout = function(){
				buttonOut(this);
			};
	}
}

function no_flash_button(){
	if(navigator.appName.indexOf("Microsoft") < 0)
		return;
	
	var btnObj = getElementsByClassName_iefix("input", "button");
	
	for(var i = 0; i < btnObj.length; ++i){
		btnObj[i].onmouseover = "";
		
		btnObj[i].onmouseout = "";
	}
}

function gotoprev(formObj){
	var prev_page = formObj.prev_page.value;
	
	if(prev_page == "/")
		prev_page = "/index.asp";
	
	if(prev_page.indexOf('QIS') < 0){
		formObj.action = prev_page;
		formObj.target = "_parent";
		formObj.submit();
	}
	else{
		formObj.action = prev_page;
		formObj.target = "";
		formObj.submit();
	}
}

function add_option(selectObj, str, value, selected){
	var tail = selectObj.options.length;
	
	if(typeof(str) != "undefined")
		selectObj.options[tail] = new Option(str);
	else
		selectObj.options[tail] = new Option();
	
	if(typeof(value) != "undefined")
		selectObj.options[tail].value = value;
	else
		selectObj.options[tail].value = "";
	
	if(selected == 1)
		selectObj.options[tail].selected = selected;
}

function free_options(selectObj){
	if(selectObj == null)
		return;
	
	for(var i = selectObj.options.length-1; i >= 0; --i){
  		selectObj.options[i].value = null;
		selectObj.options[i] = null;
	}
}

function blocking(obj_id, show){
	var state = show?'block':'none';
	
	if(document.getElementById)
		$(obj_id).style.display = state;
	else if(document.layers)
		document.layers[obj_id].display = state;
	else if(document.all)
		document.all[obj_id].style.display = state;
}

function inputCtrl(obj, flag){
	if(flag == 0){
		obj.disabled = true;
		if(obj.type != "select-one")
			obj.style.backgroundColor = "#CCCCCC";
		if(obj.type == "radio" || obj.type == "checkbox")
			obj.style.backgroundColor = "#475A5F";
		if(obj.type == "text" || obj.type == "password")
			obj.style.backgroundImage = "url(/images/New_ui/inputbg_disable.png)";
	}
	else{
		obj.disabled = false;
		if(obj.type != "select-one")	
			obj.style.backgroundColor = "#FFF";
		if(obj.type == "radio" || obj.type == "checkbox")
			obj.style.backgroundColor = "#475A5F";
		if(obj.type == "text" || obj.type == "password")
			obj.style.backgroundImage = "url(/images/New_ui/inputbg.png)";
	}

	if(current_url.indexOf("Advanced_Wireless_Content") == 0
	|| current_url.indexOf("Advanced_WAN_Content") == 0
	|| current_url.indexOf("Guest_network") == 0
	|| current_url.indexOf("Advanced_PerformanceTuning_Content") == 0
	|| current_url.indexOf("Advanced_Modem_Content") == 0
	|| current_url.indexOf("QIS_modem") == 0
	|| current_url.indexOf("Advanced_IPv6_Content") == 0
	|| current_url.indexOf("Advanced_WAdvanced_Content") == 0
	|| current_url.indexOf("Advanced_IPTV_Content") == 0
	|| current_url.indexOf("Advanced_WANPort_Content.asp") == 0
	|| current_url.indexOf("Advanced_ASUSDDNS_Content.asp") == 0
	|| current_url.indexOf("Advanced_DSL_Content.asp") == 0
	|| current_url.indexOf("Advanced_SwitchCtrl_Content.asp") == 0
	){
		if(obj.type == "checkbox")
			return true;
		if(flag == 0)
			obj.parentNode.parentNode.style.display = "none";
		else
			obj.parentNode.parentNode.style.display = "";
		return true;
	}
}

function inputHideCtrl(obj, flag){
	if(obj.type == "checkbox")
		return true;
	if(flag == 0)
		obj.parentNode.parentNode.style.display = "none";
	else
		obj.parentNode.parentNode.style.display = "";
	return true;
}

//Update current status via AJAX
var http_request_status = false;

function updateStatus_AJAX(){
	if(stopFlag == 1)
		return false;

	var ie = window.ActiveXObject;

	if(ie)
		makeRequest_status_ie('/ajax_status.asp');
	else
		makeRequest_status('/ajax_status.asp');
}

function makeRequest_status(url) {
	http_request_status = new XMLHttpRequest();
	if (http_request_status && http_request_status.overrideMimeType)
		http_request_status.overrideMimeType('text/xml');
	else
		return false;

	http_request_status.onreadystatechange = alertContents_status;
	http_request_status.open('GET', url, true);
	http_request_status.send(null);
}

var xmlDoc_ie;

function makeRequest_status_ie(file)
{
	xmlDoc_ie = new ActiveXObject("Microsoft.XMLDOM");
	xmlDoc_ie.async = false;
	if (xmlDoc_ie.readyState==4)
	{
		xmlDoc_ie.load(file);
		setTimeout("refresh_info_status(xmlDoc_ie);", 1000);
	}
}

function alertContents_status()
{
	if (http_request_status != null && http_request_status.readyState != null && http_request_status.readyState == 4)
	{
		if (http_request_status.status != null && http_request_status.status == 200)
		{
			var xmldoc_mz = http_request_status.responseXML;
			refresh_info_status(xmldoc_mz);
		}
	}
}

function updateUSBStatus(){
	if(current_url == "index.asp" || current_url == "")
		detectUSBStatusIndex();
	else
		detectUSBStatus();
}

function detectUSBStatus(){
	$j.ajax({
    		url: '/update_diskinfo.asp',
    		dataType: 'script',
    		error: function(xhr){
    			detectUSBStatus();
    		},
    		success: function(){
					return true;
  			}
  });
}

var link_status;
var link_auxstatus;
var link_sbstatus;
var usb_path1;
var usb_path2;
var usb_path1_tmp = "init";
var usb_path2_tmp = "init";
var usb_path1_removed;
var usb_path2_removed;
var usb_path1_removed_tmp = "init";
var usb_path2_removed_tmp = "init";
var ddns_return_code = '<% nvram_get("ddns_return_code_chk");%>';
var ddns_updated = '<% nvram_get("ddns_updated");%>';
if(usb_support){
	var tmp_mount_0 = foreign_disk_total_mounted_number()[0];		//Viz 2013.06
	var tmp_mount_1 = foreign_disk_total_mounted_number()[1];		//Viz 2013.06
}	

function refresh_info_status(xmldoc)
{
	var devicemapXML = xmldoc.getElementsByTagName("devicemap");
	var wanStatus = devicemapXML[0].getElementsByTagName("wan");
	link_status = wanStatus[0].firstChild.nodeValue;
	link_sbstatus = wanStatus[1].firstChild.nodeValue;
	link_auxstatus = wanStatus[2].firstChild.nodeValue;
	usb_path1 = wanStatus[3].firstChild.nodeValue;
	usb_path2 = wanStatus[4].firstChild.nodeValue;
	monoClient = wanStatus[5].firstChild.nodeValue;	
	cooler = wanStatus[6].firstChild.nodeValue;	
	_wlc_state = wanStatus[7].firstChild.nodeValue;
	_wlc_sbstate = wanStatus[8].firstChild.nodeValue;	
	_wlc_auth = wanStatus[10].firstChild.nodeValue;	
	wifi_hw_switch = wanStatus[9].firstChild.nodeValue;
	usb_path1_removed = wanStatus[11].firstChild.nodeValue;	
	usb_path2_removed = wanStatus[12].firstChild.nodeValue;
	ddns_return_code = wanStatus[13].firstChild.nodeValue.replace("ddnsRet=", "");
	ddns_updated = wanStatus[14].firstChild.nodeValue.replace("ddnsUpdate=", "");
	wan_line_state = wanStatus[15].firstChild.nodeValue.replace("wan_line_state=", "");
	wlan0_radio_flag = wanStatus[16].firstChild.nodeValue.replace("wlan0_radio_flag=", "");
	wlan1_radio_flag = wanStatus[17].firstChild.nodeValue.replace("wlan1_radio_flag=", "");

	if(location.pathname == "/"+ QISWIZARD)
		return false;	

	// internet
	if(sw_mode == 1){
		//Viz add 2013.04 for dsl sync status
		if(dsl_support){		
				if(wan_line_state == "up"){
						$("adsl_line_status").className = "linestatusup";			
						$("adsl_line_status").onclick = function(){openHint(24,6);}
				}else if(wan_line_state == "wait for init"){
						$("adsl_line_status").className = "linestatuselse";
				}else if(wan_line_state == "init"){
						$("adsl_line_status").className = "linestatuselse";
				}else{
						$("adsl_line_status").className = "linestatusdown";
				}		
				$("adsl_line_status").onmouseover = function(){overHint(9);}
				$("adsl_line_status").onmouseout = function(){nd();}
		}
						
		if((link_status == "2" && link_auxstatus == "0") || (link_status == "2" && link_auxstatus == "2")){
			$("connect_status").className = "connectstatuson";
			$("connect_status").onclick = function(){openHint(24,3);}
			if(location.pathname == "/" || location.pathname == "/index.asp"){
				$("NM_connect_status").innerHTML = "<#Connected#>";
				$('single_wan').className = "single_wan_connected";
			}	
		}
		else{
			$("connect_status").className = "connectstatusoff";
			$("connect_status").onclick = function(){openHint(24,3);}

			if(location.pathname == "/" || location.pathname == "/index.asp"){
				$("NM_connect_status").innerHTML = '<a style="color:#FFF;text-decoration:underline;" href="/'+ QISWIZARD +'?flag=detect"><#Disconnected#></a>';
				$('single_wan').className = "single_wan_disconnected";
				$("wanIP_div").style.display = "none";		
			}
		}
		$("connect_status").onmouseover = function(){overHint(3);}
		$("connect_status").onmouseout = function(){nd();}
	}
	else if(sw_mode == 2 || sw_mode == 4){
		if(sw_mode == 4){
			if(wanStatus[10].firstChild.nodeValue.search("wlc_state=1") != -1 && wanStatus[10].firstChild.nodeValue.search("wlc_state_auth=0") != -1)
				_wlc_state = "wlc_state=2";
			else
				_wlc_state = "wlc_state=0";
		}

		if(_wlc_state == "wlc_state=2"){
			$("connect_status").className = "connectstatuson";
			$("connect_status").onclick = function(){openHint(24,3);}
			if(location.pathname == "/" || location.pathname == "/index.asp"){
				$("NM_connect_status").innerHTML = "<#Connected#>";
				$('single_wan').className = "single_wan_connected";
			}	
		}
		else{
			$("connect_status").className = "connectstatusoff";
			if(location.pathname == "/" || location.pathname == "/index.asp"){
				$("NM_connect_status").innerHTML = "<#Disconnected#>";		 
				$('single_wan').className = "single_wan_disconnected";				
			}	
		}
		$("connect_status").onmouseover = function(){overHint(3);}
		$("connect_status").onmouseout = function(){nd();}
	}

	// wifi hw sw status
	if(wifi_hw_sw_support){
		if(band5g_support){
				if(wlan0_radio_flag == "0" && wlan1_radio_flag == "0"){
						$("wifi_hw_sw_status").className = "wifihwswstatusoff";
						$("wifi_hw_sw_status").onclick = function(){}
				}
				else{
						$("wifi_hw_sw_status").className = "wifihwswstatuson";
						$("wifi_hw_sw_status").onclick = function(){}
				}
		}
		else{
				if(wlan0_radio_flag == "0"){
						$("wifi_hw_sw_status").className = "wifihwswstatusoff";
						$("wifi_hw_sw_status").onclick = function(){}
				}
				else{
						$("wifi_hw_sw_status").className = "wifihwswstatuson";
						$("wifi_hw_sw_status").onclick = function(){}
				}
		}		
		$("wifi_hw_sw_status").onmouseover = function(){overHint(8);}
		$("wifi_hw_sw_status").onmouseout = function(){nd();}		
	}	

	// usb
	if(usb_support){
		if(current_url=="index.asp"||current_url==""){
			if((usb_path1_removed != usb_path1_removed_tmp && usb_path1_removed_tmp != "init")){
				location.href = "/index.asp";
			}
			else if(usb_path1_removed == "umount=0"){ // umount=0->umount=0, 0->storage
				if((usb_path1 != usb_path1_tmp && usb_path1_tmp != "init"))
					location.href = "/index.asp";
			}

			if((usb_path2_removed != usb_path2_removed_tmp && usb_path2_removed_tmp != "init")){
				location.href = "/index.asp";
			}
			else if(usb_path2_removed == "umount=0"){ // umount=0->umount=0, 0->storage
				if((usb_path2 != usb_path2_tmp && usb_path2_tmp != "init"))
					location.href = "/index.asp";
			}
		}

		if(usb_path1_removed == "umount=1")
			usb_path1 = "usb=";

		if(usb_path2_removed == "umount=1")
			usb_path2 = "usb=";

		if(usb_path1 == "usb=" && usb_path2 == "usb="){
			$("usb_status").className = "usbstatusoff";
			$("usb_status").onclick = function(){overHint(2);}
			if(printer_support){
				$("printer_status").className = "printstatusoff";
				$("printer_status").onclick = function(){overHint(5);}
				$("printer_status").onmouseover = function(){overHint(5);}
				$("printer_status").onmouseout = function(){nd();}
			}
		}
		else{
			if(usb_path1 == "usb=printer" || usb_path2 == "usb=printer"){ // printer
				if((current_url == "index.asp" || current_url == "") && $("printerName0") == null && $("printerName1") == null)
					updateUSBStatus();
				if(printer_support){
					$("printer_status").className = "printstatuson";
					$("printer_status").onmouseover = function(){overHint(6);}
					$("printer_status").onmouseout = function(){nd();}
					$("printer_status").onclick = function(){openHint(24,1);}
				}
				if(usb_path1 == "usb=" || usb_path2 == "usb=")
					$("usb_status").className = "usbstatusoff";			
				else
					$("usb_status").className = "usbstatuson";
			}
			else{ // !printer
				if((current_url == "index.asp" || current_url == "") && ($("printerName0") != null || $("printerName1") != null))
					location.href = "/index.asp";

				if(printer_support){
					$("printer_status").className = "printstatusoff";
					$("printer_status").onmouseover = function(){overHint(5);}
					$("printer_status").onmouseout = function(){nd();}
				}

				$("usb_status").className = "usbstatuson";
				//alert(tmp_mount_0+" , "+foreign_disk_total_mounted_number()[0]+" ; "+tmp_mount_1+" , "+foreign_disk_total_mounted_number()[1]);
				if((tmp_mount_0 == 0 && usb_path1_removed =="umount=0") || (tmp_mount_1 == 0 && usb_path2_removed =="umount=0")){
							updateUSBStatus();						//Viz 2013.06
				}
							
			}
			$("usb_status").onclick = function(){openHint(24,2);}
		}
		$("usb_status").onmouseover = function(){overHint(2);}
		$("usb_status").onmouseout = function(){nd();}

		usb_path1_tmp = usb_path1;
		usb_path2_tmp = usb_path2;
		usb_path1_removed_tmp = usb_path1_removed;
		usb_path2_removed_tmp = usb_path2_removed;
	}

	// guest network
	if(multissid_support != -1 && gn_array_5g.length > 0){
		for(var i=0; i<gn_array_2g.length; i++){
			if(gn_array_2g[i][0] == 1 || gn_array_5g[i][0] == 1){
				$("guestnetwork_status").className = "guestnetworkstatuson";
				$("guestnetwork_status").onclick = function(){openHint(24,4);}
				break;
			}
			else{
				$("guestnetwork_status").className = "guestnetworkstatusoff";
				$("guestnetwork_status").onclick = function(){overHint(4);}
			}
		}
		$("guestnetwork_status").onmouseover = function(){overHint(4);}
		$("guestnetwork_status").onmouseout = function(){nd();}
	}
	else if(multissid_support != -1 && gn_array_5g.length == 0){
		for(var i=0; i<gn_array_2g.length; i++){
			if(gn_array_2g[i][0] == 1){
				$("guestnetwork_status").className = "guestnetworkstatuson";
				$("guestnetwork_status").onclick = function(){openHint(24,4);}
				break;
			}
			else{
				$("guestnetwork_status").className = "guestnetworkstatusoff";
			}
		}
		$("guestnetwork_status").onmouseover = function(){overHint(4);}
		$("guestnetwork_status").onmouseout = function(){nd();}
	}

	if(cooler_support){
		if(cooler == "cooler=2"){
			$("cooler_status").className = "coolerstatusoff";
			$("cooler_status").onclick = function(){}
		}
		else{
			$("cooler_status").className = "coolerstatuson";
			$("cooler_status").onclick = function(){openHint(24,5);}
		}
		$("cooler_status").onmouseover = function(){overHint(7);}
		$("cooler_status").onmouseout = function(){nd();}
	}

	if(window.frames["statusframe"] && window.frames["statusframe"].stopFlag == 1 || stopFlag == 1){
		return 0;
	}

	setTimeout("updateStatus_AJAX();", 3000);
}

function db(obj){
	if(typeof console == 'object')
		console.log(obj);
}

function dbObj(obj){
	for(var j in obj){	
		if(j!="textContent" && j!="outerHTML" && j!="innerHTML" && j!="innerText" && j!="outerText")
			db(j+" : "+obj[j]);
	}
}

function FormActions(_Action, _ActionMode, _ActionScript, _ActionWait){
	if(_Action != "")
		document.form.action = _Action;
	if(_ActionMode != "")
		document.form.action_mode.value = _ActionMode;
	if(_ActionScript != "")
		document.form.action_script.value = _ActionScript;
	if(_ActionWait != "")
		document.form.action_wait.value = _ActionWait;
}

function change_wl_unit(){
	FormActions("apply.cgi", "change_wl_unit", "", "");
	document.form.target = "";
	document.form.submit();
}

function compareWirelessClient(target1, target2){
	if(target1.length != target2.length)
		return (target2.length-target1.length);
	
	for(var i = 0; i < target1.length; ++i)
		for(var j = 0; j < 3; ++j)
			if(target1[i][j] != target2[i][j])
					return 1;
	
	return 0;
}

function addNewScript(scriptName){
	var script = document.createElement("script");
	script.type = "text/javascript";
	script.src = scriptName;
	document.getElementsByTagName("head")[0].appendChild(script);
}

function addNewCSS(cssName){
	var cssNode = document.createElement('link');
	cssNode.type = 'text/css';
	cssNode.rel = 'stylesheet';
	cssNode.href = cssName;
	document.getElementsByTagName("head")[0].appendChild(cssNode);
}

var cookie_help = {
	set: function(key, value, days) {
		document.cookie = key + '=' + value + '; expires=' +
			(new Date(new Date().getTime() + ((days ? days : 14) * 86400000))).toUTCString() + '; path=/';
	}
};

function getCookie_help(c_name){
	if (document.cookie.length > 0){ 
		c_start=document.cookie.indexOf(c_name + "=")
		if (c_start!=-1){ 
			c_start=c_start + c_name.length+1 
			c_end=document.cookie.indexOf(";",c_start)
			if (c_end==-1) c_end=document.cookie.length
			return unescape(document.cookie.substring(c_start,c_end))
		} 
	}
	return null;
}

function unload_body(){
}

function enableCheckChangedStatus(){
}

function disableCheckChangedStatus(){
	stopFlag = 1;
}

function get_changed_status(){
}

function isMobile(){
	return false; //disable mobile QIS temporary, Jieming added at 2013.08.12
	
	if((navigator.userAgent.match(/iPhone/i))  || 
     (navigator.userAgent.match(/iPod/i))    ||
     (navigator.userAgent.match(/Android/i)) && (navigator.userAgent.match(/Mobile/i))){
		return true;
	}
	else{
		return false;
	}
}

var stopAutoFocus;
function autoFocus(str){
	if(str == "")
		return false;

	stopAutoFocus = 0;
	if(document.form){
		for(var i = 0; i < document.form.length; i++){
			if(document.form[i].name == str){
				var sec = 600;
				var maxAF = 20;
				if(navigator.userAgent.toLowerCase().search("webkit") < 0){
					window.onclick = function(){stopAutoFocus=1;document.form[i].style.border='';}
					for(var j=0; j<maxAF; j++){
						setTimeout("if(stopAutoFocus==0)document.form["+i+"].style.border='1px solid #56B4EF';", sec*j++);
						setTimeout("if(stopAutoFocus==0)document.form["+i+"].style.border='';", sec*j);							
					}
				}
				else{
					window.onclick = function(){stopAutoFocus=1;}
					document.form[i].focus();
					for(var j=1; j<maxAF; j++){
						setTimeout("if(stopAutoFocus==0)document.form["+i+"].blur();", sec*j++);
						setTimeout("if(stopAutoFocus==0)document.form["+i+"].focus();", sec*j);
					}
				}
				break;
			}
		}
	}
}

function charToAscii(str){
	var retAscii = "";
	for(var i = 0; i < str.length; i++){
		retAscii += "%";
		retAscii += str.charCodeAt(i).toString(16).toUpperCase();
	}
	return retAscii;
}

function set_variable(_variable, _val){
	var NewInput = document.createElement("input");
	NewInput.type = "hidden";
	NewInput.name = _variable;
	NewInput.value = _val;
	document.form.appendChild(NewInput);
}

function isPortConflict(_val){
	if(_val == '80')
		return "<#portConflictHint#> HTTP LAN port.";
	else if(_val == '<% nvram_get("dm_http_port"); %>')
		return "<#portConflictHint#> Download Master.";
	else if(_val == '<% nvram_get("webdav_http_port"); %>')
		return "<#portConflictHint#> Cloud Disk.";
	else if(_val == '<% nvram_get("webdav_https_port"); %>')
		return "<#portConflictHint#> Cloud Disk.";
	else
		return false;
}

//Jieming added at 2013.05.24, to switch type of password to text or password
//for IE, need to use two input field and ID should be "xxx", "xxx_text" 
var isNotIE = (navigator.userAgent.search("MSIE") == -1); 
function switchType(obj, showText, chkBox){
	if(chkBox == undefined) chkBox = false;
	var newType = showText ? "text" : "password";
	if(isNotIE){	//Not IE
		obj.type = newType;
	}
	else {	//IE
		if(obj.type != newType)
		{
			var input2 = document.createElement('input');
			input2.mergeAttributes(obj);
			input2.type = newType;
			input2.name = obj.name;
			input2.id = obj.id? obj.id : obj.name;
			input2.value = obj.value;

			obj.parentNode.replaceChild(input2,obj);
			if(showText && input2.id && !chkBox)
				setTimeout(function(){document.getElementById(input2.id).focus()},10);
		}
	}
}

function corrected_timezone(){
	var today = new Date();
	var StrIndex;	
	if(today.toString().lastIndexOf("-") > 0)
		StrIndex = today.toString().lastIndexOf("-");
	else if(today.toString().lastIndexOf("+") > 0)
		StrIndex = today.toString().lastIndexOf("+");

	if(StrIndex > 0){
		if(timezone != today.toString().substring(StrIndex, StrIndex+5)){
			$("timezone_hint_div").style.display = "";
			$("timezone_hint").innerHTML = "* <#LANHostConfig_x_TimeZone_itemhint#>";
		}
		else
			return;
	}
	else
		return;	
}

String.prototype.howMany = function(val){
	var result = this.toString().match(new RegExp(val ,"g"));
	var count = (result)?result.length:0;

	return count;
}