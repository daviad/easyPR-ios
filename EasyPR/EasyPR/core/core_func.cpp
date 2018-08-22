#import <opencv2/opencv.hpp>

using namespace cv;

namespace easypr {

bool bFindLeftRightBound1(Mat &bound_threshold, int &posLeft, int &posRight) {

  float span = bound_threshold.rows * 0.2f;

  for (int i = 0; i < bound_threshold.cols - span - 1; i += 3) {
    int whiteCount = 0;
    for (int k = 0; k < bound_threshold.rows; k++) {
      for (int l = i; l < i + span; l++) {
        if (bound_threshold.data[k * bound_threshold.step[0] + l] == 255) {
          whiteCount++;
        }
      }
    }
    if (whiteCount * 1.0 / (span * bound_threshold.rows) > 0.15) {
      posLeft = i;
      break;
    }
  }
  span = bound_threshold.rows * 0.2f;


  for (int i = bound_threshold.cols - 1; i > span; i -= 2) {
    int whiteCount = 0;
    for (int k = 0; k < bound_threshold.rows; k++) {
      for (int l = i; l > i - span; l--) {
        if (bound_threshold.data[k * bound_threshold.step[0] + l] == 255) {
          whiteCount++;
        }
      }
    }

    if (whiteCount * 1.0 / (span * bound_threshold.rows) > 0.06) {
      posRight = i;
      if (posRight + 5 < bound_threshold.cols) {
        posRight = posRight + 5;
      } else {
        posRight = bound_threshold.cols - 1;
      }

      break;
    }
  }

  if (posLeft < posRight) {
    return true;
  }
  return false;
}

bool bFindLeftRightBound(Mat &bound_threshold, int &posLeft, int &posRight) {


  float span = bound_threshold.rows * 0.2f;

  for (int i = 0; i < bound_threshold.cols - span - 1; i += 2) {
    int whiteCount = 0;
    for (int k = 0; k < bound_threshold.rows; k++) {
      for (int l = i; l < i + span; l++) {
        if (bound_threshold.data[k * bound_threshold.step[0] + l] == 255) {
          whiteCount++;
        }
      }
    }
    if (whiteCount * 1.0 / (span * bound_threshold.rows) > 0.36) {
      posLeft = i;
      break;
    }
  }
  span = bound_threshold.rows * 0.2f;


  for (int i = bound_threshold.cols - 1; i > span; i -= 2) {
    int whiteCount = 0;
    for (int k = 0; k < bound_threshold.rows; k++) {
      for (int l = i; l > i - span; l--) {
        if (bound_threshold.data[k * bound_threshold.step[0] + l] == 255) {
          whiteCount++;
        }
      }
    }

    if (whiteCount * 1.0 / (span * bound_threshold.rows) > 0.26) {
      posRight = i;
      break;
    }
  }

  if (posLeft < posRight) {
    return true;
  }
  return false;
}

bool bFindLeftRightBound2(Mat &bound_threshold, int &posLeft, int &posRight) {

  float span = bound_threshold.rows * 0.2f;

  for (int i = 0; i < bound_threshold.cols - span - 1; i += 3) {
    int whiteCount = 0;
    for (int k = 0; k < bound_threshold.rows; k++) {
      for (int l = i; l < i + span; l++) {
        if (bound_threshold.data[k * bound_threshold.step[0] + l] == 255) {
          whiteCount++;
        }
      }
    }
    if (whiteCount * 1.0 / (span * bound_threshold.rows) > 0.32) {
      posLeft = i;
      break;
    }
  }
  span = bound_threshold.rows * 0.2f;


  for (int i = bound_threshold.cols - 1; i > span; i -= 3) {
    int whiteCount = 0;
    for (int k = 0; k < bound_threshold.rows; k++) {
      for (int l = i; l > i - span; l--) {
        if (bound_threshold.data[k * bound_threshold.step[0] + l] == 255) {
          whiteCount++;
        }
      }
    }

    if (whiteCount * 1.0 / (span * bound_threshold.rows) > 0.22) {
      posRight = i;
      break;
    }
  }

  if (posLeft < posRight) {
    return true;
  }
  return false;
}

void clearLiuDingOnly(Mat &img) {
  const int x = 7;
  Mat jump = Mat::zeros(1, img.rows, CV_32F);
  for (int i = 0; i < img.rows; i++) {
    int jumpCount = 0;
    int whiteCount = 0;
    for (int j = 0; j < img.cols - 1; j++) {
      if (img.at<char>(i, j) != img.at<char>(i, j + 1)) jumpCount++;

      if (img.at<uchar>(i, j) == 255) {
        whiteCount++;
      }
    }

    jump.at<float>(i) = (float) jumpCount;
  }

  for (int i = 0; i < img.rows; i++) {
    if (jump.at<float>(i) <= x) {
      for (int j = 0; j < img.cols; j++) {
        img.at<char>(i, j) = 0;
      }
    }
  }
}

bool clearLiuDing(Mat &img) {
  std::vector<float> fJump;
  int whiteCount = 0;
  const int x = 7;
  Mat jump = Mat::zeros(1, img.rows, CV_32F);
  for (int i = 0; i < img.rows; i++) {
    int jumpCount = 0;

    for (int j = 0; j < img.cols - 1; j++) {
      if (img.at<char>(i, j) != img.at<char>(i, j + 1)) jumpCount++;

      if (img.at<uchar>(i, j) == 255) {
        whiteCount++;
      }
    }

    jump.at<float>(i) = (float) jumpCount;
  }

  int iCount = 0;
  for (int i = 0; i < img.rows; i++) {
    fJump.push_back(jump.at<float>(i));
    if (jump.at<float>(i) >= 16 && jump.at<float>(i) <= 45) {

      // jump condition
      iCount++;
    }
  }

  // if not is not plate
  if (iCount * 1.0 / img.rows <= 0.40) {
    return false;
  }

  if (whiteCount * 1.0 / (img.rows * img.cols) < 0.15 ||
      whiteCount * 1.0 / (img.rows * img.cols) > 0.50) {
    return false;
  }

  for (int i = 0; i < img.rows; i++) {
    if (jump.at<float>(i) <= x) {
      for (int j = 0; j < img.cols; j++) {
        img.at<char>(i, j) = 0;
      }
    }
  }
  return true;
}

void clearLiuDing(Mat mask, int &top, int &bottom) {
  const int x = 7;

  for (int i = 0; i < mask.rows / 2; i++) {
    int whiteCount = 0;
    int jumpCount = 0;
    for (int j = 0; j < mask.cols - 1; j++) {
      if (mask.at<char>(i, j) != mask.at<char>(i, j + 1)) jumpCount++;

      if ((int) mask.at<uchar>(i, j) == 255) {
        whiteCount++;
      }
    }
    if ((jumpCount < x && whiteCount * 1.0 / mask.cols > 0.15) ||
        whiteCount < 4) {
      top = i;
    }
  }
  top -= 1;
  if (top < 0) {
    top = 0;
  }

  // ok, find top and bottom boudnadry

  for (int i = mask.rows - 1; i >= mask.rows / 2; i--) {
    int jumpCount = 0;
    int whiteCount = 0;
    for (int j = 0; j < mask.cols - 1; j++) {
      if (mask.at<char>(i, j) != mask.at<char>(i, j + 1)) jumpCount++;
      if (mask.at<uchar>(i, j) == 255) {
        whiteCount++;
      }
    }
    if ((jumpCount < x && whiteCount * 1.0 / mask.cols > 0.15) ||
        whiteCount < 4) {
      bottom = i;
    }
  }
  bottom += 1;
  if (bottom >= mask.rows) {
    bottom = mask.rows - 1;
  }

  if (top >= bottom) {
    top = 0;
    bottom = mask.rows - 1;
  }
}

int ThresholdOtsu(Mat mat) {
  int height = mat.rows;
  int width = mat.cols;

  // histogram
  float histogram[256] = {0};
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      unsigned char p = (unsigned char) ((mat.data[i * mat.step[0] + j]));
      histogram[p]++;
    }
  }
  // normalize histogram
  int size = height * width;
  for (int i = 0; i < 256; i++) {
    histogram[i] = histogram[i] / size;
  }

  // average pixel value
  float avgValue = 0;
  for (int i = 0; i < 256; i++) {
    avgValue += i * histogram[i];
  }

  int thresholdV;
  float maxVariance = 0;
  float w = 0, u = 0;
  for (int i = 0; i < 256; i++) {
    w += histogram[i];
    u += i * histogram[i];

    float t = avgValue * w - u;
    float variance = t * t / (w * (1 - w));
    if (variance > maxVariance) {
      maxVariance = variance;
      thresholdV = i;
    }
  }

  return thresholdV;
}


Mat histeq(Mat in) {
  Mat out(in.size(), in.type());
  if (in.channels() == 3) {
    Mat hsv;
    std::vector<cv::Mat> hsvSplit;
    cvtColor(in, hsv, CV_BGR2HSV);
    split(hsv, hsvSplit);
    equalizeHist(hsvSplit[2], hsvSplit[2]);
    merge(hsvSplit, hsv);
    cvtColor(hsv, out, CV_HSV2BGR);
  } else if (in.channels() == 1) {
    equalizeHist(in, out);
  }
  return out;
}

#define HORIZONTAL 1
#define VERTICAL 0

Mat CutTheRect(Mat &in, Rect &rect) {
  int size = in.cols;  // (rect.width>rect.height)?rect.width:rect.height;
  Mat dstMat(size, size, CV_8UC1);
  dstMat.setTo(Scalar(0, 0, 0));

  int x = (int) floor((float) (size - rect.width) / 2.0f);
  int y = (int) floor((float) (size - rect.height) / 2.0f);

  for (int i = 0; i < rect.height; ++i) {

    for (int j = 0; j < rect.width; ++j) {
      dstMat.data[dstMat.step[0] * (i + y) + j + x] =
          in.data[in.step[0] * (i + rect.y) + j + rect.x];
    }
  }

  //
  return dstMat;
}

Rect GetCenterRect(Mat &in) {
  Rect _rect;

  int top = 0;
  int bottom = in.rows - 1;

  // find the center rect

  for (int i = 0; i < in.rows; ++i) {
    bool bFind = false;
    for (int j = 0; j < in.cols; ++j) {
      if (in.data[i * in.step[0] + j] > 20) {
        top = i;
        bFind = true;
        break;
      }
    }
    if (bFind) {
      break;
    }

  }
  for (int i = in.rows - 1;
  i >= 0;
  --i) {
    bool bFind = false;
    for (int j = 0; j < in.cols; ++j) {
      if (in.data[i * in.step[0] + j] > 20) {
        bottom = i;
        bFind = true;
        break;
      }
    }
    if (bFind) {
      break;
    }

  }


  int left = 0;
  int right = in.cols - 1;
  for (int j = 0; j < in.cols; ++j) {
    bool bFind = false;
    for (int i = 0; i < in.rows; ++i) {
      if (in.data[i * in.step[0] + j] > 20) {
        left = j;
        bFind = true;
        break;
      }
    }
    if (bFind) {
      break;
    }

  }
  for (int j = in.cols - 1;
  j >= 0;
  --j) {
    bool bFind = false;
    for (int i = 0; i < in.rows; ++i) {
      if (in.data[i * in.step[0] + j] > 20) {
        right = j;
        bFind = true;

        break;
      }
    }
    if (bFind) {
      break;
    }
  }

  _rect.x = left;
  _rect.y = top;
  _rect.width = right - left + 1;
  _rect.height = bottom - top + 1;

  return _rect;
}

float countOfBigValue(Mat &mat, int iValue) {
  float iCount = 0.0;
  if (mat.rows > 1) {
    for (int i = 0; i < mat.rows; ++i) {
      if (mat.data[i * mat.step[0]] > iValue) {
        iCount += 1.0;
      }
    }
    return iCount;

  } else {
    for (int i = 0; i < mat.cols; ++i) {
      if (mat.data[i] > iValue) {
        iCount += 1.0;
      }
    }

    return iCount;
  }
}

Mat ProjectedHistogram(Mat img, int t) {
  int sz = (t) ? img.rows : img.cols;
  Mat mhist = Mat::zeros(1, sz, CV_32F);

  for (int j = 0; j < sz; j++) {
    Mat data = (t) ? img.row(j) : img.col(j);

    mhist.at<float>(j) = countOfBigValue(data, 20);
  }

  // Normalize histogram
  double min, max;
  minMaxLoc(mhist, &min, &max);

  if (max > 0)
    mhist.convertTo(mhist, -1, 1.0f / max, 0);

  return mhist;
}

Mat preprocessChar(Mat in, int char_size) {
  // Remap image
  int h = in.rows;
  int w = in.cols;

  int charSize = char_size;

  Mat transformMat = Mat::eye(2, 3, CV_32F);
  int m = max(w, h);
  transformMat.at<float>(0, 2) = float(m / 2 - w / 2);
  transformMat.at<float>(1, 2) = float(m / 2 - h / 2);

  Mat warpImage(m, m, in.type());
  warpAffine(in, warpImage, transformMat, warpImage.size(), INTER_LINEAR,
    BORDER_CONSTANT, Scalar(0));

  Mat out;
  cv::resize(warpImage, out, Size(charSize, charSize));

  return out;
}

Rect GetChineseRect(const Rect rectSpe) {
  int height = rectSpe.height;
  float newwidth = rectSpe.width * 1.10f;
  int x = rectSpe.x;
  int y = rectSpe.y;

  int newx = x - int(newwidth * 1.10f);
  newx = newx > 0 ? newx : 0;

  Rect a(newx, y, int(newwidth), height);

  return a;
}

bool verifyCharSizes(Rect r) {
  // Char sizes 45x90
  float aspect = 45.0f / 90.0f;
  float charAspect = (float)r.width / (float)r.height;
  float error = 0.35f;
  float minHeight = 25.f;
  float maxHeight = 50.f;
  // We have a different aspect ratio for number 1, and it can be ~0.2
  float minAspect = 0.05f;
  float maxAspect = aspect + aspect * error;

  // bb area
  int bbArea = r.width * r.height;

  if (charAspect > minAspect && charAspect < maxAspect /*&&
                                                       r.rows >= minHeight && r.rows < maxHeight*/)
                                                       return true;
  else
    return false;
}


Mat scaleImage(const Mat& image, const Size& maxSize, double& scale_ratio) {
  Mat ret;

  if (image.cols > maxSize.width || image.rows > maxSize.height) {
    double widthRatio = image.cols / (double)maxSize.width;
    double heightRatio = image.rows / (double)maxSize.height;
    double m_real_to_scaled_ratio = max(widthRatio, heightRatio);

    int newWidth = int(image.cols / m_real_to_scaled_ratio);
    int newHeight = int(image.rows / m_real_to_scaled_ratio);

    cv::resize(image, ret, Size(newWidth, newHeight), 0, 0);
    scale_ratio = m_real_to_scaled_ratio;
  }
  else {
    ret = image;
    scale_ratio = 1.0;
  }

  return ret;
}


// Scale back RotatedRect
RotatedRect scaleBackRRect(const RotatedRect& rr, const float scale_ratio) {
  float width = rr.size.width * scale_ratio;
  float height = rr.size.height * scale_ratio;
  float x = rr.center.x * scale_ratio;
  float y = rr.center.y * scale_ratio;
  RotatedRect mserRect(Point2f(x, y), Size2f(width, height), rr.angle);
  
  return mserRect;
}

bool verifyPlateSize(Rect mr) {
  float error = 0.6f;
  // Spain car plate size: 52x11 aspect 4,7272
  // China car plate size: 440mm*140mm，aspect 3.142857

  // Real car plate size: 136 * 32, aspect 4
  float aspect = 3.75;

  // Set a min and max area. All other patchs are discarded
  // int min= 1*aspect*1; // minimum area
  // int max= 2000*aspect*2000; // maximum area
  int min = 34 * 8 * 1;  // minimum area
  int max = 34 * 8 * 200;  // maximum area

  // Get only patchs that match to a respect ratio.
  float rmin = aspect - aspect * error;
  float rmax = aspect + aspect * error;

  float area = float(mr.height * mr.width);
  float r = (float)mr.width / (float)mr.height;
  if (r < 1) r = (float)mr.height / (float)mr.width;

  // cout << "area:" << area << endl;
  // cout << "r:" << r << endl;

  if ((area < min || area > max) || (r < rmin || r > rmax))
    return false;
  else
    return true;
}

bool verifyRotatedPlateSizes(RotatedRect mr, bool showDebug) {
  float error = 0.65f;
  // Spain car plate size: 52x11 aspect 4,7272
  // China car plate size: 440mm*140mm，aspect 3.142857

  // Real car plate size: 136 * 32, aspect 4
  float aspect = 3.75f;

  // Set a min and max area. All other patchs are discarded
  // int min= 1*aspect*1; // minimum area
  // int max= 2000*aspect*2000; // maximum area
  //int min = 34 * 8 * 1;  // minimum area
  //int max = 34 * 8 * 200;  // maximum area

  // Get only patchs that match to a respect ratio.
  float aspect_min = aspect - aspect * error;
  float aspect_max = aspect + aspect * error;

  float width_max = 600.f;
  float width_min = 30.f;

  float min = float(width_min * width_min / aspect_max);  // minimum area
  float max = float(width_max * width_max / aspect_min);  // maximum area

  float width = mr.size.width;
  float height = mr.size.height;
  float area = width * height;

  float ratio = width / height;
  float angle = mr.angle;
  if (ratio < 1) {
    swap(width, height);
    ratio = width / height;

    angle = 90.f + angle;
    //std::cout << "angle:" << angle << std::endl;
  }

  float angle_min = -60.f;
  float angle_max = 60.f;

  //std::cout << "aspect_min:" << aspect_min << std::endl;
  //std::cout << "aspect_max:" << aspect_max << std::endl;

  if (area < min || area > max) {
    if (0 && showDebug) {
      std::cout << "area < min || area > max: " << area << std::endl;
    }

    return false;
  }
  else if (ratio < aspect_min || ratio > aspect_max) {
    if (0 && showDebug) {
      std::cout << "ratio < aspect_min || ratio > aspect_max: " << ratio << std::endl;
    }
    
    return false;
  }
  else if (angle < angle_min || angle > angle_max) {
    if (0 && showDebug) {
      std::cout << "angle < angle_min || angle > angle_max: " << angle << std::endl;
    }
    
    return false;
  }
  else if (width < width_min || width > width_max) {
    if (0 && showDebug) {
      std::cout << "width < width_min || width > width_max: " << width << std::endl;
    }
    
    return false;  
  }
  else {
    return true;
  }

  return true;
}

void rotatedRectangle(InputOutputArray image, RotatedRect rrect, const Scalar& color, int thickness, int lineType, int shift) {
  Point2f rect_points[4];
  rrect.points(rect_points);
  for (int j = 0; j < 4; j++) {
    cv::line(image, rect_points[j], rect_points[(j + 1) % 4], color, thickness, lineType, shift);
  }
}


Rect interRect(const Rect& a, const Rect& b) {
  Rect c;
  int x1 = a.x > b.x ? a.x : b.x;
  int y1 = a.y > b.y ? a.y : b.y;
  c.width = (a.x + a.width < b.x + b.width ? a.x + a.width : b.x + b.width) - x1;
  c.height = (a.y + a.height < b.y + b.height ? a.y + a.height : b.y + b.height) - y1;
  c.x = x1;
  c.y = y1;
  if (c.width <= 0 || c.height <= 0)
    c = Rect();
  return c;
}

Rect mergeRect(const Rect& a, const Rect& b) {
  Rect c;
  int x1 = a.x < b.x ? a.x : b.x;
  int y1 = a.y < b.y ? a.y : b.y;
  c.width = (a.x + a.width > b.x + b.width ? a.x + a.width : b.x + b.width) - x1;
  c.height = (a.y + a.height > b.y + b.height ? a.y + a.height : b.y + b.height) - y1;
  c.x = x1;
  c.y = y1;
  return c;
}

bool computeIOU(const Rect& rect1, const Rect& rect2, const float thresh, float& result) {

  Rect inter = interRect(rect1, rect2);
  Rect urect = mergeRect(rect1, rect2);

  float iou = (float)inter.area() / (float)urect.area();
  result = iou;

  if (iou > thresh) {
    return true;
  }

  return false;
}

float computeIOU(const Rect& rect1, const Rect& rect2) {

  Rect inter = interRect(rect1, rect2);
  Rect urect = mergeRect(rect1, rect2);

  float iou = (float)inter.area() / (float)urect.area();
 
  return iou;
}


Rect getSafeRect(Point2f center, float width, float height, Mat image) {
  int rows = image.rows;
  int cols = image.cols;

  float x = center.x;
  float y = center.y;

  float x_tl = (x - width / 2.f);
  float y_tl = (y - height / 2.f);

  float x_br = (x + width / 2.f);
  float y_br = (y + height / 2.f);

  x_tl = x_tl > 0.f ? x_tl : 0.f;
  y_tl = y_tl > 0.f ? y_tl : 0.f;
  x_br = x_br < (float)image.cols ? x_br : (float)image.cols;
  y_br = y_br < (float)image.rows ? y_br : (float)image.rows;

  Rect rect(Point((int)x_tl, int(y_tl)), Point((int)x_br, int(y_br)));
  return rect;
}

bool mat_valid_position(const Mat& mat, int row, int col) {
  return row >= 0 && col >= 0 && row < mat.rows && col < mat.cols;
}


template<class T>
static void mat_set_invoke(Mat& mat, int row, int col, const Scalar& value) {
  if (1 == mat.channels()) {
    mat.at<T>(row, col) = (T)value.val[0];
  }
  else if (3 == mat.channels()) {
    T* ptr_src = mat.ptr<T>(row, col);
    *ptr_src++ = (T)value.val[0];
    *ptr_src++ = (T)value.val[1];
    *ptr_src = (T)value.val[2];
  }
  else if (4 == mat.channels()) {
    T* ptr_src = mat.ptr<T>(row, col);
    *ptr_src++ = (T)value.val[0];
    *ptr_src++ = (T)value.val[1];
    *ptr_src++ = (T)value.val[2];
    *ptr_src = (T)value.val[3];
  }
}

void setPoint(Mat& mat, int row, int col, const Scalar& value) {
  if (CV_8U == mat.depth()) {
    mat_set_invoke<uchar>(mat, row, col, value);
  }
  else if (CV_8S == mat.depth()) {
    mat_set_invoke<char>(mat, row, col, value);
  }
  else if (CV_16U == mat.depth()) {
    mat_set_invoke<ushort>(mat, row, col, value);
  }
  else if (CV_16S == mat.depth()) {
    mat_set_invoke<short>(mat, row, col, value);
  }
  else if (CV_32S == mat.depth()) {
    mat_set_invoke<int>(mat, row, col, value);
  }
  else if (CV_32F == mat.depth()) {
    mat_set_invoke<float>(mat, row, col, value);
  }
  else if (CV_64F == mat.depth()) {
    mat_set_invoke<double>(mat, row, col, value);
  }
}

Rect adaptive_charrect_from_rect(const Rect& rect, int maxwidth, int maxheight) {
  int expendWidth = 0;

  if (rect.height > 3 * rect.width) {
    expendWidth = (rect.height / 2 - rect.width) / 2;
  }

  //Rect resultRect(rect.tl().x - expendWidth, rect.tl().y, 
  //  rect.width + expendWidth * 2, rect.height);

  int tlx = rect.tl().x - expendWidth > 0 ? rect.tl().x - expendWidth : 0;
  int tly = rect.tl().y;

  int brx = rect.br().x + expendWidth < maxwidth ? rect.br().x + expendWidth : maxwidth;
  int bry = rect.br().y;

  Rect resultRect(tlx, tly, brx - tlx, bry - tly);
  return resultRect;
}


Mat adaptive_image_from_points(const std::vector<Point>& points,
  const Rect& rect, const Size& size, const Scalar& backgroundColor /* = ml_color_white */, 
  const Scalar& forgroundColor /* = ml_color_black */, bool gray /* = true */) {
  int expendHeight = 0;
  int expendWidth = 0;

  if (rect.width > rect.height) {
    expendHeight = (rect.width - rect.height) / 2;
  }
  else if (rect.height > rect.width) {
    expendWidth = (rect.height - rect.width) / 2;
  }

  Mat image(rect.height + expendHeight * 2, rect.width + expendWidth * 2, gray ? CV_8UC1 : CV_8UC3, backgroundColor);

  for (int i = 0; i < (int)points.size(); ++i) {
    Point point = points[i];
    Point currentPt(point.x - rect.tl().x + expendWidth, point.y - rect.tl().y + expendHeight);
    if (mat_valid_position(image, currentPt.y, currentPt.x)) {
      setPoint(image, currentPt.y, currentPt.x, forgroundColor);
    }
  }

  Mat result;
  cv::resize(image, result, size, 0, 0, INTER_NEAREST);

  return result;
}

// shift an image
Mat translateImg(Mat img, int offsetx, int offsety){
  Mat dst;
  Mat trans_mat = (Mat_<double>(2, 3) << 1, 0, offsetx, 0, 1, offsety);
  warpAffine(img, dst, trans_mat, img.size());
  return dst;
}

// rotate an image
Mat rotateImg(Mat source, float angle){
  Point2f src_center(source.cols / 2.0F, source.rows / 2.0F);
  Mat rot_mat = getRotationMatrix2D(src_center, angle, 1.0);
  Mat dst;
  warpAffine(source, dst, rot_mat, source.size());
  return dst;
}

//  calc safe Rect
//  if not exit, return false

bool calcSafeRect(const RotatedRect &roi_rect, const Mat &src,
  Rect_<float> &safeBoundRect) {
  Rect_<float> boudRect = roi_rect.boundingRect();

  float tl_x = boudRect.x > 0 ? boudRect.x : 0;
  float tl_y = boudRect.y > 0 ? boudRect.y : 0;

  float br_x = boudRect.x + boudRect.width < src.cols
    ? boudRect.x + boudRect.width - 1
    : src.cols - 1;
  float br_y = boudRect.y + boudRect.height < src.rows
    ? boudRect.y + boudRect.height - 1
    : src.rows - 1;

  float roi_width = br_x - tl_x;
  float roi_height = br_y - tl_y;

  if (roi_width <= 0 || roi_height <= 0) return false;

  //  a new rect not out the range of mat

  safeBoundRect = Rect_<float>(tl_x, tl_y, roi_width, roi_height);

  return true;
}

bool calcSafeRect(const RotatedRect &roi_rect, const int width, const int height,
  Rect_<float> &safeBoundRect) {
  Rect_<float> boudRect = roi_rect.boundingRect();

  float tl_x = boudRect.x > 0 ? boudRect.x : 0;
  float tl_y = boudRect.y > 0 ? boudRect.y : 0;

  float br_x = boudRect.x + boudRect.width < width
    ? boudRect.x + boudRect.width - 1
    : width - 1;
  float br_y = boudRect.y + boudRect.height < height
    ? boudRect.y + boudRect.height - 1
    : height - 1;

  float roi_width = br_x - tl_x;
  float roi_height = br_y - tl_y;

  if (roi_width <= 0 || roi_height <= 0) return false;

  //  a new rect not out the range of mat

  safeBoundRect = Rect_<float>(tl_x, tl_y, roi_width, roi_height);

  return true;
}

}
