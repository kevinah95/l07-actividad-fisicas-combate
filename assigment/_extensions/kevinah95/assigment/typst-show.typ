
#show: assigment.with(
  // Imágenes embebidas (no configurables)
  header-image: (
    image: image("header.png", width: 100%),
  ),
  logo-image: (
    image: image("logo.png", width: 100%),
  ),
$if(school)$
  school: [$school$],
$endif$
$if(course-code)$
  course-code: [$course-code$],
$endif$
$if(course-name)$
  course-name: [$course-name$],
$endif$
$if(tsection)$
  tsection: [$tsection$],
$endif$
$if(period)$
  period: [$period$],
$endif$
$if(instructor)$
  instructor: [$instructor$],
$endif$
$if(activity-title)$
  activity-title: [$activity-title$],
$endif$
$if(activity-type)$
  activity-type: [$activity-type$],
$endif$
$if(due-date)$
  due-date: [$due-date$],
$endif$
$if(percentage)$
  percentage: [$percentage$],
$endif$
$if(tformat)$
  tformat: [$tformat$],
$endif$
$if(total-points)$
  total-points: [$total-points$],
$endif$
$if(individual)$
  individual: $individual$,
$endif$
$if(group)$
  group: $group$,
$endif$
$if(show-instructions-note)$
  show-instructions-note: $show-instructions-note$,
$endif$
$if(general-instructions)$
  general-instructions: [
$general-instructions$
  ],
$endif$
$if(general-objective)$
  general-objective: [
$general-objective$
  ],
$endif$
$if(specific-objectives)$
  specific-objectives: [
$specific-objectives$
  ],
$endif$
$if(activity-context)$
  activity-context: [
$activity-context$
  ],
$endif$
$if(activity-instructions)$
  activity-instructions: [
$activity-instructions$
  ],
$endif$
$if(rubric-criteria)$
  rubric-criteria: (
$for(rubric-criteria)$
    (
      criteria: [$rubric-criteria.criteria$],
      deficient: [$rubric-criteria.deficient$],
      regular: [$rubric-criteria.regular$],
      good: [$rubric-criteria.good$],
      excellent: [$rubric-criteria.excellent$],
    ),
$endfor$
  ),
$endif$
  // Footer embebido (no configurable)
  footer-image: (
    image: image("footer.png", width: 100%),
  ),
)
