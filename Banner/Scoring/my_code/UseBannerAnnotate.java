public class UseBannerAnnotate
{
      public static void main(String[] args)
      {
         BannerAnnotate b1 = new BannerAnnotate();
         int [] b2 = b1.annotate();
         int n = b2.length;
         for(int i = 0; i < n; i++) 
         {
                  System.out.print(b2[i]+",");
                  if ( (i+1) % 3 == 0) 
                     System.out.println();
            }
      }
}
/*
0,17,5,
0,159,18,
0,54,38,
...
2299,616,2,
2299,965,2,
2299,857,2,
2299,733,22,
*/