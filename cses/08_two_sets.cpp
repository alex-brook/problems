#include <bits/stdc++.h>

using namespace std;

int main() {
  int n;
  cin >> n;

  bool first_strategy = (n % 2 == 0) && (n / 2) % 2 == 0 && n >= 4;
  bool second_strategy = (n - 3) % 4 == 0;

  if (!(first_strategy || second_strategy)) {
    cout << "NO\n";
    exit(0);
  }

  vector<int> a;
  vector<int> b;
  vector<int>* first = &a;
  vector<int>* second = &b;

  cout << "YES\n";
  if (first_strategy) {
    int x = n;
    while(x >= 1) {
      first->push_back(x--);
      second->push_back(x--);
      vector<int>* temp = first;
      first = second;
      second = temp;
    }
  } else {
    int x = 1;
    while(x <= n) {
      first->push_back(x++);
      first->push_back(x++);
      second->push_back(x++);
      if (x > n) break;
      first->push_back(x++);
      if (x > n) break;
      vector<int>* temp = first;
      first = second;
      second = temp;
    }
  }

  cout << a.size() << "\n";
  for(int x: a) {
    cout << x << " ";
  }
  cout << "\n" << b.size() << "\n";
  for(int x: b) {
    cout << x << " ";
  }
}