class Solution {
public:
    struct NODE{
        long long x_left;
        long long x_right;
    };
    static bool cmp(NODE u,NODE v)
    {
        if(u.x_left!=v.x_left)return u.x_left<v.x_left;
        else return u.x_right>v.x_right;
    }
    int findMinArrowShots(vector<vector<int>>& points) {
        int n=points.size();
        vector<NODE>a(n);
        for(int i=0;i<n;i++)a[i].x_left=points[i][0],a[i].x_right=points[i][1];
        sort(a.begin(),a.end(),cmp);
        int ans=0;
        long long x=-1e18;
        for(int i=0;i<n;i++){
            if(x>=a[i].x_left){
                x=min(x,a[i].x_right);
                continue;
            }
            ans++;
            x=a[i].x_right;
        }
        return ans;
    }
};