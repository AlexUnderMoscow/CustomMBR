
def my_crc32(password):
    val = 0xFFFFFFFF
    pattern = 0xEDB88320
    for ch in password:
        byte = (ord(ch)^val) & 0xFF
        crc = 0
        for i in range(8):
            if (byte^crc) & 0x01:
                crc = (crc>>1) ^ pattern
            else:
                crc = crc >> 1
            byte = byte >> 1  
        val = (val>>8) ^ crc
    crc = -1 - val
    return crc
    
    
data = (
    '',
    'test1234',
    'hello',
    '1234',
    'string',
)    

print("---")
print("test1234")
print(hex(my_crc32("test1234") & 0xffffffff))
print("---")

#print("crc = ", hex(crc))
#for s in data:
    #print (s)
    #b = my_crc32(s)
    #print (hex(b & 0xffffffff))
    #print