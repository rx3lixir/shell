import QtQuick
import Quickshell
import "osd"
import "bar"
import "bar/ba_modules"

ShellRoot {
	// Load the OSD manager (the brain)
	OsdManager {
		id: osdManager
	}
	
	// Load the OSD display (the visuals)
	OsdDisplay {
		manager: osdManager
	}

	// Load the Bar component
	Bar {
		id: bar
	}
}
