import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

ApplicationWindow {
    id: adjustmentWindow
    width: 1600
    height: 1000
    title: "胶片调整 - Revela"
    visible: true

    property var parameterController: ({
            exposure: 0.0,
            contrast: 1.0,
            saturation: 1.0,
            shadows: 0,
            highlights: 0,
            clarity: 0,
            resetAllParameters: function () {
                exposure = 0.0;
                contrast = 1.0;
                saturation = 1.0;
                shadows = 0;
                highlights = 0;
                clarity = 0;
            }
        })

    property var imageController: ({
            imageLoaded: false,
            imageWidth: 1920,
            imageHeight: 1080,
            currentFrameIndex: 0
        })

    // 主布局
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧工具栏
        Rectangle {
            Layout.preferredWidth: 80
            Layout.fillHeight: true
            color: "#2c3e50"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 20

                // Logo
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    width: 50
                    height: 50
                    color: "#e74c3c"
                    radius: 25

                    Text {
                        anchors.centerIn: parent
                        text: "R"
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#34495e"
                }

                // 工具按钮
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter
                        text: "🎨"
                        font.pixelSize: 20
                        checkable: true
                        checked: true

                        background: Rectangle {
                            color: parent.checked ? "#3498db" : (parent.hovered ? "#34495e" : "transparent")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: parent.font.pixelSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter
                        text: "📊"
                        font.pixelSize: 20
                        checkable: true

                        background: Rectangle {
                            color: parent.checked ? "#3498db" : (parent.hovered ? "#34495e" : "transparent")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: parent.font.pixelSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        Layout.alignment: Qt.AlignHCenter
                        text: "⚙️"
                        font.pixelSize: 20
                        checkable: true

                        background: Rectangle {
                            color: parent.checked ? "#3498db" : (parent.hovered ? "#34495e" : "transparent")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: parent.font.pixelSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                // 底部按钮
                Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter
                    text: "🏠"
                    font.pixelSize: 20
                    onClicked: {
                        adjustmentWindow.close();
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#c0392b" : (parent.hovered ? "#e74c3c" : "transparent")
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: parent.font.pixelSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // 中央图像预览区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1a1a1a"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 顶部工具栏
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#2c3e50"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "胶片调整"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // 视图控制
                        RowLayout {
                            spacing: 10

                            Button {
                                text: "适应窗口"
                                height: 35
                                font.pixelSize: 12

                                background: Rectangle {
                                    color: parent.pressed ? "#34495e" : (parent.hovered ? "#3498db" : "transparent")
                                    border.color: "#3498db"
                                    border.width: 1
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: parent.font.pixelSize
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Button {
                                text: "1:1"
                                height: 35
                                font.pixelSize: 12

                                background: Rectangle {
                                    color: parent.pressed ? "#34495e" : (parent.hovered ? "#3498db" : "transparent")
                                    border.color: "#3498db"
                                    border.width: 1
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: parent.font.pixelSize
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Text {
                                text: "100%"
                                color: "#bdc3c7"
                                font.pixelSize: 12
                            }
                        }
                    }
                }

                // 图像预览区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1a1a1a"

                    // 集成LiveImageViewer组件
                    Loader {
                        id: imageViewerLoader
                        anchors.fill: parent
                        source: "components/ImageViewer.qml"
                    }

                    // 如果没有图像，显示占位符
                    Rectangle {
                        anchors.centerIn: parent
                        width: 400
                        height: 300
                        visible: !imageViewerLoader.item || !imageController.imageLoaded
                        color: "#2c3e50"
                        radius: 10
                        border.color: "#34495e"
                        border.width: 2

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "🎞️"
                                font.pixelSize: 64
                                color: "#7f8c8d"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "请先加载胶片图像"
                                font.pixelSize: 18
                                color: "#bdc3c7"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "从文件管理中选择胶片文件夹"
                                font.pixelSize: 14
                                color: "#7f8c8d"
                            }
                        }
                    }
                }

                // 底部信息栏
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#34495e"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            text: imageController.imageLoaded ? `图像: ${imageController.imageWidth} × ${imageController.imageHeight}` : "无图像"
                            color: "#bdc3c7"
                            font.pixelSize: 12
                        }

                        Rectangle {
                            width: 1
                            height: 20
                            color: "#7f8c8d"
                        }

                        Text {
                            text: imageController.imageLoaded ? `帧: ${imageController.currentFrameIndex + 1}` : "帧: -"
                            color: "#bdc3c7"
                            font.pixelSize: 12
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "实时预览已启用"
                            color: "#27ae60"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // 右侧调整面板
        Rectangle {
            Layout.preferredWidth: 380
            Layout.fillHeight: true
            color: "#ecf0f1"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 面板标题
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#34495e"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "调整面板"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "重置全部"
                            height: 30
                            font.pixelSize: 11
                            onClicked: {
                                parameterController.resetAllParameters();
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#c0392b" : (parent.hovered ? "#e74c3c" : "transparent")
                                border.color: "#e74c3c"
                                border.width: 1
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: parent.font.pixelSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // 滚动区域
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // 基础调整组
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 20
                            height: basicAdjustments.height + 40
                            color: "white"
                            radius: 10
                            border.color: "#bdc3c7"
                            border.width: 1

                            ColumnLayout {
                                id: basicAdjustments
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                // 组标题
                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 4
                                        height: 20
                                        color: "#3498db"
                                        radius: 2
                                    }

                                    Text {
                                        text: "基础调整"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }
                                }

                                // 曝光调整
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    RowLayout {
                                        Text {
                                            text: "曝光"
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            Layout.minimumWidth: 80
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: parameterController.exposure.toFixed(1) + " EV"
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        Layout.fillWidth: true
                                        from: -2.0
                                        to: 2.0
                                        value: parameterController.exposure
                                        stepSize: 0.1
                                        onValueChanged: parameterController.exposure = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 200
                                            implicitHeight: 4
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 2
                                            color: "#e9ecef"

                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#3498db"
                                                radius: 2
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: parent.pressed ? "#2980b9" : "#3498db"
                                            border.color: "white"
                                            border.width: 2
                                        }
                                    }
                                }

                                // 对比度调整
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    RowLayout {
                                        Text {
                                            text: "对比度"
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            Layout.minimumWidth: 80
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: parameterController.contrast.toFixed(2)
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        Layout.fillWidth: true
                                        from: 0.5
                                        to: 2.0
                                        value: parameterController.contrast
                                        stepSize: 0.05
                                        onValueChanged: parameterController.contrast = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 200
                                            implicitHeight: 4
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 2
                                            color: "#e9ecef"

                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#27ae60"
                                                radius: 2
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: parent.pressed ? "#229954" : "#27ae60"
                                            border.color: "white"
                                            border.width: 2
                                        }
                                    }
                                }

                                // 饱和度调整
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    RowLayout {
                                        Text {
                                            text: "饱和度"
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            Layout.minimumWidth: 80
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: parameterController.saturation.toFixed(2)
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        Layout.fillWidth: true
                                        from: 0.0
                                        to: 2.0
                                        value: parameterController.saturation
                                        stepSize: 0.05
                                        onValueChanged: parameterController.saturation = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 200
                                            implicitHeight: 4
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 2
                                            color: "#e9ecef"

                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#e74c3c"
                                                radius: 2
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: parent.pressed ? "#c0392b" : "#e74c3c"
                                            border.color: "white"
                                            border.width: 2
                                        }
                                    }
                                }
                            }
                        }

                        // 高级调整组
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 20
                            height: advancedAdjustments.height + 40
                            color: "white"
                            radius: 10
                            border.color: "#bdc3c7"
                            border.width: 1

                            ColumnLayout {
                                id: advancedAdjustments
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                // 组标题
                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 4
                                        height: 20
                                        color: "#f39c12"
                                        radius: 2
                                    }

                                    Text {
                                        text: "高级调整"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }
                                }

                                // 阴影调整
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    RowLayout {
                                        Text {
                                            text: "阴影"
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            Layout.minimumWidth: 80
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: parameterController.shadows.toString()
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        Layout.fillWidth: true
                                        from: -100
                                        to: 100
                                        value: parameterController.shadows
                                        stepSize: 5
                                        onValueChanged: parameterController.shadows = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 200
                                            implicitHeight: 4
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 2
                                            color: "#e9ecef"

                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#6c757d"
                                                radius: 2
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: parent.pressed ? "#495057" : "#6c757d"
                                            border.color: "white"
                                            border.width: 2
                                        }
                                    }
                                }

                                // 高光调整
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    RowLayout {
                                        Text {
                                            text: "高光"
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            Layout.minimumWidth: 80
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: parameterController.highlights.toString()
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        Layout.fillWidth: true
                                        from: -100
                                        to: 100
                                        value: parameterController.highlights
                                        stepSize: 5
                                        onValueChanged: parameterController.highlights = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 200
                                            implicitHeight: 4
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 2
                                            color: "#e9ecef"

                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#ffc107"
                                                radius: 2
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: parent.pressed ? "#e0a800" : "#ffc107"
                                            border.color: "white"
                                            border.width: 2
                                        }
                                    }
                                }

                                // 清晰度调整
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    RowLayout {
                                        Text {
                                            text: "清晰度"
                                            font.pixelSize: 14
                                            color: "#2c3e50"
                                            Layout.minimumWidth: 80
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: parameterController.clarity.toString()
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        Layout.fillWidth: true
                                        from: -100
                                        to: 100
                                        value: parameterController.clarity
                                        stepSize: 5
                                        onValueChanged: parameterController.clarity = value

                                        background: Rectangle {
                                            x: parent.leftPadding
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 200
                                            implicitHeight: 4
                                            width: parent.availableWidth
                                            height: implicitHeight
                                            radius: 2
                                            color: "#e9ecef"

                                            Rectangle {
                                                width: parent.parent.visualPosition * parent.width
                                                height: parent.height
                                                color: "#17a2b8"
                                                radius: 2
                                            }
                                        }

                                        handle: Rectangle {
                                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            radius: 10
                                            color: parent.pressed ? "#138496" : "#17a2b8"
                                            border.color: "white"
                                            border.width: 2
                                        }
                                    }
                                }
                            }
                        }

                        // 操作和导出组
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 20
                            height: operationsGroup.height + 40
                            color: "white"
                            radius: 10
                            border.color: "#bdc3c7"
                            border.width: 1

                            ColumnLayout {
                                id: operationsGroup
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                // 组标题
                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 4
                                        height: 20
                                        color: "#9b59b6"
                                        radius: 2
                                    }

                                    Text {
                                        text: "操作和导出"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }
                                }

                                // 预设管理
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Button {
                                        Layout.fillWidth: true
                                        text: "保存预设"
                                        height: 40

                                        background: Rectangle {
                                            color: parent.pressed ? "#8e44ad" : (parent.hovered ? "#9b59b6" : "#ecf0f1")
                                            border.color: "#9b59b6"
                                            border.width: 1
                                            radius: 5
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: parent.hovered ? "white" : "#2c3e50"
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Button {
                                        Layout.fillWidth: true
                                        text: "加载预设"
                                        height: 40

                                        background: Rectangle {
                                            color: parent.pressed ? "#8e44ad" : (parent.hovered ? "#9b59b6" : "#ecf0f1")
                                            border.color: "#9b59b6"
                                            border.width: 1
                                            radius: 5
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: parent.hovered ? "white" : "#2c3e50"
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                // 导出选项
                                Button {
                                    Layout.fillWidth: true
                                    text: "批量导出"
                                    height: 45

                                    background: Rectangle {
                                        color: parent.pressed ? "#229954" : (parent.hovered ? "#27ae60" : "#ecf0f1")
                                        border.color: "#27ae60"
                                        border.width: 1
                                        radius: 5
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.hovered ? "white" : "#2c3e50"
                                        font.pixelSize: 14
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        exportDialog.open();
                                    }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: "单张导出"
                                    height: 40

                                    background: Rectangle {
                                        color: parent.pressed ? "#d68910" : (parent.hovered ? "#f39c12" : "#ecf0f1")
                                        border.color: "#f39c12"
                                        border.width: 1
                                        radius: 5
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.hovered ? "white" : "#2c3e50"
                                        font.pixelSize: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    // 导出对话框
    Loader {
        id: exportDialog
        source: "components/ExportDialog.qml"
        active: false

        function open() {
            active = true;
            if (item) {
                item.open();
            }
        }
    }
}
