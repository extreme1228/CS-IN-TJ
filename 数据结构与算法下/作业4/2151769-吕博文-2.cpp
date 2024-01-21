class Solution {
public:
    int cnt = 0;
    int len;
    int aim;
    vector<int>a;
    void dfs(int pos,int num)
    {
        if(pos == len){
            if(num == aim)cnt++;
            return;
        }
        for(int i=1;i<=2;i++){
            if(i == 1){
                dfs(pos + 1,num + a[pos]);
            }
            else{
                dfs(pos + 1,num - a[pos]);
            }
        }
    }
    int findTargetSumWays(vector<int>& nums, int target) {
        len = nums.size();
        a = nums;
        aim = target;
        dfs(0,0);
        return cnt;
    }
};