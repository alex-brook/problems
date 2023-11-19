#include <bits/stdc++.h>

using namespace std;


int main() {
  int n;
  cin >> n;

  for (int i = 0; i < n; i++) {
    long long ty, tx;
    cin >> ty >> tx;

    long long power = max(tx, ty) * max(tx, ty);

    long long py, px;
    if (power % 2 == 0) {
      py = max(tx, ty);
      px = 1;
    } else {
      py = 1;
      px = max(tx, ty);
    }

    cout << power - abs(py - ty) - abs(px - tx) << "\n";
  }
}