
Meteor.publish "games", () ->
  q = [{public: true}]
  if this.userId
    check this.userId, String
    q.push players: this.userId
    q.push owner: this.userId
  Games.find
    $or: q

Meteor.publish "game", (gameId) ->
  check gameId, String
  q = [{public: true}]
  if this.userId
    check this.userId, String
    q.push players: this.userId
    q.push owner: this.userId
  Games.find
    _id: gameId
    $or: q

Meteor.publish "players", () ->
  Meteor.users.find
    _id:
      $ne: this.userId

Meteor.publish "waiting_for_me", () ->
  check this.userId, String
  Games.find
    players: this.userId
    currentTurnId: this.userId
    winner: ""