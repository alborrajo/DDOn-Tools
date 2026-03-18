extends Window

signal settings_updated()

func _on_SettingsWindowDialog_about_to_show():
	$VBoxContainer/ShowPlayersInAllTabsCheckBox.button_pressed = StorageProvider.get_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS_DEFAULT)
	
	$VBoxContainer/ExpSuggestionsFlowContainer/EnemiesToLevelUpSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP_DEFAULT)
	$VBoxContainer/ExpSuggestionsFlowContainer/BossesToLevelUpSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP_DEFAULT)
	$VBoxContainer/HOBOSuggestionsGridContainer/PlayPointsSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_PLAY_POINTS_RATE, Enemy.STORAGE_KEY_PLAY_POINTS_RATE_DEFAULT)
	$VBoxContainer/HOBOSuggestionsGridContainer/BloodOrbSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BLOOD_ORB_RATE, Enemy.STORAGE_KEY_BLOOD_ORB_RATE_DEFAULT)
	$VBoxContainer/HOBOSuggestionsGridContainer/HighOrbSpinBox.value = StorageProvider.get_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_HIGH_ORB_RATE, Enemy.STORAGE_KEY_HIGH_ORB_RATE_DEFAULT)
	$VBoxContainer/ApplySuggestedValuesCheckBox.button_pressed = false
	
	$VBoxContainer/ShopPriceSuggestionsFlowContainer/ShopPriceSpinBox.value = StorageProvider.get_value(ShopItem.STORAGE_SECTION_SHOPS, ShopItem.STORAGE_KEY_SHOP_PRICE_RATE, ShopItem.STORAGE_KEY_SHOP_PRICE_RATE_DEFAULT)
	$VBoxContainer/ApplySuggestedValuesCheckBox2.button_pressed = false
	
	$VBoxContainer/RPCGridContainer/RPCHostLineEdit.text = StorageProvider.get_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_HOST, RpcRequest.STORAGE_KEY_RPC_HOST_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPortSpinBox.value = StorageProvider.get_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_PORT, RpcRequest.STORAGE_KEY_RPC_PORT_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPathLineEdit.text = StorageProvider.get_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_PATH, RpcRequest.STORAGE_KEY_RPC_PATH_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text = StorageProvider.get_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_USERNAME, RpcRequest.STORAGE_KEY_RPC_USERNAME_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text = StorageProvider.get_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_PASSWORD, RpcRequest.STORAGE_KEY_RPC_PASSWORD_DEFAULT)
	
# Godot 4 migration
# The popout_hide signal was removed so I rename this to *_close_requested
# func _on_SettingsWindowDialog_popup_hide():
func _on_SettingsWindowDialog_close_requested():
	# Godot 4 migration
	# renamed the property pressed to button_pressed
	# StorageProvider.set_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, $VBoxContainer/ShowPlayersInAllTabsCheckBox.pressed)
	StorageProvider.set_value(Players.STORAGE_SECTION_PLAYERS, Players.STORAGE_KEY_SHOW_IN_ALL_TABS, $VBoxContainer/ShowPlayersInAllTabsCheckBox.button_pressed)
	
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_ENEMIES_TO_LEVEL_UP, $VBoxContainer/ExpSuggestionsFlowContainer/EnemiesToLevelUpSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BOSSES_TO_LEVEL_UP, $VBoxContainer/ExpSuggestionsFlowContainer/BossesToLevelUpSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_PLAY_POINTS_RATE, $VBoxContainer/HOBOSuggestionsGridContainer/PlayPointsSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_BLOOD_ORB_RATE, $VBoxContainer/HOBOSuggestionsGridContainer/BloodOrbSpinBox.value)
	StorageProvider.set_value(Enemy.STORAGE_SECTION_ENEMIES, Enemy.STORAGE_KEY_HIGH_ORB_RATE, $VBoxContainer/HOBOSuggestionsGridContainer/HighOrbSpinBox.value)
	
	StorageProvider.set_value(ShopItem.STORAGE_SECTION_SHOPS, ShopItem.STORAGE_KEY_SHOP_PRICE_RATE, $VBoxContainer/ShopPriceSuggestionsFlowContainer/ShopPriceSpinBox.value)
	
	StorageProvider.set_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_HOST, $VBoxContainer/RPCGridContainer/RPCHostLineEdit.text)
	StorageProvider.set_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_PORT, $VBoxContainer/RPCGridContainer/RPCPortSpinBox.value)
	StorageProvider.set_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_PATH, $VBoxContainer/RPCGridContainer/RPCPathLineEdit.text)
	StorageProvider.set_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_USERNAME, $VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text)
	StorageProvider.set_value(RpcRequest.STORAGE_SECTION_RPC, RpcRequest.STORAGE_KEY_RPC_PASSWORD, $VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text)
	
	if $VBoxContainer/ApplySuggestedValuesCheckBox.button_pressed:
		SetProvider.apply_suggested_values_for_all_enemies()
		
	if $VBoxContainer/ApplySuggestedValuesCheckBox2.button_pressed:
		SetProvider.apply_suggested_values_for_all_shops()

	emit_signal("settings_updated")
	# Godot 4 migration
	# we have to hide the window manually now
	hide()

func _on_ApplySuggestedEXPCheckBox_toggled(button_pressed):
	if button_pressed:
		$VBoxContainer/ApplySuggestedValuesCheckBox/ConfirmationDialog.popup()
		$VBoxContainer/ApplySuggestedValuesCheckBox.button_pressed = false

func _on_ConfirmationDialog_confirmed():
	$VBoxContainer/ApplySuggestedValuesCheckBox.set_pressed_no_signal(true)


func _on_ApplySuggestedValuesCheckBox2_toggled(button_pressed):
	if button_pressed:
		$VBoxContainer/ApplySuggestedValuesCheckBox2/ShopConfirmationDialog.popup()
		$VBoxContainer/ApplySuggestedValuesCheckBox2.button_pressed = false

func _on_ShopConfirmationDialog_confirmed():
	$VBoxContainer/ApplySuggestedValuesCheckBox2.set_pressed_no_signal(true)
