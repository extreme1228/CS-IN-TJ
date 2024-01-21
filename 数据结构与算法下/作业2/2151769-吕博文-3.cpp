class Solution {
public:
    const int maxn=1e4+10;
    const int INF=1e9+7;
    int coinChange(vector<int>& coins, int amount) {
        sort(coins.begin(),coins.end());
        vector<int>dp(maxn,INF);//dp[i]�Ǳ�ʾ���i����Ҫ������Ӳ�Ҹ���
        dp[0]=0;
        for(int i=0;i<coins.size();i++){
            for(int j=coins[i];j<=amount;j++){
                dp[j]=min(dp[j],1+dp[j-coins[i]]);
            }
        }
        if(dp[amount]==INF)return -1;
        else return dp[amount];
    }
};
