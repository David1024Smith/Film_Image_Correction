import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    Layout.preferredWidth: 280
    Layout.fillHeight: true
    color: "#000000"

    ScrollView {
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: 280
            spacing: 0

            // 1. Histogram - 直方图显示
            Rectangle {
                id: histogramSection
                Layout.fillWidth: true
                Layout.preferredHeight: histogramContent.implicitHeight + 32
                color: "#000000"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#404040"
                }

                ColumnLayout {
                    id: histogramContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: "Histogram"
                        color: "white"
                        font.pixelSize: 16
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 192
                        color: "#171717"
                        radius: 8
                    }
                }
            }

            // 2. LUT - 查找表控制
            Rectangle {
                id: lutSection
                Layout.fillWidth: true
                Layout.preferredHeight: lutContent.implicitHeight + 32
                color: "#000000"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#404040"
                }

                ColumnLayout {
                    id: lutContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "LUT"
                            color: "white"
                            font.pixelSize: 16
                        }

                        Item { Layout.fillWidth: true }

                        // LUT开关
                        Rectangle {
                            width: 36
                            height: 20
                            color: lutSwitch.checked ? "#FFD60A" : "#404040"
                            radius: 10

                            Rectangle {
                                id: lutSwitchHandle
                                width: 16
                                height: 16
                                radius: 8
                                color: "white"
                                x: lutSwitch.checked ? parent.width - width - 2 : 2
                                y: 2

                                Behavior on x {
                                    NumberAnimation { duration: 200 }
                                }
                            }

                            MouseArea {
                                id: lutSwitch
                                property bool checked: false
                                anchors.fill: parent
                                onClicked: checked = !checked
                            }
                        }
                    }

                    // 3x3 LUT网格预设
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 8
                        rowSpacing: 8

                        Repeater {
                            model: 8

                            Rectangle {
                                Layout.preferredWidth: (280 - 32 - 16) / 3
                                Layout.preferredHeight: (280 - 32 - 16) / 3
                                color: "#171717"
                                radius: 8
                                border.color: "transparent"
                                border.width: 1

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: 8
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: "https://image-resource.mastergo.com/146874632348805/146874632348807/af8c680adba3e36cca4fdd5b93f075ed.png"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.border.color = "#FFD60A"
                                    onExited: parent.border.color = "transparent"
                                    onClicked: {
                                        // LUT选择逻辑
                                        console.log("LUT " + index + " selected")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. Technical - 技术参数控制（可折叠）
            Rectangle {
                id: technicalSection
                property bool technicalCollapsed: false
                Layout.fillWidth: true
                Layout.preferredHeight: technicalCollapsed ? 64 : technicalContent.implicitHeight + 64
                color: "#000000"

                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#404040"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    // 标题行
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Technical"
                            color: "white"
                            font.pixelSize: 18
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: technicalSection.technicalCollapsed ? "▶" : "▼"
                            color: "white"
                            font.pixelSize: 12

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    technicalSection.technicalCollapsed = !technicalSection.technicalCollapsed
                                }
                            }
                        }
                    }

                    // Technical内容
                    ColumnLayout {
                        id: technicalContent
                        Layout.fillWidth: true
                        spacing: 24
                        visible: !technicalSection.technicalCollapsed
                        opacity: technicalSection.technicalCollapsed ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }

                        // Dmin/Dmax控制
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            // Dmin
                            ParameterControl {
                                id: dminControl
                                Layout.fillWidth: true
                                parameterName: "Dmin"
                                defaultValue: 0.00
                                minValue: 0
                                maxValue: 1
                                stepSize: 0.01
                            }

                            // Dmax
                            ParameterControl {
                                id: dmaxControl
                                Layout.fillWidth: true
                                parameterName: "Dmax"
                                defaultValue: 1.00
                                minValue: 0
                                maxValue: 1
                                stepSize: 0.01
                            }
                        }

                        // RGB Controls
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            Text {
                                text: "RGB Controls"
                                color: "white"
                                font.pixelSize: 16
                            }

                            ParameterControl {
                                id: redControl
                                Layout.fillWidth: true
                                parameterName: "Red"
                                defaultValue: 1.00
                                minValue: 0
                                maxValue: 2
                                stepSize: 0.01
                            }

                            ParameterControl {
                                id: greenControl
                                Layout.fillWidth: true
                                parameterName: "Green"
                                defaultValue: 0.82
                                minValue: 0
                                maxValue: 2
                                stepSize: 0.01
                            }

                            ParameterControl {
                                id: blueControl
                                Layout.fillWidth: true
                                parameterName: "Blue"
                                defaultValue: 0.35
                                minValue: 0
                                maxValue: 2
                                stepSize: 0.01
                            }
                        }

                        // Gray Level控制
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            Text {
                                text: "Gray"
                                color: "white"
                                font.pixelSize: 16
                            }

                            ParameterControl {
                                id: grayControl
                                Layout.fillWidth: true
                                parameterName: "Level"
                                defaultValue: 0.42
                                minValue: 0
                                maxValue: 2
                                stepSize: 0.01
                            }
                        }

                        // Clip控制
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            Text {
                                text: "Clip"
                                color: "white"
                                font.pixelSize: 16
                            }

                            ParameterControl {
                                id: pureWhiteControl
                                Layout.fillWidth: true
                                parameterName: "Pure White"
                                defaultValue: 0.87
                                minValue: 0
                                maxValue: 1
                                stepSize: 0.01
                            }

                            ParameterControl {
                                id: pureBlackControl
                                Layout.fillWidth: true
                                parameterName: "Pure Black"
                                defaultValue: 0.15
                                minValue: 0
                                maxValue: 1
                                stepSize: 0.01
                            }
                        }

                        // 统一Reset按钮
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 16
                            width: 80
                            height: 32
                            text: "Reset"

                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                radius: 8
                            }

                            contentItem: RowLayout {
                                spacing: 4
                                Text {
                                    text: "↻"
                                    color: "white"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "Reset"
                                    color: "white"
                                    font.pixelSize: 12
                                }
                            }

                            onClicked: {
                                dminControl.resetToDefault()
                                dmaxControl.resetToDefault()
                                redControl.resetToDefault()
                                greenControl.resetToDefault()
                                blueControl.resetToDefault()
                                grayControl.resetToDefault()
                                pureWhiteControl.resetToDefault()
                                pureBlackControl.resetToDefault()
                            }
                        }
                    }
                }
            }
          
  // 4. Effects - 效果参数控制
            Rectangle {
                id: effectsSection
                Layout.fillWidth: true
                Layout.preferredHeight: effectsContent.implicitHeight + 32
                color: "#000000"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#404040"
                }

                ColumnLayout {
                    id: effectsContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Effects"
                            color: "white"
                            font.pixelSize: 18
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "Reset"
                            height: 24
                            width: 60

                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "transparent")
                                radius: 8
                            }

                            contentItem: RowLayout {
                                spacing: 4
                                Text {
                                    text: "↻"
                                    color: "#888888"
                                    font.pixelSize: 10
                                }
                                Text {
                                    text: "Reset"
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }

                            onClicked: {
                                lightControl.resetToDefault()
                                exposureControl.resetToDefault()
                                saturationControl.resetToDefault()
                                warmthControl.resetToDefault()
                                tintControl.resetToDefault()
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 24

                        EffectParameterControl {
                            id: lightControl
                            Layout.fillWidth: true
                            parameterName: "Light"
                            defaultValue: 0
                            minValue: -100
                            maxValue: 100
                            stepSize: 1
                        }

                        EffectParameterControl {
                            id: exposureControl
                            Layout.fillWidth: true
                            parameterName: "Exposure"
                            defaultValue: 0
                            minValue: -100
                            maxValue: 100
                            stepSize: 1
                        }

                        EffectParameterControl {
                            id: saturationControl
                            Layout.fillWidth: true
                            parameterName: "Saturation"
                            defaultValue: 0
                            minValue: -100
                            maxValue: 100
                            stepSize: 1
                        }

                        EffectParameterControl {
                            id: warmthControl
                            Layout.fillWidth: true
                            parameterName: "Warmth"
                            defaultValue: 0
                            minValue: -100
                            maxValue: 100
                            stepSize: 1
                        }

                        EffectParameterControl {
                            id: tintControl
                            Layout.fillWidth: true
                            parameterName: "Tint"
                            defaultValue: 0
                            minValue: -100
                            maxValue: 100
                            stepSize: 1
                        }
                    }
                }
            }

            // 5. 宽高比 - 宽高比选择（可折叠）
            Rectangle {
                id: aspectRatioSection
                property bool aspectRatioCollapsed: false
                Layout.fillWidth: true
                Layout.preferredHeight: aspectRatioCollapsed ? 64 : aspectRatioContent.implicitHeight + 64
                color: "#000000"

                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#404040"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    // 标题行
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "宽高比"
                            color: "white"
                            font.pixelSize: 18
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: aspectRatioSection.aspectRatioCollapsed ? "▶" : "▼"
                            color: "white"
                            font.pixelSize: 12

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    aspectRatioSection.aspectRatioCollapsed = !aspectRatioSection.aspectRatioCollapsed
                                }
                            }
                        }
                    }

                    // 宽高比内容
                    GridLayout {
                        id: aspectRatioContent
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8
                        visible: !aspectRatioSection.aspectRatioCollapsed
                        opacity: aspectRatioSection.aspectRatioCollapsed ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }

                        // 预设比例选项
                        AspectRatioButton {
                            Layout.fillWidth: true
                            text: "Free Form"
                            onClicked: console.log("Free Form selected")
                        }

                        AspectRatioButton {
                            Layout.fillWidth: true
                            text: "3:2"
                            onClicked: console.log("3:2 selected")
                        }

                        AspectRatioButton {
                            Layout.fillWidth: true
                            text: "5:4"
                            onClicked: console.log("5:4 selected")
                        }

                        AspectRatioButton {
                            Layout.fillWidth: true
                            text: "7:5"
                            onClicked: console.log("7:5 selected")
                        }

                        AspectRatioButton {
                            Layout.fillWidth: true
                            text: "16:9"
                            onClicked: console.log("16:9 selected")
                        }

                        AspectRatioButton {
                            Layout.fillWidth: true
                            text: "自定义"
                            onClicked: console.log("Custom selected")
                        }
                    }
                }
            }

            // 底部间距
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }

    // 参数控制组件
    component ParameterControl: ColumnLayout {
        property string parameterName: ""
        property real defaultValue: 0
        property real minValue: 0
        property real maxValue: 1
        property real stepSize: 0.01
        property alias value: slider.value

        function resetToDefault() {
            slider.value = defaultValue
            input.text = defaultValue.toFixed(2)
        }

        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: parameterName
                color: "white"
                font.pixelSize: 14
            }

            Item { Layout.fillWidth: true }

            TextField {
                id: input
                text: defaultValue.toFixed(2)
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignRight
                implicitWidth: 64

                background: Rectangle {
                    color: "transparent"
                }

                onTextChanged: {
                    var val = parseFloat(text)
                    if (!isNaN(val) && val >= minValue && val <= maxValue) {
                        slider.value = val
                    }
                }
            }

            Button {
                width: 24
                height: 24
                text: "↻"

                background: Rectangle {
                    color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: resetToDefault()
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: minValue
            to: maxValue
            value: defaultValue
            stepSize: parent.stepSize

            onValueChanged: {
                input.text = value.toFixed(2)
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: "#333333"
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: "#FFD60A"
            }
        }
    }

    // 效果参数控制组件
    component EffectParameterControl: ColumnLayout {
        property string parameterName: ""
        property real defaultValue: 0
        property real minValue: -100
        property real maxValue: 100
        property real stepSize: 1
        property alias value: slider.value

        function resetToDefault() {
            slider.value = defaultValue
            valueDisplay.text = defaultValue.toString()
        }

        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: parameterName
                color: "#CCCCCC"
                font.pixelSize: 14
            }

            Item { Layout.fillWidth: true }

            Text {
                id: valueDisplay
                text: defaultValue.toString()
                color: "white"
                font.pixelSize: 14
            }

            Button {
                width: 24
                height: 24
                text: "↻"

                background: Rectangle {
                    color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: resetToDefault()
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: minValue
            to: maxValue
            value: defaultValue
            stepSize: parent.stepSize

            onValueChanged: {
                valueDisplay.text = Math.round(value).toString()
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: "#333333"
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: "#FFD60A"
            }
        }
    }

    // 宽高比按钮组件
    component AspectRatioButton: Button {
        height: 32

        background: Rectangle {
            color: parent.pressed ? "#2C2C2E" : (parent.hovered ? "#2C2C2E" : "#1C1C1E")
            radius: 8
        }

        contentItem: Text {
            text: parent.text
            color: "white"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}