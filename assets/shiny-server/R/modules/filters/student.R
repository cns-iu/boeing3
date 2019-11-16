
studentFilter <- Filter$new(
  # 1st arg: A function for namespacing ids, other args: any - should be set in calls to makeTabPanel
  # NOTE: This function MUST end with ...
  function(ns, gradeRange, ageRange, gender, levelOfEducation, ...) {
    tagList(
      sliderInput(
        ns("grade"), "Filter by Student Grade",
        gradeRange[1], gradeRange[2], gradeRange,
        dragRange = TRUE
      ),
      sliderInput(
        ns("age"), "Filter by Student Age",
        ageRange[1], ageRange[2], ageRange, 1,
        ticks = FALSE, dragRange = TRUE
      ),
      checkboxGroupInput(
        ns("gender"), "Select Student Genders",
        gender, gender
      ),
      checkboxGroupInput(
        ns("levelOfEducation"), "Select Student Level of Education",
        levelOfEducation, levelOfEducation
      )
    )
  },
  subquery = paste(
    "SELECT user_id FROM dt_students WHERE",
    "coalesce(gender, 'X') = ANY (VALUES ?gender)", "AND",
    "coalesce(level_of_education, 'X') = ANY (VALUES ?levelOfEducation)"
  )
)
