# Assumtions made in this assembler:
#   1. All numbers in the code are in hex format
#   2. All comments start with #
#   3. .ORG x y means that the following line would be at address x and it contains the content y
#   (whether instruction or another memory address as Reset, INT or Exception handler addresses)
#   4. All .ORG are sorted ascendingly
#   5. Always assume that in the document if written Rsrc without a number to be Rsrc1

import string

opCodes = { 'NOP':'00000',  'HLT':'00001',  'SETC':'00010', 'NOT':'00011',
            'INC':'00100',  'OUT':'00101',  'IN':'00110',   'MOV':'01000',
            'ADD':'01001',  'SUB':'01010',  'AND':'01011',  'PUSH':'01100',
            'POP':'01101',  'RTI':'01111',  'IADD':'10000', 'LDM':'10001',
            'LDD':'10010',  'STD':'10011',  'JZ':'11000',   'JN':'11001',
            'JC':'11010',   'JMP':'11011',  'CALL':'11100', 'RET':'11101', 
            'INT':'11111',  'R0':'000',     'R1':'001',     'R2':'010',
            'R3':'011',     'R4':'100',     'R5':'101',     'R6':'110', 'R7':'000'}

lines = []
emptymemaddress = 'XXXXXXXXXXXXXXXX'
zeromemaddress = '0000000000000000'

import sys                                          # read in <sourcefile> 2nd command parameter line by line
if len(sys.argv) != 2: print('usage: assembler.py <sourcefile>'); sys.exit(1)
f = open(sys.argv[1], 'r')
while True:                                         # read in the source line
    line = f.readline()
    if not line: break
    lines.append(line.strip())                      # store each line without leading/trailing whitespaces
f.close()

# print("Before:")
# print(lines)

for i in range(len(lines)):                         # PASS 1: do PER LINE replacements
    while(lines[i].find('\'') != -1):               # replace '...' occurances with corresponding ASCII code(s)
        k = lines[i].find('\'')
        l = lines[i].find('\'', k+1)
        if k != -1 and l != -1:
            replaced = ''
            for c in lines[i][k+1:l]: replaced += str(ord(c)) + ' '
            lines[i] = lines[i][0:k] + replaced + lines[i][l+1:]
        else: break

    if (lines[i].find('#') != -1): lines[i] = lines[i][0:lines[i].find('#')]    # delete comments
    lines[i] = lines[i].replace(',', ' ').strip()                             # replace commas with spaces

#Remove empty lines
newlines = []
for line in lines:
    if line != '':
        newlines.append(line.upper())
lines = newlines

print("After:")
print(lines)

# Create a new file to be the .mem file read by ModelSim
oldfname = sys.argv[1].split('.')
oldfname.pop()
outfilename = ''.join(oldfname) + '.mem'
outfile = open(outfilename, 'w+')
outfile.write('// format=mti addressradix=h dataradix=b version=1.0 wordsperline=1\n')
currentaddress = 0
for i in range(len(lines)):    
    if lines[i].startswith('.ORG'):
        #print('Split =',lines[i].split(' ')[1])
        memaddress = int(lines[i].split(' ')[1], 16)
        #print('Before: Memory Address=',memaddress,'Current Address',currentaddress)
        while memaddress> currentaddress :
            outfile.write(format(currentaddress, 'X')+': '+emptymemaddress+'\n')
            currentaddress += 1
        i+=1
        if all(c in string.hexdigits for c in lines[i]):
            #print('Entered if')
            #print(lines[i])
            if int(lines[i], 16) < 65536: #Then the first will contain the address and the 2nd will contain zeros
                outfile.write(format(currentaddress, 'X')+': '+( bin(int(lines[i], 16))[2:] ).zfill(16)+'\n')
                currentaddress += 1
                outfile.write(format(currentaddress, 'X')+': '+zeromemaddress+'\n')
                currentaddress += 1
            else: # Split the address into the 2 memory addresses (Very rare for our testcases so I'll write it's handeling later)
                longaddress =  bin(int(lines[i], 16))
                # outfile.write(format(currentaddress, 'X')+': '+emptymemaddress+'\n')
                # currentaddress += 1
                # outfile.write(format(currentaddress, 'X')+': '+( bin(int(lines[i+1], 16)) ).zfill(16)+'\n')
                # currentaddress += 1
            i+=1
        #print('After: Memory Address=',memaddress,'Current Address',currentaddress)
        continue
    for j in opCodes:
        if lines[i].startswith(j):
            instwords = lines[i].split(' ')
            instwords = [x.strip() for x in instwords] #Remove Extra WhiteSpace
            instwords = [i for i in instwords if i]    #Remove Empty string elements
            # Write the OpCode + Fn (5 bits)
            outfile.write(format(currentaddress, 'X')+': '+opCodes[j])
            print('Instwords=',instwords,'Lines[i]=',lines[i],'j=',j,'Opcode[j]=', opCodes[j])
            # Check if the instruction is INT:
            if instwords[0] == 'INT':
                if instwords[1] == '0': #Case of index = 0
                    outfile.write('00000000000\n')
                else:# Case of index = 2
                    outfile.write('00000000010\n')
                currentaddress += 1
                break
            # Check if the instruction is MOV:
            if instwords[0] == 'MOV':
                outfile.write(opCodes[instwords[1]]+'000'+opCodes[instwords[2]]+'00\n')
                currentaddress += 1
                break
            # Check if the instruction is STD:
            if instwords[0] == 'STD':
                offset = instwords[2].split('(')[0]
                Rsrc2 = instwords[2].split('(')[1].split(')')[0]
                outfile.write(opCodes[instwords[1]]+opCodes[Rsrc2]+'00000\n')
                currentaddress += 1
                offset = ( bin(int(offset, 16))[2:] ).zfill(16)
                outfile.write(format(currentaddress, 'X')+': '+offset+'\n')
                currentaddress += 1
                break
            # Check if the instruction is LDD:
            if instwords[0] == 'LDD':
                offset = instwords[2].split('(')[0]
                Rsrc = instwords[2].split('(')[1].split(')')[0]
                outfile.write(opCodes[Rsrc]+'000'+opCodes[instwords[1]]+'00\n')
                currentaddress += 1
                offset = ( bin(int(offset, 16))[2:] ).zfill(16)
                outfile.write(format(currentaddress, 'X')+': '+offset+'\n')
                currentaddress += 1
                break
            # Check if the instruction is LDM:
            if instwords[0] == 'LDM':
                # Write the address of Rdst and the rest is Zeros
                outfile.write('000000'+opCodes[instwords[1]]+'00\n')
                currentaddress += 1
                immediate = ( bin(int(instwords[2], 16))[2:] ).zfill(16)
                outfile.write(format(currentaddress, 'X')+': '+immediate+'\n')
                currentaddress += 1
                break

            # If the instruction is not INT or MOV or STD or LDD or LDM:
            instr = instwords.pop(0)
            inbinary = '00000000000'
            immediate = ''
            # If the instruction doesn't have any operands
            if len(instwords) == 0:
                # Write the 11 bits remaining as Zeros
                outfile.write(inbinary+'\n')
                currentaddress += 1
                break
            # If the instruction has only operand which is luckily always Rdst
            if len(instwords) == 1:
                # Write the address of Rdst and the rest is Zeros
                outfile.write('000000'+opCodes[instwords[0]]+'00\n')
                currentaddress += 1
                break
            
            # Mainly if the instruction is ADD or SUB or AND or IADD:
            inbinary = inbinary[0:6]+opCodes[instwords[0]]+inbinary[9:] # Rdst [6:8]
            inbinary = opCodes[instwords[1]]+inbinary[3:] # Rsrc1 [0:2]
            if instwords[2] in opCodes:
                inbinary = inbinary[0:3]+opCodes[instwords[2]]+inbinary[6:] # Rsrc2 [3:5]
            else:
                immediate = instwords[2]    #In case of IADD
            print('Inbinary=',inbinary)
            # # Write the 2 extra bits first
            # outfile.write('00\n')
            outfile.write(inbinary+'\n')
            currentaddress += 1

            # Check for immediate in case of IADD
            if immediate != '':
                immediateinbin = ( bin(int(immediate, 16))[2:] ).zfill(16)
                outfile.write(format(currentaddress, 'X')+': '+immediateinbin+'\n')
                currentaddress += 1
            break

# Fill the rest of the memory with Xs, since memory is 1 MB (2^20)
while currentaddress <= int('FFFFF', 16):
    outfile.write(format(currentaddress, 'X')+': '+emptymemaddress+'\n')
    currentaddress += 1

outfile.close()
