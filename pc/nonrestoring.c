       /****************************************************/
       /*           NONRESTORING DIVISION                  */
       /*   Source code written by: A. Yavuz Oruç          */
       /*            E-mail: yavuz@eng.umd.edu             */               
       /*          Last revised:  October 1998             */
       /*  Input:  32-bit dividend, and 16-bit divisor     */ 
       /*  Output: 16-bit quotient, and 16-bit remainder   */     
       /*                                                  */
       /****************************************************/

// AYO: This program computes a 16-bit  remainder and 16-bit quotient (p,q) upon receiving
// a 32-bit dividend  (p,q), and a 16-bit divisor n, both expressed in 2's complement notation.
// It uses nonrestoring division with positive operands. Negative operands are handled
// by first converting them to unsigned numbers. Both operands are entered in hexadecimal.

#include <stdio.h>

void print_nbits(int n, int i)
{
//printf("Zahl %i:", n);
     for(i = i - 1; i >= 0; i--)
     {
          printf("%c", ((n >> i) & 1)? '1': '0');
     }
}

int main(void)
{

     int p,q,i,n;
 char sp,sn,sd,sq,F = 0;
//  while(1)
  {
  //AYO: Here read in the dividend and divisor in hex. dd = qxn + r
  printf("\nEnter upper half of dividend: ");
//p = 0;
  scanf("%04X", &p);
  printf("\nEnter lower half of dividend: ");
//q = 2;
  scanf("%04X", &q);
  printf("\nEnter divisor: ");
//n = 1;
  scanf("%04X", &n);
  printf("\n      Dividend......... ................ Divisor.........\n      ");
  print_nbits(p, 17);
  printf(" ");
  print_nbits(q, 16);
  printf(" ");
  print_nbits(n, 16);
  printf("\n\n");

     sn = ((n >> 15) & 1);
     sq = ((q >> 15) & 1);
     
     if(sq)
     {
          printf("Dividend is negative!\n");
          q = -q & 0xFFFF;
     }
     if(sn)
     {
          printf("Divisor is negative!\n");
          n = -n & 0xFFFF;
     }
     if(sn | sq)
     {
  printf("\nnew:  Dividend......... ................ Divisor.........\n      ");
  print_nbits(p, 17);
  printf(" ");
  print_nbits(q, 16);
  printf(" ");
  print_nbits(n, 16);
  printf("\n\n");
     
     }

 //AYO: Extract the signs of divisor and dividend.
//  sn = (n & 0x8000) >> 15;  sp = sd = (p & 0x8000) >> 15;
 //AYO: Negate the dividend if it is negative.
//  if(sp == 1) {p = ~p + (q == 0); q = 1 + ~q; sp = 0;}
 //AYO: Negate the divisor if it is negative.
//  if(sn == 1) {n = -n;}

 //AYO: Begin the actual division.
 for(i = 1; i <= 16; i++)
  {
     printf("Step %i:\n", i);

     printf("Shift:");
     p = ((p << 1) | ((q >> 15) & 1));
     q = q << 1;
     print_nbits(p, 17);
     printf(" ");
     print_nbits(q, 16);
     printf("\n");
     
     switch((p >> 16) & 1)
     {
          case 1:
               printf("Add:  ");
               p = p + n;
               break;
          case 0:
               printf("Sub:  ");
               p = p - n;
               break;
     }
     print_nbits(p, 17);
     printf(" ");
     print_nbits(q, 16);
     printf("\n");
     
     printf("Set:  ");
     q = (q | ((~p >> 16) & 1));
     print_nbits(p, 17);
     printf(" ");
     print_nbits(q, 16);
     printf("\n");
     
     system("PAUSE");
}
     if((p >> 16) & 1)
          p = p + n;
     if(sn != sq)     
          q = -q & 0xFFFF;
    
/*     
   if (sp == 0)
    {//AYO: subtract n from 2 x dd.
     p =  ((p << 1) | ( (q >> 15) & 0x0001)) - n;
    }
   else
    {//AYO: add n to 2 x dd.
     p =  ((p << 1) |  ( (q >> 15) & 0x0001))  + n;
   }
      sp =  (p & 0x8000) >> 15; 
      q = ( q << 1) | ((~sp) & 0x0001);
   }
  */
   //AYO: Correct remainder
//    sq = (q & 0x8000) >> 15;
//    if ((!sq) && sp )  {p = p + n;}
   
   //AYO: Correct quotient
//   if (sd != sn) q = -q;
 
   //AYO: Overflow
//  if (n == 0 || sq) F = 1;

    printf("The quotient is: ");   print_nbits(q, 16); 
    printf("\nThe remainder is: ");  print_nbits(p, 16);
//    if (F) {printf("\n\nThe division is resulted in an overflow;");
//    printf("\nEither the quotient is too large or divisor is 0."); }
    printf("\n");
    system("PAUSE");
  }

}



