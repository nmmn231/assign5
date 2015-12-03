//gamestate
PImage startOne, startTwo, endOne, endTwo; 
int gamestate;
final int GAME_START = 1, GAME_RUN = 2, GAME_END = 3;

//background
PImage backgroundOne, backgroundTwo;
int x;

//hp
PImage hpImg;
float hp;

//treasure
PImage treasure;
int treasureX, treasureY;

//fighter
PImage fighter;
int fighterX, fighterY;
boolean upPressed = false, downPressed = false, leftPressed = false, rightPressed = false;

//enemy
PImage enemy;
int restartX;
int enemyCount = 8, enemyType=0;
int[] enemyX = new int[enemyCount];
int[] enemyY = new int[enemyCount];

//bullet
PImage bullet;
int bulletSpeed=5, bulletTurn=2;
int bCounter=-1;
int b=1;
int[] bulletX = new int[5];
int[] bulletY = new int [5];
boolean [] bulletShooting = new boolean[5];
boolean spacePressed = false; 

//score
int score=0;
PFont Verdana;

void setup () {
  size(640, 480) ;
  //fighter
  fighter = loadImage("img/fighter.png");  
  //hp
  hpImg = loadImage("img/hp.png"); 
  hp=196*0.2;  
  //treasure random
  treasure = loadImage("img/treasure.png");  
  treasureX=floor(random(20,520));  
  treasureY=floor(random(50,430));  
  //enemy
  enemy = loadImage("img/enemy.png");
  enemyX[0]=10;
  enemyY[0]=floor(random(50,400));  
  //background
  backgroundOne=loadImage("img/bg1.png");
  backgroundTwo=loadImage("img/bg2.png");
  x=0;
  //gamestate
  startOne = loadImage("img/start2.png");
  startTwo = loadImage("img/start1.png");
  endOne = loadImage("img/end2.png");
  endTwo = loadImage("img/end1.png");
  gamestate = GAME_START;
  //fighter
  fighterX=570;
  fighterY=240; 
  //bullet
  bullet=loadImage("img/shoot.png"); 
  for (int i=0; i<5;i++){
    bulletX[i]=-100;
    bulletY[i]=-100;
    bulletShooting[i]=false;
  }
  
  Verdana=createFont("Verdana",30);
  addEnemy(0);
}

void draw()
{
  background(0);
  
  switch(gamestate){
    case GAME_START:
      image(startOne,0,0);
      if(mouseX>210 && mouseX<450 && mouseY>370 && mouseY<420){
        image(startTwo,0,0);
        if(mousePressed){
          gamestate=2;
        }  
      }
      break;
      
    case GAME_RUN:
    
      //background moving
      image(backgroundTwo,x,0);
      image(backgroundOne,x-640,0);
      image(backgroundTwo,x-1280,0);
      x++;
      x=x%1280;  
            
      // fighter moving
      image(fighter, fighterX, fighterY); 
      if(upPressed){
        fighterY -= 8;
      }
      if(downPressed){
        fighterY += 8;
      }
      if(leftPressed){
        fighterX -= 8;
      }
      if(rightPressed){
        fighterX += 8;
      }
      
      // fighter boundary ditection
      if(fighterX>width-fighter.width){
        fighterX=width-fighter.width;
      }
      if(fighterX<0){
        fighterX=0;
      }
      if(fighterY>height-fighter.height){
        fighterY=height-fighter.height;
      }
      if(fighterY<0){
        fighterY=0;
      }
      
      //bullet
      for(int i=0; i<5; i++){
        if(bulletShooting[i]==true){
          image(bullet, bulletX[i],bulletY[i]);
          bulletX[i]-=bulletSpeed;
          if(enemyY[closestEnemy(fighterX, fighterY)]<fighterY){
            bulletY[i]-=bulletTurn;
          }else{
            bulletY[i]+=bulletTurn;
          }
          if(bulletX[i]<0){
            bulletX[i]=-10000;
            bulletShooting[i]=false;
          }
        }
      }
       if (spacePressed == true){
         int totalBullet=0;
         for(int i=0; i<5; i++){
           if(bulletShooting[i]==true){
            totalBullet++;
           }
         }
        if(b==1 && bulletShooting[(b-1)%5]==false){
           bulletX[(b-1)%5]=fighterX;
           bulletY[(b-1)%5]=fighterY+(fighter.height)/2 ;
           bulletShooting[(b-1)%5] = true;
        }
        if(totalBullet < 5 && fighterX - bulletX[(b-1)%5] >= 65){
          bulletX[b%5] = fighterX;
          bulletY[b%5] = fighterY+(fighter.height)/2;
          bulletShooting[b%5] = true;
          b++;
        }  
      }
      
      //bullet hit enemy
      for(int i =0;i< 8;i++){
        if(enemyX[i]!=-1 || enemyY[i]!=-1){
          for(int j=0; j<5; j++){
            if(isHit(enemyX[i], enemyY[i], enemy.width, enemy.height, bulletX[j], bulletY[j], bullet.width, bullet.height)){
                bulletY[j]=-10000;
                enemyY[i]=-1000;
                scoreChange(20);
            }
          }
        }
      }
      
      //score
      fill(255);
      textFont(Verdana,30);
      text("Score: "+score,10,height-10);
      
      //eating treasure
      image(treasure,treasureX,treasureY);
      if(isHit(fighterX, fighterY, fighter.width, fighter.height, treasureX, treasureY, treasure.width, treasure.height)){
        treasureX=floor(random(20,520));  
        treasureY=floor(random(50,430));
        hp += 196*0.1;
        if(hp>196){
          hp=196;
        }
      }
      
      //hp
      stroke(255,0,0,230);
      fill(255,0,0,230);
      rect(20,12,hp,18);  
      image(hpImg,10,10);
          
      //crash
      for(int i =0;i< 8;i++){
          if(isHit(fighterX, fighterY, fighter.width, fighter.height, enemyX[i], enemyY[i], enemy.width, enemy.height) ){
            hp -=196*0.2;
            enemyY[i]=-100;
            if(hp<1){
              gamestate=3;
            }
          } 
       }
       
       //enemy moving
      for (int i = 0; i < enemyCount; ++i) {
        if (enemyX[i] != -1 || enemyY[i] != -1) {
          image(enemy, enemyX[i], enemyY[i]);
          enemyX[i]+=5;
        } 
      }
      if (enemyX[0]-80*5 > width){
        enemyType++;
        enemyType%=3;
        addEnemy(enemyType);
      }
      
     break;
  
    case GAME_END:   
      image(endOne,0,0);
      if(mouseX>210 && mouseX<450 && mouseY>300 && mouseY<350){
      image(endTwo,0,0);
        if(mousePressed){
          for(int i=0; i<5; i++){
            bulletShooting[i]=false;
          }
          gamestate=2;
          addEnemy(0);
          fighterX=570;
          fighterY=240;
          treasureX=floor(random(20,520));  
          treasureY=floor(random(50,430));
          hp=196*0.2;
        }
    }
   }
 
}

// 0 - straight, 1-slope, 2-dimond
void addEnemy(int type)
{  
  for (int i = 0; i < enemyCount; ++i) {
    enemyX[i] = -1;
    enemyY[i] = -1;
  }
  switch (type) {
    case 0:
      addStraightEnemy();
      break;
    case 1:
      addSlopeEnemy();
      break;
    case 2:
      addDiamondEnemy();
      break;
  }
}

void addStraightEnemy()
{
  float t = random(height - enemy.height);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h;
  }
}
void addSlopeEnemy()
{
  float t = random(height - enemy.height * 5);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {

    enemyX[i] = (i+1)*-80;
    enemyY[i] = h + i * 40;
  }
}
void addDiamondEnemy()
{
  float t = random( enemy.height * 3 ,height - enemy.height * 3);
  int h = int(t);
  int x_axis = 1;
  for (int i = 0; i < 8; ++i) {
    if (i == 0 || i == 7) {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h;
      x_axis++;
    }
    else if (i == 1 || i == 5){
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 1 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 1 * 40;
      i++;
      x_axis++;
      
    }
    else {
      enemyX[i] = x_axis*-80;
      enemyY[i] = h + 2 * 40;
      enemyX[i+1] = x_axis*-80;
      enemyY[i+1] = h - 2 * 40;
      i++;
      x_axis++;
    }
  }
}
void scoreChange(float value){
  score+=value;
}
boolean isHit(int ax, int ay, int aw, int ah, int bx, int by, int bw, int bh){
  if(ay+ah>by && ay<by+bh && ax<bx+bw && ax+aw>bx){
    return true;
  }
  return false;
}
int closestEnemy(int x, int y){
  float minDist=800;
  float [] distances = new float [8];
  for(int i=0; i<8; i++){
    if(enemyX[i]!=-1 || enemyY[i]!=-1){
      distances[i]=dist(enemyX[i],enemyY[i],x,y);
    }
    if(distances[i]<minDist){
      minDist=distances[i];
    }
    if(distances[i]==minDist){
    return i;
    }
  }
  return -1;
}
void keyPressed(){
  if (key == CODED){
    switch(keyCode){
      case UP:
        upPressed = true;
        break;
      case DOWN:
        downPressed = true;
        break;
      case LEFT:
        leftPressed = true;
        break;
      case RIGHT:
        rightPressed = true;  
    }
  }
  if (key == ' '){
    spacePressed = true;
  }
}

void keyReleased(){
  if (key == CODED){
    switch(keyCode){
      case UP:
        upPressed = false;
        break;
      case DOWN:
        downPressed = false;
        break;
      case LEFT:
        leftPressed = false;
        break;
      case RIGHT:
        rightPressed = false;
    }
  }
    if (key == ' '){
    spacePressed = false;
  }
}
