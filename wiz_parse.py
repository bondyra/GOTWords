import fileinput
import re

sentence_id = 0
words = []

print ('name\tsentence_id\torder_id\tword')
for line in fileinput.input():
	if (re.search("\w.+:.*",line) != None):
		m = re.search("^(?P<name>\w.+):(?P<words>[^:]*)<br>$",line)
		if (m == None):
			continue
		name = m.group("name");
		wordstring = m.group("words");
		
		sentence_id = sentence_id+1;
		wordstring = wordstring.replace('.',' ').replace('\'',' ').replace('-','').replace(',','').replace('!','').replace('?','').replace('(','').replace(')','').replace('<i>','').replace('</i>','')
		words = wordstring.split(" ");
		
		#usuwanie czegos co nie jest slowami:
		words = filter((lambda x: re.search("\w",x)!= None),words)
		#nowe wiersze na wyjsciu:
		for i in range(0,len(words)):
			print ("{}\t{}\t{}\t{}".format(name, sentence_id, i, words[i])); 
		
