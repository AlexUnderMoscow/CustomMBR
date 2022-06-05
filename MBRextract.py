
imagefile = "picoBSD.img"
newMBRFile = "MBRextract.bin"

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

MBR = LoadBlock(imagefile,0)
SaveFile(newMBRFile,MBR)
print("MBR extracted")

