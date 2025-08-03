import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15
import Revela 1.0

ApplicationWindow {
    // 超过36个时，使用平方根计算
    // 超过100个时，使用平方根计算
    // 当前预览的图像索引

    id: fileManagementWindow

    property string currentPath: ""
    property var rollList: []
    property string selectedRoll: ""
    property var imageList: []
    // 网格列数控制
    property int gridColumns: 6
    // 默认6列
    property real thumbnailSize: {
        // 根据列数和可用宽度计算缩略图大小，确保填满空间
        var availableWidth = Math.max(800, fileManagementWindow.width - 240 - 48 - 16);
        // 窗口宽度 - 左侧栏 - 边距 - 滚动条空间
        var spacing = 16;
        var totalSpacing = (gridColumns - 1) * spacing;
        var size = (availableWidth - totalSpacing) / gridColumns;
        var result = Math.max(60, size); // 最小60px
        console.log("计算缩略图大小 - 可用宽度:", availableWidth, "列数:", gridColumns, "计算大小:", result);
        return result;
    }
    // 视图状态管理
    property bool isGridView: true
    // true: 网格视图, false: 单图预览
    property int currentImageIndex: 0

    // 函数
    function loadRolls() {
        // 检查是否有已加载的项目
        if (projectController && projectController.rollLoaded) {
            var rollName = projectController.getRollName();
            var frameCount = projectController.frameCount;
            rollList = [{
                "name": rollName,
                "count": frameCount,
                "path": projectController.rollPath
            }];
            selectedRoll = rollName;
            console.log("加载已存在的胶卷:", rollName, "包含", frameCount, "张图片");
        } else {
            // 启动时不加载默认胶卷，等待用户导入
            rollList = [];
            console.log("初始化空胶卷列表");
        }
    }

    function loadImages() {
        // 切换胶卷时重新加载图像
        if (!selectedRoll) {
            imageList = [];
            console.log("未选择胶卷，显示空网格");
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
            console.log("未找到胶卷数据，显示空网格");
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

    // 从项目控制器加载图片数据
    function loadImagesFromProject() {
        console.log("从项目控制器重新加载图片数据");
        if (projectController && projectController.rollLoaded) {
            var images = [];
            var frameCount = projectController.frameCount;
            for (var i = 0; i < frameCount; i++) {
                var framePath = projectController.getFramePath(i);
                var frameName = projectController.getFrameName(i);
                if (framePath)
                    images.push({
                        "path": framePath,
                        "name": frameName,
                        "index": i
                    });

            }
            imageList = images;
            console.log("重新加载了", imageList.length, "张图片");
            // 设置选中的胶卷名称
            selectedRoll = projectController.getRollName();
            // 如果imageController中有当前图片，尝试找到对应的索引
            if (imageController && imageController.currentImagePath) {
                var currentPath = imageController.currentImagePath.replace("file:///", "").replace("file://", "");
                for (var j = 0; j < imageList.length; j++) {
                    if (imageList[j].path === currentPath || imageList[j].path.endsWith(currentPath)) {
                        currentImageIndex = j;
                        console.log("找到当前图片，索引:", j);
                        break;
                    }
                }
            }
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
        // 检查是否已经有加载的项目数据
        if (projectController && projectController.rollLoaded) {
            console.log("检测到已加载的项目，重新加载图片数据");
            loadImagesFromProject();
        } else {
            // 启动时显示空网格，默认16个格子（4x4），等待用户导入
            imageList = [];
            console.log("File management window initialized with empty grid, thumbnail size:", thumbnailSize);
        }
    }

    // 主背景
    Rectangle {
        anchors.fill: parent
        color: "#1C1C1E"
        focus: true
        // 键盘事件处理
        Keys.onPressed: function(event) {
            if (!isGridView) {
                // 单图预览模式下的键盘导航
                if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                    if (currentImageIndex > 0) {
                        currentImageIndex--;
                        console.log("键盘导航：上一张图像，索引:", currentImageIndex);
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                    if (currentImageIndex < imageList.length - 1) {
                        currentImageIndex++;
                        console.log("键盘导航：下一张图像，索引:", currentImageIndex);
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return) {
                    isGridView = true;
                    console.log("键盘导航：返回网格视图");
                    event.accepted = true;
                }
            }
        }

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
                            enabled: gridColumns < 10
                            onClicked: {
                                if (gridColumns < 10) {
                                    gridColumns++;
                                    console.log("增加列数到:", gridColumns, "缩略图大小:", thumbnailSize);
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
                            id: gridColumnsSlider

                            from: 2
                            to: 10
                            value: gridColumns
                            stepSize: 1
                            implicitWidth: 120
                            implicitHeight: 20
                            onValueChanged: {
                                var newColumns = Math.round(value);
                                if (newColumns !== gridColumns) {
                                    gridColumns = newColumns;
                                    console.log("调整列数到:", gridColumns, "缩略图大小:", thumbnailSize);
                                }
                            }

                            background: Rectangle {
                                x: gridColumnsSlider.leftPadding
                                y: gridColumnsSlider.topPadding + gridColumnsSlider.availableHeight / 2 - height / 2
                                implicitWidth: 120
                                implicitHeight: 4
                                width: gridColumnsSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: "#333333"
                            }

                            handle: Rectangle {
                                x: gridColumnsSlider.leftPadding + gridColumnsSlider.visualPosition * (gridColumnsSlider.availableWidth - width)
                                y: gridColumnsSlider.topPadding + gridColumnsSlider.availableHeight / 2 - height / 2
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
                            enabled: gridColumns > 2
                            onClicked: {
                                if (gridColumns > 2) {
                                    gridColumns--;
                                    console.log("减少列数到:", gridColumns, "缩略图大小:", thumbnailSize);
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
                            text: gridColumns.toString()
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
                        enabled: projectController && projectController.rollLoaded && imageList.length > 0
                        onClicked: {
                            // 确保当前选中的图片已加载到imageController
                            if (currentImageIndex < imageList.length && imageList[currentImageIndex]) {
                                if (imageController)
                                    imageController.loadImage(imageList[currentImageIndex].path);

                            }
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

                            // 搜索图标
                            Text {
                                text: "🔍"
                                color: "#9CA3AF"
                                font.pixelSize: 14
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // 搜索输入框
                            TextField {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 32
                                anchors.rightMargin: 12
                                placeholderText: "Search..."
                                color: "white"
                                font.pixelSize: 14
                                verticalAlignment: TextInput.AlignVCenter

                                background: Rectangle {
                                    color: "transparent"
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

                    // 网格视图
                    ScrollView {
                        id: gridScrollView

                        visible: isGridView
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        anchors.rightMargin: 24 + 16 // 为滚动条留出空间
                        anchors.topMargin: 24
                        anchors.bottomMargin: 24
                        clip: true
                        // 确保内容宽度正确更新
                        onWidthChanged: {
                            console.log("ScrollView宽度变化:", width);
                        }

                        GridLayout {
                            id: imageGrid

                            property real availableWidth: parent.width // 使用ScrollView的实际宽度
                            property real cellSize: thumbnailSize // 直接使用缩略图大小

                            width: parent.width // 确保网格宽度跟随父容器
                            columns: gridColumns // 动态列数
                            columnSpacing: 16 // 网格间距
                            rowSpacing: 16 // 网格间距
                            // 监听宽度变化
                            onWidthChanged: {
                                console.log("GridLayout宽度变化:", width, "列数:", columns);
                            }

                            // 显示所有图片
                            Repeater {
                                model: imageList.length

                                Rectangle {
                                    // 只打印第一个单元格的信息避免日志过多

                                    property real cellSize: imageGrid.cellSize

                                    Layout.preferredWidth: cellSize
                                    Layout.preferredHeight: cellSize // 保持正方形
                                    Layout.minimumWidth: 80
                                    Layout.minimumHeight: 80
                                    color: "#262626"
                                    radius: 8
                                    // 调试信息
                                    onWidthChanged: {
                                        if (index === 0)
                                            console.log("单元格[0]宽度变化:", width, "高度:", height);

                                    }

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
                                        onDoubleClicked: {
                                            // 双击进入单图预览模式
                                            if (index < imageList.length && imageList[index] && imageList[index].path) {
                                                currentImageIndex = index;
                                                isGridView = false;
                                                console.log("进入单图预览模式，图像索引:", index);
                                            }
                                        }
                                    }

                                }

                            }

                        }

                        ScrollBar.vertical: ScrollBar {
                            parent: parent.parent // 设置为ScrollView的父容器
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: 8 // 距离右边缘8px
                            width: 12
                            policy: ScrollBar.AsNeeded

                            background: Rectangle {
                                color: "#2A2A2A"
                                radius: 6
                                opacity: 0.5
                            }

                            contentItem: Rectangle {
                                color: parent.pressed ? "#888888" : (parent.hovered ? "#666666" : "#555555")
                                radius: 6
                            }

                        }

                        ScrollBar.horizontal: ScrollBar {
                            policy: ScrollBar.AlwaysOff
                        }

                    }

                    // 单图预览视图
                    Rectangle {
                        id: singleImageView

                        anchors.fill: parent
                        color: "#1C1C1E"
                        visible: !isGridView

                        // 主图像显示区域
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 24
                            color: "transparent"

                            // 当前图像
                            Image {
                                id: singleImage

                                anchors.centerIn: parent
                                width: Math.min(parent.width, parent.height * (sourceSize.width / Math.max(sourceSize.height, 1)))
                                height: Math.min(parent.height, parent.width * (sourceSize.height / Math.max(sourceSize.width, 1)))
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                source: {
                                    if (currentImageIndex < imageList.length && imageList[currentImageIndex] && imageList[currentImageIndex].path)
                                        return imageController.getPreviewImagePath(imageList[currentImageIndex].path);

                                    return "";
                                }

                                // 双击返回网格视图
                                MouseArea {
                                    anchors.fill: parent
                                    onDoubleClicked: {
                                        isGridView = true;
                                        console.log("双击返回网格视图");
                                    }
                                }

                            }

                            // 导航控件
                            Row {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 20
                                spacing: 20

                                // 上一张按钮
                                Button {
                                    width: 40
                                    height: 40
                                    text: "◀"
                                    enabled: currentImageIndex > 0
                                    onClicked: {
                                        if (currentImageIndex > 0) {
                                            currentImageIndex--;
                                            console.log("切换到上一张图像，索引:", currentImageIndex);
                                        }
                                    }

                                    background: Rectangle {
                                        color: parent.enabled ? (parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")) : "#1A1A1A"
                                        radius: 20
                                        opacity: 0.8
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.enabled ? "#FFD60A" : "#666666"
                                        font.pixelSize: 16
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                }

                                // 图像计数显示
                                Rectangle {
                                    width: 80
                                    height: 40
                                    color: "#262626"
                                    radius: 20
                                    opacity: 0.8

                                    Text {
                                        anchors.centerIn: parent
                                        text: (currentImageIndex + 1) + " / " + imageList.length
                                        color: "white"
                                        font.pixelSize: 14
                                    }

                                }

                                // 下一张按钮
                                Button {
                                    width: 40
                                    height: 40
                                    text: "▶"
                                    enabled: currentImageIndex < imageList.length - 1
                                    onClicked: {
                                        if (currentImageIndex < imageList.length - 1) {
                                            currentImageIndex++;
                                            console.log("切换到下一张图像，索引:", currentImageIndex);
                                        }
                                    }

                                    background: Rectangle {
                                        color: parent.enabled ? (parent.pressed ? "#404040" : (parent.hovered ? "#404040" : "#262626")) : "#1A1A1A"
                                        radius: 20
                                        opacity: 0.8
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: parent.enabled ? "#FFD60A" : "#666666"
                                        font.pixelSize: 16
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
                // 移除自动调整逻辑，显示所有图片
                console.log("成功导入胶卷:", folderName, "包含", images.length, "张有效图像");
                console.log("网格将显示所有", images.length, "张图像，缩略图大小:", thumbnailSize);
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
            console.log("导入失败，显示空网格");
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
