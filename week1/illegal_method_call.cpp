#include <stdio.h>
using namespace std;

class Sample
{
public:
  void print()
  {
    printf("テスト");
  }
};

int main()
{
  Sample sample;
  sample.printf();
  return 0;
}
