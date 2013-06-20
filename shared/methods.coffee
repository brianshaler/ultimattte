NonEmptyString = Match.Where (x) ->
  check x, String
  x.length != 0

ValidSection = Match.Where (x) ->
  _.contains Gameplay.sectionIds, x
ValidPosition = Match.Where (x) ->
  _.contains Gameplay.sectionIds, x

Meteor.methods
  startGame: (options) ->
    check options, {public: Match.Optional Boolean}
    
    options.public = true
    
    if !this.userId
      throw new Meteor.Error 403, "You must be logged in"
    
    Games.insert
      owner: this.userId
      public: options.public
      players: [this.userId]
      board: Gameplay.BlankBoard()
      currentTurnId: this.userId
      nextSection: ""
      winner: ""
  challenge: (gameId, userId) ->
    check gameId, String
    check userId, String
    game = Games.findOne gameId
    if !game or game.owner != this.userId
      throw new Meteor.Error 404, "No such game"
    if game.players.length != 1
      throw new Meteor.Error 403, "Must have 1 current player to challenge"
    if _.contains game.players, userId
      throw new Meteor.Error 403, "This player is already in the game"
    if userId == this.userId
      throw new Meteor.Error 403, "You can't challenge yourself"
    
    game.players.push userId
    
    Games.update _id: gameId,
      $set:
        players: game.players
  joinGame: (gameId) ->
    check gameId, String
    game = Games.findOne gameId
    if !this.userId
      throw new Meteor.Error 403, "You must be signed in to play"
    if !game or !game.public
      throw new Meteor.Error 404, "No such game"
    if game.players.length != 1
      throw new Meteor.Error 403, "Can only join games with 1 player"
    if _.contains game.players, this.userId
      throw new Meteor.Error 403, "This player is already in the game"
    
    game.players.push this.userId
    
    Games.update _id: gameId,
      $set:
        players: game.players
  takeTurn: (gameId, section, position) ->
    check gameId, String
    check section, ValidSection
    check position, ValidPosition
    game = Games.findOne gameId
    if !game or (!game.public and !_.contains game.players, this.userId)
      throw new Meteor.Error 404, "No such game"
    if game.board[section][position] != ""
      throw new Meteor.Error 400, "Invalid move (taken)"
    if game.currentTurnId != this.userId
      throw new Meteor.Error 403, "It's not your turn"
    if game.players.length != 2
      throw new Meteor.Error 403, "Game isn't ready. There must be 2 players"
    if game.nextSection != "" and section != game.nextSection
      throw new Meteor.Error 400, "Invalid move (wrong section)"
    
    # make move
    game.board[section][position] = this.userId
    game.currentTurnId = _.difference(game.players, [this.userId])[0]
    
    # see if this move finished a section
    if game.board[section].winner == "" and Gameplay.checkWin game.board[section]
      game.board[section].winner = this.userId
    
    # see if nextSection can be set
    nextSection = position
    full = true
    _.each Gameplay.sectionIds, (s) ->
      if game.board[nextSection][s] == ""
        full = false
    if full
      nextSection = ""
    game.nextSection = nextSection
    
    # see if this move finished the game
    if Gameplay.checkWinBoard game.board
      game.winner = this.userId
    
    Games.update _id: gameId,
      $set:
        board: game.board
        currentTurnId: game.currentTurnId
        nextSection: game.nextSection
        winner: game.winner



@displayName = (user) ->
  if user.profile and user.profile.name
    return user.profile.name
  user.emails[0].address

@ownerName = (game) ->
  user = Meteor.users.findOne game.owner
  if user.profile and user.profile.name
    return user.profile.name
  return game.owner

@userById = (_id) ->
  _id = _id + ""
  user = Meteor.users.findOne _id
  return _id if !user
  if user.profile and user.profile.name
    return user.profile.name
  user.emails[0].address
