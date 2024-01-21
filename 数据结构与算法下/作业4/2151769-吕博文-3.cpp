class Solution {
    private:
    vector<bitset<9>> rows;
    vector<bitset<9>> cols;
    vector<vector<bitset<9>>> cell;
public:
    bitset<9>get_status(int row,int col)
    {
        return ~(rows[row] | cols[col] | cell[row/3][col/3]);
        //返回一个9位的二进制数，1的位置表示该位置可以填
    }
    vector<int> get_next(vector<vector<char>>&board)
    {
        vector<int>ret;
        int min_cnt = 10;
        for(int i = 0;i<9;i++)
            for(int j = 0;j<9;j++){
                if(board[i][j] != '.')continue;
                bitset<9>status = get_status(i,j);
                if(status.count()>=min_cnt)continue;
                min_cnt = status.count();
                ret = {i,j};
            }
        return ret;
    }
    void fill(int row,int col,int pos,bool flag)
    {
        rows[row][pos] = cols[col][pos] = cell[row/3][col/3][pos] = flag;
    }
    bool dfs(vector<vector<char>>&board,int cnt)
    {
        if(cnt == 0)return true;
        //我们每次都选择能够填的数字的个数最少的格子填写，这样可以减少回溯的次数
        auto next_pos = get_next(board);
        bitset<9>status = get_status(next_pos[0],next_pos[1]);
        for(int i = 0;i<status.size();i++){
            if(!status.test(i))continue;//0则返回，表示该数字不可填
            board[next_pos[0]][next_pos[1]] = i+'1';
            fill(next_pos[0],next_pos[1],i,true);
            if(dfs(board,cnt - 1))return true;
            board[next_pos[0]][next_pos[1]] = '.';
            fill(next_pos[0],next_pos[1],i,false);
        }
        return false;
    }
    void solveSudoku(vector<vector<char>>& board) {
        //我们用一个9位长的二进制数分别表示每行，每列，每个九宫格的填充状态。
        rows = vector<bitset<9> >(9,bitset<9>());
        cols = vector<bitset<9> >(9,bitset<9>());
        cell = vector<vector<bitset<9> > >(3,vector<bitset<9>>(3,bitset<9>()));
        int cnt = 0;//记录没有被填充过的位置
        const int row_num = 9,col_num = 9;
        for(int i=0;i<row_num;i++)
            for(int j=0;j<col_num;j++){
                if(board[i][j]=='.'){
                    cnt++;
                    continue;
                }
                int tmp_val = board[i][j] - '1';
                rows[i] |= (1<<tmp_val);
                cols[j] |= (1<<tmp_val);
                cell[i/3][j/3] |= (1<<tmp_val);
            }
        dfs(board,cnt);
    }
};