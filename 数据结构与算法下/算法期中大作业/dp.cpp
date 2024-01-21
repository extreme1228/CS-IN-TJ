#include<bits/stdc++.h>
using namespace std;


int minEditDistance(string s1, string s2,vector<vector<int>>M) {
    int m = s1.size(), n = s2.size();
    vector<vector<int>> dp(m+1, vector<int>(n+1, 0));

    // 初始化第一行和第一列
    for (int i = 1; i <= m; i++) {
        dp[i][0]=dp[i-1][0]+M[i][0];
    }
    for (int j = 1; j <= n; j++) {
        dp[0][j] = dp[0][j-1]+M[0][j];
    }

    // 计算dp数组
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            int cost = (s1[i-1] == s2[j-1]) ? 0 : M[i][j];
            dp[i][j] = min(dp[i-1][j], min(dp[i][j-1] , dp[i-1][j-1]))+M[i][j];
        }
    }

    return dp[m][n];
}

int main()
{
    string s1,s2;
    cin>>s1>>s2;
    int len1=s1.length();
    int len2=s2.length();
    vector<vector<int>>M(len1+1,vector<int>(len2+1));
    for(int i=0;i<=len1;i++)
        for(int j=0;j<=len2;j++)
            cin>>M[i][j];
    cout<<minEditDistance(s1,s2,M);
    return 0;
}