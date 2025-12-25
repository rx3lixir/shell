import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Scope {
	id: manager

	// Track PipeWire objects
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
	}

	// OSD Types
	readonly property string typeNone: "none"
	readonly property string typeVolume: "volume"
	readonly property string typeMic: "mic"
	readonly property string typeBrightness: "brightness"

	// Exposed state for the display
	property string currentType: typeNone
	property real currentValue: 0.0
	property bool currentMuted: false
	property string currentIcon: ""

	// Single unified timer
	Timer {
		id: hideTimer
		interval: 1500
		onTriggered: manager.currentType = manager.typeNone
	}

	// Helper to show OSD
	function showOsd(type, value, muted, icon) {
		manager.currentType = type;
		manager.currentValue = value;
		manager.currentMuted = muted;
		manager.currentIcon = icon;
		hideTimer.restart();
	}

	// Volume icon logic
	function getVolumeIcon(volume, muted) {
		if (muted) return "";
		if (volume == 0) return "󰕿";
    if (volume < 0.62) return "";
		return "";
	}

	// Brightness icon logic
	function getBrightnessIcon(brightness) {
		if (brightness < 0.33) return "󰃞";
		if (brightness < 0.66) return "󰃟";
		return "󰃠";
	}

	// PipeWire: Speaker/Volume
	property var audioSinkNode: Pipewire.defaultAudioSink
	property var audioSink: audioSinkNode?.audio ?? null
	
	Connections {
		target: manager.audioSink
		enabled: manager.audioSink !== null
		
		function onVolumeChanged() {
			if (!manager.audioSink) return;
			const vol = manager.audioSink.volume;
			const muted = manager.audioSink.muted;
			manager.showOsd(
				manager.typeVolume,
				vol,
				muted,
				manager.getVolumeIcon(vol, muted)
			);
		}
		
		function onMutedChanged() {
			if (!manager.audioSink) return;
			const vol = manager.audioSink.volume;
			const muted = manager.audioSink.muted;
			manager.showOsd(
				manager.typeVolume,
				vol,
				muted,
				manager.getVolumeIcon(vol, muted)
			);
		}
	}

	// PipeWire: Microphone
	property var audioSourceNode: Pipewire.defaultAudioSource
	property var audioSource: audioSourceNode?.audio ?? null
	
	Connections {
		target: manager.audioSource
		enabled: manager.audioSource !== null
		
		function onVolumeChanged() {
			if (!manager.audioSource) return;
			const vol = manager.audioSource.volume;
			const muted = manager.audioSource.muted;
			manager.showOsd(
				manager.typeMic,
				vol,
				muted,
				muted ? "󰍭" : "󰍬"
			);
		}
		
		function onMutedChanged() {
			if (!manager.audioSource) return;
			const vol = manager.audioSource.volume;
			const muted = manager.audioSource.muted;
			manager.showOsd(
				manager.typeMic,
				vol,
				muted,
				muted ? "󰍭" : "󰍬"
			);
		}
	}

	// Brightness monitoring
	property real brightnessMax: 1.0
	property real brightnessCurrent: 0.0

	// Read max brightness once at startup
	Process {
		id: maxBrightnessReader
		running: true
		command: ["cat", "/sys/class/backlight/amdgpu_bl1/max_brightness"]
		stdout: SplitParser {
			onRead: data => {
				const maxVal = parseInt(data.trim());
				if (!isNaN(maxVal) && maxVal > 0) {
					manager.brightnessMax = maxVal;
				}
				maxBrightnessReader.running = false;
			}
		}
	}

	// Watch for brightness changes
	Process {
		id: brightnessWatcher
		running: true
		command: ["sh", "-c", 
			"inotifywait -m -q -e modify /sys/class/backlight/amdgpu_bl1/brightness 2>/dev/null | " +
			"while read path event file; do cat /sys/class/backlight/amdgpu_bl1/actual_brightness; done"
		]
		
		stdout: SplitParser {
			onRead: data => {
				const rawValue = parseInt(data.trim());
				if (!isNaN(rawValue) && manager.brightnessMax > 0) {
					const brightness = rawValue / manager.brightnessMax;
					manager.brightnessCurrent = brightness;
					manager.showOsd(
						manager.typeBrightness,
						brightness,
						false,
						manager.getBrightnessIcon(brightness)
					);
				}
			}
		}
	}
}
