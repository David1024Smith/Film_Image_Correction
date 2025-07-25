import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: parameterControlWindow
    width: 1400
    height: 900
    title: "参数控制 - Revela"
    visible: true

    property var parameterController: ({
        exposure: 0.0,
        contrast: 1.0,
        saturation: 1.0,
        temperature: 5500,
        tint: 0,
        setExposure: function(value) { exposure = value },
        setContrast: function(value) { contrast = value },
        setSaturation: function(value) { saturation = value },
        setTemperature: function(value) { temperature = value },
        setTint: function(value) { tint = value },
        resetColorParameters: function() {
            exposure = 0.0;
            contrast = 1.0;
            saturation = 1.0;
            temperature = 5500;
            tint = 0;
        }
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
                        text: "🎛️"
                        font.pixelSize: 20
                        checkable: true
                        checked: true
                        
                        background: Rectangle {
                            color: parent.checked ? "#27ae60" : (parent.hovered ? "#34495e" : "transparent")
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
                            color: parent.checked ? "#27ae60" : (parent.hovered ? "#34495e" : "transparent")
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

                Item { Layout.fillHeight: true }

                // 底部按钮
                Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    Layout.alignment: Qt.AlignHCenter
                    text: "🏠"
                    font.pixelSize: 20
                    onClicked: {
                        parameterControlWindow.close()
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

        // 左侧参数控制面板
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
                            text: "参数控制面板"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "重置全部"
                            height: 30
                            font.pixelSize: 11
                            onClicked: {
                                parameterController.resetColorParameters()
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

                        // 基础参数组
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 20
                            height: basicParameters.height + 40
                            color: "white"
                            radius: 10
                            border.color: "#bdc3c7"
                            border.width: 1

                            ColumnLayout {
                                id: basicParameters
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 20

                                // 组标题
                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 4
                                        height: 20
                                        color: "#27ae60"
                                        radius: 2
                                    }

                                    Text {
                                        text: "基础参数"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#2c3e50"
                                    }

                                    Item { Layout.fillWidth: true }
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
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: parameterController.exposure.toFixed(1) + " EV"
                                            font.family: "monospace"
                                            font.pixelSize: 12
                                            color: "#7f8c8d"
                                            Layout.minimumWidth: 70
                                        }
                                    }

                                    Slider {
                                        id: exposureSlider
                                        Layout.fillWidth: true
                                        from: -3.0
                                        to: 3.0
                                        value: parameterController.exposure
                                        stepSize: 0.1
                                        onValueChanged: parameterController.setExposure(value)
                                        
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
                                        Item { Layout.fillWidth: true }
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
                                        onValueChanged: parameterController.setContrast(value)
                                        
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
                                        Item { Layout.fillWidth: true }
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
                                        onValueChanged: parameterController.setSaturation(value)
                                        
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

                            // 颜色校正组
                            GroupBox {
                                Layout.fillWidth: true
                                title: "颜色校正"
                                
                                background: Rectangle {
                                    color: "#404040"
                                    radius: 6
                                    border.color: "#666"
                                    border.width: 1
                                }
                                
                                label: Label {
                                    text: parent.title
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pointSize: 12
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 15

                                    // 色温
                                    RowLayout {
                                        Layout.fillWidth: true
                                        
                                        Label {
                                            text: "色温:"
                                            color: "#ffffff"
                                            Layout.preferredWidth: 60
                                        }
                                        
                                        Slider {
                                            id: temperatureSlider
                                            Layout.fillWidth: true
                                            from: 2000
                                            to: 10000
                                            value: (typeof parameterController !== 'undefined') ? parameterController.temperature : 5500
                                            stepSize: 100
                                            
                                            onValueChanged: {
                                                if (typeof parameterController !== 'undefined') {
                                                    parameterController.setTemperature(value)
                                                }
                                            }
                                            
                                            background: Rectangle {
                                                x: temperatureSlider.leftPadding
                                                y: temperatureSlider.topPadding + temperatureSlider.availableHeight / 2 - height / 2
                                                implicitWidth: 200
                                                implicitHeight: 4
                                                width: temperatureSlider.availableWidth
                                                height: implicitHeight
                                                radius: 2
                                                color: "#555"
                                            }
                                            
                                            handle: Rectangle {
                                                x: temperatureSlider.leftPadding + temperatureSlider.visualPosition * (temperatureSlider.availableWidth - width)
                                                y: temperatureSlider.topPadding + temperatureSlider.availableHeight / 2 - height / 2
                                                implicitWidth: 20
                                                implicitHeight: 20
                                                radius: 10
                                                color: temperatureSlider.pressed ? "#ff8000" : "#ff9900"
                                                border.color: "#ffffff"
                                                border.width: 1
                                            }
                                        }
                                        
                                        Label {
                                            text: Math.round(temperatureSlider.value) + "K"
                                            color: "#cccccc"
                                            Layout.preferredWidth: 50
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    // 色调
                                    RowLayout {
                                        Layout.fillWidth: true
                                        
                                        Label {
                                            text: "色调:"
                                            color: "#ffffff"
                                            Layout.preferredWidth: 60
                                        }
                                        
                                        Slider {
                                            id: tintSlider
                                            Layout.fillWidth: true
                                            from: -100
                                            to: 100
                                            value: (typeof parameterController !== 'undefined') ? parameterController.tint : 0
                                            stepSize: 5
                                            
                                            onValueChanged: {
                                                if (typeof parameterController !== 'undefined') {
                                                    parameterController.setTint(value)
                                                }
                                            }
                                            
                                            background: Rectangle {
                                                x: tintSlider.leftPadding
                                                y: tintSlider.topPadding + tintSlider.availableHeight / 2 - height / 2
                                                implicitWidth: 200
                                                implicitHeight: 4
                                                width: tintSlider.availableWidth
                                                height: implicitHeight
                                                radius: 2
                                                color: "#555"
                                            }
                                            
                                            handle: Rectangle {
                                                x: tintSlider.leftPadding + tintSlider.visualPosition * (tintSlider.availableWidth - width)
                                                y: tintSlider.topPadding + tintSlider.availableHeight / 2 - height / 2
                                                implicitWidth: 20
                                                implicitHeight: 20
                                                radius: 10
                                                color: tintSlider.pressed ? "#ff00ff" : "#ff44ff"
                                                border.color: "#ffffff"
                                                border.width: 1
                                            }
                                        }
                                        
                                        Label {
                                            text: Math.round(tintSlider.value).toString()
                                            color: "#cccccc"
                                            Layout.preferredWidth: 40
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }
                            }

                            // 操作按钮
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Button {
                                    text: "重置"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#666" : "#777"
                                        radius: 6
                                        border.color: "#999"
                                        border.width: 1
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: {
                                        if (typeof parameterController !== 'undefined') {
                                            parameterController.resetColorParameters()
                                        }
                                    }
                                }

                                Button {
                                    text: "预设"
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    
                                    background: Rectangle {
                                        color: parent.pressed ? "#006600" : "#008800"
                                        radius: 6
                                        border.color: "#00aa00"
                                        border.width: 1
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: {
                                        // 打开预设对话框
                                        presetDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }

                // 右侧图像预览区域
                Rectangle {
                    SplitView.fillWidth: true
                    color: "#333333"
                    radius: 8
                    border.color: "#555"
                    border.width: 1

                    // 使用现有的ImageViewer组件
                    Loader {
                        id: imageViewer
                        anchors.fill: parent
                        anchors.margins: 10
                        source: "components/ImageViewer.qml"
                    }
                }
            }
        }
    }

    // 预设对话框
    Loader {
        id: presetDialog
        source: "components/PresetDialog.qml"
        active: false
        
        function open() {
            active = true
            if (item) {
                item.open()
            }
        }
    }

    // 连接控制器信号
    Connections {
        target: parameterController
        function onColorParametersChanged() {
            // 参数变化时更新界面
        }
    }

    // 初始化
    Component.onCompleted: {
        if (typeof mainController !== 'undefined') {
            mainController.initialize()
        }
    }
}