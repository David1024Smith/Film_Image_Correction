import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: liveImageViewer

    // 辅助函数
    function _hasActiveAdjustments() {
        return parameterController.exposure !== 0 || parameterController.contrast !== 1 || parameterController.saturation !== 1 || parameterController.temperature !== 0 || parameterController.tint !== 0;
    }

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
        boundsBehavior: Flickable.StopAtBounds

        // 缩放和平移手势支持
        PinchArea {
            property real initialZoom: 1

            width: Math.max(flickable.contentWidth, flickable.width)
            height: Math.max(flickable.contentHeight, flickable.height)
            onPinchStarted: {
                initialZoom = imageController.zoomLevel;
            }
            onPinchUpdated: {
                var newZoom = initialZoom * pinch.scale;
                imageController.setZoomLevel(newZoom);
            }

            // 图像容器
            Item {
                id: imageContainer

                width: imageController.imageLoaded ? imageController.imageWidth * imageController.zoomLevel : flickable.width
                height: imageController.imageLoaded ? imageController.imageHeight * imageController.zoomLevel : flickable.height

                // 实际图像显示区域
                Rectangle {
                    // 实时效果层 - 使用多层叠加模拟不同的参数调整

                    id: imagePlaceholder

                    anchors.centerIn: parent
                    width: imageController.imageLoaded ? imageController.imageWidth * imageController.zoomLevel : 400
                    height: imageController.imageLoaded ? imageController.imageHeight * imageController.zoomLevel : 300
                    color: imageController.imageLoaded ? "transparent" : "#404040"
                    border.color: "#666"
                    border.width: imageController.imageLoaded ? 0 : 1

                    // 基础图像
                    Image {
                        id: baseImage

                        anchors.fill: parent
                        source: imageController.currentImagePath
                        fillMode: Image.PreserveAspectFit
                        visible: imageController.imageLoaded
                        asynchronous: true
                        cache: false
                        onStatusChanged: {
                            console.log("[LiveImageViewer] 图像状态:", status, "源:", source);
                            if (status === Image.Ready) {
                                console.log("[LiveImageViewer] 图像加载成功，尺寸:", paintedWidth, "x", paintedHeight);
                                mainController.setStatus("图像显示就绪");
                            } else if (status === Image.Error) {
                                console.log("[LiveImageViewer] 图像加载失败:", source);
                                mainController.setStatus("图像加载失败");
                            } else if (status === Image.Loading) {
                                mainController.setStatus("正在加载图像...");
                            }
                        }
                    }

                    // 曝光调整层
                    Rectangle {
                        id: exposureOverlay

                        anchors.fill: baseImage
                        visible: imageController.imageLoaded && baseImage.status === Image.Ready && parameterController.exposure !== 0
                        color: parameterController.exposure > 0 ? "white" : "black"
                        opacity: Math.abs(parameterController.exposure) * 0.15 // 曝光强度
                        onVisibleChanged: {
                            if (visible)
                                console.log("[LiveImageViewer] 曝光调整:", parameterController.exposure);

                        }
                    }

                    // 对比度调整层
                    Rectangle {
                        id: contrastOverlay

                        anchors.fill: baseImage
                        visible: imageController.imageLoaded && baseImage.status === Image.Ready && parameterController.contrast !== 1
                        color: "#808080" // 中性灰
                        opacity: Math.abs(parameterController.contrast - 1) * 0.2
                        onVisibleChanged: {
                            if (visible)
                                console.log("[LiveImageViewer] 对比度调整:", parameterController.contrast);

                        }
                    }

                    // 色温调整层
                    Rectangle {
                        id: temperatureOverlay

                        anchors.fill: baseImage
                        visible: imageController.imageLoaded && baseImage.status === Image.Ready && parameterController.temperature !== 0
                        color: {
                            // 正值偏暖（黄色）
                            // 负值偏冷（蓝色）

                            var temp = parameterController.temperature;
                            if (temp > 0)
                                return Qt.rgba(1, 0.9, 0.7, Math.abs(temp) / 2000 * 0.3);
                            else
                                return Qt.rgba(0.7, 0.8, 1, Math.abs(temp) / 2000 * 0.3);
                        }
                        onVisibleChanged: {
                            if (visible)
                                console.log("[LiveImageViewer] 色温调整:", parameterController.temperature);

                        }
                    }

                    // 色调调整层
                    Rectangle {
                        id: tintOverlay

                        anchors.fill: baseImage
                        visible: imageController.imageLoaded && baseImage.status === Image.Ready && parameterController.tint !== 0
                        color: {
                            // 正值偏品红
                            // 负值偏绿

                            var tint = parameterController.tint;
                            if (tint > 0)
                                return Qt.rgba(1, 0.8, 1, Math.abs(tint) / 50 * 0.2);
                            else
                                return Qt.rgba(0.8, 1, 0.8, Math.abs(tint) / 50 * 0.2);
                        }
                        onVisibleChanged: {
                            if (visible)
                                console.log("[LiveImageViewer] 色调调整:", parameterController.tint);

                        }
                    }

                    // 饱和度调整层
                    Rectangle {
                        id: saturationOverlay

                        anchors.fill: baseImage
                        visible: imageController.imageLoaded && baseImage.status === Image.Ready && parameterController.saturation !== 1
                        color: "#808080" // 中性灰，用于去饱和
                        opacity: parameterController.saturation < 1 ? (1 - parameterController.saturation) * 0.8 : 0
                        onVisibleChanged: {
                            if (visible)
                                console.log("[LiveImageViewer] 饱和度调整:", parameterController.saturation);

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
                            text: projectController.rollLoaded ? "点击左侧帧列表\n选择要预览的图像" : "请先加载胶卷\n然后选择帧进行预览"
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

                    // 参数显示叠加层
                    Rectangle {
                        visible: imageController.imageLoaded && _hasActiveAdjustments()
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: paramColumn.width + 20
                        height: paramColumn.height + 20
                        color: "#80000000"
                        radius: 4

                        ColumnLayout {
                            id: paramColumn

                            anchors.centerIn: parent
                            spacing: 2

                            Label {
                                text: "实时调整"
                                color: "#00ff00"
                                font.bold: true
                                font.pointSize: 9
                            }

                            Label {
                                visible: parameterController.exposure !== 0
                                text: `曝光: ${parameterController.exposure.toFixed(1)} EV`
                                color: "white"
                                font.pointSize: 8
                            }

                            Label {
                                visible: parameterController.contrast !== 1
                                text: `对比度: ${parameterController.contrast.toFixed(2)}`
                                color: "white"
                                font.pointSize: 8
                            }

                            Label {
                                visible: parameterController.saturation !== 1
                                text: `饱和度: ${parameterController.saturation.toFixed(2)}`
                                color: "white"
                                font.pointSize: 8
                            }

                            Label {
                                visible: parameterController.temperature !== 0
                                text: `色温: ${parameterController.temperature.toFixed(0)}K`
                                color: "white"
                                font.pointSize: 8
                            }

                            Label {
                                visible: parameterController.tint !== 0
                                text: `色调: ${parameterController.tint.toFixed(0)}`
                                color: "white"
                                font.pointSize: 8
                            }

                        }

                    }

                }

                // 双击重置缩放
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        imageController.resetZoom();
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
                var scaleFactor = wheel.angleDelta.y > 0 ? 1.1 : 0.9;
                var newZoom = imageController.zoomLevel * scaleFactor;
                imageController.setZoomLevel(newZoom);
                wheel.accepted = true;
            }
        }
    }

}
