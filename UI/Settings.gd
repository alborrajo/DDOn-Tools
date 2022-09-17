extends WindowDialog

func _on_SettingsWindowDialog_about_to_show():
	$GridContainer/RPCHostLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, RpcClient.STORAGE_KEY_RPC_HOST_DEFAULT)
	$GridContainer/RPCPortSpinBox.value = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, RpcClient.STORAGE_KEY_RPC_PORT_DEFAULT)
	$GridContainer/RPCPathLineEdit.text = StorageProvider.get_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, RpcClient.STORAGE_KEY_RPC_PATH_DEFAULT)

func _on_SettingsWindowDialog_popup_hide():
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_HOST, $GridContainer/RPCHostLineEdit.text)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PORT, $GridContainer/RPCPortSpinBox.value)
	StorageProvider.set_value(RpcClient.STORAGE_SECTION_RPC, RpcClient.STORAGE_KEY_RPC_PATH, $GridContainer/RPCPathLineEdit.text)
