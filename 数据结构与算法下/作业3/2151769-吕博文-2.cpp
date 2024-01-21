class Solution {
public:
    int candy(vector<int>& ratings) {
        int ans=0;
        int n=ratings.size();
        int pos=0;
        vector<int>a(n,1);
        while(pos<n){
            while(pos+1<n&&ratings[pos]==ratings[pos+1]){
                a[pos+1]=1;
                pos++;
            }
            if(pos==n-1)break;
            if(ratings[pos]<ratings[pos+1]){
                while(pos+1<n&&ratings[pos]<ratings[pos+1]){
                    a[pos+1]=a[pos]+1;
                    pos++;
                }
            }
            else{
                int tmp_pos=pos;
                int len=1;
                while(tmp_pos+1<n&&ratings[tmp_pos]>ratings[tmp_pos+1]){
                    len++;
                    tmp_pos++;
                }
                int tmp_val=max(a[pos],len);
                int tmp_p=pos;
                a[pos]=len;
                while(pos+1<n&&ratings[pos]>ratings[pos+1]){
                    a[pos+1]=a[pos]-1;
                    pos++;
                }
                a[tmp_p]=tmp_val;
            }
        }
        for(int i=0;i<a.size();i++)ans+=a[i];
        return ans;
    }
};