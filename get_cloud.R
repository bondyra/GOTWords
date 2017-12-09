
data = read.table("~/repos/GOTWords/data.txt",sep=",",header=T,quote="")

library(dplyr)

#return top n words spoken by character, enforcing previous words' left context
#charname - name of character
#wordno - number of word in sentence, defaults to the first word
#prev_words - previous words in sentence, defaults to none (proper for wordno default)
#cnt - how many words do you want in cloud, defaults to 30
get_cloud = function (charname, wordno = 1, prev_words=NULL, cnt = 30){
  
  stopifnot ((wordno-1) == length(prev_words))
  name_words = data %>% filter(name==charname)
  
  if (wordno==1){ #first word, simple operation
    topwords = name_words %>% filter(order_id==1) %>% group_by(word) %>% summarise(n=n()) %>% arrange(desc(n)) %>% as.data.frame %>% head(cnt)
  }else{#processing word context
    #iterative search of sentences fullfilling context bounds
    good_sentences = name_words %>% distinct(sentence_id)
    for (i in 1:(wordno-1)){
      tmpsentences = name_words %>% filter((sentence_id %in% good_sentences$sentence_id) &(order_id==i) & (word==prev_words[i]) ) %>% distinct(sentence_id)
      good_sentences = tmpsentences
    }
    tmpwords = name_words %>% filter((order_id==wordno) & (sentence_id %in% good_sentences$sentence_id))
    topwords = tmpwords %>% group_by(word) %>% summarise(n=n()) %>% arrange(desc(n)) %>% as.data.frame %>% head(cnt)
  }
  return (topwords)
}