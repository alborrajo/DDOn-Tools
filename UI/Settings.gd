extends WindowDialog

func _on_SettingsWindowDialog_about_to_show():
	$VBoxContainer/RPCGridContainer/RPCHostLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, RpcClient.STORAGE_KEY_RPC_HOST_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPortSpinBox.value = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, RpcClient.STORAGE_KEY_RPC_PORT_DEFAULT)
	$VBoxContainer/RPCGridContainer/RPCPathLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, RpcClient.STORAGE_KEY_RPC_PATH_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_USERNAME, RpcClient.STORAGE_KEY_RPC_USERNAME_DEFAULT)
	$VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PASSWORD, RpcClient.STORAGE_KEY_RPC_PASSWORD_DEFAULT)

func _on_SettingsWindowDialog_popup_hide():
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, $VBoxContainer/RPCGridContainer/RPCHostLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, $VBoxContainer/RPCGridContainer/RPCPortSpinBox.value)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, $VBoxContainer/RPCGridContainer/RPCPathLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_USERNAME, $VBoxContainer/RPCCredentialsGridContainer/UserLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PASSWORD, $VBoxContainer/RPCCredentialsGridContainer/PassLineEdit.text)
