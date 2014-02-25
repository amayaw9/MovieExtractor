#include <iostream>
#include <string>
#include <sstream>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>



using namespace cv;
using namespace std;

class Descriptor {
private: 
  string id;
  string fname;
  Mat img;
  HOGDescriptor hog;
  vector<Rect> found;

public:
  Descriptor(void) {}
  Descriptor(const string &id) {
    this->id = id;
    string fname = id + ".jpg";
    img = imread(fname, 1);
    if(img.empty()) 
      exit(-1);
    hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
  }
  ~Descriptor(void) {}
  
  void descript(void) {    
    hog.detectMultiScale(img, found, 0.2, Size(8,8), Size(16,16), 1.05, 2);
    int i = 0;
    for(auto iter = found.begin(); iter != found.end(); iter++, i++) {
      Rect r = *iter;
      r.x += cvRound(r.width*0.1);
      r.width = cvRound(r.width*0.8);
      r.y += cvRound(r.height*0.07);
      r.height = cvRound(r.height*0.8);
      // 検出した人物をくり抜く
      Mat roi_img(img, r);
      ostringstream oss;
      oss.str("");
      oss << id << '-' << i << '.' << "jpg";
      cout << oss.str() << endl;
      imwrite(oss.str(), roi_img);
      cout << oss.str() << endl;
    }
  }
};

int main(int argc, char *argv[]) {
  if (argc != 2) {
    return -1;
  }
  Descriptor d = Descriptor(argv[1]);
  d.descript();
  return 0;
}
