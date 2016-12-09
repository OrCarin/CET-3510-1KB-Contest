/*
 * CET 3510-1KB challenge 
 * LEDs flashing patter
 * 
 *  RECOMMNED USING RGB LEDS
 *  USING PWM TO CONTROLL LIGHT INTENSITY
 *  
 * ============================PLAYER SCRORE NOTIFICATION===========================
 * -Flash all player's LEDs once for one second (brigthest setting)
 * -Flash Player's LED 4 times, 0.5s intervals (or dim accordingly)
 * 
 * =================================================================================
 * 
 * 
 * =========================END OF MATCH(WINNER_LED)================================
 * -Flash all LEDs 6 times 0.2s intervals 
 * 
 * =================================================================================
 * 
 * 
 * 
 */

//==========================LED PIN def====================//

const int Player1_LED=8;//player 1 LED set to pin 3(either one end LED or separete LED)
const int Player2_LED=9;// player 2 LED set topin 9
const int RGB_R=4;//RGB red led 
const int RGB_G=3;// RGB green led
const int RGB_B=2;// RGB blue Led
int LED_Max= 255;
int LED_Min= 0; // minimum acceptable LED brightness (still on)

char TEST = 0; //TESTING DIFFRENT PATTERS THROUGH SERIAL MONITOR INPUTS 
int brns = 10; 
int light=0;

void setup() 
{
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(Player1_LED, OUTPUT);
  pinMode(Player2_LED, OUTPUT);
  pinMode(RGB_R,OUTPUT);
  pinMode (RGB_G,OUTPUT);
  pinMode (RGB_B, OUTPUT);
  //LEDs off 
  analogWrite(Player1_LED, 0);
  analogWrite(Player2_LED, 0);
  analogWrite(RGB_R,255);//RGB common anode (PIN MUST BE HIGH TO BE OFF)
  analogWrite (RGB_G,255);
  analogWrite (RGB_B,255);
  Serial.print("Nothing to see here");
}

void loop() 
{

//===========patter test==============//

if (Serial.available())
{
  Serial.println("Waiting for input(choose a patter {1,2,3})");
  TEST = Serial.read();
}

// use 1 for game over, 2 for player scored, 3 for match begin,

  if (TEST == '1') //(game over)
  {
    Serial.println("Game over");
    GameOver(Player1_LED,Player2_LED,LED_Max,LED_Min, 500);
    delay(1000); //wait a second and standby
    TEST =4;
  }


if (TEST == '2')
{
  Serial.println("Player1 Scored!");
  analogWrite(Player2_LED,0);// turn the loser LED off [for testing]
 Player_Scored(Player1_LED, 100,255);// asume player 1 wins, for testing
}

if (TEST == '3')
{
  Serial.println("Get ready to. . . see LEDs flashing. . .");
  Match_Begin( Player1_LED, Player2_LED, 500,255);
  //CHANGE TEST STATE SO THAT WE CAN RETURN TO STANDBY
}

 if (TEST == '4')
 {
  Serial.println("standby");
 
  Standby_Pattern(Player1_LED, Player2_LED, LED_Max);
 }

 if (TEST == '5')
 {
  Serial.println("What do you see?");
  //digitalWrite(RGB_B, HIGH);
  RGB_Play();
  digitalWrite(RGB_R,HIGH);
  digitalWrite (RGB_G,HIGH);
  digitalWrite (RGB_B,HIGH);
  TEST=0;
 }

 if (TEST == '6')
 {
  Serial.println("Nothing special");
  RGB_TEST();
  TEST = 0;
 }
 
}




//==================================FLASH LED FUCTION=============================//
//defining multiple functions with a single patter (call one of the functions according to event and input proper parameters)


void Standby_Pattern( int LED_1, int LED_2, int Light)
{
  
 Dim_light3(LED_1,LED_2,Light);
// Dim_light3(LED_2,Light);
}


//===================================================
void GameOver(int LED_1, int LED_2, int Max, int Min,int pause) //pending to include more parameters based on LEDs implemented
{
  for (int i=5; i>=0;i--)
  {
 analogWrite(LED_1,LED_Max);
 analogWrite(LED_2,LED_Max);
  delay(pause);
 analogWrite(LED_1,Min);
 analogWrite(LED_2,Min);
 delay(pause);
  }
}

//=======================================================
void Player_Scored(int Player_LED, int interval,int light)
{
 
  for(int i=0; i <=2; i++ )
  {
  analogWrite(Player_LED, light);
  delay(interval);
  analogWrite (Player_LED,0);
  delay(interval);
  }
  
  Dim_light(Player_LED,light);
  
}


//=======================================================
void Match_Begin(int LED1,int LED2, int interval, int Light) // to run before game starts (interval controls the speed of the blinking lights)
{
 //for(int i=0; i <=2; i++ )
 /// {
  
  analogWrite(LED2, 0);
  Dim_light(LED1,Light);
  delay(interval);
  analogWrite(LED1, 0);
  Dim_light(LED2,Light);
  
  delay(interval);
  //}
}

void Dim_light(int LED, int Light)// dims lights and halts code until the leds are off
{
  while (Light >=0)
  {
    analogWrite(LED,Light);
    Light = Light-3;
    delay(30);
  }
  
  
}
 void Dim_light2(int LED, int Light) // second light dim (allows for parallel excecution)
{

    if(Light >0)
    {
    analogWrite(LED,Light);
    Light = Light-5;
    }
  }

  void Dim_light3(int LED, int LED2, int Light)// dims lights and halts code until the leds are off
{
  while (Light >0)
  {
    analogWrite(LED,Light);
    analogWrite(LED2,Light);
    Light = Light-5;
    delay(30);
  }
}

void RGB_Play()//cycles from yellow to white
{

  /*
   USE DIFFERENT INTENSITIES TO CREATE MORE COLOURS

   LIST IN 255 BASIS
  
  
  
  */
   int Light =0;
   int inc= 5;
   int rep=0;
   boolean Done = false;
   while(Done == false)
   {
    Light = Light + inc;
    analogWrite(RGB_R,Light/15);
    delay(30);
    analogWrite(RGB_G,Light);
    delay(50);
    analogWrite(RGB_B,Light/20);
    delay(50);

    if (Light >= 255)
    {
      inc = -5;
      rep++; 
    }
     if (Light <=0)
     {
      inc = 5;
        if(rep >= 2)
        {
          Done = true;
          Serial.println("Done");
        }
       }
     }
}

void RGB_TEST()
{

//one colour
analogWrite(RGB_R,204);
analogWrite(RGB_G,255);
analogWrite(RGB_B,255);
delay (500);
//another colour
analogWrite(RGB_R,251);
analogWrite(RGB_G,153);
analogWrite(RGB_B,51);
delay (500);
analogWrite(RGB_R,204/256);
analogWrite(RGB_G,255/256);
analogWrite(RGB_B,255/256);
delay (500);

// turns RGB off
analogWrite(RGB_R,255);
analogWrite (RGB_G,255);
analogWrite (RGB_B,255);
delay(100);


}
   
   
  


  




