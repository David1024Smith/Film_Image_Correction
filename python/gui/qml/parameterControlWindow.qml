import "./components"
import Qt5Compat.GraphicalEffects
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: parameterControlWindow

    // 接收从adjustmentWindow传递的数据
    property var imageList: []
    property int selectedImageIndex: 0
    property string currentImagePath: ""

    // 从项目控制器加载图片数据
    function loadImagesFromProject() {
        console.log("从项目控制器加载图片数据");
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

    // 更新选中索引
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

    width: 1400
    height: 900
    title: "图片编辑器 - Revela"
    visible: true
    color: "#1C1C1E"
    // 初始化时从projectController获取图片数据
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
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.flipVertical();

                        }

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

                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Flip Horizontal"
                        ToolTip.visible: hovered
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.flipHorizontal();

                        }

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

                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Rotate Right"
                        ToolTip.visible: hovered
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.rotateRight();

                        }

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

                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Rotate Left"
                        ToolTip.visible: hovered
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.rotateLeft();

                        }

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

                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        ToolTip.text: "Zoom In"
                        ToolTip.visible: hovered
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.zoomIn();

                        }

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

                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // 中央分类按钮
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spacing: 48

                    Button {
                        text: "胶片"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 64
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.switchToFilm();

                        }

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

                    }

                    Button {
                        text: "成片"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 64
                        onClicked: {
                            if (typeof parameterController !== 'undefined')
                                parameterController.switchToFinal();

                        }

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

                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // 右侧完成按钮
                Button {
                    text: "完成"
                    height: 30
                    implicitWidth: 64
                    onClicked: {
                        // 跳转回文件管理窗口，完成循环
                        console.log("完成按钮被点击，导航回文件管理窗口");
                        var component = Qt.createComponent("fileManagementWindow.qml");
                        if (component.status === Component.Ready) {
                            var newWindow = component.createObject();
                            if (newWindow) {
                                newWindow.show();
                                parameterControlWindow.close();
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
                            id: mainImage

                            anchors.fill: parent
                            anchors.margins: 1
                            fillMode: Image.PreserveAspectFit
                            source: {
                                if (imageController && imageController.currentImagePath)
                                    return imageController.currentImagePath;

                                return "";
                            }
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

                        // 缩略图切换按钮
                        Button {
                            id: thumbnailToggleBtn

                            property bool thumbnailsVisible: true

                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: 16
                            width: 120
                            height: 30
                            onClicked: {
                                thumbnailsVisible = !thumbnailsVisible;
                                thumbnailContainer.visible = thumbnailsVisible;
                            }

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
                                    model: imageList.length

                                    Rectangle {
                                        width: 96
                                        height: 80
                                        color: "transparent"
                                        border.color: index === selectedImageIndex ? "#FFD60A" : "#404040"
                                        border.width: 1

                                        Image {
                                            id: thumbnailImage

                                            anchors.fill: parent
                                            anchors.margins: 1
                                            fillMode: Image.PreserveAspectCrop
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
                                            onClicked: {
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

            // 右侧工具栏
            RightToolbar {
                id: rightToolbar
            }

        }

    }

}
