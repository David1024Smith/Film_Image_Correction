import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import "./components"

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
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 0

                // 左侧工具按钮
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 12

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Flip Vertical"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Image {
                            source: "../../image/FlipVertical.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                        }

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.flipVertical()
                            }
                        }
                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Flip Horizontal"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Image {
                            source: "../../image/FlipHorizontal.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                        }

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.flipHorizontal()
                            }
                        }
                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Rotate Right"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Image {
                            source: "../../image/RotateRight.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                        }

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.rotateRight()
                            }
                        }
                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Rotate Left"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Image {
                            source: "../../image/RotateLeft.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                        }

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.rotateLeft()
                            }
                        }
                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Zoom In"
                        ToolTip.visible: hovered

                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")
                            radius: 8
                        }

                        contentItem: Image {
                            source: "../../image/ZoomIn.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                        }

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.zoomIn()
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // 中央分类按钮
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spacing: 48

                    Button {
                        text: "胶片"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 64

                        background: Rectangle {
                            anchors.fill: parent
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

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.switchToFilm()
                            }
                        }
                    }

                    Button {
                        text: "成片"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 64

                        background: Rectangle {
                            anchors.fill: parent
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

                        onClicked: {
                            if (typeof parameterController !== 'undefined') {
                                parameterController.switchToFinal()
                            }
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
            RightToolbar {
                id: rightToolbar
            }
        }
    }
}