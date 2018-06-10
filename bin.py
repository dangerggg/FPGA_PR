# -*- coding: utf-8 -*-
from PIL import Image
import numpy as np 
import matplotlib as plt 

resultname ='result.bin'
for i in range(0,3):

    if i < 10:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]000"+str(i)+".bmp"
    elif i < 100:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]00"+str(i)+".bmp"
    elif i < 1000:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]0"+str(i)+".bmp"
    elif i < 10000:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]"+str(i)+".bmp"
    
    nums = 0
    im = Image.open(filename)
    img = np.array(im)
    for rows in range(img.shape[0]):
        for columns in range(img.shape[1]):
            x = ((img[rows,columns,0]>>7)&1)*128 + ((img[rows,columns,0]>>6)&1)*64 + ((img[rows,columns,0]>>5)&1)*32 + ((img[rows,columns,1]>>7)&1)*16 + ((img[rows,columns,1]>>6)&1)*8 + ((img[rows,columns,1]>>5)&1)*4 + ((img[rows,columns,2]>>7)&1)*2 + ((img[rows,columns,2]>>6)&1)*1
            y = x.astype(np.uint8)
            if nums == 0 and i == 0:
                with open(resultname,'wb') as f:
                    f.write(y)
                nums = nums + 1
            else:
                with open(resultname,'ab') as f:
                    f.write(y)
                nums = nums + 1
    print(i)
