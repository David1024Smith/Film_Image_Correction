import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"

ApplicationWindow {
    id: root

    width: 1400
    height: 900
    visible: true
    title: "图片编辑器"
    color: "#1C1C1E"

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部工具栏 - 横贯整个界面
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#000000"
            opacity: 0.8

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#333333"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                // 左侧空白区域
                Item {
                    Layout.fillWidth: true
                }

                // 中间按钮
                Button {
                    text: "胶片成像区框选"
                            onClicked: {
                                // 调用Python后端功能
                                console.log("胶片成像区框选按钮被点击");
                                if (typeof analysisController !== 'undefined')
                                    analysisController.startFrameDetection();

                            }

                            background: Rectangle {
                                color: parent.hovered ? "#FFD60A" : "#000000"
                                opacity: parent.hovered ? 0.9 : 0.4
                                radius: 8
                                implicitWidth: 160
                                implicitHeight: 32
                            }

                            contentItem: Text {
                                text: parent.text
                                color: parent.hovered ? "#000000" : "#FFFFFF"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }

                        }

                        // 右侧空白区域
                        Item {
                            Layout.fillWidth: true
                        }

                        // 完成按钮
                        Button {
                            text: "完成"
                                onClicked: {
                                    // 导航到参数控制窗口
                                    console.log("完成按钮被点击，导航到参数控制窗口");
                                    var component = Qt.createComponent("parameterControlWindow.qml");
                                    if (component.status === Component.Ready) {
                                        var newWindow = component.createObject();
                                        if (newWindow) {
                                            newWindow.show();
                                            root.close();
                                        }
                                    }
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#E6C109" : "#FFD60A"
                                     radius: 8
                                    implicitWidth: 64
                                    implicitHeight: 32
                                }

                            contentItem: Text {
                                text: parent.text
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }

                }

            }

        }

        // 主内容区域
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // 图片编辑区域
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 32
                    spacing: 16

                        // 主图片显示区域
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#262626"
                            border.color: "#666666"
                            border.width: 1
                            radius: 8

                            Image {
                                id: mainImage
                                anchors.fill: parent
                                anchors.margins: 1
                                source: "" // 暂时设为空，显示占位图
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                visible: source !== "" && status === Image.Ready
                                
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.log("主图片加载错误:", source)
                                    } else if (status === Image.Ready) {
                                        console.log("主图片加载成功:", source)
                                    }
                                }
                            }

                            // 占位文本 
                            Text {
                                anchors.centerIn: parent
                                text: "Main Image"
                                color: "#6B7280" 
                                font.pixelSize: 48
                                visible: mainImage.source === "" || mainImage.status !== Image.Ready
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("主图片被点击");
                                }
                            }
                        }

                        // 缩略图滚动区域
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: "transparent"

                            ScrollView {
                                anchors.fill: parent
                                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                                ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                                Row {
                                    spacing: 8

                                    // 显示6个缩略图，先使用占位图进行测试
                                    Repeater {
                                        model: 6 

                                        Rectangle {
                                            width: 96
                                            height: 80
                                            color: "#262626" 
                                            border.color: index === 0 ? "#FFD60A" : "#666666" // 第一个默认选中
                                            border.width: 1
                                            radius: 8 

                                            Image {
                                                id: thumbnailImage
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                source: "" // 暂时设为空，显示占位图
                                                fillMode: Image.PreserveAspectCrop
                                                asynchronous: true
                                                visible: source !== "" && status === Image.Ready
                                                
                                                onStatusChanged: {
                                                    if (status === Image.Error) {
                                                        console.log("缩略图", index, "加载错误:", source)
                                                    } else if (status === Image.Ready) {
                                                        console.log("缩略图", index, "加载成功:", source)
                                                    }
                                                }
                                            }

                                            // 占位文本 
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Image" 
                                                color: "#6B7280" 
                                                font.pixelSize: 12 
                                                visible: thumbnailImage.source === "" || thumbnailImage.status !== Image.Ready
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    console.log("缩略图", index, "被点击");
                                                    if (imageController)
                                                        imageController.setCurrentFrame(index);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                }

            }

            // 右侧控制面板
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "#000000"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 滚动区域
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: 280
                        spacing: 0

                        // 成像比例部分
                        AspectRatioSection {
                            Layout.fillWidth: true
                        }

                        // 裁剪模式部分
                        CropModeSection {
                            Layout.fillWidth: true
                        }

                        // 阈值调节部分
                        ThresholdSection {
                            Layout.fillWidth: true
                        }

                    }

                }

                // 底部按钮
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    color: "transparent"

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: "#333333"
                    }

                    Button {
                        anchors.centerIn: parent
                        width: parent.width - 32
                        height: 40
                        text: "去色罩"
                        onClicked: {
                            // 调用Python后端去色罩功能
                            console.log("去色罩按钮被点击");
                            if (typeof analysisController !== 'undefined')
                                analysisController.removeColorCast();

                        }

                        background: Rectangle {
                            color: parent.hovered ? "#E6C109" : "#FFD60A"
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#000000"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }

                    }

                }

            }

        }

    }

}
}