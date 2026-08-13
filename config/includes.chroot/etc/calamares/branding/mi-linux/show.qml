import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 20000
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Text {
            anchors.centerIn: parent
            text: qsTr("Welcome to MI Linux Founder Preview.<br/>" +
                  "The rest of the installation is automated and should complete in a few minutes.")
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
            font.pixelSize: 22
            color: "#031326"
        }
    }
}
