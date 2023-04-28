// LGPLv3

import UM 1.5 as UM
import QtQuick 2.15
import QtQuick.Window 2.2
import QtQuick.Controls 2.15

import Cura 1.5 as Cura

UM.Dialog
{
    id: base
    title: "About"
    width: 300 * screenScaleFactor
    height: 100 * screenScaleFactor
    minimumWidth: 300 * screenScaleFactor
    minimumHeight: 100 * screenScaleFactor

    Text
    {
        anchors.fill: parent            
        onLinkActivated: Qt.openUrlExternally(link)
        color: UM.Theme.getColor("text")
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.horizontalCenter
        verticalAlignment: Text.verticalCenter
        text:
"
Energy Usage Estimation Plugin
Copyright © 2023 ---. All Rights Reserved.
"
    }
}
