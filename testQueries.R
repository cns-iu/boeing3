courses <- DBI::dbGetQuery(conn, 
                         DBI::sqlInterpolate(conn, 
                                           paste("SELECT * FROM dt_courses")))
disconnect()
crsStr <- isolate(DBI::dbGetQuery(conn, 
                          DBI::sqlInterpolate(conn, 
                                              paste0("SELECT * FROM dt_course_str WHERE course_id = '",
                                                     courses[2,]$course_id,"'"))))

crsStr <- isolate(DBI::dbGetQuery(conn,
                                  sqlInterpolate(conn,
                                                 paste0("SELECT * FROM dt_course_str WHERE course_id = '",
                                                        input$crsInput,"'"))))

rm(course,crsStr)
