# =============================================================================
# App: Complaints Dashboard — Server
# Purpose: Handle server-side processing, including data validation, wrangling,
#          and generating interactive outputs for the CSAC performance report.
#
# Author: Owen Williams
# Created: 2025-09-26
#
#
#
#
# How to run:
#   1) Ensure packages are installed by using 'Load_packages.R'.
#   2) Run the app via 'ui.R' + 'server.R' or 'app.R' script.
# =============================================================================



# shiny server side ------------------------------------------------------

function(input, output, session) {
  
  ##################################
  # Pull in imported data and tidy #
  ##################################
  
  # Pull in data and validate columns
  data = reactive({
    req(input$file1)
    
    ext = file_ext(input$file1$name)
    
    df = switch(
      tolower(ext),
      "csv"  = read.csv(input$file1$datapath, check.names = FALSE),
      "xls"  = read_excel(input$file1$datapath),
      "xlsx" = read_excel(input$file1$datapath),
      {
        validate(need(FALSE, "Invalid file; please upload a .csv, .xls, or .xlsx file."))
        return(NULL)
      }
    )

  })
  

  #############
  # tidy data #
  #############
  
  tidy_data = reactive({
    req(data())
    df = data() %>%
      mutate(date = paste(Month, Year),
             date = as.Date(paste0("1 ", date), format = "%d %B %Y"),
             FY_qtr   = yearquarter(date, fiscal_start = 4),             
             FY_year  = year(date) - as.integer(month(date) < 4),
             Month = yearmonth(date),
             FY_label = sprintf("%04d/%02d", FY_year, (FY_year + 1) %% 100))
  })
  
  ##################
  # Observe Events #
  ##################
  
  observeEvent(tidy_data(), {
    dat = tidy_data()
    req(nrow(dat) > 0)
    
    date_range = dat$date
    updateDateRangeInput(
      session,
      "dateRange",
      min   = min(date_range, na.rm = TRUE),
      max   = max(date_range, na.rm = TRUE),
      start = min(date_range, na.rm = TRUE),
      end   = max(date_range, na.rm = TRUE)
    )
  })
  
  
  ###########################  
  # Create summarised Table #
  ###########################
  
  summarisedTable = reactive({
    req(tidy_data())
    
    DateAgg_code = sym(input$DateAggregate)
    
    # Apply filters
    dat = tidy_data() %>%
      filter(Domain == "Categories",
             date >= min(as.Date(input$dateRange[1])) & date <= max(as.Date(input$dateRange[2]))) %>%
      group_by(!!DateAgg_code, Topic) %>%
      summarise(count = sum(Count), .groups = "drop") 
    
  })
  

  
  #####################
  # Table and Figures #
  #####################


# Table -------------------------------------------------------------------

  
  output$contents = renderTable({
    req(summarisedTable())
    
    DateAgg_code = sym(input$DateAggregate)
    
    summarisedTable() %>%
      mutate(Date = paste(!!DateAgg_code)) %>%
      select(Date, everything(), -!!DateAgg_code) %>%
      pivot_wider(names_from = 'Topic', values_from = 'count')


   })


# Create Figure -----------------------------------------------------------

  
  # colour palette
  af_main12 = reactive({
    df = c("#12436D","#28A197","#801650","#F46A25","#3D3D3D","#A285D1",
                 "#0F8243","#1478A7","#E17E93","#B2D5DC","#E1B782","#BABABA")
  })
  
  output$plot <- renderPlot({
    req(summarisedTable())
    dat <- summarisedTable()
    
    # Build a Date-valued x column + label for ticks
    if (input$DateAggregate == "Month") {
      # Month is tsibble::yearmonth -> coerce to first-of-month Date
      dat <- dat %>%
        mutate(
          .x_date = as.Date(Month),
          .x_lab  = format(.x_date, "%b %Y")
        )
    } else if (input$DateAggregate == "FY_qtr") {
      # FY_qtr is tsibble::yearquarter -> first day of quarter as Date
      dat <- dat %>%
        mutate(
          .x_date = as.Date(FY_qtr),
          .x_lab  = as.character(FY_qtr)  # e.g. "2024 Q2"
        )
    } else if (input$DateAggregate == "FY_year") {
      # Map FY start year to 01-Apr of that year
      dat <- dat %>%
        mutate(
          .x_date = as.Date(paste0(FY_year, "-04-01")),
          .x_lab  = sprintf("%04d/%02d", FY_year, (FY_year + 1) %% 100)
        )
    } else {
      validate(need(FALSE, "Unknown DateAggregate option"))
    }
    
    # Unique breaks/labels in order
    breaks_tbl <- dat %>%
      distinct(.x_date, .x_lab) %>%
      arrange(.x_date)
    
    p <- ggplot(dat, aes(x = .x_date, y = count, fill = Topic)) +
      geom_col() +
      geom_text(
        aes(label = ifelse(count == 0, "", count)),
        position = position_stack(vjust = 0.5),
        colour = "black", size = 3, show.legend = FALSE
      ) +
      scale_fill_manual(values = af_main12(), drop = FALSE) +
      scale_x_date(breaks = breaks_tbl$.x_date, labels = breaks_tbl$.x_lab) +
      theme_bw() +
      labs(
        title    = input$figureTitle,
        subtitle = input$subHeadingTitle,
        caption  = input$captionTitle,
        x        = "Date",
        fill     = input$LegendTitle
      ) +
      theme(
        axis.text.y     = element_text(size = 15),
        axis.text.x     = element_text(size = 15, angle = 45, hjust = 1),
        title           = element_text(size = 25),
        legend.text     = element_text(size = 15),
        legend.position = "bottom"
      )
    
    p
  }, height = function() input$plotheight, width = function() input$plotwidth)
  
  
  
  #######################
  # SLA count and Table #
  #######################
  
  # Create reactive summary table

  table_SLA = reactive({
    req(tidy_data())

    DateAgg_code = sym(input$DateAggregate)


    tidy_data() %>%
      filter(Domain %in% c("Volume", 'SLA')) %>%
      group_by(!!DateAgg_code) %>%
      summarise(
        Closed = sum(Count[Topic == "Closed"], na.rm = TRUE),
        SLA    = sum(Count[Topic == "SLA number"],    na.rm = TRUE),
        percent = round(SLA/Closed * 100,1),
        .groups = "drop"
        )

  })

  # render table
  output$SLATable_Render = renderTable({
    req(table_SLA)

    DateAgg_code = sym(input$DateAggregate)

    table_SLA() %>%
      mutate(Date = paste(!!DateAgg_code)) %>%
      select(Date, everything(), -!!DateAgg_code)

  })


  # Render SLA plot

  output$plot_SLA <- renderPlot({
    req(table_SLA())
    dat <- table_SLA()
    
    # Build a Date-valued x column + label for ticks
    if (input$DateAggregate == "Month") {
      dat <- dat %>%
        mutate(
          .x_date = as.Date(Month),                 # tsibble::yearmonth -> Date (1st of month)
          .x_lab  = format(.x_date, "%b %Y")
        )
    } else if (input$DateAggregate == "FY_qtr") {
      dat <- dat %>%
        mutate(
          .x_date = as.Date(FY_qtr),                # tsibble::yearquarter -> first day of quarter
          .x_lab  = as.character(FY_qtr)            # e.g. "2024 Q2"
        )
    } else if (input$DateAggregate == "FY_year") {
      dat <- dat %>%
        mutate(
          .x_date = as.Date(paste0(FY_year, "-04-01")),            # UK FY start
          .x_lab  = sprintf("%04d/%02d", FY_year, (FY_year + 1) %% 100)
        )
    } else {
      validate(need(FALSE, "Unknown DateAggregate option"))
    }
    
    # Unique breaks/labels in order
    breaks_tbl <- dat %>%
      dplyr::distinct(.x_date, .x_lab) %>%
      dplyr::arrange(.x_date)
    
    # Build plot
    p <- ggplot(dat, aes(x = .x_date, y = percent)) +
      geom_col(fill = "#12436D") +
      geom_text(
        aes(label = ifelse(percent == 0, "", paste0(percent, "%"))),
        vjust = -0.4,
        size = 3,
        show.legend = FALSE
      ) +
      scale_x_date(breaks = breaks_tbl$.x_date, labels = breaks_tbl$.x_lab) +
      scale_y_continuous(labels = function(x) paste0(x, "%")) +
      theme_bw() +   # <- make sure the '+' is here
      labs(
        title    = input$figureTitle,
        subtitle = input$subHeadingTitle,
        caption  = input$captionTitle,
        x        = "Date",
        y        = "SLA achieved (%)",
        fill     = NULL
      ) +
      theme(
        axis.text.y     = element_text(size = 15),
        axis.text.x     = element_text(size = 15, angle = 45, hjust = 1),
        title           = element_text(size = 25),
        legend.text     = element_text(size = 15),
        legend.position = "bottom"
      )
    
    p
  }, height = function() input$plotheight, width = function() input$plotwidth)
  
  
}




