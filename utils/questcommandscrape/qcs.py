# ghidra jython script for the ps4 build. dumps all function signatures for each result and check quest command handlers
spaceID = getAddressFactory().getDefaultAddressSpace().getSpaceID()

command = 1
resultFuncTableSymbol = list(currentProgram.symbolTable.getSymbols("pResultfuncTable"))[0]
while True:
    fnAddrOffset = getLong(pResultfuncTable.address.add(command*16))
    fnAddr = getAddressFactory().getAddress(spaceID, fnAddrOffset)
    executeCommandFunction = currentProgram.functionManager.getFunctionAt(fnAddr)
    if executeCommandFunction is None:
        break
    print(command, executeCommandFunction.getSignature())
    command = command + 1

command = 1
checkFuncTableSymbol = list(currentProgram.symbolTable.getSymbols("pCheckfuncTable"))[0]
while True:
    fnAddrOffset = getLong(checkFuncTableSymbol.address.add(command*16))
    fnAddr = getAddressFactory().getAddress(spaceID, fnAddrOffset)
    executeCommandFunction = currentProgram.functionManager.getFunctionAt(fnAddr)
    if executeCommandFunction is None:
        break
    print(command, executeCommandFunction.getSignature())
    command = command + 1