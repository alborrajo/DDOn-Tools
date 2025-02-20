extends WindowDialog

signal settings_updated()

func _on_SettingsWindowDialog_about_to_show():
	$VBoxContainer/ShowPlayersInAllTabsCheckBox.pressed = StorageProvider.get_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS_DEFAULT)
	
	$VBoxContainer/ExpSuggestionsFlowContainer/EnemiesToLevelUpSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP_DEFAULT)
	$VBoxContainer/ExpSuggestionsFlowContainer/BossesToLevelUpSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP_DEFAULT)
	
	$VBoxContainer/RPCGridContainer/RPCHostLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, RpcClient.STORAGE_KEY_RPC_HOST_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPortSpinBox.value = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, RpcClient.STORAGE_KEY_RPC_PORT_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPathLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, RpcClient.STORAGE_KEY_RPC_PATH_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_USERNAME, RpcClient.STORAGE_KEY_RPC_USERNAME_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PASSWORD, RpcClient.STORAGE_KEY_RPC_PASSWORD_DEFAULT)
	

func _on_SettingsWindowDialog_popup_hide():
	StorageProvider.set_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, $VBoxContainer/ShowPlayersInAllTabsCheckBox.pressed)
	
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP, $VBoxContainer/ExpSuggestionsFlowContainer/EnemiesToLevelUpSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP, $VBoxContainer/ExpSuggestionsFlowContainer/BossesToLevelUpSpinBox.value)
	
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, $VBoxContainer/RPCGridContainer/RPCHostLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, $VBoxContainer/RPCGridContainer/RPCPortSpinBox.value)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, $VBoxContainer/RPCGridContainer/RPCPathLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_USERNAME, $VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PASSWORD, $VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text)

	emit_signal("settings_updated")
