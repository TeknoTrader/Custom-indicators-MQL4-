//+------------------------------------------------------------------+
//|                                                    Tekno RSI.mq4 |
//|                                  Chimenti Nicola (@tekno_trader) |
//|          https://instagram.com/tekno_trader?utm_medium=copy_link |
//+------------------------------------------------------------------+
#property copyright "Chimenti Nicola (@tekno_trader)"
#property link      "https://instagram.com/tekno_trader?utm_medium=copy_link"
#property version   "1.00"
#property strict
#property description "The indicator is based on RSI with the addition of two moving averages applied to the RSI itself."
#property description "It can be used to generate trading signals (overbought/oversold) in various ways, for example:"
#property description "1) Go long/short when a certain deviation occurs between the moving averages and the RSI value."
#property description "2) Use the crossover of the moving averages as trading signals."
#property description "3) Utilize during discrepancies between averages and RSI values."
#property description "\n"
#property description "Please, test the software thoroughly before risking real money and avoid risks."
#property description "Good luck!"

//#property icon          "\\Files\\Logo_tekno_trader.ico"

#property indicator_separate_window

#property indicator_minimum 0
#property indicator_maximum 100

#property indicator_level1 20
#property indicator_level2 80
#property indicator_level3 0
#property indicator_level4 100

#property indicator_levelcolor Orange
#property indicator_levelwidth 3

#property indicator_buffers 6
#property indicator_color1 White
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Yellow        // Fast MA
#property indicator_color6 Orange        // Slow MA

#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 3
#property indicator_width6 3

// ------------------------- User inputs (translated to English) -------------------------
input string  line_separator_top = "-------------------------------------------------";    // CHOOSE THE ALERT YOU WANT

input bool Deviation_alert = true;             // Do you want alert based on distance between moving average and RSI?
input int Deviation_level = 20;                // Deviation requested between RSI and moving average 
input bool Crossover_alert = true;             // Do you want alert on crossover of moving averages?

input string  line_separator_01 = "-------------------------------------------------";    // ------------------
input string  line_separator_02 = "-------------------------------------------------";    // IMPORTANT VALUES
input string  line_separator_03 = "-------------------------------------------------";    // ------------------

input int Oversold_value = 40;             // Oversold (low) threshold
input int Overbought_value = 60;            // Overbought (high) threshold

enum DisplayType { DT_Line = 0, DT_Histogram = 1 };
input DisplayType RSI_Display_Mode = DT_Histogram;  // What you want draw on the chart?

bool Histogram = true;
bool Line = false;

input int RSIPeriod = 14;                        // Period of RSI
int appliedprice = 0;                            // PRICE_CLOSE

input string  line_separator_04 = "-------------------------------------------------";    // About the moving averages periods...
input int ShortMAPeriod = 21;                              // Short term moving average period
input int LongMAPeriod = 200;                            // Long term moving average period

input string  line_separator_05 = "-------------------------------------------------";    // -------------------------
input string  line_separator_06 = "-------------------------------------------------";    //    GRAPHICAL CONTENT
input string  line_separator_07 = "-------------------------------------------------";    // -------------------------

enum Language { LANG_English, LANG_Italiano };
input Language language = LANG_English;

input int Text_line_spacing = 25;                             // Distance of text messages (vertical spacing)
input int Secondary_font_size = 15;            // Text font size for labels

enum CornerPosition { CORNER_Left = 0, CORNER_Right = 1 };
input CornerPosition corner = CORNER_Right;    

input string text_color = "White";                  // Color of text

// Buffers and arrays (renamed to English)
double RSIArrayUp[], RSIArrayDown[], RSIArrayNeutral[];
double MAArray[], MAArrayUp[], MAArrayDown[];
double MALongArray[], MALongArrayUp[], MALongArrayDown[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initial comments and alerts
   Comment("EA made by Tekno Trader ©", "\n"
           "VAT Code: 02674000464", "\n"
           "","\n"
           "Please, trade responsibly");
   
   Alert("");
   Alert("Indicator  '' " + __FILE__ + " ''  has been activated");
   Alert("Good trading " + AccountName());
   
   IndicatorBuffers(7);
   
   string short_name="RSI killer";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexStyle(0,DRAW_NONE);
   
   // Setup drawing style based on display mode
   if(RSI_Display_Mode == DT_Histogram)
   {
      SetIndexBuffer(1,RSIArrayUp);
      SetIndexLabel(1,"RSI uptrend");
      SetIndexStyle(1,DRAW_HISTOGRAM);
      
      SetIndexBuffer(2,RSIArrayDown);
      SetIndexLabel(2,"RSI downtrend");
      SetIndexStyle(2,DRAW_HISTOGRAM);
      
      SetIndexBuffer(3,RSIArrayNeutral);
      SetIndexLabel(3,"RSI neutral");
      SetIndexStyle(3,DRAW_HISTOGRAM);
   }
   else
   {
      SetIndexBuffer(1,RSIArrayUp);
      SetIndexLabel(1,"RSI uptrend");
      SetIndexStyle(1,DRAW_LINE);
      
      SetIndexBuffer(2,RSIArrayDown);
      SetIndexLabel(2,"RSI downtrend");
      SetIndexStyle(2,DRAW_LINE);
      
      SetIndexBuffer(3,RSIArrayNeutral);
      SetIndexLabel(3,"RSI neutral");
      SetIndexStyle(3,DRAW_LINE);
   }
   
   SetIndexBuffer(4,MAArray);
   SetIndexLabel(4,"Average " + IntegerToString(ShortMAPeriod) + " periods");
   SetIndexStyle(4,DRAW_LINE);
   
   SetIndexBuffer(5,MALongArray);
   SetIndexLabel(5,"Average " + IntegerToString(LongMAPeriod) + " periods");
   SetIndexStyle(5,DRAW_LINE);
  
//---
   return(INIT_SUCCEEDED);
  }
  
  
  
    int deinit()
  {
  Comment("");
  
  Alert("");
  
  Alert("Indicator  " + __FILE__ + "  deactivated");
  Alert("Have a nice day  " + AccountName() + "! ");
  
   ObjectsDeleteAll();
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   int limit;

int counted_bars = IndicatorCounted();

if(counted_bars > 0) 
counted_bars--;

limit = Bars - counted_bars;


for (int a = 0; a < limit; a++)
{
 double RSI = iRSI(NULL,0,RSIPeriod,appliedprice,a);
   if(RSI > Overbought_value)
 {
 RSIArrayUp[a] = RSI;
  RSIArrayDown[a] = EMPTY_VALUE;
  RSIArrayNeutral[a] = EMPTY_VALUE;
  
  }
  
  if (Oversold_value > RSI)
 {
  RSIArrayDown[a] = RSI;
  RSIArrayUp[a] = EMPTY_VALUE;
  RSIArrayNeutral[a] = EMPTY_VALUE;
  }
  
 
 
 if (RSI >= Oversold_value && Overbought_value >= RSI)
  {
  
    RSIArrayNeutral[a] = RSI;
  RSIArrayUp[a] = EMPTY_VALUE;
  RSIArrayDown[a] = EMPTY_VALUE;
  }
  
}


// MOVING AVERAGES

double Counter = 0;

for (int b = 0; b < limit; b++)
{
   

  
   MAArray[b] = RSISum(b,ShortMAPeriod);


}

for (int k = 0; k < limit; k++)
{
   

  
   MALongArray[k] = RSISum(k,LongMAPeriod);


}




  // --------------------------------
   
  // GRAPHICS AND ALERTS
  
     ObjectCreate("Deviation1",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Deviation1", "DEVIATION FROM AVERAGE RSI VALUES:", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Deviation1",OBJPROP_XDISTANCE,10);     
     ObjectSet("Deviation1",OBJPROP_YDISTANCE,50 + Text_line_spacing);
     ObjectSet("Deviation1",OBJPROP_CORNER,corner);

double LongDeviation = MALongArray[1] - iRSI(NULL,0,RSIPeriod,appliedprice,1);

double ShortDeviation = MAArray[1] - iRSI(NULL,0,RSIPeriod,appliedprice,1);

        ObjectCreate("DeviationLongLabel",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("DeviationLongLabel", "Last long term average " + Above_or_below(LongDeviation) + " the RSI for:   " + DoubleToString(LongDeviation,2), Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("DeviationLongLabel",OBJPROP_XDISTANCE,10);     
     ObjectSet("DeviationLongLabel",OBJPROP_YDISTANCE,50 + 2*Text_line_spacing);
     ObjectSet("DeviationLongLabel",OBJPROP_CORNER,corner);
     
             ObjectCreate("DeviationShortLabel",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("DeviationShortLabel", "Last short term average " + Above_or_below(ShortDeviation) + " the RSI for:  " + DoubleToString(ShortDeviation,2), Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("DeviationShortLabel",OBJPROP_XDISTANCE,10);     
     ObjectSet("DeviationShortLabel",OBJPROP_YDISTANCE,50 + 3*Text_line_spacing);
     ObjectSet("DeviationShortLabel",OBJPROP_CORNER,corner);



   if(MathAbs(LongDeviation) >= Deviation_level)
   {
   
      if(Deviation_alert == true && ObjectGetString(0,"Deviation_reached",OBJPROP_TEXT,0) == "Waiting confirmations on the " + IntegerToString(LongMAPeriod) + " periods average")
    {
     Alert("");
     Alert("Indicator  " + __FILE__ + "  says:");
     Alert("Possible signal on " + Symbol());
     
     ObjectDelete("Deviation_reached");
  }
   
     ObjectCreate("Deviation_reached",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Deviation_reached", "We have a confirmation on the " + IntegerToString(LongMAPeriod) + " periods average", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Deviation_reached",OBJPROP_XDISTANCE,10);     
     ObjectSet("Deviation_reached",OBJPROP_YDISTANCE,50 + 5*Text_line_spacing);
     ObjectSet("Deviation_reached",OBJPROP_CORNER,corner);
}

else

{
     ObjectCreate("Deviation_reached",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Deviation_reached", "Waiting confirmations on the " + IntegerToString(LongMAPeriod) + " periods average", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Deviation_reached",OBJPROP_XDISTANCE,10);     
     ObjectSet("Deviation_reached",OBJPROP_YDISTANCE,50 + 5*Text_line_spacing);
     ObjectSet("Deviation_reached",OBJPROP_CORNER,corner);

}


   if(MathAbs(ShortDeviation) >= Deviation_level)
   {
   if(Deviation_alert == true && ObjectGetString(0,"Deviation2_reached",OBJPROP_TEXT,0) != "We have a confirmation on the " + IntegerToString(ShortMAPeriod) + " periods average")
   {
     Alert("");
     Alert("Indicator  " + __FILE__ + "  says:");
     Alert("Possible signal on " + Symbol());
     
     ObjectDelete("Deviation2_reached");
  }
     ObjectCreate("Deviation2_reached",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Deviation2_reached", "We have a confirmation on the " + IntegerToString(ShortMAPeriod) + " periods average", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Deviation2_reached",OBJPROP_XDISTANCE,10);     
     ObjectSet("Deviation2_reached",OBJPROP_YDISTANCE,50 + 6*Text_line_spacing);
     ObjectSet("Deviation2_reached",OBJPROP_CORNER,corner);
}

else

{
     ObjectCreate("Deviation2_reached",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Deviation2_reached", "Waiting confirmations on the " + IntegerToString(ShortMAPeriod) + " periods average", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Deviation2_reached",OBJPROP_XDISTANCE,10);     
     ObjectSet("Deviation2_reached",OBJPROP_YDISTANCE,50 + 6*Text_line_spacing);
     ObjectSet("Deviation2_reached",OBJPROP_CORNER,corner);

}


if(Crossover_alert == true)
{

  if(ShortDeviation > LongDeviation)
  {
    if(ObjectGetString(0,"Crossover",OBJPROP_TEXT,0) == "Moving average " + IntegerToString(LongMAPeriod) + " periods is above the other moving average")
    {
         Alert("");
     Alert("Indicator  " + __FILE__ + "  says:");
     Alert("Average RSI crossover on " + Symbol());
     
     ObjectDelete("Crossover");
    
    }
     ObjectCreate("Crossover",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Crossover", "Moving average " + IntegerToString(ShortMAPeriod) + " periods is above the other moving average", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Crossover",OBJPROP_XDISTANCE,10);     
     ObjectSet("Crossover",OBJPROP_YDISTANCE,50 + 8*Text_line_spacing);
     ObjectSet("Crossover",OBJPROP_CORNER,corner);
     
     }
     
     else
     {
     
         if(ObjectGetString(0,"Crossover",OBJPROP_TEXT,0) == "Moving average " + IntegerToString(ShortMAPeriod) + " periods is above the other moving average")
    {
         Alert("");
     Alert("Indicator  " + __FILE__ + "  says:");
     Alert("Average RSI crossover on " + Symbol());
     
     ObjectDelete("Crossover");
    
    }
     
     
     ObjectCreate("Crossover",OBJ_LABEL,0,0,0,0,0);
     ObjectSetText("Crossover", "Moving average " + IntegerToString(LongMAPeriod) + " periods is above the other moving average", Secondary_font_size, "Arial",StringToColor("clr" + text_color));
     ObjectSet("Crossover",OBJPROP_XDISTANCE,10);     
     ObjectSet("Crossover",OBJPROP_YDISTANCE,50 + 8*Text_line_spacing);
     ObjectSet("Crossover",OBJPROP_CORNER,corner);

}
}

else
ObjectDelete(0,"Crossover");


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



double RSISum(int c, int periodi)
{

double A = 0;
double B = 0;

  for (int d = c; d < c + periodi; d++)
{
   
   A = A + iRSI(NULL,0,RSIPeriod,appliedprice,d);
  
  
  if (d == c + periodi - 1)
  {
  B = A/periodi;
  break;
  }
  
  else
  continue;
}
return B;
}


string Above_or_below(double value1)
{
  string A = "";

   if(value1 > 0)
   A = "is above";

else
A = "is below";

return A;
}

//+------------------------------------------------------------------+
// End of translated indicator
//+------------------------------------------------------------------+
