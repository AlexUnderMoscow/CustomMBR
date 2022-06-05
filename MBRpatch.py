
imagefile = "picoBSD.img"
outFile = "new_picoBSD.img"
newMBRFile = "passMBR_1.com"

def LoadBlock(filename, blkNum):
    f = open(filename,'rb')
    f.seek(blkNum*512)
    array = f.read(512)
    return array

def LoadAllBlocks(filename):
    f = open(filename,'rb')
    f.seek(0)
    array = f.read()
    return array

def SaveAllBlocks(filename,buffer):
    f = open(filename,'wb')
    f.write(buffer)
    return

def SaveFile(filename, buffer):
    f = open(filename,'wb')
    f.write(buffer)
    return

newMBR = LoadBlock(newMBRFile,0)
inputImage = LoadAllBlocks(imagefile)
lst = list(inputImage)
for i in range(512):
    lst[i] = newMBR[i]
inputImage = bytearray(lst)
SaveFile(outFile,inputImage)
print("OS image patched")