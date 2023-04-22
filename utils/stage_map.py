from io import BufferedReader
from typing import Any
import json
import struct

def readcstr(f: BufferedReader):
    buf = bytearray()
    while True:
        b = f.read(1)
        if b[0] == 0:
            return buf.decode('utf-8')
        else:
            buf.append(b[0])


with open("gui_cmn\\param\\stage_map.34CE45C5","rb") as file:
    data: list[dict[str, Any]] = []
    
    file.read(4) # dunno, its just a 1
    elements = int.from_bytes(file.read(4), byteorder='little')
    for i in range(elements):
        datum = {}
        data.append(datum)
        datum["StageNo"],datum["PartsNum"],datum["OffsetY"],datum["StageFlag"] = struct.unpack('<HHfI', file.read(12))
        
        paramList: list[dict[str, Any]] = []
        datum["ParamList"] = paramList

        cParamsListSize = int.from_bytes(file.read(4), byteorder='little')
        for j in range(cParamsListSize):
            param = {}
            paramList.append(param)
            param["AreaNo"],param["Size"] = struct.unpack('<If', file.read(8))
            param["ModelName"] = readcstr(file)

            param["ConnectPos"] = {}
            param["ConnectPos"]["x"],param["ConnectPos"]["y"],param["ConnectPos"]["z"] = struct.unpack('<3f', file.read(12))            
    
    print(json.dumps(data, indent=4))