// Function to create activity details table
#let activity-details-table(activity-type, due-date, percentage, tformat, total-points, individual, group, show-instructions-note: false) = {
  //set text(size: 9pt)
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: (left, left, left, left),
    stroke: 1pt + black,
    inset: 6pt,

    table.cell(colspan: 4)[
      *Tipo de actividad:* #if show-instructions-note [(Resolución de problemas, estudio de caso, práctica, presentación, avance de proyecto, laboratorio, taller, infografía, portafolio, tarea, etc)] #h(1em) #if activity-type != none { activity-type } else { [ ] }
    ],

    table.cell(colspan: 2)[*Fecha de entrega:* #h(1em) #if due-date != none { due-date } else { [] }],
    table.cell(colspan: 2)[*Valor porcentual:* #h(1em) #if percentage != none { percentage } else { [] }],

    table.cell(colspan: 2)[*Formato de entrega:* #if show-instructions-note [(PDF, DOCX, ZIP, video, código, etc.)] #h(1em) #if tformat != none { tformat } else { [] }],
    table.cell(colspan: 2)[*Puntaje total:* #h(1em) #if total-points != none { total-points } else { [] }],

    table.cell(colspan: 2)[*Individual:* #h(1em) #if individual != none and individual { [X] } else { [ ] }],
    table.cell(colspan: 2)[*Grupal:* #h(1em) #if group != none and group { [X] } else { [ ] }],
  )
}

// Function to create objectives table
#let objectives-table(general-objective, specific-objectives) = {
  table(
    columns: (1fr, 2fr),
    align: (center, left),
    fill: (col, row) => if col == 0 { rgb("#9CC8FF") } else { none },
    stroke: 0.5pt + black,
    inset: 8pt,

    [*Objetivo general o competencia del curso*],
    if general-objective != none {
      general-objective
    } else {
      [Coloque aquí el objetivo general o la competencia indicada en el programa del curso]
    },

    [*Objetivos específicos o resultados de aprendizaje que se evalúan*],
    if specific-objectives != none {
      specific-objectives
    } else {
      [Coloque aquí todos los objetivos específicos o los resultados de aprendizaje indicados en el programa del curso que se relacionan con esta actividad]
    },
  )
}

// Function to create a rubric table based on provided criteria
#let rubric-table(criteria) = {
  set text(size: 9pt)
  table(
    columns: 5,
    align: (left, center, center, center, center),
    fill: (col, row) => if row == 0 { rgb("#00479B") } else if col == 0 { rgb("#D1D3D4") } else { rgb("#9CC8FF") },
    inset: 8pt,
    stroke: 1.5pt + rgb("#000000"),

    // Header
    [#text(fill: white, weight: "bold")[Criterios de desempeño]],
    [#text(fill: white, weight: "bold")[Deficiente (1 punto)]],
    [#text(fill: white, weight: "bold")[Regular (2 puntos)]],
    [#text(fill: white, weight: "bold")[Bueno (3 puntos)]],
    [#text(fill: white, weight: "bold")[Excelente (4 puntos)]],

    // Rows
    ..criteria.map(c => (
      [#c.criteria],
      [#c.deficient],
      [#c.regular],
      [#c.good],
      [#c.excellent]
    )).flatten()
  )
}

// This function gets your whole document as its `body`
#let assigment(
  body,
  // Header
  header-image: none,
  // Logo and course information
  logo-image: none,
  school: "Software, Fundamentos, TI, SINT, etc.",
  course-code: "BISOFT-38",
  course-name: "Proyecto de Ing. de Software 4",
  tsection: "SCV2",
  period: "Q02",
  instructor: "Clive Staples Lewis",
  // Activity title
  activity-title: "{Proyecto}",
  // Activity details (Datos generales)
  activity-type: "{Resolución de problemas, estudio de caso, práctica, presentación, avance de proyecto, laboratorio, taller, infografía, portafolio, tarea, etc}",
  due-date: "dd/mm/aaaa a las hh:mm am/pm",
  percentage: "xx%",
  tformat: "{PDF, DOCX, ZIP, video, código, etc}",
  total-points: "100",
  individual: none, // true, false, or none
  group: none, // true, false, or none
  // Instructions note
  show-instructions-note: false,
  // General instructions
  general-instructions: none,
  // Objectives
  general-objective: none,
  specific-objectives: none,
  // Activity description
  activity-context: none,
  activity-instructions: none,
  // Rubric
  rubric-criteria: none,
  // Footer
  footer-image: none,
) = {
  // Configure page and text properties.
  set page(
    paper: "us-letter",
    margin: (top: 2.8cm, left: 2.54cm, right: 2.54cm, bottom: 2.54cm),
    header: if header-image != none {
      place(
            top,
            dx: -2.54cm,
            box(
                width: 21.59cm, // Ancho completo de carta US
                height: 3cm,
                header-image.image
            )
        )
    } else {
      none
    },
    header-ascent: 0%,
    footer: [
      #if footer-image != none {
        place(
          bottom,
          dx: -2.54cm,
          //dy: 0.5cm,
          box(
            width: 21.59cm, // Ancho completo de carta US
            height: 3cm,
            footer-image.image
          )
        )
      }
      #align(right, context counter(page).display("1"))
    ],
  )
  set text(font: "Arial")
  set heading(numbering: "1.a.")
  show heading: set text(fill: rgb("#164A98"))
  show link: underline
  show link: set text(fill: rgb("#0000EE"))
  set enum(indent: .5cm)
  set list(indent: .5cm)
  set par(
    spacing: 1.15em,
  )

  // Universidad CENFOTEC header
  align(center)[
    #text(size: 16pt, weight: "bold", fill: rgb("#164A98"))[Universidad CENFOTEC]
  ]
  v(2em)

  if show-instructions-note [
    #highlight[_Los campos que se muestran a continuación pueden ser adaptados según las especificaciones del curso o de la actividad. Complete los campos que correspondan y deje en blanco los que no apliquen._
    _Elimine las notas de instrucciones cambiando el valor de `show-instructions-note` a `false` al crear la consigna de cada actividad._]
  ]

  // Logo and Course information table
  table(
    columns: (auto, 1fr),
    stroke: none,
    align: (top, left),
    inset: (x: 0.5em, y: 0.3em),

    // Logo column
    table.cell(
      rowspan: 5,
      if logo-image != none {
        box(
          width: 2.4cm,
          logo-image.image
        )
      } else {
        []
      }
    ),

    // Course information
    [
      #table(
        columns: (auto, 1fr),
        stroke: none,
        inset: 0.3em,
        align: (left, left),

        [*Escuela de:*], [#box(stroke: (bottom: 1pt), inset: (bottom: 2pt), width: 100%)[#school]],
        [*Código del curso:*], [#box(stroke: (bottom: 1pt), inset: (bottom: 2pt), width: 100%)[#course-code]],
        [*Nombre del curso:*], [#box(stroke: (bottom: 1pt), inset: (bottom: 2pt), width: 100%)[#course-name]],
        [*Sección:*], [#box(stroke: (bottom: 1pt), inset: (bottom: 2pt), width: 100%)[#tsection]],
        [*Periodo:*], [#box(stroke: (bottom: 1pt), inset: (bottom: 2pt), width: 100%)[#period]],
        [*Docente facilitador:*], [#box(stroke: (bottom: 1pt), inset: (bottom: 2pt), width: 100%)[#instructor]],
      )
    ],
  )


  // Activity title
  align(center)[
    #text(size: 14pt, weight: "bold", fill: rgb("#164A98"))[CONSIGNA DE #(activity-title)]
  ]
  v(1em)

  // Activity details table
  [= Datos generales de la actividad]
  activity-details-table(activity-type, due-date, percentage, tformat, total-points, individual, group, show-instructions-note: show-instructions-note)
  v(1em)

  [= Instrucciones generales]
  if show-instructions-note [
    _Estas instrucciones pueden ser adaptadas según las especificaciones del curso o de la actividad_
  ]
  if general-instructions != none [
    #general-instructions
  ] else [
    + Lea cuidadosamente las instrucciones de la actividad, en caso de tener alguna duda puede consultar con el docente.
    + Esta actividad se desarrolla de manera individual o grupal (de acuerdo con lo especificado en los datos generales), cualquier intento de plagio será sancionado de acuerdo con el reglamento académico vigente.
    + Al completar la actividad, debe subir la solución en la plataforma Moodle en el formato, tiempo y espacio indicado por el docente.
  ]


  [= Objetivos o competencias del curso que se evaluarán en la actividad de aprendizaje]
  objectives-table(general-objective, specific-objectives)
  v(1em)

  // Descripción de la actividad
  [= Descripción de la actividad]
  if activity-context != none [
    *Contexto:* #emph[#activity-context]
    #v(0.5em)
  ]

  if activity-instructions != none [
    *Instrucciones:*
    #activity-instructions
  ]
  v(1em)


  // Renderizar rúbrica si existe
  if rubric-criteria != none {
    v(1em)
    [= Rúbrica]
    [Esta actividad de aprendizaje será evaluada mediante la siguiente rúbrica:]
    v(0.5em)
    if show-instructions-note [
      #highlight[_Usted debe copiar la rúbrica indicada para esta actividad de aprendizaje según lo definido en el programa del curso. Recuerde respetar la rúbrica definida. A continuación se presenta una *rúbrica de ejemplo* (para borrar esta nota vea el texto marcado al inicio del documento)._]
      #v(0.5em)
    ]
    rubric-table(rubric-criteria)
  }

  body
}
