import de.voidplus.leapmotion.*;

LeapMotion leap;

GameStateEnum gameState;
WaitingTicks ticks;

int playerLeftId = -1;
int playerRightId = -1;
int numHands = 0;

void setup() {
  size(800, 500);
  background(255);
  leap = new LeapMotion(this);
  gameState = GameStateEnum.IDLE_WAITING;
  ticks = new WaitingTicks();
  ticks.setNoWaiting();
}

void drawGameState()
{
  text("Game State: " + gameState, 10, 10);
  text("Waiting ticks: " + ticks.toString(), 10, 20);
  text("Number hands: " + numHands, 10, 30);
  text("Player Left Id: " + playerLeftId, 10, 40);
  text("Player Right Id: " + playerRightId, 10, 50);
}

void draw()
{
  background(255);
  numHands = leap.countHands();

  drawGameState();

  for (Hand hand : leap.getHands ()) {
    hand.draw();
  }
  switch (gameState)
  {
  case IDLE_WAITING:
    idle_waiting(); 
    break;
  case ONE_HAND_WAITING:
    one_hand_waiting(); 
    break;
  case TWO_HANDS_WAITING:
    two_hands_waiting(); 
    break;
  case CLOSE_HAND_WAITING:
    close_hand_waiting(); 
    break;
  case READY_STARTING:
    ready_starting(); 
    break;
  case SET_STARTING:
    set_starting(); 
    break;
  case GO_STARTING:
    go_starting(); 
    break;
  case PLAYING:
    playing(); 
    break;
  case WINNER_PLAYER_LEFT:
    winner_player_left(); 
    break;
  case WINNER_PLAYER_RIGHT:
    winner_player_right(); 
    break;
  }
  ticks.increase();
}

void set_state(GameStateEnum new_state)
{
  exit_current_state(gameState);
  gameState = new_state;
  enter_new_state(gameState);
}

void exit_current_state(GameStateEnum st)
{
  switch (st)
  {
  case IDLE_WAITING:
    //idle_waiting_exit(); 
    break;
  case ONE_HAND_WAITING:
    //one_hand_waiting_exit(); 
    break;
  case TWO_HANDS_WAITING:
    two_hands_waiting_exit(); 
    break;
  case CLOSE_HAND_WAITING:
    close_hand_waiting_exit(); 
    break;
  case READY_STARTING:
    ready_starting_exit(); 
    break;
  case SET_STARTING:
    set_starting_exit(); 
    break;
  case GO_STARTING:
    go_starting_exit(); 
    break;
  case PLAYING:
    playing_exit(); 
    break;
  case WINNER_PLAYER_LEFT:
    //winner_player_left_exit(); 
    break;
  case WINNER_PLAYER_RIGHT:
    //winner_player_right_exit(); 
    break;
  }
}

void enter_new_state(GameStateEnum st)
{
  switch (st)
  {
  case IDLE_WAITING:
    //idle_waiting_enter(); 
    break;
  case ONE_HAND_WAITING:
    //one_hand_waiting_enter();
    break;
  case TWO_HANDS_WAITING:
    two_hands_waiting_enter();
    break;
  case CLOSE_HAND_WAITING:
    close_hand_waiting_enter(); 
    break;
  case READY_STARTING:
    ready_starting_enter(); 
    break;
  case SET_STARTING:
    set_starting_enter(); 
    break;
  case GO_STARTING:
    go_starting_enter(); 
    break;
  case PLAYING:
    playing_enter(); 
    break;
  case WINNER_PLAYER_LEFT:
    //winner_player_left_enter(); 
    break;
  case WINNER_PLAYER_RIGHT:
    //winner_player_right_enter(); 
    break;
  }
}

/************************
 IDLE_WAITING
 ************************/
void idle_waiting()
{
  if (leap.countHands() == 1)
  {
    set_state(GameStateEnum.ONE_HAND_WAITING);
  }
}

/************************
 ONE_HAND_WAITING
 ************************/
void one_hand_waiting()
{
  if (leap.countHands() == 0)
  {
    set_state(GameStateEnum.IDLE_WAITING);
  } else if (leap.countHands() == 2)
  {
    set_state(GameStateEnum.TWO_HANDS_WAITING);
  }
}

/************************
 TWO_HANDS_WAITING
 ************************/
void two_hands_waiting_enter()
{
  ticks.setWaitingTicks(200);
}

void two_hands_waiting_exit()
{
  ticks.setNoWaiting();
}

void two_hands_waiting()
{
  if (leap.countHands() == 1)
  {
    set_state(GameStateEnum.ONE_HAND_WAITING);
  } else if (leap.countHands() == 0)
  {
    set_state(GameStateEnum.IDLE_WAITING);
  }

  if (ticks.triggered())
  {
    set_state(GameStateEnum.CLOSE_HAND_WAITING);
  }
}

/************************
 CLOSE_HAND_WAITING
 ************************/
void close_hand_waiting()
{
  if (ticks.triggered())
  {
    set_state(GameStateEnum.READY_STARTING);
  }
}

void close_hand_waiting_enter()
{
  ArrayList<Hand> hands = leap.getHands();
  //Assign player hands
  if (hands.get(0).getPosition().x < hands.get(1).getPosition().x)
  {
    playerLeftId = hands.get(0).getId();
    playerRightId = hands.get(1).getId();
  }
  else
  {
    playerLeftId = hands.get(1).getId();
    playerRightId = hands.get(0).getId();
  }
  
  ticks.setWaitingTicks(500);
}

void close_hand_waiting_exit()
{
  ticks.setNoWaiting();
}

/************************
 READY_STARTING
 ************************/
void ready_starting()
{
}

void ready_starting_enter()
{
  ticks.setWaitingTicks(300);
}

void ready_starting_exit()
{
  ticks.setNoWaiting();
}

/************************
 SET_STARTING
 ************************/
void set_starting()
{
}

void set_starting_enter()
{
  ticks.setWaitingTicks(300);
}

void set_starting_exit()
{
  ticks.setNoWaiting();
}

/************************
 GO_STARTING
 ************************/
void go_starting()
{
}

void go_starting_enter()
{
  ticks.setWaitingTicks(300);
}

void go_starting_exit()
{
  ticks.setNoWaiting();
}

/************************
 PLAYING
 ************************/
void playing()
{
}

void playing_enter()
{
}

void playing_exit()
{
}

/************************
 WINNER_PLAYER_LEFT
 ************************/
void winner_player_left()
{
}

/************************
 WINNER_PLAYER_RIGHT
 ************************/
void winner_player_right()
{
}