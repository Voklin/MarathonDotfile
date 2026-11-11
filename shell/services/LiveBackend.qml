import QtQuick

QtObject {
    id: root

    property WorkspacesAdapter workspaces: WorkspacesAdapter {}
    property ActiveWindowAdapter activeWindow: ActiveWindowAdapter {}
    property AudioAdapter audio: AudioAdapter {}
    property NetworkAdapter network: NetworkAdapter {}
    property BluetoothAdapter bluetooth: BluetoothAdapter {}
    property BatteryAdapter battery: BatteryAdapter {}
    property BrightnessAdapter brightness: BrightnessAdapter {}
    property NotificationsAdapter notifications: NotificationsAdapter {}
    property SessionAdapter session: SessionAdapter {}
    property LauncherAdapter launcher: LauncherAdapter {}
    property AppearanceAdapter appearance: AppearanceAdapter {}
    property SettingsAdapter settings: SettingsAdapter {}
    property MediaAdapter media: MediaAdapter {}
    property UtilitiesAdapter utilities: UtilitiesAdapter {}
}

