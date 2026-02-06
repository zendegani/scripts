#!/usr/bin/python

with open('INCAR', 'r') as file:
    lines=file.readlines()
    for n,i in enumerate(lines):
        if 'MAGMOM' in i: 
#             print(i)
            items=i.split()
            index=items.index('=') 
            moments=items[index+1:]
#             print(moments)

magmom=''
size=4
for i in range(len(moments)//3):
    k=' '.join(k for k in moments[3*i:3*i+3])
    magmom+=(k+' ')*size
print(magmom)
