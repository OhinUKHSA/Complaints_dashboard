# =============================================================================
# App: Complaints Dashboard — UI
# Purpose: Provide the user interface for uploading safeguard extract data and
#          controlling the display of performance metrics required for the CSAC
#          performance report.
#
# Author: Owen Williams
# Created: 2025-09-26
#
#
# How to run:
#   1) Ensure packages are installed by using 'Load_packages.R'.
#   2) Click 'Run App'. Upload the processed safeguard extract file 
#      (see SOP for preparing data).
# =============================================================================


# Install packages --------------------------------------------------------

require(tidyverse)
require(readxl)
require(shiny)
require(tools)
require(tsibble)


# dashboard ---------------------------------------------------------------

fluidPage(
  titlePanel("Complaints"),
  
  ############
  # Side Bar #
  ############
  
  
  sidebarLayout(
    sidebarPanel(
      fileInput(
        "file1", "Choose CSV or Excel File",
        multiple = FALSE,
        accept = c(".csv", ".xls", ".xlsx")
      ),
      tags$hr(),
      tags$h2('Filters'),
      dateRangeInput(inputId = 'dateRange', label = 'Select Date Range'),
      tags$hr(),
      # modify plot size
      sliderInput('plotheight', 'Set plot height', min = 300, max = 1000,
                  step = 50, value = 750),
      sliderInput('plotwidth', 'Set plot width', min = 500, max = 1500,
                  step = 50, value = 1100),
      checkboxInput("show_table", "Show table", value = FALSE)
      ),
    
    
    #############
    # Main pane #
    #############
    
    mainPanel(
      tags$h1('Customise Plot'),
      hr(),
      tags$h3('Choose how to aggregate date'),
      # Select date aggregate
      fluidRow(column(width = 6,
                      selectInput(inputId = 'DateAggregate', label = 'Select Date Aggregate:',
                                  choices = c('Month' = 'Month',
                                              'Financial Quarter' = 'FY_qtr',
                                              'Finanacial Year' = 'FY_year'),
                                  multiple = FALSE))

               ),
      hr(),
      # modify Plot labels
      tags$h3('Plot labels'),
      fluidRow(column(width = 6,
                      textInput('figureTitle', 'Figure Title:', 
                                value = 'Give Figure Title',
                                width = '800px'),
                      textInput('subHeadingTitle',  'Sub Heading Title:', value = 'Give Sub Heading Title ',
                                width = '800px')),
               column(width = 6,
                      textInput('LegendTitle', 'Legend Title: ', 
                                value = 'Legend',
                                width = '800px'),
                      textInput('captionTitle',  'Caption Title:', value = '',
                                width = '800px'))),
      numericInput('textsize', 'plot label text size:', min = 1, max = 15, value = 5, step = 1),
      hr(),
      tags$h2('Choose analysis'),
      tags$p('Toggle between the different tabs to view different analyses'),
      hr(),
      tabsetPanel(
        tabPanel("Root Cause",
                 conditionalPanel(
                   tags$h2('Summary Table'),
                   condition = "input.show_table == true",
                   div(style = "margin-top:20px;", tableOutput("contents"))
                   ),
                 plotOutput("plot")),
        tabPanel('SLA',
                 conditionalPanel(
                   tags$h2('Summary Table'),
                   condition = "input.show_table == true",
                   div(style = "margin-top:20px;", tableOutput("SLATable_Render"))
                   ),
                 plotOutput("plot_SLA")
                 )
        )
      )
    )
  )

  
  