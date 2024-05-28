# LGPLv3

import os.path

from typing import cast

from PyQt6.QtCore import QObject

from UM.i18n import i18nCatalog
from UM.Extension import Extension
from UM.Application import Application
from UM.PluginRegistry import PluginRegistry
from UM.Logger import Logger

from cura.CuraApplication import CuraApplication
from cura.Settings.ExtruderManager import ExtruderManager

catalog = i18nCatalog("cura")


class EstimatedEnergy(Extension, QObject):
    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        Extension.__init__(self)

        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/estimated_energy", 0)
        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/power", 220)
        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/density", 1.2)
        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/weight", 0)
        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/print_temp", 200)
        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/bed_temp", 60)
        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/current_print_time", 300)

        Application.getInstance().getPreferences().addPreference(
            "estimated_energy/open_settings", False)

        self.settings_window = None
        self.about_window = None
        self._print_info = None

        self.setMenuName("Esimated Energy")
        self.addMenuItem("Esimated Energy Settings", self.settings)
        self.addMenuItem("About", self.openAbout)

        self._application = CuraApplication.getInstance()
        self._application.engineCreatedSignal.connect(self._onEngineCreated)

    def _onPreferenceChanged(self, preference):
        Logger.log("d", "Changed key: ", preference)
        if preference == 'estimated_energy/open_settings':
            is_open = self._preferences.getValue(preference)
            if is_open:
                self.settings()

    def settings(self):
        if self.settings_window is None:
            self.settings_window = self._createSettingsDialogue()
        self.settings_window.show()

    def _createSettingsDialogue(self):
        qml_file_path = os.path.join(PluginRegistry.getInstance(
        ).getPluginPath(self.getPluginId()), "qml/Settings.qml")
        component = Application.getInstance().createQmlComponent(qml_file_path)

        return component

    def _createAutoSlideView(self):
        Logger.log("d", "Creating additional ui components for Auto Slide")

        qml_path = os.path.join(os.path.dirname(
            os.path.abspath(__file__)), "qml/AutoSlide.qml")

        self._autoslide_component = Application.getInstance(
        ).createQmlComponent(qml_path, {"manager": self})
        if not self._autoslide_component:
            Logger.log("w", "Could not create additional components.")
            return
        Application.getInstance().addAdditionalComponent(
            "saveButton", self._autoslide_component.findChild(QObject, "pauseResumeButton"))

    def _createEstimatedEnergyView(self):
        Logger.log(
            "d", "Creating additional ui components for display Energy Usage")
        qml_path = os.path.join(os.path.dirname(
            os.path.abspath(__file__)), "qml/EstimatedEnergy.qml")

        self._estimatedenergy_component = Application.getInstance(
        ).createQmlComponent(qml_path, {"manager": self})
        if not self._estimatedenergy_component:
            Logger.log("w", "Could not create additional components.")
            return
        Application.getInstance().addAdditionalComponent("saveButton",
                                                         self._estimatedenergy_component.findChild(QObject, "estimatedEnergyButton"))

    def openAbout(self):
        if not self.about_window:
            self.about_window = self._createAboutDialog()
        self.about_window.show()

    def _createAboutDialog(self):
        qml_file_path = os.path.join(PluginRegistry.getInstance(
        ).getPluginPath(self.getPluginId()), "qml/About.qml")
        component = Application.getInstance().createQmlComponent(qml_file_path)
        return component

    def _onEngineCreated(self) -> None:
        Application.getInstance().getPreferences().setValue(
            "estimated_energy/estimated_energy", 0)
        Application.getInstance().getPreferences().setValue(
            "estimated_energy/power", 220)
        Application.getInstance().getPreferences().setValue(
            "estimated_energy/density", 1.2)
        Application.getInstance().getPreferences().setValue(
            "estimated_energy/weight", 0)
        Application.getInstance().getPreferences().setValue(
            "estimated_energy/print_temp", 200)
        Application.getInstance().getPreferences().setValue(
            "estimated_energy/bed_temp", 60)

        self._print_info = self._application.getPrintInformation()
        self._print_info.currentPrintTimeChanged.connect(
            self._triggerJobNameUpdate)
        self._print_info.materialWeightsChanged.connect(
            self._triggerJobNameUpdate)
        self._print_info.jobNameChanged.connect(self._onJobNameChanged)

        self._global_stack = None
        CuraApplication.getInstance().getMachineManager(
        ).globalContainerChanged.connect(self._onMachineChanged)
        self._onMachineChanged()
        # self.settings()
        self._createAutoSlideView()
        self._createEstimatedEnergyView()

        self._preferences = Application.getInstance().getPreferences()
        self._preferences.preferenceChanged.connect(self._onPreferenceChanged)

    def _onJobNameChanged(self) -> None:
        if self._print_info._is_user_specified_job_name:
            job_name = self._print_info._job_name
            if job_name == catalog.i18nc("@text Print job name", "Untitled"):
                return

            self._print_info._is_user_specified_job_name = False

    def _onMachineChanged(self) -> None:
        if self._global_stack:
            self._global_stack.containersChanged.disconnect(
                self._triggerJobNameUpdate)
            self._global_stack.metaDataChanged.disconnect(
                self._triggerJobNameUpdate)

        self._global_stack = CuraApplication.getInstance().getGlobalContainerStack()

        if self._global_stack:
            self._global_stack.containersChanged.connect(
                self._triggerJobNameUpdate)
            self._global_stack.metaDataChanged.connect(
                self._triggerJobNameUpdate)

    def _triggerJobNameUpdate(self, *args, **kwargs) -> None:
        # Fixes filename clobbering from repeated calls
        self._print_info._job_name = ""

        application = cast(CuraApplication, Application.getInstance())

        print_info = application.getPrintInformation()
        first_extruder_stack = ExtruderManager.getInstance().getActiveExtruderStacks()[
            0]
        # active_extruder_stacks = ExtruderManager.getInstance().getActiveExtruderStacks()

        print_temp = first_extruder_stack.getProperty(
            "material_print_temperature", "value")
        bed_temp = first_extruder_stack.getProperty(
            "material_bed_temperature", "value")


        material_weights = print_info.materialWeights
        material_weight = 0
        current_print_time = int(print_info.currentPrintTime)
        if len(material_weights) > 1:
            material_weight = round(
                float(material_weights[0]), 3) + round(float(material_weights[1]), 3)
        if len(material_weights) == 1:
            material_weight = round(float(material_weights[0]), 3)
            

        # Get from settings
        rated_power = float(Application.getInstance().getPreferences().getValue(
            "estimated_energy/power"))
        density = round(float(first_extruder_stack.getMetaDataEntry(
            "properties", {}).get("density", 0)), 3)

        Logger.log("d", "== Calculated == {} {} {} {}".format(
            density, material_weight, print_temp, bed_temp))

        if not not material_weight:

            estimated_energy = 0.0212 + .0000984 * current_print_time
            estimated_energy = round(estimated_energy, 2)
            Logger.log("d", "== Estimated == {}".format(estimated_energy))

            Application.getInstance().getPreferences().setValue(
                "estimated_energy/estimated_energy", estimated_energy)
            Application.getInstance().getPreferences().setValue(
                "estimated_energy/density", density)
            Application.getInstance().getPreferences().setValue(
                "estimated_energy/weight", material_weight)
            Application.getInstance().getPreferences().setValue(
                "estimated_energy/print_temp", print_temp)
            Application.getInstance().getPreferences().setValue(
                "estimated_energy/bed_temp", bed_temp)

        return
