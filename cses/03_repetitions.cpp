#include <bits/stdc++.h>

using namespace std;

int main() {
  char cur, last;
  int run, best;
  run = best = last = 0;

  while (cin >> cur) {
    if (cur == last) {
      run += 1;
    } else { 
      best = max(best, run);
      run = 1;
      last = cur;
    }
  }
  best = max(best, run);
  cout << best;
}