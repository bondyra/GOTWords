library(dplyr)

data = read.table("~/repos/GOTWords/data.txt",sep=",",header=T,quote="")

shinyServer(function(input, output) {
  
  #R data processing
  get_words = function (data, charname, wordno = 1, prev_words=NULL, cnt = 30){
    
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
  
  #get words cloud response
  getCloud <- function(){
    if (!is.null(input$req_data)){
      req_name = input$req_data$name;
      req_order_id = input$req_data$orderID;
      
      get_words(data = data, charname = req_name)
    }
  }
  output$perfbarplot <- reactive(getCloud())  #when data changes, update the bar plot

})
