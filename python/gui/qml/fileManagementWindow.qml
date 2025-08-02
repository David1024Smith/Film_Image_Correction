import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15
import Revela 1.0

ApplicationWindow {
    id: fileManagementWindow

    property string currentPath: ""
    property var rollList: []
    property string selectedRoll: ""
    property var imageList: []
    // 网格缩放控制
    property int imageCount: 16
    // 默认显示16张图片（4x4）
    property int gridColumns: {
        // 根据imageCount智能计算列数
        if (imageCount <= 9)
            return 3;

        // 8-9个：3列
        if (imageCount <= 16)
            return 4;

        // 10-16个：4列
        if (imageCount <= 25)
            return 5;

        // 17-25个：5列
        return 6;
    }

    // 函数
    function loadRolls() {
        // 启动时不加载默认胶卷，等待用户导入
        // 显示空网格，默认4x4布局，可通过缩放控件调整
        rollList = [];
    }

    function loadImages() {
        // 切换胶卷时重新加载图像
        if (!selectedRoll) {
            imageList = [];
            console.log("未选择胶卷，显示空网格，当前设置:", imageCount, "个格子");
            return ;
        }
        console.log("加载胶卷图像:", selectedRoll);
        // 如果选中的胶卷有路径信息，重新加载
        var selectedRollData = null;
        for (var i = 0; i < rollList.length; i++) {
            if (rollList[i].name === selectedRoll) {
                selectedRollData = rollList[i];
                break;
            }
        }
        if (selectedRollData && selectedRollData.path) {
            // 重新加载这个胶卷
            projectController.loadRoll(selectedRollData.path);
        } else {
            // 没有找到胶卷数据，显示空网格
            imageList = [];
            console.log("未找到胶卷数据，显示空网格，当前设置:", imageCount, "个格子");
        }
    }

    function importRollFromFolder(folderPath) {
        console.log("开始导入胶卷文件夹:", folderPath);
        try {
            // 设置默认胶片类型
            if (projectController.filmType === "未选择" || !projectController.filmType)
                projectController.setFilmType("Portra 400");

            // 调用ProjectController加载胶卷
            projectController.loadRoll(folderPath);
        } catch (error) {
            console.error("导入错误:", error);
            // 导入失败时，确保显示空网格
            imageList = [];
            selectedRoll = "";
        }
    }

    width: 1400
    height: 900
    title: "Film Manager - Revela"
    visible: true
    // 连接主控制器
    Component.onCompleted: {
        mainController.initialize();
        loadRolls();
        // 启动时显示空网格，默认16个格子（4x4），等待用户导入
        imageList = [];
        // 确保图像列表为空，显示占位图
        console.log("File management window initialized with empty grid, default:", imageCount, "cells");
    }

    // 主背景
    Rectangle {
        anchors.fill: parent
        color: "#1C1C1E"

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
                    color: "#262626"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16

                    // 左侧缩放控件
                    RowLayout {
                        spacing: 8

                        Button {
                            width: 24
                            height: 24
                            text: "-"
                            enabled: imageCount > 8
                            onClicked: {
                                if (imageCount > 8) {
                                    imageCount--;
                                    console.log("减少网格数量到:", imageCount, "列数:", gridColumns);
                                }
                            }

                            background: Rectangle {
                                color: parent.enabled ? (parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "transparent")) : "#333333"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "#9CA3AF" : "#666666"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                        Slider {
                            id: imageCountSlider

                            from: 8
                            to: 32
                            value: imageCount
                            stepSize: 1
                            implicitWidth: 120
                            implicitHeight: 20
                            onValueChanged: {
                                imageCount = Math.round(value);
                                console.log("调整网格数量到:", imageCount, "列数:", gridColumns);
                                console.log("当前窗口宽度:", fileManagementWindow.width);
                            }

                            background: Rectangle {
                                x: imageCountSlider.leftPadding
                                y: imageCountSlider.topPadding + imageCountSlider.availableHeight / 2 - height / 2
                                implicitWidth: 120
                                implicitHeight: 4
                                width: imageCountSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: "#333333"
                            }

                            handle: Rectangle {
                                x: imageCountSlider.leftPadding + imageCountSlider.visualPosition * (imageCountSlider.availableWidth - width)
                                y: imageCountSlider.topPadding + imageCountSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: "#FFD60A"
                            }

                        }

                        Button {
                            width: 24
                            height: 24
                            text: "+"
                            enabled: imageCount < 32
                            onClicked: {
                                if (imageCount < 32) {
                                    imageCount++;
                                    console.log("增加网格数量到:", imageCount, "列数:", gridColumns);
                                }
                            }

                            background: Rectangle {
                                color: parent.enabled ? (parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "transparent")) : "#333333"
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "#9CA3AF" : "#666666"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                        Text {
                            text: imageCount.toString()
                            color: "#9CA3AF"
                            font.pixelSize: 14
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // 中央分类标签
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Text {
                            text: "Roll-2"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Text {
                            text: "Date"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Text {
                            text: "Film"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // 右侧成片按钮
                    Button {
                        text: "成片"
                        height: 36
                        enabled: true // 始终启用，允许界面循环跳转
                        onClicked: {
                            // 跳转到调整窗口
                            var component = Qt.createComponent("adjustmentWindow.qml");
                            if (component.status === Component.Ready) {
                                var newWindow = component.createObject();
                                if (newWindow) {
                                    newWindow.show();
                                    fileManagementWindow.close();
                                }
                            }
                        }

                        background: Rectangle {
                            color: parent.pressed ? "#E6C200" : (parent.hovered ? "#E6C200" : "#FFD60A")
                            radius: 8
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "black"
                            font.pixelSize: 14
                            font.bold: true
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
                // 调试信息
                onWidthChanged: {
                    console.log("主内容区域RowLayout宽度:", width);
                }

                // 左侧边栏
                Rectangle {
                    Layout.preferredWidth: 240
                    Layout.fillHeight: true
                    color: "#171717"
                    // 调试信息
                    onWidthChanged: {
                        console.log("左侧边栏宽度:", width);
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: "#262626"
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // 搜索框
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: "#262626"
                            radius: 8

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    text: "🔍"
                                    color: "#9CA3AF"
                                    font.pixelSize: 14
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    placeholderText: "Search..."
                                    color: "white"
                                    font.pixelSize: 14

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                }

                            }

                        }

                        // Rolls标题
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Rolls"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        // 分割线
                        Rectangle {
                            Layout.fillWidth: true
                            height: 2
                            color: "#262626"
                        }

                        // 胶卷列表
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                width: parent.parent.width
                                spacing: 16

                                Repeater {
                                    model: rollList

                                    Button {
                                        Layout.fillWidth: true
                                        height: 60
                                        onClicked: {
                                            selectedRoll = modelData.name;
                                            loadImages();
                                        }

                                        background: Rectangle {
                                            color: selectedRoll === modelData.name ? "#FFD60A" : (parent.hovered ? "#262626" : "transparent")
                                            radius: 8
                                        }

                                        contentItem: RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            anchors.topMargin: 4
                                            anchors.bottomMargin: 4
                                            spacing: 8

                                            Text {
                                                //文字垂直居中

                                                text: modelData.name
                                                color: selectedRoll === modelData.name ? "black" : "white"
                                                font.pixelSize: 14
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            Text {
                                                text: modelData.count.toString()
                                                color: selectedRoll === modelData.name ? "#666666" : "#9CA3AF"
                                                font.pixelSize: 14
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                        }

                                    }

                                }

                            }

                        }

                        // 导入按钮
                        Button {
                            Layout.fillWidth: true
                            height: 48
                            text: "Import New Roll"
                            onClicked: folderDialog.open()

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

                        }

                    }

                }

                // 主图像网格区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1C1C1E"

                    GridLayout {
                        id: imageGrid

                        property real availableWidth: width - anchors.margins * 2
                        property real cellSize: {
                            var spacing = (gridColumns - 1) * 16;
                            var size = (availableWidth - spacing) / gridColumns;
                            var finalSize = Math.max(120, size);
                            console.log("计算单元格大小 - 可用宽度:", availableWidth, "间距:", spacing, "列数:", gridColumns, "计算大小:", size, "最终大小:", finalSize);
                            console.log("父容器宽度:", parent.width, "GridLayout宽度:", width);
                            return finalSize;
                        }

                        anchors.fill: parent
                        anchors.margins: 24
                        columns: gridColumns // 动态列数
                        columnSpacing: 16 // 网格间距
                        rowSpacing: 16 // 网格间距

                        // 动态显示网格，数量由imageCount控制
                        Repeater {
                            model: imageCount

                            Rectangle {
                                property real cellSize: imageGrid.cellSize

                                Layout.preferredWidth: imageGrid.cellSize
                                Layout.preferredHeight: imageGrid.cellSize // 保持正方形
                                color: "#262626"
                                radius: 8

                                // 图像显示
                                Image {
                                    // 使用ImageController获取预览路径（处理TIFF转换）
                                    id: imagePreview

                                    anchors.fill: parent
                                    anchors.margins: 0
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    source: {
                                        // 检查是否有对应的图像
                                        if (index < imageList.length && imageList[index] && imageList[index].path)
                                            return imageController.getPreviewImagePath(imageList[index].path);

                                        return "";
                                    }
                                    visible: source !== ""
                                    // 处理加载错误
                                    onStatusChanged: {
                                        if (status === Image.Error)
                                            console.log("Image load error for:", source);
                                        else if (status === Image.Ready)
                                            console.log("Image loaded successfully:", source);
                                    }
                                }

                                // 占位文本
                                Text {
                                    anchors.centerIn: parent
                                    text: "Image"
                                    color: "#6B7280"
                                    font.pixelSize: Math.max(14, cellSize / 8) // 根据格子大小调整字体
                                    visible: imagePreview.source === "" || imagePreview.status !== Image.Ready
                                }

                                // Hover覆盖层
                                Rectangle {
                                    id: overlay

                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: 0
                                    radius: 8

                                    Button {
                                        anchors.centerIn: parent
                                        text: "View"
                                        visible: overlay.opacity > 0
                                        width: Math.min(80, cellSize * 0.6) // 按钮大小适应格子大小
                                        height: Math.min(32, cellSize * 0.2)
                                        onClicked: {
                                            // 使用ImageController加载选中的图像
                                            if (index < imageList.length && imageList[index] && imageList[index].path) {
                                                console.log("Loading image:", imageList[index].name);
                                                imageController.loadImage(imageList[index].path);
                                            }
                                        }

                                        background: Rectangle {
                                            color: parent.pressed ? "#E6C200" : "#FFD60A"
                                            radius: 8
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "black"
                                            font.pixelSize: Math.max(12, cellSize / 10)
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 200 // 平滑的hover效果动画
                                        }

                                    }

                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        // 只有当有图像且加载成功时才显示hover效果
                                        if (imagePreview.source !== "" && imagePreview.status === Image.Ready)
                                            overlay.opacity = 0.4;

                                    }
                                    onExited: overlay.opacity = 0
                                    onClicked: {
                                        // 使用ImageController加载选中的图像
                                        if (index < imageList.length && imageList[index] && imageList[index].path) {
                                            console.log("Loading image:", imageList[index].name);
                                            imageController.loadImage(imageList[index].path);
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

    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog

        title: "选择胶片文件夹"
        onAccepted: {
            var folderPath = selectedFolder.toString().replace("file:///", "");
            importRollFromFolder(folderPath);
        }
    }

    // 连接控制器信号
    Connections {
        // 重新索引

        function onRollLoadedChanged() {
            if (projectController.rollLoaded) {
                // 胶卷加载成功，更新界面
                var frameCount = projectController.frameCount;
                console.log("胶卷加载成功，包含", frameCount, "帧");
                // 获取文件夹名称
                var folderName = projectController.getRollName();
                // 构建图像列表
                var images = [];
                for (var i = 0; i < frameCount; i++) {
                    var framePath = projectController.getFramePath(i);
                    var frameName = projectController.getFrameName(i);
                    // 过滤掉隐藏文件（以._开头的文件）
                    if (framePath && framePath !== "" && !frameName.startsWith("._"))
                        images.push({
                        "index": images.length,
                        "name": frameName,
                        "path": framePath
                    });

                }
                // 检查是否已存在同名胶卷
                var existingIndex = -1;
                for (var j = 0; j < rollList.length; j++) {
                    if (rollList[j].name === folderName) {
                        existingIndex = j;
                        break;
                    }
                }
                if (existingIndex >= 0) {
                    // 更新现有胶卷
                    var newRollList = rollList.slice();
                    newRollList[existingIndex] = {
                        "name": folderName,
                        "count": images.length,
                        "path": projectController.rollPath
                    };
                    rollList = newRollList;
                } else {
                    // 添加新胶卷
                    var newRollList = rollList.slice();
                    newRollList.push({
                        "name": folderName,
                        "count": images.length,
                        "path": projectController.rollPath
                    });
                    rollList = newRollList;
                }
                // 选择当前胶卷并更新图像列表
                selectedRoll = folderName;
                imageList = images;
                console.log("成功导入胶卷:", folderName, "包含", images.length, "张有效图像");
                console.log("网格将显示前", imageCount, "张图像，剩余格子显示占位文本");
                // 加载第一张有效图像
                if (images.length > 0)
                    imageController.loadImage(images[0].path);

            }
        }

        function onErrorOccurred(message) {
            console.log("项目控制器错误:", message);
            // 导入失败时，清空图像列表，显示空网格
            // 每个格子显示"Image"占位文本，保持布局结构完整
            imageList = [];
            selectedRoll = "";
            console.log("导入失败，显示空网格，当前", imageCount, "个格子，每个格子显示占位文本");
        }

        target: projectController
    }

    Connections {
        // 当前图像变化时的处理

        function onCurrentImageChanged() {
        }

        target: imageController
    }

    Connections {
        function onErrorOccurred(message) {
            console.log("主控制器错误:", message);
        }

        target: mainController
    }

}
