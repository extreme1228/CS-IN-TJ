class Solution {
public:
    vector<vector<int>> subsets(vector<int>& nums) {
        int len = nums.size();
        int x = 1<<(len);
        vector<vector<int>>res;
        for(int i=0;i<x;i++){
            vector<int>tmp_set;
            int tmp = i;
            for(int j=0;j<len;j++){
                if(tmp & (1<<j))tmp_set.push_back(nums[j]);
            }
            res.push_back(tmp_set);
        }
        return res;
    }
};