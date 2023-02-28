#include<math.h>
#define M_PI 3.1415926535897932384626433832795


int main(int argc, char argv[])
{
    int i;
    printf("\t;; a sinetable for all angles between 0 and 90 degrees,\n\t;; represented as 16 bit fixed point number.\n\n");
    
    for(i = 0; i <= 90; i++)
    {
//        printf("\t .word %i\t;; sin(%ideg)\n", (short)(256 * sin((M_PI / 180) * i)), i);
// bytes were swapped
        printf("\t .byte %i\n\t .byte %i\t;; sin(%ideg)\n", (unsigned char)(sin((M_PI / 180) * i)), (unsigned char)(256 * sin((M_PI / 180) * i)), i);
    }



    return 1;
}
