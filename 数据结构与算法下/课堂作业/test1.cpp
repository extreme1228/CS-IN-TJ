#include<bits/stdc++.h>
using namespace std;


bool cmp(int x,int y)
{
    vector<int>num_x,num_y;
    while(x){
        num_x.push_back(x%10);
        x/=10;
    }
    reverse(num_x.begin(),num_x.end());
    while(y){
        num_y.push_back(y%10);
        y/=10;
    }
    reverse(num_y.begin(),num_y.end());
    int len=min(num_x.size(),num_y.size());
    for(int i=0;i<len;i++){
        if(num_x[i]>num_y[i])return true;
        else if(num_x[i]<num_y[i])return false;
        else continue;
    }
    if(num_x.size()>len)return false;
    return true;
}
int main()
{
    int n;
    cin>>n;
    vector<int>a(n+1);
    for(int i=1;i<=n;i++){
        cin>>a[i];
    }
    sort(a.begin()+1,a.end(),cmp);
    for(int i=1;i<=n;i++)cout<<a[i];
}