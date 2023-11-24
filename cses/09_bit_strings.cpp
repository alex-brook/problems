#include <bits/stdc++.h>

using namespace std;

int main() {
  int n;
  cin >> n;

  long long acc = 1;
  long long modulo = 1000000007;

  for (int i = 0; i < n; i++ ) {
    acc *= 2;
    acc %= modulo;
  }

  cout << acc << "\n";
}