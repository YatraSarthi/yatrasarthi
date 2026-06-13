import QtQuick 2.12
import QtQuick.Controls 2.12
import "pages"

ApplicationWindow {
    visible: true
    width: 400
    height: 700
    title: "YatraSarthi"

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: homeComponent
    }

    Component {
        id: homeComponent

        HomePage {
            stack: stack
        }
    }
}