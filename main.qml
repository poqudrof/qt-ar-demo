import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtMultimedia 5.5
import Qt.labs.settings 1.0
import Qt3D.Core 2.0
import "qrc:/thymio-ar"
//import "qrc:/thymio-vpl2" as VPL2
import QtSensors 5.0

import ExperimentFilter 1.0
import MarkerModel 1.0

ApplicationWindow {
	id: window
	title: qsTr("Thymio AR demo")
	visible: true
	width: 960
	height: 600

	header: ToolBar {
		RowLayout {
			anchors.fill: parent

			Repeater {
				model: (camera.cameraStatus === Camera.ActiveStatus && vision) ? vision.landmarks : 0
				delegate: ToolButton {
					contentItem: Item {
						Image {
							source: modelData.icon
							x: parent.height * 0.1
							height: parent.height * 0.8
							width: parent.height * 0.8
						}
						ProgressBar {
							width: parent.width
							to: 0.5
							value: modelData.confidence
							anchors.bottom: parent.bottom
						}
					}
				}
			}

			Item {
				 Layout.fillWidth: true
			}

            // Button to start and stop the monitoring. For more information check markermodel.cpp
            ToolButton {
                property bool active: false
                id: monitoringToggle
                contentItem: Image {
                    anchors.centerIn:  parent
                    source: monitoringToggle.active ? "icons/ic_monitoring_on_24px.svg"
                                                          : "icons/ic_monitoring_off_24px.svg"
                }
                onClicked: {
                    active = !active
                    active ? markermodel.startMonitoring() : markermodel.stopMonitoring()
                }
            }

            // Button to activate and deactivate the experiment filter.
            ToolButton {
                property bool active: false
                id: experimentFilterToggle
                contentItem: Image {
                    anchors.centerIn:  parent
                    source: experimentFilterToggle.active ? "icons/ic_experiment_filter_on_24px.svg"
                                                          : "icons/ic_experiment_filter_off_24px.svg"
                }
                onClicked: active = !active
            }

            // Button to hide and unhide the lower left part of the image.
            ToolButton {
                property bool active: false
                id: hideLowerLeftToggle
                contentItem:  Image {
                    anchors.centerIn:  parent
                    source : hideLowerLeftToggle.active ? "icons/ic_hide_lower_left_on_24px.svg"
                                                        : "icons/ic_hide_lower_left_off_24px.svg"
                }
                onClicked: {
                    active = !active
                    experimentFilter.setHideFlag(2, active)
                }
            }

            // Button to hide and unhide the upper left part of the image.
            ToolButton {
                property bool active: false
                id: hideUpperLeftToggle
                contentItem:  Image {
                    anchors.centerIn:  parent
                    source : hideUpperLeftToggle.active ? "icons/ic_hide_upper_left_on_24px.svg"
                                                        : "icons/ic_hide_upper_left_off_24px.svg"
                }
                onClicked: {
                    active = !active
                    experimentFilter.setHideFlag(0, active)
                }
            }

            // Button to hide and unhide the upper right part of the image.
            ToolButton {
                property bool active: false
                id: hideUpperRightToggle
                contentItem:  Image {
                    anchors.centerIn:  parent
                    source : hideUpperRightToggle.active ? "icons/ic_hide_upper_right_on_24px.svg"
                                                        : "icons/ic_hide_upper_right_off_24px.svg"
                }
                onClicked: {
                    active = !active
                    experimentFilter.setHideFlag(1, active)
                }
            }

            // Button to hide and unhide the lower right part of the image.
            ToolButton {
                property bool active: false
                id: hideLowerRightToggle
                contentItem:  Image {
                    anchors.centerIn:  parent
                    source : hideLowerRightToggle.active ? "icons/ic_hide_lower_right_on_24px.svg"
                                                        : "icons/ic_hide_lower_right_off_24px.svg"
                }
                onClicked: {
                    active = !active
                    experimentFilter.setHideFlag(3, active)
                }
            }

            // Slider to control the noise magnitude of the experiment filter.
            Slider {
                id: saltyNoiseSlider
                onValueChanged: experimentFilter.setNoiseMagnitude(value)

            }

			ToolButton {
				contentItem: Image {
					anchors.centerIn: parent
					source: "icons/ic_filter_center_focus_black_24px.svg"
				}
				onClicked: vision.calibrationRunning = true;
			}
		}
    }

    Camera {
		id: camera

        // For the logitec c920 webcam the following viewfinder resolutions work:
        //  "640x480" / "1280x720" / "1600X986" / "1920x1080" */
        viewfinder.resolution: "1280x720"

        captureMode: Camera.CaptureViewfinder
		cameraState: Camera.LoadedState

        //deviceId: QtMultimedia.availableCameras[1].deviceId // hack to use second camera on laptop
	}

    // HACK
    Timer {
        running: true
        interval: 3000
        onTriggered: {
            camera.stop();
            camera.start();
        }
    }

    // Timer to update model.
    Timer {
        running: true
        interval: 30
        onTriggered: markermodel.updateModel()
        repeat: true
    }

	Vision {
		id: vision
        active: true

        property string cameraName : "cam"

        landmarks: [
			Landmark {
				id: worldCenterLandmark
                name: "world"
				fileName: ":/assets/markers/worldcenter.xml"
				property string icon: "assets/markers/worldcenter_tracker.png"
            },
			Landmark {
				id: orangeHouseLandmark
                name: "orangeHouse"
                fileName: ":/assets/markers/orangehouse.xml"
				property string icon: "assets/markers/orangehouse_tracker.png"
            },
            Landmark {
                id: adaHouseLandmark
                name: "adaHouse"
                fileName: ":/assets/markers/adahouse.xml"
                property string icon: "assets/markers/adahouse_tracker.png"
            }
		]
	}

	property rect cameraRect
	VideoOutput {
		id: videoOutput
		anchors.fill: parent
        //focus : visible
		source: camera
        filters: [experimentFilter, vision]
		fillMode: VideoOutput.PreserveAspectCrop
		onContentRectChanged: cameraRect = mapNormalizedRectToItem(Qt.rect(0, 0, 1, 1));
	}

	Component.onCompleted: {
        camera.start();
	}

	Component.onDestruction: {
		camera.stop();
	}

    // For more information check markermodel.cpp
    MarkerModel {
        id: markermodel
    }

    // For more information check out experimentfilter.cpp
    ExperimentFilter {
        id: experimentFilter
        active: experimentFilterToggle.active
    }

    Item {

        Connections {
            target: worldCenterLandmark
            onChanged: {
                markermodel.updateLinkNow(worldCenterLandmark.name, vision.cameraName, worldCenterLandmark.pose, worldCenterLandmark.confidence)
            }
        }

        Connections {
            target: orangeHouseLandmark
            onChanged: {
                markermodel.updateLinkNow(orangeHouseLandmark.name, vision.cameraName, orangeHouseLandmark.pose, orangeHouseLandmark.confidence)
            }
        }

        Connections {
            target: adaHouseLandmark
            onChanged: {
                markermodel.updateLinkNow(adaHouseLandmark.name, vision.cameraName, adaHouseLandmark.pose, adaHouseLandmark.confidence)
            }
        }        
    }

	Scene3d {
		anchors.fill: parent

        camera: markermodel.world2cam
        lens: vision.lens

        Entity {
           OrangeHouse {
                id: orangeHouse
                enabled: markermodel.world2orangeHouseActive
                t: markermodel.world2orangeHouse
            }

           AdaHouse {
               id: adaHouse
               enabled: markermodel.world2adaHouseActive
               t: markermodel.world2adaHouse
           }
        }

        WorldCenter {
			id: worldCenter
            enabled: markermodel.world2camActive
        }
    }

	// calibration rectangle
	Rectangle {
		visible: vision.calibrationRunning

		x: cameraRect.x  + (vision.calibrationRight ? cameraRect.width - cameraRect.height : 0)
		y: cameraRect.y
		height: cameraRect.height
		width: cameraRect.height
		opacity: 0.5

		transform: [
			Scale {
				xScale: 1 / cameraRect.height
				yScale: 1 / cameraRect.height
			},
			Matrix4x4 {
				matrix: vision.calibrationTransform
			},
			Scale {
				xScale: cameraRect.height
				yScale: cameraRect.height
			}
		]
	}

	// calibration progress bar
	ProgressBar {
		visible: vision.calibrationRunning

		width: parent.width / 3
		anchors.bottom: parent.bottom
		anchors.bottomMargin: parent.height / 3
		anchors.horizontalCenter: parent.horizontalCenter
		value: vision.calibrationProgress
	}
}
