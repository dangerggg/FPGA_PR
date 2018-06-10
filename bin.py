# -*- coding: utf-8 -*-
resultname ='result.bin'
for i in range(1,10000):
    print(i)
    if i < 10:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]000"+str(i)+".bmp"
    elif i < 100:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]00"+str(i)+".bmp"
    elif i < 1000:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]0"+str(i)+".bmp"
    elif i < 10000:
        filename = "0001.哔哩哔哩-小猪佩奇女生版四川话，软绵绵的-45605025[流畅版]"+str(i)+".bmp"
    with open(filename,'rb') as f:
        s = f.read()
        read_data = s[54:921654]
        if i == 7:
            with open(resultname,'wb') as f1:
                f1.write(read_data)
        else:
            with open(resultname,'rb') as f0:
                s0 = f0.read()
                read_data = s0 + read_data
            with open(resultname,'wb') as f1:
                f1.write(read_data)

