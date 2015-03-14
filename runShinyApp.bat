SET ROPTS=--no-save --no-environ --no-init-file --no-restore --no-Rconsole 
"C:\Program Files\R\R-3.1.2\bin\x64\R.exe" %ROPTS% -e "shiny::runApp( '.', host = '0.0.0.0', port=2323, launch.browser = FALSE )" 1> ShinyApp.log 2>&1
