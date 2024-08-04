breed [ industries industry] ;; industry breed
breed [ universities university] ;; university breed
breed [ students student] ;; student breed
industries-own [
ind-type ;; the types of industry including  high-tech, mid-tech and low-tech
capacity  ;; the capacity of each industry type
]
universities-own [
  grade ;; the rank of university including grade A, grade B and grade C.
]
students-own [
  job? ;; when the student has a job, it is true otherwise it is false.
  age ;; the age of students if exceeding 100, the student dies
  gradu-period ;; the period of student graduation ranging from 1 to ....n
]
globals [
  value ;; a value for counting graduation period
]



to setup
ca
resize-world -30 30 -16 16  ;; the size of world view
ask patches [ set pcolor magenta]

industrial-district ;; industrial district is established ( either spread or concentrated)
uinversity-district ;; university district is established (either spread or concentrated)

ask industries [
    set-type
    set-capacity
  ]
ask universities [
    set-grade
  ]

set value 0

reset-ticks
end

to go
   ;; a specified number of targeted graduates should be achieved over 5 years so universities are called for meeting this need.
  if count students < num-of-targeted-graduates-for-a-5year-period [

    ask-universities-to-train
  ]

  ask students [
    update-age  ;; students update age
  ]
  ask students with [not job?] [

    come-to-market  ;; unemployed students come to market
    search-for-job  ;; ;; unemployed students search for job
  ]

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;helper procedures
;; This is a core mechanism for connecting graduates to universities.In this a high-tech industry just recruits grade A students
;; a mid-tech industry just recruits grade B students and a low-tech industry only recruits grade C students.
to search-for-job
  let target-industry one-of industries-here
  ifelse target-industry != nobody [
    if [capacity] of target-industry > 0 [
      if color = [color] of target-industry [setxy [xcor] of target-industry [ycor] of target-industry  set job? true ask target-industry [ set capacity capacity - 1 ]
      ]
    ]
  ]

  [ come-to-market ]

end

;; a gtaduate come to market
to come-to-market
  rt random 90
  lt random 90
  if not can-move? 1 [ rt 180]
  fd 1
end

to update-age
  if age > 21 [ set age age + 0.025 ] ;; since 40 ticks are 1 year
  if age  > 100 [ die]   ;; the limit of lifetime
end

to ask-universities-to-train
  let gra-target ( num-of-targeted-graduates-for-a-5year-period / 5 ) ;;;  number of graduates per year
  if (ticks > 0 and (ticks mod 40 = 0) )  [  while  [ gra-target > 0 ] [
    ask one-of universities [hatch-students 1 [features] set gra-target gra-target - 1  ]
    ]
  set value value + 1
  ]
;
end
;; features of a student when he or she gets graduated
to features
  set shape "person"
  set job? false  ;; has no job
  set age 22  ;; is at 22. this is for bachelors and can be extended.
  set gradu-period value + 1 ;; his or her graduation period is chosen
  fd 0.5
end

;; universities grading system completely depends on the quanlity of universities. The grades range from A to C.
to set-grade
  ifelse random-float 1.0 <= university-quality
  [set grade 1 set color white] [ifelse random-float 1.0 <= university-quality [set grade 2 set color cyan ] [set grade 3 set color gray]]
end

to set-capacity
   if ind-type = 1 [set capacity cap-of-high-tech-industries]
   if ind-type = 2  [ set capacity cap-of-mid-tech-industries]
   if ind-type = 3  [ set capacity cap-of-low-tech-industries]
end

to set-type
  ifelse random-float 1.0 <= inudstry-advancement [set ind-type 1 set color white] [ifelse random-float 1.0 <= inudstry-advancement
    [set ind-type 2 set color cyan ] [set ind-type 3 set color gray]]
end


to industrial-district
  ifelse spatial-spread? [
  while [count industries < num-of-industries] [
  ask one-of patches with [not any? turtles-here] [ sprout-industries 1 [set shape "pentagon"] ]
  ]
  ]
  [  ;set industrial-zone patches with [ pxcor >= 15 and pycor >= 8 ]
    while [count industries < num-of-industries]
    [ ask one-of industrial-zone with [not any? turtles-here] [ sprout-industries 1 [set shape "pentagon"] ]  ]
  ]

end

to uinversity-district

  ifelse spatial-spread? [
  while [count universities < num-of-universities] [
  ask one-of patches with [not any? turtles-here] [ sprout-universities 1 [set shape "square"] ]
  ]
  ]
  [
    while [count universities < num-of-universities]
    [ ask one-of university-zone with [not any? turtles-here] [ sprout-universities 1 [set shape "square"] ]  ]
  ]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; University Zone  & industrial Zone
to-report university-zone
  let unive-zone patches with [ pxcor <= -12 and pycor <= -5 ]
  report  unive-zone
end
;
 to-report industrial-zone
  let indust-zone patches with [ pxcor >= 15 and pycor >= 8 ]
  report  indust-zone
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Industrial Capacity

to-report capacity-of-industries
  report sum [capacity] of industries
end

to-report total-capacity

  let high-techs (count industries with [ind-type = 1 ] * cap-of-high-tech-industries)
  let mid-techs (count industries with [ind-type = 2 ] * cap-of-mid-tech-industries)
  let low-techs (count industries with [ind-type = 3 ] * cap-of-low-tech-industries)
  report (high-techs + mid-techs + low-techs  )
end
@#$#@#$#@
GRAPHICS-WINDOW
3
10
810
451
-1
-1
13.1
1
10
1
1
1
0
0
0
1
-30
30
-16
16
1
1
1
ticks
30.0

SLIDER
1350
325
1541
358
university-quality
university-quality
0
1.0
0.6
0.05
1
%
HORIZONTAL

SLIDER
1294
602
1569
635
num-of-targeted-graduates-for-a-5year-period
num-of-targeted-graduates-for-a-5year-period
0
4000
1000.0
100
1
NIL
HORIZONTAL

BUTTON
1318
561
1391
594
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
852
63
932
108
employed 
count students with [ job?]
17
1
11

MONITOR
947
61
1037
106
unused capacity
capacity-of-industries
17
1
11

PLOT
819
175
1342
436
Capacity and Employment
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"employed students" 1.0 0 -10899396 true "" "plot count students with [job?]"
"capacity-threshold" 1.0 0 -7500403 true "" "plot-pen-reset\nplotxy 0 total-capacity\nplotxy plot-x-max total-capacity"
"unemployed students" 1.0 0 -2674135 true "" "plot count students with [not job?]"

SLIDER
1350
403
1543
436
cap-of-high-tech-industries
cap-of-high-tech-industries
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
1350
440
1543
473
cap-of-mid-tech-industries
cap-of-mid-tech-industries
0
20
7.0
1
1
NIL
HORIZONTAL

SLIDER
1349
479
1543
512
cap-of-low-tech-industries
cap-of-low-tech-industries
0
30
18.0
1
1
NIL
HORIZONTAL

SLIDER
1350
243
1538
276
num-of-universities
num-of-universities
0
count university-zone
146.0
2
1
NIL
HORIZONTAL

SLIDER
1350
284
1541
317
num-of-industries
num-of-industries
0
count industrial-zone
90.0
1
1
NIL
HORIZONTAL

BUTTON
1396
561
1473
594
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
1350
520
1549
553
spatial-spread?
spatial-spread?
1
1
-1000

MONITOR
853
11
931
56
All students
count students
17
1
11

MONITOR
849
113
933
158
unemployed
count students with [not job?]
17
1
11

MONITOR
947
10
1035
55
total capacity
total-capacity
17
1
11

MONITOR
948
113
1039
158
used capacity
total-capacity - capacity-of-industries
17
1
11

MONITOR
1152
12
1268
57
grade 1 graduates
count students with [color = white]
17
1
11

MONITOR
1152
61
1268
106
grade 2 graduates
count students with [color = cyan]
17
1
11

MONITOR
1152
113
1269
158
grade 3 students
count students with [color = gray]
17
1
11

MONITOR
1274
15
1345
60
high-techs
count industries with [color = white]
17
1
11

MONITOR
1276
65
1342
110
mid-techs
count industries with [color = cyan]
17
1
11

MONITOR
1279
114
1345
159
low-techs
count industries with [color = gray]
17
1
11

MONITOR
1058
10
1140
55
grade 1 univ
count universities with [ color = white]
17
1
11

MONITOR
1055
59
1139
104
gtade 2 univ
count universities with [ color = cyan]
17
1
11

MONITOR
1055
115
1141
160
grade 3 univ
count universities with [ color = gray]
17
1
11

SLIDER
1348
365
1543
398
inudstry-advancement
inudstry-advancement
0
1.0
0.75
0.05
1
%
HORIZONTAL

MONITOR
1368
131
1539
176
oldest unemployed graduate
max[age] of students with [ not job?]
17
1
11

MONITOR
1368
187
1538
232
youngest unemployed graduate
min[age] of students with [ not job?]
17
1
11

MONITOR
1361
17
1537
62
NIL
max [gradu-period] of students
17
1
11

MONITOR
1362
73
1538
118
NIL
min [gradu-period] of students
17
1
11

BUTTON
1478
561
1555
595
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is to answer following questions :
1- How do university-quality and industry-advancement affect the employment of university graduates?
1-1- What happens for the employment of university graduates if university-quality and industry-advancement are incoordinated?
1-2- What happens for the employment of university graduates if university-quality and industry-advancement are coordinated?
2- What are the most effective scenarios (parameters combinations ) to secure the highest rate of the employment of university graduates after graduation?


## HOW IT WORKS

According to academic quality, universities are ranked into three grades of grade-1 (white), grade-2(cyan) and grade-3(gray).correspondingly, industries are ranked into three types of type-1 (high-tech with white color), type-2 (mid-tech with cyan color) and type-3 (low-tech with gray color) based on their advancement level.The core mechanism of employment is that the high-tech industries employ graduates of grade-1 universities, the mid-tech industries employ graduates of grade-2 universities and the low-tech industries only employ graduates of grade-3 universities.  

## HOW TO USE IT

"university-quality " is a slider for determining the quality of university system ranging from 0 to 100%.

"industry-advancement" is a slider for determining the modernity and technological level of industries of the country.

"spatial-spread switch " is On when the universities and industries are spatially spread and it is Off when they are concentrated in specific districs.
 
"num-of-industries" is a slider for determining the number of industries.

"unm-of-universities" is a slider for determining the number of universities.

"num-of-targeted-graduates slider" is for determining the number of graduates targeted for a 5-year period by ministry of education or other organizational planners.

"cap-of-hightech-industries" is a slider for determining the capacity level of high-tech industries.

"cap-of-midtech-industries" is a slider for determining the capacity level of mid-tech industries.

"cap-of-lowtech-industries" is a slider for determining the capacity level of low-tech industries.



## THINGS TO NOTICE

"num-of-industries" slider depends on industrial district.

"num-of-universities" slider depends on university district.


## THINGS TO TRY

Use "university-quality slider" and "industry-advancement slider" in the same direction and see unemployemet rate of university graduates.

Use "university-quality slider" and "industry-advancement slider" in the opposite direction and see unemployemet rate of university graduates.

Turn"spatial-spread switch" Off and compare unemployemet rate of university graduates whith when the switch is On.

in which parameter combination, the unemployment rate becomes as minimised as possible?  


## EXTENDING THE MODEL

Add a mechanism in a way that each industry can recruit graduates of each univesrity.

Add a mecahnism for entrepreneurship that when a unemployed graduate becomes 40 year old he or she try entrepreneurial  activities ( with or withouth cooperation of other unempolyed graduates).

Add a mechanism for immigration that when a graduate can not find a good job, he or she immigrates to another country.

## CREDITS AND REFERENCES

This model has been developed by Hossein Sabzian.He is a PhD student at Iran University of Science and Technology.His major interests include Agent Based Modeling, Statistical Inference, ICT industry, epistemology and history of physics and economics. You can email Hossein via 
1-sabzeyan@yahoo.com 
2-hossein_sabzian@pgre.iust.ac.ir
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="indus-university-all-1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count students with [job?]</metric>
    <steppedValueSet variable="inudstry-advancement" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="university-quality" first="0" step="0.2" last="1"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
