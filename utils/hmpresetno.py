file = open("game_common\\param\\hmem\\preset.11E53B6B","rb")
file.read(4)
elements = int.from_bytes(file.read(4), byteorder='little')
print("Number of elements: ", elements)

for n in range(elements):
    print("HmPresetNo: ", int.from_bytes(file.read(4), byteorder='little'))
    # skip other data
    file.read(15)