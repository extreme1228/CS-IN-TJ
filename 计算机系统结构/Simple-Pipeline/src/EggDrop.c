#include <stdio.h>
#include <limits.h>

#define MAX_FLOORS 100
#define MAX_EGGS 10

int min(int a, int b) {
    return (a < b) ? a : b;
}

int eggDrop(int floors, int eggs) {
    int dp[MAX_FLOORS + 1][MAX_EGGS + 1];

    for (int i = 1; i <= floors; i++) {
        dp[i][1] = i;
        dp[i][0] = 0;
    }

    for (int j = 1; j <= eggs; j++) {
        dp[0][j] = 0;
    }

    for (int i = 2; i <= floors; i++) {
        for (int j = 2; j <= eggs; j++) {
            dp[i][j] = INT_MAX;
            for (int x = 1; x <= i; x++) {
                int res = 1 + max(dp[x - 1][j - 1], dp[i - x][j]);
                if (res < dp[i][j]) {
                    dp[i][j] = res;
                }
            }
        }
    }

    return dp[floors][eggs];
}

int main() {
    int floors = 10;
    int eggs = 2;

    int result = eggDrop(floors, eggs);

    printf("Minimum number of trials in the worst case: %d\n", result);

    return 0;
}
