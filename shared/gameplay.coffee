sectionIds = ["tl", "tc", "tr", "ml", "mc", "mr", "bl", "bc", "br"]
class @Gameplay
  @sectionIds: sectionIds
  
  @checkWin: (b) ->
    won = false
    wins = [
      ["tl", "ml", "bl"]
      ["tc", "mc", "bc"]
      ["tr", "mr", "br"]
      ["tl", "tc", "tr"]
      ["ml", "mc", "mr"]
      ["bl", "bc", "br"]
      ["tl", "mc", "br"]
      ["tr", "mc", "bl"]
    ]
    # for each win case
    _.each wins, (keys) ->
      # get board values for win case cells
      values = _.map keys, (cell) -> b[cell]
      # if there are no blanks and only one player in each spot, a win occurred
      if !_.contains(values, "") and _.keys(_.groupBy(values)).length == 1
        won = true
    won
  
  @checkWinBoard: (board) ->
    # fold the winners of each section into a new board, then use @checkWin
    @checkWin _.reduce board,
      (obj, v, k) ->
        obj[k] = v.winner
        obj
      , {}
  
  @totalMoves: (b) =>
    taken = 0
    notTaken = 0
    _.each @sectionIds, (s) =>
      _.each @sectionIds, (s2) =>
        if b[s][s2] != ""
          taken++
        else
          notTaken++
    taken
  
  @BlankBoard: () ->
    board = {}
    for i in [0..@sectionIds.length-1]
      board[@sectionIds[i]] = 
        winner: ""
      for j in [0..@sectionIds.length-1]
        board[@sectionIds[i]][@sectionIds[j]] = ""
    board



###
# OLD LOGIC  
# vertical
if (b.tl != "" && b.tl == b.ml && b.ml == b.bl) {
  return true;
}
if (b.tc != "" && b.tc == b.mc && b.mc == b.bc) {
  return true;
}
if (b.tr != "" && b.tr == b.mr && b.mr == b.br) {
  return true;
}
# horizontal
if (b.tl != "" && b.tl == b.tc && b.tc == b.tr) {
  return true;
}
if (b.ml != "" && b.ml == b.mc && b.mc == b.mr) {
  return true;
}
if (b.bl != "" && b.bl == b.bc && b.bc == b.br) {
  return true;
}
# diagonal
if (b.tl != "" && b.tl == b.mc && b.mc == b.br) {
  return true;
}
if (b.bl != "" && b.bl == b.mc && b.mc == b.tr) {
  return true;
}

return false
###
