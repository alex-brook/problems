#include <bits/stdc++.h>

using namespace std;

// 5 4 3 2 1 
// 0 + 1 + 2 + 3 + 4 = 10
int main() {
  long long last, sum;
  int n;
  sum = last = 0;
  cin >> n;
  for (int i = 0; i < n; i++) {
    long long x;
    cin >> x;
    if (x >= last) {
      last = max(last, x);
    } else {
      sum += last - x; // shortfall
    }
  }

  cout << sum;
}