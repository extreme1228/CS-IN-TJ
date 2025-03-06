#include <bits/stdc++.h>
using namespace std;

int main()
{
    //n为楼层高度 n>=1    m为耐摔值，在0-n之间 
    int n = 15,m = 5;
    // cin>>n>>m;

    int op = 0,eggs = 0,last_egg_broken=0;//1表示最后一个碎了 0表示没碎
    int l = 0,r = n;
    while(l<r){
        //1
        op++;//摔一次

        //2
        int mid = (l+r)>>1;
        if(mid > m){
            //高度高于耐摔值
            eggs++;//碎了
            r=mid;
        }
        else{
            l = mid+1;
        }
        
        //3
        last_egg_broken = (mid > m);
    }
    // cout<<op<<" "<<eggs<<" "<<last_egg_broken<<endl;
    return 0;
}