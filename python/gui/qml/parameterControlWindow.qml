import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: parameterControlWindow
    width: 1400
    height: 900
    title: "图片编辑器 - Revela"
    visible: true
    color: "#1C1C1E"

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部工具栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#000000"

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#404040"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 0

                // 左侧工具按钮
                RowLayout {
                    spacing: 8

                    Button {
                        width: 40
                        height: 40
                        text: "↕"
                        ToolTip.text: "Flip Vertical"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: 40
                        height: 40
                        text: "↔"
                        ToolTip.text: "Flip Horizontal"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: 40
                        height: 40
                        text: "↻"
                        ToolTip.text: "Rotate Right"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: 40
                        height: 40
                        text: "↺"
                        ToolTip.text: "Rotate Left"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        width: 40
                        height: 40
                        text: "🔍"
                        ToolTip.text: "Zoom In"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // 中央分类按钮
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 48

                    Button {
                        text: "胶片"
                        height: 30
                        implicitWidth: 64

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "成片"
                        height: 30
                        implicitWidth: 64

                        background: Rectangle {
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.hovered ? "#FFD60A" : "white"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // 右侧完成按钮
                Button {
                    text: "完成"
                    height: 30
                    implicitWidth: 64

                    background: Rectangle {
                        color: parent.pressed ? "#E6C200" : (parent.hovered ? "#E6C200" : "#FFD60A")
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "black"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // 主内容区域
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // 中央图像显示区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1C1C1E"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 32
                    spacing: 16

                    // 主图像区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: "#404040"
                        border.width: 1

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            fillMode: Image.PreserveAspectFit
                            source: "https://image-resource.mastergo.com/146874632348805/146874632348807/af8c680adba3e36cca4fdd5b93f075ed.png"
                        }

                        // 缩略图切换按钮
                        Button {
                            id: thumbnailToggleBtn
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: 16
                            width: 120
                            height: 30

                            property bool thumbnailsVisible: true

                            background: Rectangle {
                                color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                radius: 8
                                opacity: 0.8
                            }

                            contentItem: RowLayout {
                                spacing: 8

                                Text {
                                    text: thumbnailToggleBtn.thumbnailsVisible ? "▼" : "▲"
                                    color: "white"
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: "Thumbnails"
                                    color: "white"
                                    font.pixelSize: 12
                                }
                            }

                            onClicked: {
                                thumbnailsVisible = !thumbnailsVisible
                                thumbnailContainer.visible = thumbnailsVisible
                            }
                        }
                    }

                    // 缩略图容器
                    Rectangle {
                        id: thumbnailContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "transparent"

                        ScrollView {
                            anchors.fill: parent
                            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                            RowLayout {
                                height: 80
                                spacing: 8

                                Repeater {
                                    model: 10

                                    Rectangle {
                                        width: 96
                                        height: 80
                                        color: "transparent"
                                        border.color: index === 0 ? "#FFD60A" : "#404040"
                                        border.width: 1

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            fillMode: Image.PreserveAspectCrop
                                            source: "https://image-resource.mastergo.com/146874632348805/146874632348807/af8c680adba3e36cca4fdd5b93f075ed.png"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                // 更新选中状态
                                                for (var i = 0; i < 10; i++) {
                                                    if (i === index) {
                                                        parent.border.color = "#FFD60A"
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
            }

            // 右侧工具栏
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "#000000"

                ScrollView {
                    anchors.fill: parent
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: 280
                        spacing: 0

                        // 1. Histogram
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: histogramContent.height + 32
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
                                    text: "H:stogram"
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

                        // 2. LUT
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: lutContent.height + 32
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

                                    // 开关
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
                                            anchors.fill: parent
                                            property bool checked: false
                                            onClicked: checked = !checked
                                        }
                                    }
                                }

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
                                            }
                                        }
                                    }
                                }
                            }
                        }   
                     // 3. Technical
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: technicalCollapsed ? 64 : technicalContent.height + 32
                            color: "#000000"

                            property bool technicalCollapsed: false

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
                                        text: parent.parent.parent.technicalCollapsed ? "▶" : "▼"
                                        color: "white"
                                        font.pixelSize: 12

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                parent.parent.parent.parent.technicalCollapsed = !parent.parent.parent.parent.technicalCollapsed
                                            }
                                        }
                                    }
                                }

                                // 内容区域
                                ColumnLayout {
                                    id: technicalContent
                                    Layout.fillWidth: true
                                    spacing: 24
                                    visible: !parent.parent.technicalCollapsed

                                    // Dmin/Dmax 控制
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 16

                                        // Dmin
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Dmin"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: dminInput
                                                    text: "0.00"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        dminInput.text = "0.00"
                                                        dminSlider.value = 0
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: dminSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 1
                                                value: 0
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    dminInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: dminSlider.leftPadding
                                                    y: dminSlider.topPadding + dminSlider.availableHeight / 2 - height / 2
                                                    width: dminSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: dminSlider.leftPadding + dminSlider.visualPosition * (dminSlider.availableWidth - width)
                                                    y: dminSlider.topPadding + dminSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }

                                        // Dmax
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Dmax"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: dmaxInput
                                                    text: "1.00"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        dmaxInput.text = "1.00"
                                                        dmaxSlider.value = 1
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: dmaxSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 1
                                                value: 1
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    dmaxInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: dmaxSlider.leftPadding
                                                    y: dmaxSlider.topPadding + dmaxSlider.availableHeight / 2 - height / 2
                                                    width: dmaxSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: dmaxSlider.leftPadding + dmaxSlider.visualPosition * (dmaxSlider.availableWidth - width)
                                                    y: dmaxSlider.topPadding + dmaxSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
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

                                        // Red
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Red"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: redInput
                                                    text: "1.00"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        redInput.text = "1.00"
                                                        redSlider.value = 1
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: redSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 2
                                                value: 1
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    redInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: redSlider.leftPadding
                                                    y: redSlider.topPadding + redSlider.availableHeight / 2 - height / 2
                                                    width: redSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: redSlider.leftPadding + redSlider.visualPosition * (redSlider.availableWidth - width)
                                                    y: redSlider.topPadding + redSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }

                                        // Green
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Green"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: greenInput
                                                    text: "0.82"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        greenInput.text = "0.82"
                                                        greenSlider.value = 0.82
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: greenSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 2
                                                value: 0.82
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    greenInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: greenSlider.leftPadding
                                                    y: greenSlider.topPadding + greenSlider.availableHeight / 2 - height / 2
                                                    width: greenSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: greenSlider.leftPadding + greenSlider.visualPosition * (greenSlider.availableWidth - width)
                                                    y: greenSlider.topPadding + greenSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }

                                        // Blue
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Blue"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: blueInput
                                                    text: "0.35"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        blueInput.text = "0.35"
                                                        blueSlider.value = 0.35
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: blueSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 2
                                                value: 0.35
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    blueInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: blueSlider.leftPadding
                                                    y: blueSlider.topPadding + blueSlider.availableHeight / 2 - height / 2
                                                    width: blueSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: blueSlider.leftPadding + blueSlider.visualPosition * (blueSlider.availableWidth - width)
                                                    y: blueSlider.topPadding + blueSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }
                                    }

                                    // Gray
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 16

                                        Text {
                                            text: "Gray"
                                            color: "white"
                                            font.pixelSize: 16
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Level"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: grayInput
                                                    text: "0.42"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        grayInput.text = "0.42"
                                                        graySlider.value = 0.42
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: graySlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 2
                                                value: 0.42
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    grayInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: graySlider.leftPadding
                                                    y: graySlider.topPadding + graySlider.availableHeight / 2 - height / 2
                                                    width: graySlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: graySlider.leftPadding + graySlider.visualPosition * (graySlider.availableWidth - width)
                                                    y: graySlider.topPadding + graySlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }
                                    }

                                    // Clip
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 16

                                        Text {
                                            text: "Clip"
                                            color: "white"
                                            font.pixelSize: 16
                                        }

                                        // Pure White
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Pure White"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: pureWhiteInput
                                                    text: "0.87"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        pureWhiteInput.text = "0.87"
                                                        pureWhiteSlider.value = 0.87
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: pureWhiteSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 1
                                                value: 0.87
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    pureWhiteInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: pureWhiteSlider.leftPadding
                                                    y: pureWhiteSlider.topPadding + pureWhiteSlider.availableHeight / 2 - height / 2
                                                    width: pureWhiteSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: pureWhiteSlider.leftPadding + pureWhiteSlider.visualPosition * (pureWhiteSlider.availableWidth - width)
                                                    y: pureWhiteSlider.topPadding + pureWhiteSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }

                                        // Pure Black
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true

                                                Text {
                                                    text: "Pure Black"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                }

                                                Item { Layout.fillWidth: true }

                                                TextField {
                                                    id: pureBlackInput
                                                    text: "0.15"
                                                    color: "white"
                                                    font.pixelSize: 14
                                                    horizontalAlignment: Text.AlignRight
                                                    implicitWidth: 64

                                                    background: Rectangle {
                                                        color: "transparent"
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

                                                    onClicked: {
                                                        pureBlackInput.text = "0.15"
                                                        pureBlackSlider.value = 0.15
                                                    }
                                                }
                                            }

                                            Slider {
                                                id: pureBlackSlider
                                                Layout.fillWidth: true
                                                from: 0
                                                to: 1
                                                value: 0.15
                                                stepSize: 0.01

                                                onValueChanged: {
                                                    pureBlackInput.text = value.toFixed(2)
                                                }

                                                background: Rectangle {
                                                    x: pureBlackSlider.leftPadding
                                                    y: pureBlackSlider.topPadding + pureBlackSlider.availableHeight / 2 - height / 2
                                                    width: pureBlackSlider.availableWidth
                                                    height: 4
                                                    radius: 2
                                                    color: "#333333"
                                                }

                                                handle: Rectangle {
                                                    x: pureBlackSlider.leftPadding + pureBlackSlider.visualPosition * (pureBlackSlider.availableWidth - width)
                                                    y: pureBlackSlider.topPadding + pureBlackSlider.availableHeight / 2 - height / 2
                                                    width: 16
                                                    height: 16
                                                    radius: 8
                                                    color: "#FFD60A"
                                                }
                                            }
                                        }
                                    }

                                    // Reset按钮
                                    Button {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.topMargin: 16
                                        text: "↻ Reset"
                                        implicitWidth: 80
                                        height: 32

                                        background: Rectangle {
                                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                                            radius: 8
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            // 重置所有Technical参数
                                            dminInput.text = "0.00"; dminSlider.value = 0
                                            dmaxInput.text = "1.00"; dmaxSlider.value = 1
                                            redInput.text = "1.00"; redSlider.value = 1
                                            greenInput.text = "0.82"; greenSlider.value = 0.82
                                            blueInput.text = "0.35"; blueSlider.value = 0.35
                                            grayInput.text = "0.42"; graySlider.value = 0.42
                                            pureWhiteInput.text = "0.87"; pureWhiteSlider.value = 0.87
                                            pureBlackInput.text = "0.15"; pureBlackSlider.value = 0.15
                                        }
                                    }
                                }
                            }
                        }      
                  // 4. Effects
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: effectsContent.height + 32
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
                                        text: "↻ Reset"
                                        height: 24
                                        implicitWidth: 60

                                        background: Rectangle {
                                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "transparent")
                                            radius: 8
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#9CA3AF"
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            lightSlider.value = 0; lightValue.text = "0"
                                            exposureEffectSlider.value = 0; exposureEffectValue.text = "0"
                                            saturationEffectSlider.value = 0; saturationEffectValue.text = "0"
                                            warmthSlider.value = 0; warmthValue.text = "0"
                                            tintSlider.value = 0; tintValue.text = "0"
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 24

                                    // Light
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Light"
                                                color: "#B3B3B3"
                                                font.pixelSize: 14
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                id: lightValue
                                                text: "0"
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

                                                onClicked: {
                                                    lightSlider.value = 0
                                                    lightValue.text = "0"
                                                }
                                            }
                                        }

                                        Slider {
                                            id: lightSlider
                                            Layout.fillWidth: true
                                            from: -100
                                            to: 100
                                            value: 0
                                            stepSize: 1

                                            onValueChanged: {
                                                lightValue.text = Math.round(value).toString()
                                            }

                                            background: Rectangle {
                                                x: lightSlider.leftPadding
                                                y: lightSlider.topPadding + lightSlider.availableHeight / 2 - height / 2
                                                width: lightSlider.availableWidth
                                                height: 4
                                                radius: 2
                                                color: "#333333"
                                            }

                                            handle: Rectangle {
                                                x: lightSlider.leftPadding + lightSlider.visualPosition * (lightSlider.availableWidth - width)
                                                y: lightSlider.topPadding + lightSlider.availableHeight / 2 - height / 2
                                                width: 16
                                                height: 16
                                                radius: 8
                                                color: "#FFD60A"
                                            }
                                        }
                                    }

                                    // Exposure
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Exposure"
                                                color: "#B3B3B3"
                                                font.pixelSize: 14
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                id: exposureEffectValue
                                                text: "0"
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

                                                onClicked: {
                                                    exposureEffectSlider.value = 0
                                                    exposureEffectValue.text = "0"
                                                }
                                            }
                                        }

                                        Slider {
                                            id: exposureEffectSlider
                                            Layout.fillWidth: true
                                            from: -100
                                            to: 100
                                            value: 0
                                            stepSize: 1

                                            onValueChanged: {
                                                exposureEffectValue.text = Math.round(value).toString()
                                            }

                                            background: Rectangle {
                                                x: exposureEffectSlider.leftPadding
                                                y: exposureEffectSlider.topPadding + exposureEffectSlider.availableHeight / 2 - height / 2
                                                width: exposureEffectSlider.availableWidth
                                                height: 4
                                                radius: 2
                                                color: "#333333"
                                            }

                                            handle: Rectangle {
                                                x: exposureEffectSlider.leftPadding + exposureEffectSlider.visualPosition * (exposureEffectSlider.availableWidth - width)
                                                y: exposureEffectSlider.topPadding + exposureEffectSlider.availableHeight / 2 - height / 2
                                                width: 16
                                                height: 16
                                                radius: 8
                                                color: "#FFD60A"
                                            }
                                        }
                                    }

                                    // Saturation
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Saturation"
                                                color: "#B3B3B3"
                                                font.pixelSize: 14
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                id: saturationEffectValue
                                                text: "0"
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

                                                onClicked: {
                                                    saturationEffectSlider.value = 0
                                                    saturationEffectValue.text = "0"
                                                }
                                            }
                                        }

                                        Slider {
                                            id: saturationEffectSlider
                                            Layout.fillWidth: true
                                            from: -100
                                            to: 100
                                            value: 0
                                            stepSize: 1

                                            onValueChanged: {
                                                saturationEffectValue.text = Math.round(value).toString()
                                            }

                                            background: Rectangle {
                                                x: saturationEffectSlider.leftPadding
                                                y: saturationEffectSlider.topPadding + saturationEffectSlider.availableHeight / 2 - height / 2
                                                width: saturationEffectSlider.availableWidth
                                                height: 4
                                                radius: 2
                                                color: "#333333"
                                            }

                                            handle: Rectangle {
                                                x: saturationEffectSlider.leftPadding + saturationEffectSlider.visualPosition * (saturationEffectSlider.availableWidth - width)
                                                y: saturationEffectSlider.topPadding + saturationEffectSlider.availableHeight / 2 - height / 2
                                                width: 16
                                                height: 16
                                                radius: 8
                                                color: "#FFD60A"
                                            }
                                        }
                                    }

                                    // Warmth
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Warmth"
                                                color: "#B3B3B3"
                                                font.pixelSize: 14
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                id: warmthValue
                                                text: "0"
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

                                                onClicked: {
                                                    warmthSlider.value = 0
                                                    warmthValue.text = "0"
                                                }
                                            }
                                        }

                                        Slider {
                                            id: warmthSlider
                                            Layout.fillWidth: true
                                            from: -100
                                            to: 100
                                            value: 0
                                            stepSize: 1

                                            onValueChanged: {
                                                warmthValue.text = Math.round(value).toString()
                                            }

                                            background: Rectangle {
                                                x: warmthSlider.leftPadding
                                                y: warmthSlider.topPadding + warmthSlider.availableHeight / 2 - height / 2
                                                width: warmthSlider.availableWidth
                                                height: 4
                                                radius: 2
                                                color: "#333333"
                                            }

                                            handle: Rectangle {
                                                x: warmthSlider.leftPadding + warmthSlider.visualPosition * (warmthSlider.availableWidth - width)
                                                y: warmthSlider.topPadding + warmthSlider.availableHeight / 2 - height / 2
                                                width: 16
                                                height: 16
                                                radius: 8
                                                color: "#FFD60A"
                                            }
                                        }
                                    }

                                    // Tint
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Tint"
                                                color: "#B3B3B3"
                                                font.pixelSize: 14
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                id: tintValue
                                                text: "0"
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

                                                onClicked: {
                                                    tintSlider.value = 0
                                                    tintValue.text = "0"
                                                }
                                            }
                                        }

                                        Slider {
                                            id: tintSlider
                                            Layout.fillWidth: true
                                            from: -100
                                            to: 100
                                            value: 0
                                            stepSize: 1

                                            onValueChanged: {
                                                tintValue.text = Math.round(value).toString()
                                            }

                                            background: Rectangle {
                                                x: tintSlider.leftPadding
                                                y: tintSlider.topPadding + tintSlider.availableHeight / 2 - height / 2
                                                width: tintSlider.availableWidth
                                                height: 4
                                                radius: 2
                                                color: "#333333"
                                            }

                                            handle: Rectangle {
                                                x: tintSlider.leftPadding + tintSlider.visualPosition * (tintSlider.availableWidth - width)
                                                y: tintSlider.topPadding + tintSlider.availableHeight / 2 - height / 2
                                                width: 16
                                                height: 16
                                                radius: 8
                                                color: "#FFD60A"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 5. 宽高比
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: aspectRatioCollapsed ? 64 : aspectRatioContent.height + 32
                            color: "#000000"

                            property bool aspectRatioCollapsed: false

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
                                        text: parent.parent.parent.aspectRatioCollapsed ? "▶" : "▼"
                                        color: "white"
                                        font.pixelSize: 12

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                parent.parent.parent.parent.aspectRatioCollapsed = !parent.parent.parent.parent.aspectRatioCollapsed
                                            }
                                        }
                                    }
                                }

                                // 内容区域
                                GridLayout {
                                    id: aspectRatioContent
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 8
                                    rowSpacing: 8
                                    visible: !parent.parent.aspectRatioCollapsed

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        text: "Free Form"

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

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        text: "3:2"

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

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        text: "5:4"

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

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        text: "7:5"

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

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        text: "16:9"

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

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        text: "自定义"

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
                            }
                        }
                    }
                }
            }
        }
    }
}