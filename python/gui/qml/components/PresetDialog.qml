import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: presetDialog
    title: "预设管理"
    width: 600
    height: 500
    anchors.centerIn: parent
    modal: true

    property bool isLoadMode: true  // true: 加载模式, false: 保存模式
    property string selectedPreset: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 模式切换
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "模式:"
                font.bold: true
            }

            RadioButton {
                text: "加载预设"
                checked: presetDialog.isLoadMode
                onClicked: presetDialog.isLoadMode = true
            }

            RadioButton {
                text: "保存预设"
                checked: !presetDialog.isLoadMode
                onClicked: presetDialog.isLoadMode = false
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "刷新"
                onClicked: presetController.refreshPresets()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#ddd"
        }

        // 预设列表区域
        GroupBox {
            title: "预设列表 (" + presetController.presetCount + " 个)"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent

                ListView {
                    id: presetListView
                    model: presetController.presetNames
                    
                    delegate: Rectangle {
                        width: presetListView.width
                        height: 60
                        color: mouseArea.containsMouse ? "#f0f0f0" : "transparent"
                        border.color: presetDialog.selectedPreset === modelData ? "#2196f3" : "#ddd"
                        border.width: presetDialog.selectedPreset === modelData ? 2 : 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            // 预设图标
                            Rectangle {
                                width: 40
                                height: 40
                                color: "#2196f3"
                                radius: 20

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.charAt(0).toUpperCase()
                                    color: "white"
                                    font.bold: true
                                    font.pointSize: 14
                                }
                            }

                            // 预设信息
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: modelData
                                    font.bold: true
                                    font.pointSize: 11
                                }

                                Label {
                                    text: {
                                        var info = presetController.getPresetInfo(modelData)
                                        return info.created_time ? 
                                               "创建时间: " + info.created_time : 
                                               "无创建时间信息"
                                    }
                                    font.pointSize: 9
                                    color: "#666"
                                }

                                Label {
                                    text: {
                                        var info = presetController.getPresetInfo(modelData)
                                        return "参数数量: " + (info.parameter_count || 0)
                                    }
                                    font.pointSize: 9
                                    color: "#666"
                                }
                            }

                            // 操作按钮
                            ColumnLayout {
                                spacing: 4

                                Button {
                                    text: "重命名"
                                    font.pointSize: 8
                                    onClicked: {
                                        renameDialog.oldName = modelData
                                        renameDialog.open()
                                    }
                                }

                                Button {
                                    text: "删除"
                                    font.pointSize: 8
                                    onClicked: {
                                        deleteConfirmDialog.presetName = modelData
                                        deleteConfirmDialog.open()
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                presetDialog.selectedPreset = modelData
                            }
                            onDoubleClicked: {
                                if (presetDialog.isLoadMode) {
                                    loadSelectedPreset()
                                }
                            }
                        }
                    }

                    // 空状态显示
                    Label {
                        anchors.centerIn: parent
                        visible: presetController.presetCount === 0
                        text: "暂无预设\n\n点击'保存预设'创建第一个预设"
                        color: "#999"
                        font.pointSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // 保存预设区域（仅保存模式显示）
        GroupBox {
            title: "保存新预设"
            Layout.fillWidth: true
            visible: !presetDialog.isLoadMode

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    Label {
                        text: "预设名称:"
                        Layout.minimumWidth: 80
                    }

                    TextField {
                        id: newPresetNameField
                        Layout.fillWidth: true
                        placeholderText: "输入预设名称..."
                    }
                }

                Label {
                    text: "将保存当前的所有颜色调整参数"
                    font.pointSize: 9
                    color: "#666"
                    Layout.fillWidth: true
                }
            }
        }

        // 预设预览区域（仅加载模式显示）
        GroupBox {
            title: "预设预览"
            Layout.fillWidth: true
            visible: presetDialog.isLoadMode && presetDialog.selectedPreset !== ""

            ScrollView {
                anchors.fill: parent
                height: 120

                ColumnLayout {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: presetDialog.selectedPreset ? 
                               _getPresetParametersList(presetDialog.selectedPreset) : []

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: modelData.name + ":"
                                Layout.minimumWidth: 100
                                font.pointSize: 9
                            }

                            Label {
                                text: modelData.value
                                color: "#666"
                                font.pointSize: 9
                                font.family: "monospace"
                            }
                        }
                    }
                }
            }
        }
    }

    // 对话框按钮
    footer: DialogButtonBox {
        Button {
            text: presetDialog.isLoadMode ? "加载预设" : "保存预设"
            enabled: presetDialog.isLoadMode ? 
                    presetDialog.selectedPreset !== "" : 
                    newPresetNameField.text.trim() !== ""
            highlighted: true
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            onClicked: {
                if (presetDialog.isLoadMode) {
                    loadSelectedPreset()
                } else {
                    saveNewPreset()
                }
            }
        }

        Button {
            text: "取消"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            onClicked: presetDialog.close()
        }
    }

    // 重命名对话框
    Dialog {
        id: renameDialog
        title: "重命名预设"
        property string oldName: ""
        anchors.centerIn: parent
        modal: true

        ColumnLayout {
            spacing: 10

            Label {
                text: "原名称: " + renameDialog.oldName
                font.pointSize: 10
            }

            RowLayout {
                Label {
                    text: "新名称:"
                }

                TextField {
                    id: newNameField
                    text: renameDialog.oldName
                    Layout.preferredWidth: 200
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: "确定"
                enabled: newNameField.text.trim() !== "" && 
                        newNameField.text.trim() !== renameDialog.oldName
                highlighted: true
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: {
                    presetController.renamePreset(renameDialog.oldName, newNameField.text.trim())
                    renameDialog.close()
                }
            }

            Button {
                text: "取消"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: renameDialog.close()
            }
        }
    }

    // 删除确认对话框
    Dialog {
        id: deleteConfirmDialog
        title: "确认删除"
        property string presetName: ""
        anchors.centerIn: parent
        modal: true

        Label {
            text: "确定要删除预设 '" + deleteConfirmDialog.presetName + "' 吗？\n\n此操作无法撤销。"
            wrapMode: Text.WordWrap
            width: 250
        }

        footer: DialogButtonBox {
            Button {
                text: "删除"
                highlighted: true
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: {
                    presetController.deletePreset(deleteConfirmDialog.presetName)
                    deleteConfirmDialog.close()
                    presetDialog.selectedPreset = ""
                }
            }

            Button {
                text: "取消"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: deleteConfirmDialog.close()
            }
        }
    }

    // 连接预设控制器信号
    Connections {
        target: presetController
        function onPresetSaved(presetName) {
            mainController.setStatus("预设已保存: " + presetName)
            presetDialog.close()
        }

        function onPresetLoaded(presetName) {
            mainController.setStatus("预设已加载: " + presetName)
            presetDialog.close()
        }

        function onPresetError(message) {
            errorDialog.text = message
            errorDialog.open()
        }
    }

    // 错误对话框
    Dialog {
        id: errorDialog
        title: "错误"
        property string text: ""
        anchors.centerIn: parent
        modal: true

        Label {
            text: errorDialog.text
            wrapMode: Text.WordWrap
            width: 300
        }
    }

    // 辅助函数
    function loadSelectedPreset() {
        if (presetDialog.selectedPreset === "") return

        var parameters = presetController.loadPreset(presetDialog.selectedPreset)
        if (parameters && Object.keys(parameters).length > 0) {
            // 应用参数到参数控制器
            for (var key in parameters) {
                if (parameterController.hasOwnProperty(key)) {
                    parameterController[key] = parameters[key]
                }
            }
        }
    }

    function saveNewPreset() {
        var presetName = newPresetNameField.text.trim()
        if (presetName === "") return

        // 获取当前参数
        var parameters = parameterController.getColorParametersDict()
        presetController.savePreset(presetName, parameters)
    }

    function _getPresetParametersList(presetName) {
        var parameters = presetController.loadPreset(presetName)
        var paramList = []

        var paramNames = {
            "exposure": "曝光",
            "contrast": "对比度", 
            "saturation": "饱和度",
            "highlights": "高光",
            "shadows": "阴影",
            "vibrance": "自然饱和度",
            "temperature": "色温",
            "tint": "色调"
        }

        for (var key in parameters) {
            var displayName = paramNames[key] || key
            var value = parameters[key]
            
            // 格式化数值显示
            var formattedValue = ""
            if (key === "temperature") {
                formattedValue = value.toFixed(0) + " K"
            } else if (key === "exposure") {
                formattedValue = value.toFixed(1) + " EV"
            } else if (["highlights", "shadows", "vibrance"].includes(key)) {
                formattedValue = value.toFixed(0)
            } else {
                formattedValue = value.toFixed(2)
            }

            paramList.push({
                name: displayName,
                value: formattedValue
            })
        }

        return paramList
    }
}