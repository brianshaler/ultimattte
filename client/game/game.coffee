class @Game
  constructor: ->
    @game = null
    
    Meteor.autosubscribe =>
      Meteor.subscribe "game", @gameId() if @gameId()
    
    Deps.autorun =>
      lastUpdate = Session.set "lastUpdate", Date.now()
      @game = Games.findOne Session.get "gameId"
      #g = Games.find(Session.get "gameId").fetch()
      #if g and g.length >= 1
      #  @game = g[0]
    
    Template.game.playerList = ->
      Meteor.users.find _id: {$nin: [Meteor.userId()]}

    Template.game.mySymbol = ->
      if @game.players[0] == Meteor.userId() then "X" else "O"
    
    Template.game.myTurn = @myTurn
    Template.game.gameReady = @gameReady
    Template.game.board = @board
    Template.game.gameId = @gameId
    Template.game.game = @getGame
    Template.game.nextSection = @nextSection
    Template.game.myGame = @myGame
    Template.game.displayName = () ->
      displayName this
    
    Template.game.events
      "click .challenge-button": (event, template) =>
        id = String $(event.target).attr "id"
        if id.length > 0
          Meteor.call "challenge", @gameId(), id
        #Meteor.call('invite', Session.get("selected"), this._id);
      "click .ttt-enabled .move-btn": (event, template) =>
        id = String $(event.target).attr "id"
        move = id.split "-"
        if move.length == 2 and _.contains(Gameplay.sectionIds, move[0]) and _.contains(Gameplay.sectionIds, move[1])
          Meteor.call "takeTurn", @gameId(), move[0], move[1]
        else
          console.log move + " is not a valid move"
  
  loadGame: (id) =>
    # access parameters in order a function args too
    Meteor.subscribe "game", id, (err) =>
      console.log "found..?"
      Session.set id, true
      game = Games.findOne id
      if game
        console.log "Showing game."
        Session.set "gameId", id
        Session.set "showGame", true
        Session.set "createError", null
        Session.set "title", "Ultimate tic tac toe"
      else
        console.log "Okay, no game."
        x = "do something else"
        Session.set "gameId", null
        Session.set "showGame", false
        Session.set "createError", "Game not found"
      Session.set "visible", true
    cnt = Games.find(_id: id).count()
    console.log "Finding game. #{id} #{cnt}"
    if cnt > 0
      x = 1
  
  gameId: ->
    Session.get "gameId"
  
  getGame: =>
    lastUpdate = Session.get "lastUpdate"
    #Games.findOne Session.get "gameId"
    @addGameInfo @game
    @game
  
  gameReady: =>
    lastUpdate = Session.get "lastUpdate"
    if !@game or !@game.players
      return false
    return @game.players.length == 2
  
  myGame: =>
    lastUpdate = Session.get "lastUpdate"
    @game.owner == Meteor.userId()
  
  myTurn: =>
    lastUpdate = Session.get "lastUpdate"
    @game.currentTurnId == Meteor.userId()
  
  nextSection: =>
    lastUpdate = Session.get "lastUpdate"
    if @game.currentTurnId == Meteor.userId() then @game.nextSection else null
  
  board: =>
    lastUpdate = Session.get "lastUpdate"
    board = []
    p1 = @game.players[0]
    p2 = @game.players[1]

    for k, b of @game.board
      little = {}
      for i in [0..Gameplay.sectionIds.length-1]
        p = b[Gameplay.sectionIds[i]]
        if p == p1
          p = "X"
        else if p == p2
          p = "O"
        else
          p = ""
        little[Gameplay.sectionIds[i]] = p
        #little.push({pos: k2, symbol: (b[k2] == game.players[0] ? "X" : "O")});
      b2 =
        pos: k,
        winnerX: (b.winner == p1)
        winnerO: (b.winner == p2)
        b: little
        top: if _.contains(["tl", "tc", "tr"], k) then true else false
        bottom: if _.contains(["bl", "bc", "br"], k) then true else false
        left: if _.contains(["tl", "ml", "bl"], k) then true else false
        right: if _.contains(["tr", "mr", "br"], k) then true else false
      if @myTurn() and (@nextSection() != "" and @nextSection() != b2.pos)
        b2.disabled = true
      board.push b2
    board

  addPlayerInfo: (games) =>
    _.each games, (game) =>
      @addGameInfo game
    games
  
  addGameInfo: (game) =>
    notMe = []
    if game.players.length >= 1
      game.player1 = @playerById game.players[0]
      if game.player1._id != Meteor.userId()
        notMe.push game.player1
    if game.players.length >= 2
      game.player2 = @playerById game.players[1]
      if game.player2._id != Meteor.userId()
        notMe.push game.player2
    
    if notMe.length == 1 and game.players.length == 2
      game.opponent = notMe[0]
    game.playerCount = game.players
    game.moves = Gameplay.totalMoves game.board
    game.lonely = game.players.length != 2
    game
  
  playerById: (_id) =>
    Meteor.users.findOne _id


Template.game.userById = () ->
  userById this
