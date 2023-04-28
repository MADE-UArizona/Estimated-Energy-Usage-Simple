// AGPLv3

import UM 1.5 as UM
import QtQuick 2.15
import QtQuick.Window 2.2
import QtQuick.Controls 2.15

import Cura 1.5 as Cura

UM.Dialog
{
    id: base
    title: "Estimated Energy"
    width: 300 * screenScaleFactor
    height: 400 * screenScaleFactor
    minimumWidth: 300 * screenScaleFactor
    minimumHeight: 300 * screenScaleFactor

    function saveSettings() {
        UM.Preferences.setValue('estimated_energy/power', parseFloat(txtPowerRate.text))
    }

    onVisibleChanged: {
        if (visible) {
            txtPowerRate.text = UM.Preferences.getValue('estimated_energy/power')
            txtMaterialDensity.text = UM.Preferences.getValue('estimated_energy/density')
            txtMaterialWeight.text = UM.Preferences.getValue('estimated_energy/weight')
            txtMaterialPrintTemp.text = UM.Preferences.getValue('estimated_energy/print_temp')
            txtMaterialBedTemp.text = UM.Preferences.getValue('estimated_energy/bed_temp')

            let energy = UM.Preferences.getValue('estimated_energy/estimated_energy')
            estimatedEnergyText.text = `${energy.toLocaleString()} J`;
        }
    }

    Column
    {
        width: parent.width
        spacing: 2 * screenScaleFactor

        Connections
        {
            target: UM.Preferences
            function onPreferenceChanged(preference)
            {
                if (preference === "estimated_energy/estimated_energy")
                {
                    let value = UM.Preferences.getValue(preference);
                    estimatedEnergyText.text = `${value.toLocaleString()} J`;
                    return;
                }
                if (preference === "estimated_energy/density")
                {
                    let value = UM.Preferences.getValue(preference);
                    txtMaterialDensity.text = value;
                    return;
                }
                if (preference === "estimated_energy/weight")
                {
                    let value = UM.Preferences.getValue(preference);
                    txtMaterialWeight.text = value;
                    return;
                }
                if (preference === "estimated_energy/print_temp")
                {
                    let value = UM.Preferences.getValue(preference);
                    txtMaterialPrintTemp.text = value;
                    return;
                }
                if (preference === "estimated_energy/bed_temp")
                {
                    let value = UM.Preferences.getValue(preference);
                    txtMaterialBedTemp.text = value;
                    return;
                }

                if (preference === "estimated_energy/power")
                {
                    let rated_power = parseFloat(UM.Preferences.getValue(preference));
                    let density = parseFloat(UM.Preferences.getValue('estimated_energy/density'));
                    let material_weight = parseFloat(UM.Preferences.getValue('estimated_energy/weight'))
                    let print_temp = parseFloat(UM.Preferences.getValue('estimated_energy/print_temp'))
                    let bed_temp = parseFloat(UM.Preferences.getValue('estimated_energy/bed_temp'))

                    let estimated_energy = 0.5 + (0.25 * print_temp +
                            0.25 * bed_temp +
                            0.25 * material_weight/density) * 0.5 * rated_power * bed_temp

                    UM.Preferences.setValue('estimated_energy/estimated_energy', Math.round(estimated_energy));
                    return;
                }
            }
        }

        UM.Label
        {
            text: "Printer's rated power"
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Row
        {
            spacing: 2 * screenScaleFactor
            Cura.TextField
            {
                id: txtPowerRate
                width: base.width *2/3
                maximumLength: 20
                validator: DoubleValidator {bottom: 0; top: 999999}
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter 
            }

            UM.Label
            {
                text: "  W"
                height: txtPowerRate.height
                verticalAlignment: Text.verticalCenter
            }
        }

        UM.Label
        {
            text: 'Material density'
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Row
        {
            spacing: 2 * screenScaleFactor
            Text
            {
                id: txtMaterialDensity
                width: base.width *2/3
                enabled: false
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter 
            }

            UM.Label
            {
                text: "  g/cm3"
                height: txtPowerRate.height
                verticalAlignment: Text.verticalCenter
            }
        }

        UM.Label
        {
            text: 'Material weight'
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Row
        {
            spacing: 2 * screenScaleFactor
            Text
            {
                id: txtMaterialWeight
                width: base.width *2/3
                enabled: false
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter 
            }

            UM.Label
            {
                text: "  g"
                height: txtPowerRate.height
                verticalAlignment: Text.verticalCenter
            }
        }

        UM.Label
        {
            text: 'Material print temperature'
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Row
        {
            spacing: 2 * screenScaleFactor
            Text
            {
                id: txtMaterialPrintTemp
                width: base.width *2/3
                enabled: false
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter 
            }

            UM.Label
            {
                text: "  C"
                height: txtPowerRate.height
                verticalAlignment: Text.verticalCenter
            }
        }

        UM.Label
        {
            text: 'Material bed temperature'
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Row
        {
            spacing: 2 * screenScaleFactor
            Text
            {
                id: txtMaterialBedTemp
                width: base.width *2/3
                enabled: false
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter 
            }

            UM.Label
            {
                text: "  C"
                height: txtPowerRate.height
                verticalAlignment: Text.verticalCenter
            }
        }
        
        UM.Label
        {
            text: '\nEstimated Energy Usage'
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment : Text.AlignVCenter 
        }

        Row
        {
            spacing: 2 * screenScaleFactor
            Text
            {
                id: estimatedEnergyText
                width: base.width
                enabled: false
                font.pixelSize: 16
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter 
            }
        }
    }

    leftButtons: Cura.SecondaryButton
    {
        text: "Save"
        onClicked:
        {
            base.saveSettings();
        }
    }

    rightButtons: Cura.SecondaryButton
    {
        text: "Close"
        onClicked:
        {
            base.visible = false;
        }
    }

}
