library(shiny)
library(DT)
library(shinyjs)
library(V8)
library(shinycssloaders)
library(shinythemes)
library(gridExtra)

source("assignRoleTokens.R")
source("plotBestWords.R")
beta <- readRDS("finalBETA.RDS")
betaRelative <- readRDS("finalBETArelative.RDS")
titles <- readRDS("titles.RDS")
prior <- readRDS("prior.RDS")

icona_narobe <- fluidRow(
  column(12,align="center",
         icon("fas fa-exclamation-triangle", lib = "font-awesome")
  ))

icona_ok <- fluidRow(
  column(12,align="center",
         icon("fas fa-check-circle", lib = "font-awesome")
  ))

ui <- shinyUI(
  navbarPage(title="Job Titles",id="jt",
             tabPanel("Tokenizer",value="tokenize",
                      fluidPage(
                        useShinyjs(),
                        theme= shinytheme("flatly"),
                        tags$style(type="text/css", "
                                   #loadmessage {
                                   position: fixed;
                                   top: 30%;
                                   left: 0px;
                                   width: 100%;
                                   padding: 5px 0px 5px 0px;
                                   text-align: center;
                                   font-weight: bold;
                                   font-size: 400%;
                                   color: '';
                                   background-color: ;
                                   z-index: 105;
                                   }
                                   "),
                        tags$head(
                          tags$style(HTML("hr {border-top: 1px solid #7f7f87;}"))
                        ),
                        # App title ----
                        
                        
                        # Sidebar layout with input and output definitions ----
                        sidebarLayout(
                          
                          # Sidebar panel for inputs ---
                          sidebarPanel(align="center",id="side",width = 4,
                                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                        tags$div(withSpinner(h1(""),7,"black"),id="loadmessage")),
                                       h1("Tokenizer"),
                                       br(),
                                       hr(),
                                       br(),
                                       actionButton("rand", "Random Select",icon("paper-plane")
                                                    # style="color: #f0edf5; background-color: #000; border-color: #f0edf5"
                                       ),
                                       helpText("Randomly select 20 job titles from the sample."),
                                       helpText("Function will use thresholds that were set below."),
                                       br(),
                                       hr(),
                                       br(),
                                       textInput("text","Input arbitrary job title:",placeholder = "director, manager"),
                                       helpText("Separate additional titles with comma"),
                                       h3("Parameters:"),
                                       br(),
                                       sliderInput("th1","Distance threshold 1:",min = 0.01,max = 0.15,step = 0.005,value = 0.075),
                                       helpText("Lower value means stricter matching condition"),
                                       sliderInput("th2","Distance threshold 2:",min = 0.01,max = 0.15,step = 0.005,value = 0.075),
                                       helpText("Lower value means stricter matching condition"),
                                       br(),
                                       actionButton("Tokenize","Tokenize",icon("wrench")
                                                    # style="color: #f0edf5; background-color: #000; border-color: #f0edf5"
                                       ),
                                       hr(),
                                       br()
                                       
                                       
                                       # actionButton("reset_button", "Zamenjaj podatke")
                          ),
                          # Main panel for displaying outputs ----
                          mainPanel(align="center",
                                    
                                    DT::dataTableOutput("tabela"),
                                    br(),
                                    h4("Please let me know any feedback or possible errors. Everyday
                                       I correct something from the dictionary and it is far from perfect.")
                                    
                          )
                        )
                      )),
             tabPanel("LDA Grouping",value="group",
                      fluidPage(
                        theme= shinytheme("flatly"),
                        tags$style(type="text/css", "
                                              #loadmessage {
                                              position: fixed;
                                              top: 30%;
                                              left: 0px;
                                              width: 100%;
                                              padding: 5px 0px 5px 0px;
                                              text-align: center;
                                              font-weight: bold;
                                              font-size: 400%;
                                              color: '';
                                              background-color: ;
                                              z-index: 105;
                                              }
                                              "),
                        tags$head(
                          tags$style(HTML("hr {border-top: 1px solid #7f7f87;}"))
                        ),
                        # App title ----
                        
                        
                        # Sidebar layout with input and output definitions ----
                        sidebarLayout(
                          # Sidebar panel for inputs ---
                          sidebarPanel(width = 3,align="center",
                                       br(),
                                       
                                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                        tags$div(withSpinner(h1(""),7,"black"),id="loadmessage")),
                                       h1("Skill Classifier"),
                                       hr(),
                                       actionButton("randomToken", "Random Select",icon("paper-plane")
                                                    # style="color: #f0edf5; background-color: #000; border-color: #f0edf5"
                                       ),
                                       helpText("Randomly select one job title from the sample."),
                                       hr(),
                                       textInput("inputToken","Input one arbitrary Job Title:",placeholder = "doctor"),
                                       hr(),
                                       actionButton("class","Classify",icon("wrench")),
                                       br(),
                                       hr(),
                                       br(),
                                       DT::dataTableOutput("tokenizerOUTPUT"),
                                       br(),
                                       hr()
                                       
                                       
                                       
                                       # actionButton("reset_button", "Zamenjaj podatke")
                                       
                                       
                          ),
                          # Main panel for displaying outputs ----
                          mainPanel(align="center",
                                    br(),
                                    h4("I assume that some combination of both Beta's will be the best."),
                                    h4("Higher line means better fit to the group below."),
                                    plotOutput("groups"),
                                    br()
                                    
                                    
                          )
                        )
                      )
             ),
             navbarMenu("Data & Documentaion",
                        tabPanel("Dictionary",value="dict",
                                 fluidPage(
                                   tags$style(type="text/css", "
                                   #loadmessage {
                                   position: fixed;
                                   top: 30%;
                                   left: 0px;
                                   width: 100%;
                                   padding: 5px 0px 5px 0px;
                                   text-align: center;
                                   font-weight: bold;
                                   font-size: 400%;
                                   color: '';
                                   background-color: ;
                                   z-index: 105;
                                   }
                                   "),
                                   tags$head(
                                     tags$style(HTML("hr {border-top: 1px solid #7f7f87;}"))
                                   ),
                                   conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                                    tags$div(withSpinner(h1(""),7,"black"),id="loadmessage")),
                                   column(12,align="center",
                                          br(),
                                          DT::dataTableOutput("prior"))
                                 )
                        ),
                        tabPanel("Documented Workflow",value="wf",
                                 fluidPage(
                                   br(),
                                   h4("Here I will present more detailed workflow...")
                                 )
                        )
                        
             )
  )
)


server <- shinyServer(function(input, output,session){
  
  ### LDA
  LDAtabel <- reactiveValues(
    out= data.table(From="Med. doctor",Token1="doctor")
  )
  
  output$tokenizerOUTPUT <- DT::renderDataTable({
    a <- data.table(Variable=rownames(t(LDAtabel$out)),Value=t(LDAtabel$out))
    colnames(a) <- c("Variable","Value")
    a
  },
  rownames = F,
  options = list(
    lengthMenu = c(20,25),
    initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#2D3E50', 'color': '#f0edf5'});",
      "}")
  ))
  
  observeEvent(input$randomToken,{
    base <- sample(titles,size = 1)
    updateTextInput(session, "inputToken",value=base )
    click("class")
  })
  
  observeEvent(input$class,{
    if(input$inputToken != ""){
      base <- input$inputToken
      base <- tolower(base)
      base <- trimws(base)
      base <- assignRoleTokens(base,prior,cores=1,thresh = 0.1,thresh2 = 0.1,maxCol = 11)
      LDAtabel$out <- base
      if(!is.na(base$token1) & any(base[,-1] %in% unique(beta$term))){
        termInput$inp <- list(base) 
      }else{
        showModal(
          modalDialog(
            title=h2(icona_narobe),
            fluidRow(column(12,align="center",
                            br(),
                            h4("I am sorry, I was not able to categorize that specific job title."),
                            br())),
            easyClose = T,
            size = "m",
            footer=column(12,align="center",
                          modalButton("Close",icon=icon("fas fa-check-circle")))
            
          ) 
        )
      }
      
    }else{
      showModal(
        modalDialog(
          title=h2(icona_narobe),
          fluidRow(column(12,align="center",
                          br(),
                          h4("Please provide at least one job title."),
                          br())),
          easyClose = T,
          size = "m",
          footer=column(12,align="center",
                        modalButton("Close",icon=icon("fas fa-check-circle")))
          
        ) 
      )
    }
  })
  
  termInput <- reactiveValues(inp=list(data.table(from="med. doctor", token1= "doctor")))
  
  output$groups <- renderPlot({
    #print(termInput$inp[[1]])
    assignY(as.matrix(termInput$inp[[1]][,-1,drop=F]),beta,betaRelative)[,1] %>% phraseOnTopic(.,beta,betaRelative)
  },height=900)
  
  ## tokenizer
  
  tabela <- reactiveValues(
    out= data.frame(from="med. doctor",token1="doctor",token2=NA,token3=NA)
  )
  
  output$tabela <- DT::renderDataTable({
    tabela$out
  },
  rownames = F,
  options = list(
    lengthMenu = c(20,25),
    initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#2D3E50', 'color': '#f0edf5'});",
      "}")
  ))
  
  observeEvent(input$rand,{
    base <- sample(titles,size = 20)
    tabela$out <- assignRoleTokens(base,prior,cores=1,thresh = input$th1,thresh2 = input$th2,maxCol = 11)
  })
  
  observeEvent(input$Tokenize,{
    if(input$text != ""){
      base <- stringr::str_split(input$text,",") %>% unlist()
      base <- tolower(base)
      base <- trimws(base)
      tabela$out <- assignRoleTokens(base,prior,cores=1,thresh = input$th1,thresh2 = input$th2,maxCol = 11)
      
    }else{
      showModal(
        modalDialog(
          title=h2(icona_narobe),
          fluidRow(column(12,align="center",
                          br(),
                          h4("Please provide at least one job title."),
                          br())),
          easyClose = T,
          size = "m",
          footer=column(12,align="center",
                        modalButton("Close",icon=icon("fas fa-check-circle")))
          
        ) 
      )
    }
  })
  
  output$prior <- DT::renderDataTable({
    prior[order(prior$from,decreasing = T),c(-2,-4)]
  },
  filter = 'top',
  rownames = F,
  options = list(
    lengthMenu = c(10,25,100,250),
    initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#2D3E50', 'color': '#f0edf5'});",
      "}")
  ))
  
  
  
  
})

shinyApp(ui, server)