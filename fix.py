import re
data = open('src/main/webapp/chat.jsp', 'r', encoding='utf-8').read()
data = data.replace('${', '\\${')
open('src/main/webapp/chat.jsp', 'w', encoding='utf-8').write(data)
