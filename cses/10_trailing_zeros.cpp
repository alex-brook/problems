#include <bits/stdc++.h>

using namespace std;

int main() {
  long long n;
  cin >> n;

  long long zeros = 0;
  long long z = 0;
  long long divisor = 5;
  do {
    z = n / divisor;
    zeros += z;
    divisor *= 5;
  } while (z > 0);

  cout << zeros << "\n";
}