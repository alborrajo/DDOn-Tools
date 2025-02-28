extends WindowDialog

signal settings_updated()

func _on_SettingsWindowDialog_about_to_show():
	$VBoxContainer/ShowPlayersInAllTabsCheckBox.pressed = StorageProvider.get_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS_DEFAULT)
	
	$VBoxContainer/ExpSuggestionsFlowContainer/EnemiesToLevelUpSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP_DEFAULT)
	$VBoxContainer/ExpSuggestionsFlowContainer/BossesToLevelUpSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP_DEFAULT)
	$VBoxContainer/HOBOSuggestionsGridContainer/BloodOrbSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BLOOD_ORB_RATE, Enemy.STORAGE_KEY_BLOOD_ORB_RATE_DEFAULT)
	$VBoxContainer/HOBOSuggestionsGridContainer/HighOrbSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_HIGH_ORB_RATE, Enemy.STORAGE_KEY_HIGH_ORB_RATE_DEFAULT)
	$VBoxContainer/ApplySuggestedValuesCheckBox.pressed = false
	
	$VBoxContainer/RPCGridContainer/RPCHostLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, RpcClient.STORAGE_KEY_RPC_HOST_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPortSpinBox.value = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, RpcClient.STORAGE_KEY_RPC_PORT_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPathLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, RpcClient.STORAGE_KEY_RPC_PATH_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_USERNAME, RpcClient.STORAGE_KEY_RPC_USERNAME_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PASSWORD, RpcClient.STORAGE_KEY_RPC_PASSWORD_DEFAULT)
	

func _on_SettingsWindowDialog_popup_hide():
	StorageProvider.set_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, $VBoxContainer/ShowPlayersInAllTabsCheckBox.pressed)
	
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP, $VBoxContainer/ExpSuggestionsFlowContainer/EnemiesToLevelUpSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP, $VBoxContainer/ExpSuggestionsFlowContainer/BossesToLevelUpSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BLOOD_ORB_RATE, $VBoxContainer/HOBOSuggestionsGridContainer/BloodOrbSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_HIGH_ORB_RATE, $VBoxContainer/HOBOSuggestionsGridContainer/HighOrbSpinBox.value)
	
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, $VBoxContainer/RPCGridContainer/RPCHostLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, $VBoxContainer/RPCGridContainer/RPCPortSpinBox.value)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, $VBoxContainer/RPCGridContainer/RPCPathLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_USERNAME, $VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PASSWORD, $VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text)
	
	if $VBoxContainer/ApplySuggestedValuesCheckBox.pressed:
		SetProvider.apply_suggested_values_for_all_enemies()

	emit_signal("settings_updated")


func _on_ApplySuggestedEXPCheckBox_toggled(button_pressed):
	if button_pressed:
		$VBoxContainer/ApplySuggestedValuesCheckBox/ConfirmationDialog.popup()
		$VBoxContainer/ApplySuggestedValuesCheckBox.pressed = false

func _on_ConfirmationDialog_confirmed():
	$VBoxContainer/ApplySuggestedValuesCheckBox.set_pressed_no_signal(true)
