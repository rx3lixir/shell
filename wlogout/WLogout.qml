import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

QtObject {
	id: root
	property color backgroundColor: "#e60c0c0c"
	property color buttonColor: "#1e1e1e"
	property color buttonHoverColor: "#3700b3"
	default property list<LogoutButton> buttons
	
	// Add a visible property that we can control
	property bool visible: false
	
	onVisibleChanged: {
		console.log("WLogout visible changed to:", visible)
	}
	
	// Create windows for each screen
	property var windows: {
		const wins = []
		for (let i = 0; i < Quickshell.screens.length; i++) {
			wins.push(windowComponent.createObject(root, { screen: Quickshell.screens[i] }))
		}
		return wins
	}
	
	property Component windowComponent: Component {
		LazyLoader {
			id: loader
			required property var screen
			
			active: root.visible
			
			onActiveChanged: {
				console.log("LazyLoader active changed to:", active, "for screen:", screen?.name)
			}
			
			PanelWindow {
				id: w

				screen: loader.screen

				exclusionMode: ExclusionMode.Ignore
				WlrLayershell.layer: WlrLayer.Overlay
				WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

				color: "transparent"

				contentItem {
					focus: true
					Keys.onPressed: event => {
						if (event.key == Qt.Key_Escape) {
							root.visible = false;
						} else {
							for (let i = 0; i < root.buttons.length; i++) {
								let button = root.buttons[i];
								if (event.key == button.keybind) button.exec();
							}
						}
					}
				}

				anchors {
					top: true
					left: true
					bottom: true
					right: true
				}

				Rectangle {
					color: root.backgroundColor;
					anchors.fill: parent

					MouseArea {
						anchors.fill: parent
						onClicked: root.visible = false

						GridLayout {
							anchors.centerIn: parent

							width: parent.width * 0.75
							height: parent.height * 0.75

							columns: 3
							columnSpacing: 0
							rowSpacing: 0

							Repeater {
								model: root.buttons
								delegate: Rectangle {
									required property LogoutButton modelData;

									Layout.fillWidth: true
									Layout.fillHeight: true

									color: ma.containsMouse ? root.buttonHoverColor : root.buttonColor
									border.color: "black"
									border.width: ma.containsMouse ? 0 : 1

									MouseArea {
										id: ma
										anchors.fill: parent
										hoverEnabled: true
										onClicked: modelData.exec()
									}

									Text {
										id: icon
										anchors.centerIn: parent
										text: modelData.nerdIcon
										font.family: "Ubuntu Nerd Font Propo"
										font.pointSize: 80
										color: "white"
									}

									Text {
										anchors {
											top: icon.bottom
											topMargin: 20
											horizontalCenter: parent.horizontalCenter
										}

										text: modelData.text
										font.pointSize: 20
										color: "white"
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
