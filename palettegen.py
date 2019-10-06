# palette LUT gen

from itertools import product

palettes = [
    '0143456689abcd8e',
    '014355562493d522',
    '0144555524941122',
]

table = ''.join(
    ''.join(i[0]+i[1] for i in product(p, p)) for p in palettes
)

# print in 128 nibble blocks
for i in range(12):
    print(table[i*128:(i+1)*128])
