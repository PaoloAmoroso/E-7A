# Aircraft Config Center
# Joshua Davidson (it0uchpods)

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
setprop("/systems/acconfig/options/welcome-skip", 0);
setprop("/systems/acconfig/options/yokes-visible", 1);
setprop("/systems/acconfig/options/increase-fps", 0);
var main_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/main/dialog", "Aircraft/E-7A/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/E-7A/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/E-7A/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/E-7A/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/init/dialog", "Aircraft/E-7A/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/help/dialog", "Aircraft/E-7A/AircraftConfig/help.xml");
var fctl_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fctl/dialog", "Aircraft/E-7A/AircraftConfig/fctl.xml");
var announcements_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/announcements/dialog", "Aircraft/E-7A/AircraftConfig/announcements.xml");
var lights_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/lights/dialog", "Aircraft/E-7A/AircraftConfig/lights.xml");
var fuel_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fuel/dialog", "Aircraft/E-7A/AircraftConfig/fuel.xml");
var fail_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fail/dialog", "Aircraft/E-7A/AircraftConfig/fail.xml");
var error_mismatch = gui.Dialog.new("sim/gui/dialogs/acconfig/error/mismatch/dialog", "Aircraft/E-7A/AircraftConfig/error-mismatch.xml");
spinning.start();
init_dlg.open();

var mismatch_chk = func {
	if (num(string.replace(getprop("/sim/version/flightgear"),".","")) < 201810) {
		setprop("/systems/acconfig/mismatch-code", "0x121");
		setprop("/systems/acconfig/mismatch-reason", "FGFS version is too old! Please update FlightGear to at least 2018.1.0.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x121");
		welcome_dlg.close();
	} else if (getprop("/gear/gear[0]/wow") == 0 or getprop("/position/altitude-ft") >= 15000) {
		setprop("/systems/acconfig/mismatch-code", "0x223");
		setprop("/systems/acconfig/mismatch-reason", "Preposterous configuration detected for initialization. Check your position or scenery.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		print("Mismatch: 0x223");
		welcome_dlg.close();
	}
	setprop("/sim/minimum-fg-version", "2018.1.0");
	setprop("/sim/minimum-flightgear-version", getprop("/sim/minimum-fg-version"));
}

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	mismatch_chk();
	readSettings();
	if (getprop("/systems/acconfig/options/welcome-skip") != 1) {
		welcome_dlg.open();
	}
	writeSettings();
	spinning.stop();
});

var readSettings = func {
	io.read_properties(getprop("/sim/fg-home") ~ "/Export/E-7A-config.xml", "/systems/acconfig/options");
	setprop("/sim/yokes-visible", getprop("/systems/acconfig/options/yokes-visible"));
	setprop("/controls/switches/increase-fps", getprop("/systems/acconfig/options/increase-fps"));
}

var writeSettings = func {
	setprop("/systems/acconfig/options/yokes-visible", getprop("/sim/yokes-visible"));
	setprop("/systems/acconfig/options/increase-fps", getprop("/controls/switches/increase-fps"));
	io.write_properties(getprop("/sim/fg-home") ~ "/Export/E-7A-config.xml", "/systems/acconfig/options");
}

var systemsReset = func { # Not used yet, for panel states when implemented
}
