//+------------------------------------------------------------------+
//|                                                 Trend_killer.mq4 |
//|                              Chimenti Nicola (@tekno_trader)     |
//+------------------------------------------------------------------+
#property copyright "Chimenti Nicola (@tekno_trader)"
#property link      "https://www.fiverr.com/teknonicola"
#property version   "1.00"
#property description "This EA is designed on 2 special Smoothed MA, which allows to determine a trend with a statistic advantage really high."
#property description "Automatical alert can be send when there are good conditions for entering in the market."
#property description "\n"
#property description "ATTENTION!!!"
#property description "The system does not provide any investment and/or trading suggestions."
#property description "It is an useful tool, but you have to manage risk properly and try it on a demo account."
#property description "Go to real account only when you're sure 100% that you can be responsable and profitable."
//#property icon "\\Files\\Logo_tekno_trader.ico"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrSteelBlue
#property indicator_color2 clrDarkOrange
#property indicator_color3 clrGray
#property indicator_color4 clrPurple
#property indicator_color5 clrWhiteSmoke
#property indicator_color6 clrOrangeRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 5
#property indicator_width6 5

input bool Welcome = true;                     // Welcome message
input bool Bye = true;                         // Shutdown message
//input string ahcianacja = "----------------";  // -------------------------
input string FIRST_SECTION = "------------------"; 
//input string ahcidancja = "----------------";  // -------------------------
input int Periods = 20;                        // First MA period
input int Periods2 = 200;                      // Second MA period
input int Periods_Daily = 20;                  // Third MA period
/*input*/ int Method = 0;                      
int Periodo_smoothing = 15;                    // Smoothing period
input int Higher_timeframe_minutes = 1440;     // Timeframe of the third MA (in minutes)
/*input*/ int Smoothing_method = 1;            // 1 would be exponential smoothing
//input string ahciancj = "----------------";    // -------------------------
input string SECOND_SECTION = "----------------"; // Text and alert settings
//input string ahciansj = "----------------";    // -------------------------
input string Alert_color_bearish = "DarkOrange";
input string Alert_color_bullish = "Green";
input string Alert_color_uncertain = "White";
input int Charachter = 16;                     // Text dimension
input int Charachter2 = 20;                    // "Important" text dimension
enum List {Left, Right};
/*input*/ List Corner = Left;                 // Corner of text
int Left = 0;                                  // Left Corner
int Right = 1;

int colore_bearish = StringToColor("clr" + Alert_color_bearish);
int colore_bullish = StringToColor("clr" + Alert_color_bullish);
int colore_uncertain = StringToColor("clr" + Alert_color_uncertain);

input int Dimension_X_rectangle = 450;         // Dimension X rectangle
input int Dimension_Y_rectangle = 350;         // Dimension Y rectangle
//input string ahciancja = "----------------";   // -------------------------
input string REVIEW_SECTION = "----------------"; // REVIEW SECTION
//input string ahciancjd = "----------------";   // -------------------------
input bool Review_button = true;               // Visualize Review Button

string colore_rettangolo = "Black";

double MaBuffer[], SmoothMAbuffer[];
double ColorUpBUffer[],ColorDownBuffer[];  // The second series of buffers indicates when color changes, everything recalculates
double MaBuffer2[], SmoothMAbuffer2[];
double ColorUpBUffer2[],ColorDownBuffer2[]; // The second series of buffers indicates when color changes, everything recalculates
double MaBufferDaily[], SmoothMAbufferDaily[];
double ColorUpBUfferDaily[], ColorDownBufferDaily[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Comment("EA made by Tekno Trader ©", "\n"
           "VAT Code: 02674000464", "\n"
           "","\n"
           "Please, trade with responsability");
           
   if(Welcome)
     {
      Alert("");
      Alert("Have a nice trading day " + AccountName() + " !");
     }

   // Creating large rectangle
   ObjectCreate("Rectangle",OBJ_BUTTON,0,0,0);
   ObjectSetText("Rectangle","" ,16,"Arial",StringToColor("clr" + colore_rettangolo));
   ObjectSetInteger(0,"Rectangle",OBJPROP_XSIZE,Dimension_X_rectangle);
   ObjectSetInteger(0,"Rectangle",OBJPROP_YSIZE, Dimension_Y_rectangle);
   ObjectSet("Rectangle",OBJPROP_XDISTANCE,0);
   ObjectSet("Rectangle",OBJPROP_YDISTANCE, 70);
   ObjectSet("Rectangle",OBJPROP_CORNER,Corner);
   ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,indicator_color3);
   ObjectSetInteger(0,"Rectangle",OBJPROP_BGCOLOR,StringToColor("clr" + colore_rettangolo));

   ObjectCreate("OVERALL SITUATION",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("OVERALL SITUATION","Connecting..." ,20,"Arial",colore_uncertain);
   ObjectSet("OVERALL SITUATION",OBJPROP_XDISTANCE,260);
   ObjectSet("OVERALL SITUATION",OBJPROP_YDISTANCE, 120);
   ObjectSet("OVERALL SITUATION",OBJPROP_CORNER,0);

   ObjectCreate("Long term situation",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("Long term situation","Connecting..." ,16,"Arial",colore_uncertain);
   ObjectSet("Long term situation",OBJPROP_XDISTANCE,200);
   ObjectSet("Long term situation",OBJPROP_YDISTANCE, 100);
   ObjectSet("Long term situation",OBJPROP_CORNER,0);

   ObjectCreate("Short term situation",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("Short term situation","Connecting..." ,16,"Arial",colore_uncertain);
   ObjectSet("Short term situation",OBJPROP_XDISTANCE,200);
   ObjectSet("Short term situation",OBJPROP_YDISTANCE, 80);
   ObjectSet("Short term situation",OBJPROP_CORNER,0);

   ObjectCreate("Status111",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("Status111","--------------------------------------" ,16,"Arial",clrWhite);
   ObjectSet("Status111",OBJPROP_XDISTANCE,10);
   ObjectSet("Status111",OBJPROP_YDISTANCE, 160);
   ObjectSet("Status111",OBJPROP_CORNER,0);

   ObjectCreate("Bias",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("Bias","Connecting..." ,16,"Arial",colore_uncertain);
   ObjectSet("Bias",OBJPROP_XDISTANCE,260);
   ObjectSet("Bias",OBJPROP_YDISTANCE, 200);
   ObjectSet("Bias",OBJPROP_CORNER,0);

   ObjectCreate("Status1",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("Status1","--------------------------------------" ,16,"Arial",clrWhite);
   ObjectSet("Status1",OBJPROP_XDISTANCE,10);
   ObjectSet("Status1",OBJPROP_YDISTANCE, 235);
   ObjectSet("Status1",OBJPROP_CORNER,0);

   if(ObjectFind(0,"button") < 0)
     {
      ObjectCreate("Status",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Status","Alert status: NOT ALLOWED" ,16,"Arial",colore_uncertain);
      ObjectSet("Status",OBJPROP_XDISTANCE,10);
      ObjectSet("Status",OBJPROP_YDISTANCE, 270);
      ObjectSet("Status",OBJPROP_CORNER,0);

      ObjectCreate("Text",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Text","To activate alerts, click the button below!" ,16,"Arial",clrWhite);
      ObjectSet("Text",OBJPROP_XDISTANCE,10);
      ObjectSet("Text",OBJPROP_YDISTANCE, 330);
      ObjectSet("Text",OBJPROP_CORNER,0);

      ObjectCreate(0,"button",OBJ_BUTTON,0,0,0);
      ObjectSetText("button","Enable Alerts",16,"Arial",clrRed);
      ObjectSetInteger(0,"button",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"button",OBJPROP_YSIZE, 30);
      ObjectSetInteger(0,"button",OBJPROP_XDISTANCE,120);
      ObjectSetInteger(0,"button",OBJPROP_YDISTANCE, 360);
      ObjectSetInteger(0,"button",OBJPROP_CORNER,0);
      ObjectSetInteger(0,"button",OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,"button",OBJPROP_BGCOLOR,clrBlue/*indicator_color2*/);
     }

   IndicatorBuffers(12);

   // First 2 buffers, the colored ones
   SetIndexBuffer(0,ColorUpBUffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,"MA UP");

   SetIndexBuffer(1,ColorDownBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexLabel(1,"MA DOWN");

   // Colored buffers long average
   SetIndexBuffer(2,ColorUpBUffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexLabel(2,"MA UP long term");

   SetIndexBuffer(3,ColorDownBuffer2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexLabel(3,"MA DOWN long term");

   // DAILY MOVING AVERAGE
   SetIndexBuffer(4,ColorUpBUfferDaily);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexLabel(4,"Bias up");

   SetIndexBuffer(5,ColorDownBufferDaily);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexLabel(5,"Bias down");

   // Non-drawn buffers
   SetIndexBuffer(6,MaBuffer);
   SetIndexStyle(6,DRAW_NONE);

   SetIndexBuffer(7,SmoothMAbuffer);
   SetIndexStyle(7,DRAW_NONE);

   //---
   SetIndexBuffer(8,MaBuffer2);
   SetIndexStyle(8,DRAW_NONE);

   SetIndexBuffer(9,SmoothMAbuffer2);
   SetIndexStyle(9,DRAW_NONE);

   // DAILY MOVING AVERAGE
   SetIndexBuffer(10,MaBufferDaily);
   SetIndexStyle(10,DRAW_NONE);

   SetIndexBuffer(11,SmoothMAbufferDaily);
   SetIndexStyle(11,DRAW_NONE);

   return(INIT_SUCCEEDED);
  }

int deinit()
  {
   ObjectDelete("OVERALL SITUATION999");
   ObjectDelete("OVERALL SITUATION1");
   ObjectDelete("OVERALL SITUATION2");
   ObjectDelete("OVERALL SITUATION3");
   ObjectDelete("BORDER");

   if(Bye)
     {
      Alert("");
      Alert("Expert '' " + __FILE__ +" '' turned off");
     }

   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   // Recalculates when there's a bar that hasn't been calculated
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars > 0)
      counted_bars--;
   limit = Bars - counted_bars;

   // Now we start with the actual array calculation
   // Daily calculation
   for (int a = 0; a < limit;a++)
     {
      MaBufferDaily[a] = iMA(NULL,Higher_timeframe_minutes,Periods2,0,Method,PRICE_CLOSE,a);
     }

   // When using old MQL without strict, you can't use int i everywhere but have to change
   for (int b = 0; b < limit; b++)
     {
      SmoothMAbufferDaily[b] = iMAOnArray(MaBufferDaily,0,Periodo_smoothing,0,Smoothing_method,b);
     }

   for (a = 0; a < limit; a++)
     {
      if(SmoothMAbufferDaily[a] < SmoothMAbufferDaily[a+1])
        {
         ColorDownBufferDaily[a] = SmoothMAbufferDaily[a];
         ColorUpBUfferDaily[a] = EMPTY_VALUE;
        }
      else
        {
         ColorUpBUfferDaily[a] = SmoothMAbufferDaily[a];
         ColorDownBufferDaily[a] = EMPTY_VALUE;
        }
     }

   // Functions for drawing short and medium term average
   for (int i = 0; i < limit;i++)
     {
      MaBuffer[i] = iMA(NULL,0,Periods,0,Method,PRICE_CLOSE,i);
     }

   // When using old MQL without strict, you can't use int i everywhere but have to change
   for (int y = 0; y < limit; y++)
     {
      SmoothMAbuffer[y] = iMAOnArray(MaBuffer,0,Periodo_smoothing,0,Smoothing_method,y);
     }

   // Reusing i, but now int is not needed because I declared it in a previous for
   for (i = 0; i < limit; i++)
     {
      if(SmoothMAbuffer[i] < SmoothMAbuffer[i+1])
        {
         ColorDownBuffer[i] = SmoothMAbuffer[i];
         ColorUpBUffer[i] = EMPTY_VALUE;
        }
      else
        {
         ColorUpBUffer[i] = SmoothMAbuffer[i];
         ColorDownBuffer[i] = EMPTY_VALUE;
        }
     }

   // Start of long moving average
   for (int z = 0; z < limit;z++)
     {
      MaBuffer2[z] = iMA(NULL,0,Periods2,0,Method,PRICE_CLOSE,z);
     }

   // When using old MQL without strict, you can't use int i everywhere but have to change
   for (int k = 0; k < limit; k++)
     {
      SmoothMAbuffer2[k] = iMAOnArray(MaBuffer2,0,Periodo_smoothing,0,Smoothing_method,k);
     }

   // Reusing i, but now int is not needed because I declared it in a previous for
   for (z = 0; z < limit; z++)
     {
      if(SmoothMAbuffer2[z] < SmoothMAbuffer2[z+1])
        {
         ColorDownBuffer2[z] = SmoothMAbuffer2[z];
         ColorUpBUffer2[z] = EMPTY_VALUE;
        }
      else
        {
         ColorUpBUffer2[z] = SmoothMAbuffer2[z];
         ColorDownBuffer2[z] = EMPTY_VALUE;
        }
     }

   // START OF GRAPHIC FUNCTIONS + SEND OPERATIONAL SIGNALS
   if (ColorDownBuffer[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Short term situation",OBJPROP_TEXT,0) != "It's a possible BULLISH setup SHORT TERM")
        {
         ObjectSetText("Short term situation","It's a possible BULLISH setup SHORT TERM" ,Charachter,"Arial",colore_bullish);
        }
      ObjectCreate("Short term situation",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Short term situation","It's a possible BULLISH setup SHORT TERM" ,Charachter,"Arial",colore_bullish);
      ObjectSet("Short term situation",OBJPROP_XDISTANCE,10);
      ObjectSet("Short term situation",OBJPROP_YDISTANCE, 80);
      ObjectSet("Short term situation",OBJPROP_CORNER,Corner);
     }

   if (ColorUpBUffer[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Short term situation",OBJPROP_TEXT,0) != "It's a possible BEARISH setup SHORT TERM")
        {
         ObjectSetText("Short term situation","It's a possible BEARISH setup SHORT TERM" ,Charachter,"Arial",colore_bearish);
        }
      ObjectCreate("Short term situation",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Short term situation","It's a possible BEARISH setup SHORT TERM" ,Charachter,"Arial",colore_bearish);
      ObjectSet("Short term situation",OBJPROP_XDISTANCE,10);
      ObjectSet("Short term situation",OBJPROP_YDISTANCE, 80);
      ObjectSet("Short term situation",OBJPROP_CORNER,Corner);
     }

   if (ColorDownBuffer2[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Long term situation",OBJPROP_TEXT,0) != "It's a possible BULLISH setup LONG TERM")
        {
         ObjectSetText("Long term situation","It's a possible BULLISH setup LONG TERM" ,Charachter,"Arial",colore_bullish);
        }
      ObjectCreate("Long term situation",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Long term situation","It's a possible BULLISH setup LONG TERM" ,Charachter,"Arial",colore_bullish);
      ObjectSet("Long term situation",OBJPROP_XDISTANCE,10);
      ObjectSet("Long term situation",OBJPROP_YDISTANCE, 100);
      ObjectSet("Long term situation",OBJPROP_CORNER,Corner);
     }

   if (ColorUpBUffer2[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Long term situation",OBJPROP_TEXT,0) != "It's a possible BEARISH setup LONG TERM")
        {
         ObjectSetText("Long term situation","It's a possible BEARISH setup LONG TERM" ,Charachter,"Arial",colore_bearish);
        }
      ObjectCreate("Long term situation",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Long term situation","It's a possible BEARISH setup LONG TERM" ,Charachter,"Arial",colore_bearish);
      ObjectSet("Long term situation",OBJPROP_XDISTANCE,10);
      ObjectSet("Long term situation",OBJPROP_YDISTANCE, 100);
      ObjectSet("Long term situation",OBJPROP_CORNER,Corner);
     }

   //---------------------------------
   //---------- OVERALL SITUATION -----------------------
   //---------------------------------
   if (ColorDownBuffer[0] == EMPTY_VALUE && ColorDownBuffer2[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"OVERALL SITUATION",OBJPROP_TEXT,0) != "Possible STRONG BULLISH setup")
        {
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) == "Alert status: ENABLED")
           {
            Alert("");
            Alert("Possible accurate BULLISH setup on " + Symbol());
            Alert("Indicator ''" + __FILE__ + "'' says: ");
           }
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) != "Alert status: NOT ALLOWED")
            Create_review();
         ObjectSetText("OVERALL SITUATION","It's a possible STRONG BULLISH setup" ,Charachter2,"Arial",colore_bullish);
        }
      ObjectCreate("OVERALL SITUATION",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("OVERALL SITUATION","Possible STRONG BULLISH setup" ,Charachter2,"Arial",colore_bullish);
      ObjectSet("OVERALL SITUATION",OBJPROP_XDISTANCE,10);
      ObjectSet("OVERALL SITUATION",OBJPROP_YDISTANCE, 120);
      ObjectSet("OVERALL SITUATION",OBJPROP_CORNER,Corner);
     }

   if (ColorUpBUffer[0] == EMPTY_VALUE && ColorUpBUffer2[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"OVERALL SITUATION",OBJPROP_TEXT,0) != "Possible STRONG BEARISH setup")
        {
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) == "Alert status: ENABLED")
           {
            Alert("");
            Alert("Possible accurate BEARISH setup on " + Symbol());
            Alert("Indicator ''" + __FILE__ + "'' says: ");
           }
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) != "Alert status: NOT ALLOWED")
            Create_review();
         ObjectSetText("OVERALL SITUATION","Possible STRONG BEARISH setup" ,Charachter2,"Arial",colore_bearish);
        }
      ObjectCreate("OVERALL SITUATION",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("OVERALL SITUATION","Possible STRONG BEARISH setup" ,Charachter2,"Arial",colore_bearish);
      ObjectSet("OVERALL SITUATION",OBJPROP_XDISTANCE,10);
      ObjectSet("OVERALL SITUATION",OBJPROP_YDISTANCE, 120);
      ObjectSet("OVERALL SITUATION",OBJPROP_CORNER,Corner);
     }

   if (ColorDownBuffer[0] == EMPTY_VALUE && ColorUpBUffer2[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"OVERALL SITUATION",OBJPROP_TEXT,0) != "Indecision, type 1")
        {
         ObjectSetText("OVERALL SITUATION","Indecision, type 1" ,Charachter2,"Arial",colore_uncertain);
        }
      ObjectCreate("OVERALL SITUATION",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("OVERALL SITUATION","Indecision, type 1" ,Charachter2,"Arial",colore_uncertain);
      ObjectSet("OVERALL SITUATION",OBJPROP_XDISTANCE,10);
      ObjectSet("OVERALL SITUATION",OBJPROP_YDISTANCE, 120);
      ObjectSet("OVERALL SITUATION",OBJPROP_CORNER,Corner);
     }

   if (ColorDownBuffer2[0] == EMPTY_VALUE && ColorUpBUffer[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"OVERALL SITUATION",OBJPROP_TEXT,0) != "Indecision, type 2")
        {
         ObjectSetText("OVERALL SITUATION","Indecision, type 2" ,Charachter2,"Arial",colore_uncertain);
        }
      ObjectCreate("OVERALL SITUATION",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("OVERALL SITUATION","Indecision, type 2" ,Charachter2,"Arial",colore_uncertain);
      ObjectSet("OVERALL SITUATION",OBJPROP_XDISTANCE,10);
      ObjectSet("OVERALL SITUATION",OBJPROP_YDISTANCE, 120);
      ObjectSet("OVERALL SITUATION",OBJPROP_CORNER,Corner);
     }

   if (ColorDownBufferDaily[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Bias",OBJPROP_TEXT,0) != "Bias HIGHER TF: Bullish")
        {
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) == "Alert status: ENABLED")
           {
            Alert("");
            Alert("Uptrend on " + Symbol());
            Alert("Attention! ''" + __FILE__ + "'' says: ");
           }
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) != "Alert status: NOT ALLOWED")
            Create_review();
         ObjectSetText("Bias","Bias HIGHER TF: Bullish" ,Charachter2,"Arial",colore_bullish);
        }
      ObjectCreate("Bias",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Bias","Bias HIGHER TF: Bullish" ,Charachter2,"Arial",colore_bullish);
      ObjectSet("Bias",OBJPROP_XDISTANCE,10);
      ObjectSet("Bias",OBJPROP_YDISTANCE, 200);
      ObjectSet("Bias",OBJPROP_CORNER,Corner);
     }

   if (ColorUpBUfferDaily[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Bias",OBJPROP_TEXT,0) != "Bias HIGHER TF: Bearish")
        {
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) == "Alert status: ENABLED")
           {
            Alert("");
            Alert("Possible bias bearish on " + Symbol());
            Alert("Attention! ''" + __FILE__ + "'' says: ");
           }
         if(ObjectGetString(0,"Status",OBJPROP_TEXT,0) != "Alert status: NOT ALLOWED")
            Create_review();
         ObjectSetText("Bias","Bias HIGHER TF: Bearish" ,Charachter2,"Arial",colore_bearish);
        }
      ObjectCreate("Bias",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Bias","Bias HIGHER TF: Bearish" ,Charachter2,"Arial",colore_bearish);
      ObjectSet("Bias",OBJPROP_XDISTANCE,10);
      ObjectSet("Bias",OBJPROP_YDISTANCE, 200);
      ObjectSet("Bias",OBJPROP_CORNER,Corner);
     }

   if (ColorUpBUfferDaily[0] == EMPTY_VALUE && ColorDownBufferDaily[0] == EMPTY_VALUE)
     {
      if(ObjectGetString(0,"Bias",OBJPROP_TEXT,0) != "Timeframe inadequate to determine the bias")
        {
         Alert("");
         Alert("Timeframe inadequate to determine the bias on " + Symbol());
         Alert("Attention! ''" + __FILE__ + "'' says: ");
         ObjectSetText("Bias","Timeframe inadequate to determine the bias" ,Charachter2,"Arial",colore_bearish);
        }
      ObjectCreate("Bias",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("Bias","Timeframe inadequate to determine the bias" ,Charachter2,"Arial",colore_uncertain);
      ObjectSet("Bias",OBJPROP_XDISTANCE,10);
      ObjectSet("Bias",OBJPROP_YDISTANCE, 200);
      ObjectSet("Bias",OBJPROP_CORNER,Corner);
     }

   return(0);
  }

void Create_review()
  {
   if (Review_button == false)
     {
      ObjectDelete("OVERALL SITUATION999");
      ObjectDelete("OVERALL SITUATION1");
      ObjectDelete("OVERALL SITUATION2");
      ObjectDelete("OVERALL SITUATION3");
      ObjectDelete("BORDER");
     }
   else
     {
      ObjectCreate(0,"BORDER",OBJ_BUTTON,0,0,0);
      ObjectSetText("BORDER","",16,"Arial",clrRed);
      ObjectSetInteger(0,"BORDER",OBJPROP_XSIZE,300);
      ObjectSetInteger(0,"BORDER",OBJPROP_YSIZE, 80);
      ObjectSetInteger(0,"BORDER",OBJPROP_XDISTANCE,300);
      ObjectSetInteger(0,"BORDER",OBJPROP_YDISTANCE, 45);
      ObjectSetInteger(0,"BORDER",OBJPROP_CORNER,1);
      ObjectSetInteger(0,"BORDER",OBJPROP_COLOR,indicator_color1);
      ObjectSetInteger(0,"BORDER",OBJPROP_BGCOLOR,clrBlack/*indicator_color2*/);

      ObjectCreate("OVERALL SITUATION1",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("OVERALL SITUATION1","Do you like the indicator?" ,16,"Arial",clrWhite);
      ObjectSet("OVERALL SITUATION1",OBJPROP_XDISTANCE,10);
      ObjectSet("OVERALL SITUATION1",OBJPROP_YDISTANCE, 50);
      ObjectSet("OVERALL SITUATION1",OBJPROP_CORNER,1);

      ObjectCreate("OVERALL SITUATION2",OBJ_LABEL,0,0,0,0,0);
      ObjectSetText("OVERALL SITUATION2","Please, click the button below!" ,16,"Arial",clrWhite);
      ObjectSet("OVERALL SITUATION2",OBJPROP_XDISTANCE,10);
      ObjectSet("OVERALL SITUATION2",OBJPROP_YDISTANCE, 70);
      ObjectSet("OVERALL SITUATION2",OBJPROP_CORNER,1);

      ObjectCreate(0,"OVERALL SITUATION999",OBJ_BUTTON,0,0,0);
      ObjectSetText("OVERALL SITUATION999","Leave a review!",16,"Arial",clrRed);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_YSIZE, 20);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_XDISTANCE,100+170);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_YDISTANCE, 95);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_CORNER,1);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,"OVERALL SITUATION999",OBJPROP_BGCOLOR,clrBlue);

      ObjectCreate(0,"OVERALL SITUATION3",OBJ_BUTTON,0,0,0);
      ObjectSetText("OVERALL SITUATION3","No, thanks",16,"Arial",clrRed);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_XSIZE,120);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_YSIZE, 20);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_XDISTANCE,100+30);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_YDISTANCE, 95);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_CORNER,1);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_BGCOLOR,clrRed/*indicator_color2*/);
     }
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
//---
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == "button")
        {
         ObjectSetText("Status","Alert status: ENABLED",16,"Arial",colore_uncertain);
         ObjectSetText("Text","To disactivate alerts, click the button below",16,"Arial",clrWhite);
         ObjectDelete(0,"button");

         ObjectCreate(0,"button1",OBJ_BUTTON,0,0,0);
         ObjectSetText("button1","Disable Alerts",16,"Arial",clrRed);
         ObjectSetInteger(0,"button1",OBJPROP_XSIZE,120);
         ObjectSetInteger(0,"button1",OBJPROP_YSIZE, 30);
         ObjectSetInteger(0,"button1",OBJPROP_XDISTANCE,120);
         ObjectSetInteger(0,"button1",OBJPROP_YDISTANCE, 360);
         ObjectSetInteger(0,"button1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"button1",OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(0,"button1",OBJPROP_BGCOLOR,clrRed/*indicator_color2*/);
        }

      if(sparam == "button1")
        {
         ObjectSetText("Status","Alert status: DISABLED",16,"Arial",colore_uncertain);
         ObjectSetText("Text","To activate alerts, click the button below",16,"Arial",clrWhite);
         ObjectDelete(0,"button1");

         ObjectCreate(0,"button",OBJ_BUTTON,0,0,0);
         ObjectSetText("button","Enable Alerts",16,"Arial",clrRed);
         ObjectSetInteger(0,"button",OBJPROP_XSIZE,120);
         ObjectSetInteger(0,"button",OBJPROP_YSIZE, 30);
         ObjectSetInteger(0,"button",OBJPROP_XDISTANCE,120);
         ObjectSetInteger(0,"button",OBJPROP_YDISTANCE, 360);
         ObjectSetInteger(0,"button",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"button",OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(0,"button",OBJPROP_BGCOLOR,clrBlue/*indicator_color2*/);
        }
     }

   if(sparam == "OVERALL SITUATION999")
     {
      Alert("");
      Alert("Thank you for your support!");
      Alert("");
      Alert("Please, copy the link and paste it on your browser:");
      Alert("https://www.mql5.com/it/market/product/112324?source=Site+Profile+Seller#");

      ObjectDelete(0,"OVERALL SITUATION999");
      ObjectDelete(0,"OVERALL SITUATION1");
      ObjectDelete(0,"OVERALL SITUATION2");

      if(Corner == Left)
        {
         ObjectCreate(0,"BORDER",OBJ_BUTTON,0,0,0);
         ObjectSetText("BORDER","",16,"Arial",clrRed);
         ObjectSetInteger(0,"BORDER",OBJPROP_XSIZE,300);
         ObjectSetInteger(0,"BORDER",OBJPROP_YSIZE, 95);
         ObjectSetInteger(0,"BORDER",OBJPROP_XDISTANCE,300);
         ObjectSetInteger(0,"BORDER",OBJPROP_YDISTANCE, 45);
         ObjectSetInteger(0,"BORDER",OBJPROP_CORNER,1);
         ObjectSetInteger(0,"BORDER",OBJPROP_COLOR,indicator_color1);
         ObjectSetInteger(0,"BORDER",OBJPROP_BGCOLOR,clrBlack/*indicator_color2*/);

         ObjectCreate("OVERALL SITUATION9",OBJ_LABEL,0,0,0,0,0);
         ObjectSetText("OVERALL SITUATION9","To disactivate the ''review'' button, set the final" ,10,"Arial",clrWhite);
         ObjectSet("OVERALL SITUATION9",OBJPROP_XDISTANCE,10);
         ObjectSet("OVERALL SITUATION9",OBJPROP_YDISTANCE, 50);
         ObjectSet("OVERALL SITUATION9",OBJPROP_CORNER,1);

         ObjectCreate("OVERALL SITUATION8",OBJ_LABEL,0,0,0,0,0);
         ObjectSetText("OVERALL SITUATION8","parameter in the indicator ''inputs'' as ''false''." ,10,"Arial",clrWhite);
         ObjectSet("OVERALL SITUATION8",OBJPROP_XDISTANCE,10);
         ObjectSet("OVERALL SITUATION8",OBJPROP_YDISTANCE, 70);
         ObjectSet("OVERALL SITUATION8",OBJPROP_CORNER,1);

         ObjectCreate("SITUATION C",OBJ_LABEL,0,0,0,0,0);
         ObjectSetText("SITUATION C","The parameter name is: ''Review_button''" ,10,"Arial",clrWhite);
         ObjectSet("SITUATION C",OBJPROP_XDISTANCE,10);
         ObjectSet("SITUATION C",OBJPROP_YDISTANCE, 90);
         ObjectSet("SITUATION C",OBJPROP_CORNER,1);

         ObjectSetText("OVERALL SITUATION3","OK" ,16,"Arial",clrWhite);
         ObjectSet("OVERALL SITUATION3",OBJPROP_XDISTANCE,200);
         ObjectSet("OVERALL SITUATION3",OBJPROP_YDISTANCE, 110);
         ObjectSet("OVERALL SITUATION3",OBJPROP_CORNER,1);
         ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_BGCOLOR,clrGreen);
        }
      else
        {
         ObjectCreate(0,"BORDER",OBJ_BUTTON,0,0,0);
         ObjectSetText("BORDER","",16,"Arial",clrRed);
         ObjectSetInteger(0,"BORDER",OBJPROP_XSIZE,300);
         ObjectSetInteger(0,"BORDER",OBJPROP_YSIZE, 95);
         ObjectSetInteger(0,"BORDER",OBJPROP_XDISTANCE,0);
         ObjectSetInteger(0,"BORDER",OBJPROP_YDISTANCE, 65);
         ObjectSetInteger(0,"BORDER",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"BORDER",OBJPROP_COLOR,indicator_color1);
         ObjectSetInteger(0,"BORDER",OBJPROP_BGCOLOR,clrBlack/*indicator_color2*/);

         ObjectCreate("OVERALL SITUATION9",OBJ_LABEL,0,0,0,0,0);
         ObjectSetText("OVERALL SITUATION9","To disactivate the ''review'' button, set the final" ,10,"Arial",clrWhite);
         ObjectSet("OVERALL SITUATION9",OBJPROP_XDISTANCE,10);
         ObjectSet("OVERALL SITUATION9",OBJPROP_YDISTANCE, 70);
         ObjectSet("OVERALL SITUATION9",OBJPROP_CORNER,0);

         ObjectCreate("OVERALL SITUATION8",OBJ_LABEL,0,0,0,0,0);
         ObjectSetText("OVERALL SITUATION8","parameter in the indicator ''inputs'' as ''false''." ,10,"Arial",clrWhite);
         ObjectSet("OVERALL SITUATION8",OBJPROP_XDISTANCE,10);
         ObjectSet("OVERALL SITUATION8",OBJPROP_YDISTANCE, 90);
         ObjectSet("OVERALL SITUATION8",OBJPROP_CORNER,0);

         ObjectCreate("SITUATION C",OBJ_LABEL,0,0,0,0,0);
         ObjectSetText("SITUATION C","The parameter name is: ''Visualize Review Button''" ,10,"Arial",clrWhite);
         ObjectSet("SITUATION C",OBJPROP_XDISTANCE,10);
         ObjectSet("SITUATION C",OBJPROP_YDISTANCE, 110);
         ObjectSet("SITUATION C",OBJPROP_CORNER,0);

         ObjectSetText("OVERALL SITUATION3","OK" ,16,"Arial",clrWhite);
         ObjectSet("OVERALL SITUATION3",OBJPROP_XDISTANCE,75);
         ObjectSet("OVERALL SITUATION3",OBJPROP_YDISTANCE, 130);
         ObjectSet("OVERALL SITUATION3",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(0,"OVERALL SITUATION3",OBJPROP_BGCOLOR,clrGreen);
        }
     }

   if (sparam == "OVERALL SITUATION3")
     {
      ObjectDelete("OVERALL SITUATION999");
      ObjectDelete("OVERALL SITUATION1");
      ObjectDelete("OVERALL SITUATION2");
      ObjectDelete("OVERALL SITUATION3");
      ObjectDelete("OVERALL SITUATION9");
      ObjectDelete("OVERALL SITUATION8");
      ObjectDelete("SITUATION C");
      ObjectDelete("BORDER");
     }
  }
