class Solution {
public:
    vector<int>nums;
    vector<int>ans;
    int len;
    bool flag=false;
    bool dfs(int pos,int x)
    {
        if(pos==len)return true;
        if(flag){
            ans[pos]=9;
            dfs(pos+1,9);
            return true;
        }
        else{
            ans[pos]=nums[pos];
            if(pos>0&&ans[pos]<ans[pos-1])return false;
            bool ok=dfs(pos+1,ans[pos]);
            if(ok)return true;
            else{
                ans[pos]=nums[pos]-1;
                if(pos>0&&ans[pos]<ans[pos-1])return false;
                else {
                    flag=true;
                    dfs(pos+1,ans[pos]);
                }
            }
        }
        return true;
    }
    int monotoneIncreasingDigits(int n) {
        int tmp=n;
        while(tmp){
            nums.push_back(tmp%10);
            tmp/=10;
        }
        reverse(nums.begin(),nums.end());
        len=nums.size();
        ans.resize(len,0);
        dfs(0,0);
        int res=0;
        for(int i=0;i<ans.size();i++){
            res=10*res+ans[i];
        }
        return res;
    }
};