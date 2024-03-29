
#################################################################
#                    PART 06) 비정형 데이터마이닝             
#################################################################



##===============================================================
### 1. 텍스트마이닝 : 텍스트로부터 고품질의 정보를 도출하는 분석방법으로, 입력된 텍스트를 구조화해 그 데이터에서
###                   패턴을 도출한 후 결과를 평가 및 해석하는 일련의 과정.
###                   단어들 간의 관계를 이용해 감성분석, 워드클라우드 분석 등을 수행한 후 이 정보를 클러스터링, 
###                   분류, 사회연결망 분석 등에 활용할 수 있음.

### 해당 과정에서는 ADP 실기에 출제되는 한글에 대한 텍스트 마이닝 분석 방법을 설명함.

## 가. 데이터 전처리 : 수집된 데이터에 문장 부호나 의미 없는 숫자와 단어, URL등과 같이 분석을 하는데 있어
##                     유의하게 사용되지 않는 부분을 제거하거나 변형하여 분석에 용이하게 텍스트를 가공하는 과정.

# 1) tm : tm 패키지는 문서를 관리하는 기본구조인 Corpus를 생성하여 tm_map 함수를 통해 데이터들을 전처리 및 가공함.
#         Corpus와 VCorpus 중 VCorpus에서 에러가 적게 나타나므로 VCorpus를 활용

#VectorSource(text)   #텍스트 마이닝 전 텍스트 데이터를 문서로 만들기 위한 함수.

#VCoupus(data)         #data는 vectorSource함수를 실행한 데이터가 들어가야함.

#ex) 아래의 R 내장데이터로 코퍼스를 살펴보자.

library(tm)

data(crude)       #crude데이터는 로이터 뉴스 기사 중 원유와 관련된 기사 20개가 저장되어 있음.

summary(crude)[1:6,]    #summary를 통해 20개의 기사가 있음을 확인할 수 있음.
#class는 TextDocument 이며, list 형태로 저장되어 있음

inspect(crude[1])   #inspect함수로 문서의 character수 등을 확인할 수 있음.

crude[[1]]$content  #첫번째 문서의 본문은 왼쪽 명령어처럼 작성하여 확인이 가능(리스트 이므로)


#tm_map(x,            #x는 코퍼스 데이터
#       FUN)          #FUN은 변환에 사용할 함수, 종류는 아래와 같음

#tm_map(x,tolower) : 소문자로 만들기
#tm_map(x,stemDocument) : 어근만 남기기
#tm_map(x,stripWhitespace) : 공백제거
#tm_map(x,removePunctuation) : 문장부호 제거
#tm_map(x,removeNumbers) : 숫자 제거
#tm_map(x,removeWords,“word”) : 단어 제거
#tm_map(x,remobeWords,stopwords(“english”)) : 불용어 제거
#tm_map(x,PlainTextDocument) : TextDocument로 변환 


#ex) 데이터 분석 전문가라는 키워드로 뉴스기사를 검색하여 10개의 기사를 수집하였다.
#    아래의 데이터를 Corpus로 만들고, tm_map함수로 데이터를 전처리해보자.

news<-readLines("키워드_뉴스.txt")

news

news.corpus<-VCorpus(VectorSource(news))

news.corpus[[1]]$content

clean_txt<-function(txt){
  txt<-tm_map(txt, removeNumbers)       #숫자제거       
  txt<-tm_map(txt, removePunctuation)   #문장부호 제거
  txt<-tm_map(txt, stripWhitespace)     #공백제거
  return(txt)
}

clean.news<-clean_txt(news.corpus)

clean.news[[1]]$content


txt2<-gsub("[[:punct:]]","",clean.news[[1]])   #gsub 함수는 엑셀 등에서의 찾아바꾸기의 기능을 함.
txt2


# 2) 자연어처리(KoNLP) : KoNLP가 대표적이며, KoNLP 사용 시 rJava패키지를 설치해야 함.
#                        자연어 처리에 앞서 reference를 삼을 사전을 설정. 주로 SejongDic 사용
#                        extraNoun, mergeUserDic, SimplePos09 등의 함수로 자연어 처리가 가능

#extraNoun(text)                    #텍스트 중 명사를 추출하는 함수.
#buildDictionary(ext_dic,           #사전에 단어를 추가으로 추가할 사전을 선택, "woorimalsam", "sejong" 등이 있음.
#                data)              #data는 추가하고자하는 단어와 품사.
#SimplePos22(txt)                   #22개의 품사 태그를 달아주는 함수.

#ex) 간단한 문장으로 명사추출, 사전 단어추가, 품사를 확인해보자.

library(KoNLP)

useSejongDic()         #세종사전 사용

sentence<-'아버지가 방에 스르륵 들어가신다.'

extractNoun(sentence)  #'스르륵'은 명사가 아니라 부사임. '스르륵'이란 단어가 세종사전에 포함되어 있지 않으므로
#'스르륵'을 부사로 세종사전에 추가

buildDictionary(ext_dic="sejong",                           #sejong 사전에 스르륵을 부사로 추가.
                user_dic=data.frame(c('스르륵'),c('mag')))

extractNoun(sentence)  #'스르륵'이 명사로 추출되지 않음을 알 수 있음.

SimplePos22(sentence)  #품사를 확인할 수 있음. NC은 명사(N으로 시작하는건 모두 명사)이며, 
#PV는 동사, PA는 형용사, MA는 부사임.



#ex) 위의 news데이터에서 corpus로 변환하지 않고 전처리 및 명사추출, 사전추가, 품사확인을 해보자.

# tm패키지에서 tm_map()에 들어가는 FUN을 그대로 사용하여 전처리가 가능

clean_txt2<-function(txt){
  txt<-removeNumbers(txt)          #숫자 제거
  txt<-removePunctuation(txt)      #문장부호 제거
  txt<-stripWhitespace(txt)        #공백제거
  txt<-gsub("[^[:alnum:]]"," ",txt) #영숫자, 문자를 제외한 것들을 " "으로 처리
  return(txt)
}

clean.news2<-clean_txt2(news)

Noun.news<-extractNoun(clean.news2)     #각 문서마다 명사가 추출

Noun.news[5]

#clean.news2의 5번째 기사에서 '푸드테크', '스타트업', '빅데이터', '우아한형제들' 명사로 추가하여 명사추출

Noun.news[5]      #푸드와 테크, 스타트와 업을 따로 인식하고, 빅데이터를,이 와 우아한형제들대표 등 명사로 인식 못함.

buildDictionary(ext_dic="sejong",                               
                user_dic=data.frame(c(read.table("food.txt"))))   #text파일 형태로 호출 가능

extractNoun(clean.news2[5])         #스타트업, 빅데이터, 푸드테크, 우아한형제들이 명사로 추출됨을 확인

#SimplePos22를 활용해 형용사 추출하기.(stringr 패키지의 str_match함수로 형용사 뽑아내기)
library(stringr)

doc1<-paste(SimplePos22(clean.news2[[2]]))    #SimplePos22를 통해 품사를 구분하고, 분석에 용이하게 하기 위해


doc2<-str_match(doc1,"([가-힣]+)/PA")         #품사중 PA가 형용사이므로 형용사만 뽑아내기 위해 str_match함수 이용.

doc2

doc3<-doc2[,2]                                #결과 중 품사가 안붙어있는 2열만 뽑아냄
doc3[!is.na(doc3)]                            #NA가 아닌 형용사만 뽑아내어 나타냄.


# 3) Stemming : 어간추출은 공통 어간을 가지는 단어를 묶는 작업
#               stemDocument, stemCompletion을 활용하여 완성.

# stemDocument(text)               #문자 또는 문서

# stemCompletion(text,             #stemming이 완료된 문자 또는 문서
#                dictionary,       #어간 추출이 필요한 단어를 사전에 추가
#                ...)

#ex) analyze, analyzed, analyzing 단어의 어간을 추출하고 가장 기본단어로 만들어 보자.

test<-stemDocument(c('analyze', 'analyzed','analyzing'))
test                            # 앞 어간을 제외한 나머지 부분은 잘려나가게 됨.

completion<-stemCompletion(test,dictionary = c('analyze', 'analyzed','analyzing'))
completion                      # analyz로 stemming되었던 단어들이 dictionary에 포함된 단어 중 가장 기본 어휘로 완성



## 나. Term-Document Matrix : Corpus의 데이터를 각 문서와 단어 간의 사용 여부를 이용해 만들어진 matrix가 TDM임.
##                          : TDM을 보면 등장한 각 단어의 빈도수를 쉽게 확인할 수 있음.

#TermDocumentMatrix(data,     
#                   control)   #사전변경, 가중치부여 등의 옵션을 활용할 수 있음.

#ex) 전처리가 완료된 clean.news2 데이터를 VCorpus로 변환하여 TDM을 만들어보자.

VC.news<-VCorpus(VectorSource(clean.news2))

VC.news[[1]]$content

TDM.news<-TermDocumentMatrix(VC.news)
dim(TDM.news)              #10개의 기사에서 총 1011개의 단어가 추출되어 1011개의 행과 10개의 열을 가지는 형태

inspect(TDM.news[1:5,])          #생성된 TDM에서 전체 문서와 단어의 분포를 확인.
#여기서 '빅데이터'라는 단어가 1번문서에는 1번, 2번문서에는 3번 등으로 사용됐음을 확인.

#명사만 추출하는 TermDocumentMatrix를 만들기위한 사용자 정의함수 생성
words<-function(doc){
  doc<-as.character(doc)
  extractNoun(doc)
}

TDM.news2<-TermDocumentMatrix(VC.news, control=list(tokenize=words))
dim(TDM.news2)             #10개의 기사에서 총 289개의 단어가 추출되어 289개의 행과 10개의 열을 가지는 형태

inspect(TDM.news2)         #생성된 TDM에서 전체 문서와 단어의 분포를 확인.

#TDM으로 나타난 단어들의 빈도 체크
tdm2<-as.matrix(TDM.news2)
tdm3<-rowSums(tdm2)
tdm4<-tdm3[order(tdm3, decreasing = T)]
tdm4[1:10]      #1~10위까지만 나타냄.


#분석에 사용하고자하는 단어들을 별도 사전으로 정의해 해당 단어들에 대해서만 결과를 산출

mydict<-c("빅데이터", "스마트", "산업혁명", "인공지능", "사물인터넷", "AI", "스타트업", "머신러닝")

my.news<-TermDocumentMatrix(VC.news,control=list(tokenize=words, dictionary=mydict))

inspect(my.news)            #별도 사전으로 정의된 단어만 떠있음을 확인할 수 있음.


## 다. 분석 및 시각화 

# 1) 연관규칙분석 : 작성된 TDM에서 특정 단어와의 연관성에 따라 단어를 조회할 수 있음.

#findAssocs(data,        #TDM
#           terms,       #연관성을 확인할 단어
#           corlimit)    #최소 연관성

#ex) TDM에서 '분석'이라는 단어와의 연관성이 0.3이상인 단어들만 표시

findAssocs(TDM.news2,'빅데이터',0.9)    #빅데이터란 단어와 무슨 내용이 연관되어 함께 언급되는지 알수 있음.

# 2) 워드 클라우드 : 문서에 포함되는 단어의 사용 빈도를 효과적으로 보여주기 위해 워드 클라우드를 이용
#                    wordcloud 패키지를 이용

#wordcloud(words,         #단어
#          freq,          #단어의 빈도
#          min.freq,      #최소 빈도
#          random.order,  #단어 배치를 물어봄. F면 빈도순으로 그려짐.
#          colors,        #단어의 색, R의 색상 파레트 함수인 brewer.pal을 주로 사용.
#          ...)

#ex) TDM.news2 데이터를 워드클라우드로 만들어보자.

install.packages("wordcloud")
library(wordcloud)

tdm2<-as.matrix(TDM.news2)
term.freq<-sort(rowSums(tdm2),decreasing = T)    #행을 기준으로 모든 열의 값을 합하여 각 단어에 대한 빈도수 계산.
head(term.freq,15)

wordcloud(words=names(term.freq),        #term.freq의 이름만 가져옴.
          freq=term.freq,                #빈도는 위에 저장한 term.freq.
          min.freq=5,                    #최소빈도는 5
          random.order=F,
          colors=brewer.pal(8,'Dark2'))