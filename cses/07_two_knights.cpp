#include <bits/stdc++.h>

using namespace std;

int main() {
  long long n_ub;
  cin >> n_ub;

  for (long long n=1; n <= n_ub; n++) {
    long long possible = (n * n) * (n * n - 1) / 2;
    long long attacking = 2 * (2 * n * n - 6 * n + 4);

    cout << possible - attacking << " ";
  }
}