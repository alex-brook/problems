#include <bits/stdc++.h>

using namespace std;

int main() {
  int n, x;
  cin >> n;
  set<int> seen;
  for (int i = 1; i < n; i++) {
    cin >> x;
    seen.insert(x);
  }

  for (x = 1; seen.find(x) != seen.end(); x++) { }
  cout << x;
}
