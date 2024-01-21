class Solution {
public:
    static bool cmp(vector<int>a,vector<int>b)
    {
        if(a[1]!=b[1])return a[1]<b[1];
        else return a[0]<b[0];
    }
    vector<vector<int>> reconstructQueue(vector<vector<int>>& people) {
        int n=people.size();
        sort(people.begin(),people.end(),cmp);
        vector<vector<int>>ans;
        for(auto x:people){
            if(ans.size()==0){
                ans.push_back(x);
            }
            else{
                int val=x[0];
                int num=x[1];
                int pos=0;
                int kase=0;
                while(pos<ans.size()){
                    if(ans[pos][0]>=val)kase++;
                    if(kase>num)break;
                    pos++;
                }
                ans.insert(ans.begin()+pos,x);
            }
        }
        return ans;
    }
};