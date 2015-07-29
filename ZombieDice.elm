module ZombieDice where

import Html            exposing (..)
import Html.Events     exposing (..)
import Html.Attributes exposing (..)
import Signal          exposing (..)

type Action = NoOp
            | Prompt
            | Add String
            | Inc Int
            | Reset
            | ResetAll
            | Finish

actions : Signal.Mailbox Action
actions =
    Signal.mailbox NoOp

type alias Player =
  { id       : Int,
    name     : String,
    gamesWon : Int,
    score    : Int }

type alias Model =
  { players : List Player,
    uid     : Int }

initialModel : Model
initialModel =
  { players = [],
    uid     = 0 }

newPlayer: Int -> String -> Player
newPlayer id name =
  { id       = id,
    name     = name,
    gamesWon = 0,
    score    = 0 }

-- PORTS --------------------------------

-- port is used to push the name stirng in from javascript
port addPlayer : Signal String

-- port is used to force the display of a prompt
port displayPrompt : Signal ()
port displayPrompt =
  actions.signal
    |> filter (\s -> s == Prompt) NoOp
    |> map (always ())

externalActions: Signal Action
externalActions =
  mergeMany
    [ (Add) <~ addPlayer ]

update: Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model
    Prompt ->
      model -- this is just a pass through as it is handled externally
    Add name ->
      { model | players <- (model.players ++ [ newPlayer model.uid name ]),
                uid     <- model.uid + 1 }
    Inc id ->
      let inc p = if p.id == id then { p | score <- p.score + 1  } else p
      in
         { model | players <- List.map inc model.players }
    Reset ->
      let resetPlayer p = { p | score <- 0, gamesWon <- 0 }
      in
        { model | players <- List.map resetPlayer model.players }
    ResetAll ->
      initialModel
    Finish ->
      let winnerId = model.players
                       |> List.sortBy .score
                       |> List.reverse
                       |> List.head
                       |> Maybe.map .id
                       |> Maybe.withDefault 0
          win p = if p.id == winnerId then { p | score <- 0, gamesWon <- p.gamesWon + 1  } else { p | score <- 0 }
      in
         { model | players <- List.map win model.players }

-- taking our initialModel we combine all the actions that conspire to change our state
model : Signal Model
model =
  let
    allActions = mergeMany
      [ actions.signal,
        externalActions ]
  in
    foldp update initialModel allActions

-- VIEWS --------------------------------

wonGame: Html
wonGame =
  img
    [ src    "images/gold-brain.png",
      height 20 ]
    []

playerEntry: Address Action -> Player -> Html
playerEntry address player =
  div
    [ class "row" ]
    [ div
        [ class "col span_3 name" ]
        [ h2
            []
            [ text player.name ],
          span
            []
            (List.map (always wonGame) [1..(player.gamesWon)])],
      div
        [ class "col span_3" ]
        [ img
            [ class "brain",
              src   "images/brain.png",
              onClick address (Inc player.id) ]
            [],
          span
            [ class "score" ]
            [ small
                []
                [ text "x" ],
              span
                []
                [text (toString player.score)]  ] ] ]

scoreCard : Address Action -> Model -> Html
scoreCard address model =
  div
    []
    [ h1
        []
        [ text "Zombie Dice" ],
      h2
        []
        [ text "Score Card"],
      div
        [ class "buttons" ]
        [ button
            [ onClick address Prompt ]
            [ text "Add Player" ],
          button
            [ onClick address Reset ]
            [ text "Reset Scores" ],
          button
            [ onClick address ResetAll ]
            [ text "Clear All!" ],
          button
            [ onClick address Finish ]
            [ text "Finish Game" ] ],
      div
        [ class "players" ]
        (List.map (playerEntry address) model.players)]

main : Signal Html
main = map (scoreCard actions.address) model
