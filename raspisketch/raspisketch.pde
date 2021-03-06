import de.voidplus.leapmotion.*;
import processing.serial.*;

LeapMotion leap;

GameStateEnum gameState;
WaitingTicks ticks;

int numHands = 0;

int playerLeftId = -1;
float progressLeft = 0.0f;
PVector previousPalmNormalLeft;
float minPalmRollLeft = Float.MAX_VALUE;
float maxPalmRollLeft = Float.MIN_VALUE;

int playerRightId = -1;
float progressRight = 0.0f;
PVector previousPalmNormalRight;
float minPalmRollRight = Float.MAX_VALUE;
float maxPalmRollRight = Float.MIN_VALUE;

ArrayList<Hand> hands;

final float maxProgress = 150.0f;
byte[] progressBytes = new byte[]{0, 0};

Serial screenPort;
Serial carPort;

void setup() {
  size(800, 500);
  background(255);
  leap = new LeapMotion(this);
  gameState = GameStateEnum.IDLE_WAITING;
  ticks = new WaitingTicks();
  ticks.setNoWaiting();

  printArray(Serial.list());
  screenPort = new Serial(this, "COM5", 9600);
  carPort = new Serial(this, "COM6", 9600);

  if (screenPort != null)
    screenPort.write('0');
  if (carPort != null)
  {
    progressBytes[0] = progress(progressLeft);
    progressBytes[1] = progress(progressRight);
    carPort.write(progressBytes);
  }
}

void drawGameState()
{
  text("Game State: " + gameState, 10, 10);
  text("Waiting ticks: " + ticks.toString(), 10, 20);
  text("Number hands: " + numHands, 10, 30);
  text("Player Left Id: " + playerLeftId, 10, 40);
  text("Player Left Dynamics: "+ (previousPalmNormalLeft == null? "nil": (int)previousPalmNormalLeft.x + "," + (int)previousPalmNormalLeft.y + "," + (int)previousPalmNormalLeft.z), 10, 50);
  text("Player Left Progress: " + progressLeft + "/" + maxProgress + " (" + progress(progressLeft) + ")", 10, 60);
  text("Player Left Roll Range: " + minPalmRollLeft + "/" + maxPalmRollLeft + ")", 10, 70);
  text("Player Right Id: " + playerRightId, 10, 80);
  text("Player Right Dynamics: "+ (previousPalmNormalRight == null? "nil": previousPalmNormalRight.toString()), 10, 90);
  text("Player Right Progress: " + progressRight + "/" + maxProgress + " (" + progress(progressRight) + ")", 10, 100);
  text("Player Right Roll Range: " + minPalmRollRight + "/" + maxPalmRollRight + ")", 10, 110);
}

byte progress(float input)
{
  return (byte)Math.max(30, Math.min(120, 30 + (input/maxProgress*90)));
}

void draw()
{
  background(255);
  numHands = leap.countHands();

  drawGameState();

  hands = leap.getHands();
  //for (Hand hand : hands) {
  //  hand.draw();
  //}
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
    idle_waiting_exit(); 
    break;
  case ONE_HAND_WAITING:
    one_hand_waiting_exit(); 
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
    winner_player_left_exit(); 
    break;
  case WINNER_PLAYER_RIGHT:
    winner_player_right_exit(); 
    break;
  }
}

void enter_new_state(GameStateEnum st)
{
  switch (st)
  {
  case IDLE_WAITING:
    idle_waiting_enter(); 
    break;
  case ONE_HAND_WAITING:
    one_hand_waiting_enter();
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
    winner_player_left_enter(); 
    break;
  case WINNER_PLAYER_RIGHT:
    winner_player_right_enter(); 
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

void idle_waiting_enter()
{
  if (screenPort != null)
    screenPort.write('0');
  progressLeft = 0;
  progressRight = 0;
  if (carPort != null)
  {
    progressBytes[0] = 30;
    progressBytes[1] = 30;
    carPort.write(progressBytes);
  }

  previousPalmNormalLeft = null;
  previousPalmNormalRight = null;
  minPalmRollLeft = Float.MAX_VALUE;
  maxPalmRollLeft = Float.MIN_VALUE;
  minPalmRollRight = Float.MAX_VALUE;
  maxPalmRollRight = Float.MIN_VALUE;
  playerLeftId = -1;
  playerRightId = -1;
}

void idle_waiting_exit()
{
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

  //if (hands.size() > 0)
  //{
  //  PVector currentPalmNormalLeft = hands.get(0).getDynamics();

  //  if (currentPalmNormalLeft.x < minPalmRollLeft)
  //  {
  //    minPalmRollLeft = currentPalmNormalLeft.x;
  //  }
  //  if (currentPalmNormalLeft.x > maxPalmRollLeft)
  //  {
  //    maxPalmRollLeft = currentPalmNormalLeft.x;
  //  }

  //  if (previousPalmNormalLeft == null)
  //  {
  //    previousPalmNormalLeft = currentPalmNormalLeft;
  //  } else
  //  {
  //    if ((previousPalmNormalLeft.x < palmRollCenterLeft() && currentPalmNormalLeft.x > palmRollCenterLeft()) ||
  //      (previousPalmNormalLeft.x > palmRollCenterLeft() && currentPalmNormalLeft.x < palmRollCenterLeft()))
  //    {
  //      progressRight += 1.0f;
  //    }
  //    previousPalmNormalLeft = currentPalmNormalLeft;
  //  }
  //}

  if (carPort != null)
  {
    progressBytes[0] = progress(progressLeft);
    progressBytes[1] = progress(progressRight);
    carPort.write(progressBytes);
  }
}

void one_hand_waiting_enter()
{
  if (screenPort != null)
    screenPort.write('1');
}

void one_hand_waiting_exit()
{
}

/************************
 TWO_HANDS_WAITING
 ************************/
void two_hands_waiting_enter()
{
  if (screenPort != null)
    screenPort.write('2');
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
  assignPlayerHands();

  ticks.setWaitingTicks(500);
  if (screenPort != null)
    screenPort.write('3');
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
  if (ticks.triggered())
  {
    set_state(GameStateEnum.SET_STARTING);
  }
}

void ready_starting_enter()
{
  if (screenPort != null)
    screenPort.write('4');
  ticks.setWaitingTicks(200);
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
  if (ticks.triggered())
  {
    set_state(GameStateEnum.GO_STARTING);
  }
}

void set_starting_enter()
{
  if (screenPort != null)
    screenPort.write('5');
  ticks.setWaitingTicks(150);
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
  if (ticks.triggered())
  {
    set_state(GameStateEnum.PLAYING);
  }
}

void go_starting_enter()
{
  if (screenPort != null)
    screenPort.write('6');
  ticks.setWaitingTicks(100);
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
  PVector currentPalmNormalLeft = getPalmDynamicsLeft();
  PVector currentPalmNormalRight = getPalmDynamicsRight();

  if (currentPalmNormalLeft != null)
  {
    if (currentPalmNormalLeft.x < minPalmRollLeft)
    {
      minPalmRollLeft = currentPalmNormalLeft.x;
    }
    if (currentPalmNormalLeft.x > maxPalmRollLeft)
    {
      maxPalmRollLeft = currentPalmNormalLeft.x;
    }
      
    if (previousPalmNormalLeft == null)
    {
      previousPalmNormalLeft = currentPalmNormalLeft;
    }
    else
    {
      if ((previousPalmNormalLeft.x < palmRollCenterLeft() && currentPalmNormalLeft.x > palmRollCenterLeft()) ||
          (previousPalmNormalLeft.x > palmRollCenterLeft() && currentPalmNormalLeft.x < palmRollCenterLeft()))
      {
        progressLeft += 1.0f;
      }
      previousPalmNormalLeft = currentPalmNormalLeft;
    }
    
    previousPalmNormalLeft = currentPalmNormalLeft;
  }
  
  if (currentPalmNormalRight != null)
  {
    if (currentPalmNormalRight.x < minPalmRollRight)
    {
      minPalmRollRight = currentPalmNormalRight.x;
    }
    if (currentPalmNormalRight.x > maxPalmRollRight)
    {
      maxPalmRollRight = currentPalmNormalRight.x;
    }
      
    if (previousPalmNormalRight == null)
    {
      previousPalmNormalRight = currentPalmNormalRight;
    }
    else
    {
      if ((previousPalmNormalRight.x < palmRollCenterRight() && currentPalmNormalRight.x > palmRollCenterRight()) ||
          (previousPalmNormalRight.x > palmRollCenterRight() && currentPalmNormalRight.x < palmRollCenterRight()))
      {
        progressRight += 1.0f;
      }
      previousPalmNormalRight = currentPalmNormalRight;
    }
    
    previousPalmNormalRight = currentPalmNormalRight;
  }

  if (carPort != null)
  {
    progressBytes[0] = progress(progressLeft);
    progressBytes[1] = progress(progressRight);
    carPort.write(progressBytes);
  }
  
  if (progressLeft >= 120)
  {
    set_state(GameStateEnum.WINNER_PLAYER_LEFT);
  }
  else if (progressRight >= 120)
  {
    set_state(GameStateEnum.WINNER_PLAYER_RIGHT);
  }
}

void playing_enter()
{
  if (screenPort != null)
    screenPort.write('7');
  progressLeft = 0.0f;
  progressRight = 0.0f;
  previousPalmNormalLeft = getPalmDynamicsLeft();
  previousPalmNormalRight = getPalmDynamicsRight();
}

void playing_exit()
{
}

/************************
 WINNER_PLAYER_LEFT
 ************************/
void winner_player_left()
{
  if (ticks.triggered())
  {
    set_state(GameStateEnum.IDLE_WAITING);
  }
}

void winner_player_left_enter()
{
  if (screenPort != null)
    screenPort.write('8');
  ticks.setWaitingTicks(500);
}

void winner_player_left_exit()
{
  ticks.setNoWaiting();
}

/************************
 WINNER_PLAYER_RIGHT
 ************************/
void winner_player_right()
{
  if (ticks.triggered())
  {
    set_state(GameStateEnum.IDLE_WAITING);
  }
}


void winner_player_right_enter()
{
  if (screenPort != null)
    screenPort.write('9');
  ticks.setWaitingTicks(500);
}

void winner_player_right_exit()
{
  ticks.setNoWaiting();
}

/*************
 THE HANDS
 *************/
void assignPlayerHands()
{
  if (playerLeftId == -1 && playerRightId == -1 && leap.countHands() == 2)
  {
    if (hands.get(0).getPosition().x < hands.get(1).getPosition().x)
    {
      playerLeftId = hands.get(0).getId();
      playerRightId = hands.get(1).getId();
    } else
    {
      playerLeftId = hands.get(1).getId();
      playerRightId = hands.get(0).getId();
    }
  }
}

PVector getPalmDynamicsLeft()
{
  for (Hand h : hands)
  {
    if (h.getId() == playerLeftId)
    {
      return h.getDynamics();
    }
  }
  return null;
}

PVector getPalmDynamicsRight()
{
  for (Hand h : hands)
  {
    if (h.getId() == playerRightId)
    {
      return h.getDynamics();
    }
  }
  return null;
}

float palmRollCenterLeft()
{
  return minPalmRollLeft + (maxPalmRollLeft - minPalmRollLeft) / 2.0f;
}

float palmRollCenterRight()
{
  return minPalmRollRight + (maxPalmRollRight - minPalmRollRight) / 2.0f;
}