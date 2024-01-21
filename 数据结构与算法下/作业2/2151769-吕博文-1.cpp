class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        int n=nums.size();
        vector<long long>dp(n+1);//dp[i]表示以第i个元素结尾的连续子数组的最大和
        for(int i=1;i<=n;i++)dp[i]=nums[i-1];
        for(int i=2;i<=n;i++){
            dp[i]=max(1LL*nums[i-1],nums[i-1]+dp[i-1]);
        }
        long long ans=-1e18;
        for(int i=1;i<=n;i++)ans=max(ans,dp[i]);
        return ans;
    }
};
