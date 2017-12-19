library(dplyr)
library(wordcloud)


data = read.table("data.txt",sep=",",header=T,quote="")
write.csv(character(0), "history.txt", row.names = F)
write.csv("TYRION", "character.txt", row.names = F)

shinyServer(function(input, output) {
	getNextWord = function() {
		renderUI({
			character = input$character
			nextword = input$nextword
			history = as.character(read.table("history.txt",header=T)[,1])
			lastWord = history[length(history)]
			if (length(lastWord) == 0)
				lastWord = ""
			words = get_words(data = data, charname = input$character, prev_words = history, cnt = 100) 
			selectInput("nextword", "Słowo:",unique(c(lastWord, as.character(words$word))), selected = lastWord)
		})
	}
	observeEvent(input$previous, {
		history = as.character(read.table("history.txt",header=T)[,1])
		history = head(history, length(history) - 1)
		write.csv(as.data.frame(history), "history.txt", row.names = F)
		output$nextword = getNextWord()
	})
  
  #R data processing
  get_words = function (data, charname, prev_words=character(0), cnt = 30){
    
    wordno = length(prev_words) + 1
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
  
  output$cloud <- renderPlot({
  	character = as.character(read.table("character.txt",header=T)[1,1])
  	if (input$character != character) {
  		write.csv(character(0), "history.txt", row.names = F)
  		write.csv(input$character, "character.txt", row.names = F)
  	}
  	history = as.character(read.table("history.txt",header=T)[,1])
  	lastWord = history[length(history)]
  	if (length(lastWord) == 0)
  		lastWord = ""
  	if (!is.null(input$nextword) && nchar(input$nextword) > 0 && input$nextword != lastWord) {
  		history[length(history) + 1] = input$nextword 
  		write.csv(as.data.frame(history), "history.txt", row.names = F)
  		lastWord = input$nextword
  	}
  	words = get_words(data = data, charname = input$character, prev_words = history, cnt = 100) 
  	if (length(words) > 0) {
	  		return(wordcloud(words$word, words$n, scale = c(0.5,10*input$dimension[1]/2560) #maksymalny rozmiar slowa zalezny od szerokosci okna
	  																		 , random.color=F, colors=heat.colors(30), min.freq = 0, max.words = 30))
	  	}
  	})  #when data changes, update the bar plot
  output$nextword = getNextWord()
})
