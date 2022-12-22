#Include monkeyvars/GLOBALS.txt

FileDelete monkeyvars/includeIncludes.txt
for mapName in maps {
  FileAppend, #Include monkeyvars/%mapName%Vars.txt`n , monkeyvars/includeIncludes.txt
}

#Include monkeyvars/includeIncludes.txt

#Persistent
SetTimer, showVars, 1000

showVars:
  MouseGetPos x , y
  ToolTip, (%x%`, %y%) , 0, 0
Return

^j::
;  targetMap := "Ravine"
;  targetMap := "Sanctuary"
;  targetMap := "MuddyPuddles"
;  targetMap := "BloodyPuddles"
;  targetMap := "Workshop"
  targetMap := "Ouch"
;  targetMap := "Quad"
;  targetMap := "FloodedValley"
;  targetMap := "Infernal"
;  targetMap := "DarkCastle"
;  targetMap := "SpiceIslands"
  targetDiff := "Easy"
;  targetDiff := "Hard"
  targetLevel := "Standard"
  loop
    doLevel()
  return

^m::
  pickLevel()
  return

^k::
  ExitApp
  return

^p::
  targetDiff := "Easy"
  targetLevel := "Standard"
  loop {
    findBonus()
    playLevel()
  }
  return

^o::
  PixelGetColor color , 1170 , 602
  msgBox % "color is" color
  return

^u::
  InputBox, u,, "Upgrade slot?"
  upgrade(u)
  return

^f::
  clearTotems()
;  finishUp()
  return

^g::
rotateTargeting(5)
;  clearLevelUp()
  return

findBonus()
{
  clickPlay()
  x := mapDiffX["Expert"]
  Click %x%, %mapDiffY%
  Sleep 1000
  mapCount := 0
  loop {
    bonusX := 744 + 423 * Mod(mapCount, 3)
	row := mapCount // 3
    bonusY := 287 + Mod(row, 2) * 319
	PixelGetColor color , %bonusX% , %bonusY%
	color &= 0xF0F0F0
	if (color == 0xF0F0F0)
	  break
	Sleep 100
	mapCount++
	if (mapCount == 6) {
	  Click 1650 , 430
	  Sleep 1000
	}
  }
  for mName, mData in maps {
    if ((mData[1] == "Expert") and (mData[2] == mapCount)) {
	  targetMap := mName
	  break
	}
  }
  Sleep 1000
  bonusX -= 100
  Click %bonusX% , %bonusY%
  chooseDifficulty()
}

pickLevel() {
  list := ""
  for mapName in maps {
    list .= mapName . "|"
  }
  Gui Add, DropDownList, vtargetMap Choose1, %list%
  Gui Show
}

enterGame() {
  clickPlay()
  chooseMap()
  chooseDifficulty()
}

playLevel() {
  monkeys := monkeyList[targetMap][targetDiff][targetLevel]
  placeInitialMonkeys(monkeys)
  startGame()
  buildMonkeys( buildOrder[targetMap][targetDiff][targetLevel] )
  finishUp()
}

doLevel() {
  enterGame()
  playLevel()
}

clickPlay() {
  Click 850 , 1000
  Sleep 1500
}

chooseMap() {
  diff := maps[targetMap][1]
  x := mapDiffX[diff]
  mapNum := maps[targetMap][2]
  Click %x%, %mapDiffY%
  Sleep 1000
  loop % (mapNum // 6) {
    Click 1650 , 475
    Sleep 1250
  }
  mod := Mod(mapNum , 6)
  if (mod > 2) {
    mod -= 3
    y := 600
  } else {
    y := 300
  }
  x := 500 + 500 * mod
  Click  %x% , %y%
  sleep 1000
}

chooseDifficulty() {
  Sleep 1000
  x := levelDiffX[targetDiff]
  Click %x% , %levelDiffY%
  Sleep 1000
  x := versionLoc[targetLevel][1]
  y := versionLoc[targetLevel][2]
  Click %x% , %y%
  Sleep 1000  
}

clearLevelUp() {
  Sleep 500
  PixelGetColor color , 1880 , 30
  color &= 0xF0F0F0
  if ( color == 0X203040 ) {
    Click 1500 , 1000
    Sleep 2000
    Click 500 , 500
    Sleep 2000
    clickActiveMonkey()
    return 1
  }
}

clickActiveMonkey() {
  x := abs(monkeys[activeMonkey][2])
  y := abs(monkeys[activeMonkey][3])
  MouseMove %x% , %y%
  Sleep 200
  loop {
    Click %x% , %y%
    Sleep 500
    PixelGetColor color , 60 , 100
    if (color == 0x6099C1)
      return
    PixelGetColor color , 1600 , 100
    if (color == 0x6098C1)
      return
    Sleep 500
  }
}

build(key) {
  loop {
    MouseMove 500,500
    Sleep 500
    Send %key% 
    Sleep 500
    PixelGetColor color, 1600 , 100
    if (color == 0x0079FF)
      break
    if ((Mod(A_Index , 10) == 0) or spamOn) {
;      clearLevelUp()
      useAbilities()
    }
  }
  while (color == 0x0079FF) {
    Sleep 500
    clickActiveMonkey()
	PixelGetColor color, 1600 , 100
  }
}

placeInitialMonkeys(init) {
  for i , a in init {
    activeMonkey := i
    monkey := a[1]
    x := a[2]
    if ( x < 0 )
      return
    key := hotkey[monkey]
    build(key)
  }
}

startGame() {
  Send { Space }
  Sleep 1000
  Send { Space }
  Sleep 1000
}

useAbilities()
{
;  Send {1} {2} {3} {4}
;  Sleep 500
}

rotateTargeting(direction) {
  if (direction == 4) {
    Send {Tab}
  } else if (direction == 5) {
    Send ^{Tab}
  }
  Sleep 500
}

upgrade(u) {
  y := upgradeY[u]
  loop {
    x := upgradeX[1]
    PixelGetColor color , %x% , %y%
    color |= 0x000F1F
    if (color == 0x00DF5F)
      break
    x := upgradeX[2]
    PixelGetColor color , %x% , %y%
    color |= 0x000F1F
    if (color == 0x00DF5F)
      break
    Sleep 500
    if ((Mod(A_Index , 10) == 0) or spamOn) {
;      clearLevelUp()
      UseAbilities()
    }
  }
  Sleep 500
  Click %x% , %y%
  Sleep 1000
}

buildMonkeys(toBuild) {
  for i , a in toBuild {
    Click 1600 , 1050
	Sleep 300
    activeMonkey := a[1]
	if ( a[2] != BUILD )
      clickActiveMonkey()
    for j, action in a {
      if (j == 1)
        continue
      if (action == BUILD ) {
        key := hotkey[monkeys[activeMonkey][1]]
        build(key)
        clickActiveMonkey()
      } else if (( action == RROTATE) or (action == LROTATE)) {
        rotateTargeting(action)
      } else if ( action == SPAM ) {
	    spamOn := 1
	  } else {
        upgrade(action)
      }
    }
  }
}

clearTotems() {
  Click 1000, 700 ; collect
  Sleep 2000
  x := 650
  y := 550
  loop {
    Click %x% , %y%
    x += 150
    Sleep 2000
    Click %x% , %y%
    Sleep 1000
    if ( x > 1250)
      break
  }
  Sleep 2000
  Click 950 , 1000 ; Continue
  Sleep 2000
  Click 80 , 50 ; home
  Sleep 2000
}

finishUp() {
    loop {
      PixelGetColor color , 900 , 910
      color &= 0xFFE0C0
      if (color == 0x00E040)
        break
      if ((Mod(A_Index , 10) == 0) or spamOn) {
;        clearLevelUp()
        useAbilities()
      }
      Sleep 2000
    }
    Sleep 2000
    Click 1000, 910
    Sleep 3000
    Click 1000, 930
    Sleep 2000
    Click 700 , 860
    Sleep 6000
    PixelGetColor color , 870 , 670
    color &= 0xF0F0F0
    if (color == 0x00E060)
      clearTotems()
}