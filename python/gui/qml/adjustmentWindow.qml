import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"

ApplicationWindow {
    id: root

    // 接收从fileManagementWindow传递的数据
    property var imageList: []
    property int selectedImageIndex: 0
    property string currentImagePath: ""

    function loadImagesFromProject() {
        if (projectController && projectController.rollLoaded) {
            // 从file:// URL中提取路径

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
            console.log("从项目加载了", imageList.length, "张图片");
            // 如果imageController中有当前图片，尝试找到对应的索引
            var currentPath = "";
            if (imageController && imageController.currentImagePath)
                currentPath = imageController.currentImagePath.replace("file:///", "").replace("file://", "");

            // 查找当前图片在列表中的索引
            var foundIndex = -1;
            for (var j = 0; j < imageList.length; j++) {
                if (imageList[j].path === currentPath || imageList[j].path.endsWith(currentPath)) {
                    foundIndex = j;
                    break;
                }
            }
            // 设置当前选中的图片
            if (foundIndex >= 0) {
                selectedImageIndex = foundIndex;
                currentImagePath = imageList[foundIndex].path;
                console.log("找到当前图片，索引:", foundIndex);
            } else if (imageList.length > 0) {
                selectedImageIndex = 0;
                currentImagePath = imageList[0].path;
                // 加载主图片
                if (imageController)
                    imageController.loadImage(currentImagePath);

                console.log("使用第一张图片作为默认选择");
            }
        } else {
            console.log("项目控制器未加载或胶卷未加载");
            imageList = [];
            selectedImageIndex = 0;
            currentImagePath = "";
        }
    }

    function updateSelectedIndex() {
        if (!imageController || !imageController.currentImagePath || imageList.length === 0)
            return ;

        // 从file:// URL中提取路径
        var currentPath = imageController.currentImagePath.replace("file:///", "").replace("file://", "");
        // 查找当前图片在列表中的索引
        for (var i = 0; i < imageList.length; i++) {
            if (imageList[i].path === currentPath || imageList[i].path.endsWith(currentPath)) {
                if (selectedImageIndex !== i) {
                    selectedImageIndex = i;
                    currentImagePath = imageList[i].path;
                    console.log("更新选中图片索引:", i);
                }
                break;
            }
        }
    }

    // 获取动态创建选择框的相对坐标函数
    function getSelectionRelativeCoords() {
        if (!selectionMouseArea || !selectionMouseArea.selectionBox || !mainImage) {
            return null;
        }
        
        var selectionBox = selectionMouseArea.selectionBox;
        var imageWidth = mainImage.paintedWidth;
        var imageHeight = mainImage.paintedHeight;
        
        if (imageWidth <= 0 || imageHeight <= 0) {
            return null;
        }
        
        var imageX = (mainImage.width - imageWidth) / 2;
        var imageY = (mainImage.height - imageHeight) / 2;
        
        var relativeX = (selectionBox.x - imageX) / imageWidth;
        var relativeY = (selectionBox.y - imageY) / imageHeight;
        var relativeWidth = selectionBox.width / imageWidth;
        var relativeHeight = selectionBox.height / imageHeight;
        
        return {
            x: Math.max(0, Math.min(1, relativeX)),
            y: Math.max(0, Math.min(1, relativeY)),
            width: Math.max(0, Math.min(1, relativeWidth)),
            height: Math.max(0, Math.min(1, relativeHeight))
        };
    }

    width: 1400
    height: 900
    visible: true
    title: "图片编辑器"
    color: "#1C1C1E"
    

    // 组件初始化
    Component.onCompleted: {
        loadImagesFromProject();
        // 连接projectController信号
        if (projectController) {
            projectController.rollLoadedChanged.connect(loadImagesFromProject);
            projectController.frameCountChanged.connect(loadImagesFromProject);
        }
        // 连接imageController信号
        if (imageController)
            imageController.currentImageChanged.connect(updateSelectedIndex);
    }

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

                // 中间标题文本
                Text {
                    text: "胶片成像区框选"
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
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
                            source: {
                                if (imageController && imageController.currentImagePath)
                                    return imageController.currentImagePath;

                                return "";
                            }
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: source !== "" && status === Image.Ready
                            onStatusChanged: {
                                if (status === Image.Error)
                                    console.log("主图片加载错误:", source);
                                else if (status === Image.Ready)
                                    console.log("主图片加载成功:", source);
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

                        // 手动框选功能 
                        MouseArea {
                            id: selectionMouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            
                            property bool isSelecting: false
                            property real startX: 0
                            property real startY: 0
                            property var selectionBox: null
                            
                            onPressed: function(mouse) {
                                if (mouse.button === Qt.LeftButton) {
                                    isSelecting = true;
                                    startX = mouse.x;
                                    startY = mouse.y;
                                    
                                    // 动态创建选择框
                                    if (selectionBox) {
                                        selectionBox.destroy();
                                    }
                                    
                                    var component = Qt.createComponent("data:text/plain,import QtQuick 2.15; Rectangle { color: '#40FFD60A'; border.color: '#FFD60A'; border.width: 2; }");
                                    selectionBox = component.createObject(selectionMouseArea, {
                                        x: startX,
                                        y: startY,
                                        width: 0,
                                        height: 0
                                    });
                                    
                                    console.log("开始框选:", startX, startY);
                                } else if (mouse.button === Qt.RightButton) {
                                    // 右键清除选择框
                                    if (selectionBox) {
                                        selectionBox.destroy();
                                        selectionBox = null;
                                        console.log("右键清除选择框");
                                    }
                                }
                            }
                            
                            onPositionChanged: function(mouse) {
                                if (isSelecting && selectionBox) {
                                    var currentX = mouse.x;
                                    var currentY = mouse.y;
                                    
                                    var rectX = Math.min(startX, currentX);
                                    var rectY = Math.min(startY, currentY);
                                    var rectWidth = Math.abs(currentX - startX);
                                    var rectHeight = Math.abs(currentY - startY);
                                    
                                    selectionBox.x = rectX;
                                    selectionBox.y = rectY;
                                    selectionBox.width = rectWidth;
                                    selectionBox.height = rectHeight;
                                }
                            }
                            
                            onReleased: function(mouse) {
                                if (mouse.button === Qt.LeftButton && isSelecting) {
                                    isSelecting = false;
                                    
                                    if (selectionBox && (selectionBox.width < 10 || selectionBox.height < 10)) {
                                        selectionBox.destroy();
                                        selectionBox = null;
                                        console.log("选择区域太小，已清除");
                                    } else if (selectionBox) {
                                        console.log("框选完成:", selectionBox.x, selectionBox.y, selectionBox.width, selectionBox.height);
                                    }
                                }
                            }
                            
                            onDoubleClicked: function(mouse) {
                                if (mouse.button === Qt.LeftButton && selectionBox) {
                                    selectionBox.destroy();
                                    selectionBox = null;
                                    console.log("双击清除选择框");
                                }
                            }
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
                                    text: "Thumbnails (" + imageList.length + ")"
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

                    // 缩略图滚动区域
                    Rectangle {
                        id: thumbnailContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "transparent"

                        ScrollView {
                            anchors.fill: parent
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                            ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                            Row {
                                spacing: 8

                                // 显示所有图片的缩略图
                                Repeater {
                                    model: imageList.length

                                    Rectangle {
                                        width: 96
                                        height: 80
                                        color: "#262626"
                                        border.color: index === selectedImageIndex ? "#FFD60A" : "#666666"
                                        border.width: 1
                                        radius: 8

                                        Image {
                                            id: thumbnailImage

                                            anchors.fill: parent
                                            anchors.margins: 1
                                            source: {
                                                if (index < imageList.length && imageList[index] && imageList[index].path) {
                                                    if (imageController)
                                                        return imageController.getPreviewImagePath(imageList[index].path);

                                                    // 确保路径格式正确
                                                    var path = imageList[index].path;
                                                    if (path.startsWith("file://"))
                                                        return path;
                                                    else
                                                        return "file:///" + path.replace(/\\/g, "/");
                                                }
                                                return "";
                                            }
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            visible: source !== "" && status === Image.Ready
                                            onStatusChanged: {
                                                if (status === Image.Error)
                                                    console.log("缩略图", index, "加载错误:", source);
                                                else if (status === Image.Ready)
                                                    console.log("缩略图", index, "加载成功:", source);
                                            }
                                        }

                                        // 占位文本
                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                if (index < imageList.length && imageList[index] && imageList[index].name) {
                                                    // 只显示文件名，不显示扩展名
                                                    var name = imageList[index].name;
                                                    var dotIndex = name.lastIndexOf('.');
                                                    return dotIndex > 0 ? name.substring(0, dotIndex) : name;
                                                }
                                                return "Image " + (index + 1);
                                            }
                                            color: "#6B7280"
                                            font.pixelSize: 10
                                            visible: thumbnailImage.source === "" || thumbnailImage.status !== Image.Ready
                                            wrapMode: Text.WordWrap
                                            width: parent.width - 4
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: function(mouse) {
                                                console.log("缩略图", index, "被点击");
                                                if (index < imageList.length && imageList[index]) {
                                                    selectedImageIndex = index;
                                                    currentImagePath = imageList[index].path;
                                                    if (imageController)
                                                        imageController.loadImage(currentImagePath);

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
