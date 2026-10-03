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
                  "The installer walks you through language, keyboard, disk, and user setup before anything is written.")
            wrapMode: Text.WordWrap
            width: 720
            horizontalAlignment: Text.Center
            font.pixelSize: 22
            color: "#031326"
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            text: qsTr("Choose the target disk carefully.<br/>" +
                  "Erase disk is the simplest path for a dedicated MI Linux computer, but it removes the selected drive's existing data.")
            wrapMode: Text.WordWrap
            width: 720
            horizontalAlignment: Text.Center
            font.pixelSize: 22
            color: "#031326"
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            text: qsTr("Review the summary before installing.<br/>" +
                  "MI Linux asks for confirmation at the point of no return, then completes the install and offers to reboot.")
            wrapMode: Text.WordWrap
            width: 720
            horizontalAlignment: Text.Center
            font.pixelSize: 22
            color: "#031326"
        }
    }
}
