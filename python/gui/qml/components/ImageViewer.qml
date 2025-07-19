import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: imageViewer
    color: "#2b2b2b"
    border.color: "#555"
    border.width: 1

    // 图像显示区域
    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: 2
        
        contentWidth: imageContainer.width
        contentHeight: imageContainer.height
        
        // 限制滚动范围
        boundsBehavior: Flickable.StopAtBounds
        
        // 缩放和平移手势支持
        PinchArea {
            width: Math.max(flickable.contentWidth, flickable.width)
            height: Math.max(flickable.contentHeight, flickable.height)

            property real initialZoom: 1.0

            onPinchStarted: {
                initialZoom = imageController.zoomLevel
            }

            onPinchUpdated: {
                var newZoom = initialZoom * pinch.scale
                imageController.setZoomLevel(newZoom)
            }

            // 图像容器
            Item {
                id: imageContainer
                width: imageController.imageLoaded ? 
                       imageController.imageWidth * imageController.zoomLevel : 
                       flickable.width
                height: imageController.imageLoaded ? 
                        imageController.imageHeight * imageController.zoomLevel : 
                        flickable.height

                // 实际图像显示
                Rectangle {
                    id: imagePlaceholder
                    anchors.centerIn: parent
                    width: imageController.imageLoaded ? 
                           imageController.imageWidth * imageController.zoomLevel : 
                           400
                    height: imageController.imageLoaded ? 
                            imageController.imageHeight * imageController.zoomLevel : 
                            300
                    color: imageController.imageLoaded ? "transparent" : "#404040"
                    border.color: "#666"
                    border.width: imageController.imageLoaded ? 0 : 1

                    // 实际图像显示
                    Image {
                        id: actualImage
                        anchors.fill: parent
                        source: imageController.currentImagePath
                        fillMode: Image.PreserveAspectFit
                        visible: imageController.imageLoaded
                        asynchronous: true
                        cache: false
                        
                        // 图像加载状态处理
                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("图像加载失败:", source)
                            } else if (status === Image.Ready) {
                                console.log("图像加载成功:", source)
                            }
                        }
                    }

                    // 占位符内容
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: !imageController.imageLoaded
                        spacing: 20

                        Rectangle {
                            width: 64
                            height: 64
                            color: "#555"
                            radius: 8
                            Layout.alignment: Qt.AlignHCenter

                            Label {
                                anchors.centerIn: parent
                                text: "🖼"
                                font.pointSize: 24
                                color: "#999"
                            }
                        }

                        Label {
                            text: projectController.rollLoaded ? 
                                  "点击左侧帧列表\n选择要预览的图像" : 
                                  "请先加载胶卷\n然后选择帧进行预览"
                            color: "#999"
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // 图像信息叠加层
                    Rectangle {
                        visible: imageController.imageLoaded
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 10
                        width: infoColumn.width + 20
                        height: infoColumn.height + 20
                        color: "#80000000"
                        radius: 4

                        ColumnLayout {
                            id: infoColumn
                            anchors.centerIn: parent
                            spacing: 4

                            Label {
                                text: `帧 ${imageController.currentFrameIndex + 1}`
                                color: "white"
                                font.bold: true
                                font.pointSize: 10
                            }

                            Label {
                                text: `${imageController.imageWidth} × ${imageController.imageHeight}`
                                color: "white"
                                font.pointSize: 9
                            }

                            Label {
                                text: `${Math.round(imageController.zoomLevel * 100)}%`
                                color: "white"
                                font.pointSize: 9
                            }
                        }
                    }
                }

                // 双击重置缩放
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        imageController.resetZoom()
                    }
                }
            }
        }
    }

    // 缩放控制工具栏
    Rectangle {
        id: zoomToolbar
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: toolbarRow.width + 20
        height: 40
        color: "#80000000"
        radius: 20
        visible: imageController.imageLoaded

        RowLayout {
            id: toolbarRow
            anchors.centerIn: parent
            spacing: 10

            // 缩小按钮
            Button {
                text: "−"
                width: 32
                height: 32
                font.pointSize: 16
                font.bold: true
                enabled: imageController.zoomLevel > imageController.minZoom
                onClicked: imageController.zoomOut()
                
                background: Rectangle {
                    color: parent.pressed ? "#444" : "#666"
                    radius: 16
                    border.color: "#888"
                    border.width: 1
                }
                
                contentItem: Label {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
            }

            // 缩放级别显示
            Label {
                text: `${Math.round(imageController.zoomLevel * 100)}%`
                color: "white"
                font.pointSize: 10
                font.bold: true
                Layout.minimumWidth: 50
                horizontalAlignment: Text.AlignHCenter
            }

            // 放大按钮
            Button {
                text: "+"
                width: 32
                height: 32
                font.pointSize: 14
                font.bold: true
                enabled: imageController.zoomLevel < imageController.maxZoom
                onClicked: imageController.zoomIn()
                
                background: Rectangle {
                    color: parent.pressed ? "#444" : "#666"
                    radius: 16
                    border.color: "#888"
                    border.width: 1
                }
                
                contentItem: Label {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
            }

            Rectangle {
                width: 1
                height: 24
                color: "#888"
            }

            // 适应窗口按钮
            Button {
                text: "适应"
                height: 32
                font.pointSize: 9
                onClicked: imageController.fitToWindow()
                
                background: Rectangle {
                    color: parent.pressed ? "#444" : "#666"
                    radius: 4
                    border.color: "#888"
                    border.width: 1
                }
                
                contentItem: Label {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
            }

            // 1:1 缩放按钮
            Button {
                text: "1:1"
                height: 32
                font.pointSize: 9
                onClicked: imageController.resetZoom()
                
                background: Rectangle {
                    color: parent.pressed ? "#444" : "#666"
                    radius: 4
                    border.color: "#888"
                    border.width: 1
                }
                
                contentItem: Label {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
            }
        }
    }

    // 滚轮缩放支持
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheel) {
            if (wheel.modifiers & Qt.ControlModifier) {
                var scaleFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                var newZoom = imageController.zoomLevel * scaleFactor
                imageController.setZoomLevel(newZoom)
                wheel.accepted = true
            }
        }
    }
} 