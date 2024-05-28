// Copyright (c) 2022 Aldo Hoeben / fieldOfView
// PauseBackendPlugin is released under the terms of the AGPLv3 or higher.

import UM 1.5 as UM
import Cura 1.5 as Cura

import QtQuick 2.2
import QtQuick.Controls 2.3

Item
{
    id: base

    Cura.SecondaryButton
    {
        id: estimatedEnergyButton
        objectName: "estimatedEnergyButton"
        width: 220 * screenScaleFactor
        
        Connections
        {
            target: UM.Preferences
            function onPreferenceChanged(preference)
            {
                if (preference !== "estimated_energy/estimated_energy")
                {
                    return;
                }

                let value = UM.Preferences.getValue(preference);
                estimatedEnergyText.text = `<p>Estimated Energy: ${value.toLocaleString()} MJ</p>`;
            }
        }

        function toggleSettings()
        {
            UM.Preferences.setValue("estimated_energy/open_settings", false);
            UM.Preferences.setValue("estimated_energy/open_settings", true);
        }

        Text {
            id: estimatedEnergyText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 5 * screenScaleFactor
            text: '<p>Estimated Energy: --- MJ</p>'
            font.pixelSize: 14
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment : Text.AlignVCenter 
        }
        
        onClicked: toggleSettings()
    }

    UM.I18nCatalog{id: catalog; name:"cura"}
}
