/**

   Copyright 2013 CSIR Meraka HLT and Multilingual Speech Technologies (MuST) North-West University

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

**/

#include <fstream>
#include <sstream>
#include <iostream>
#include <vector>
#include <cstdlib>
#include <string>
#include <iterator>
#include <algorithm>

//#define DEBUG

using namespace std;

static bool NATURALWRITEORDER = false;
static bool NATURALREADORDER = false;

void swap_bytes(char *elements, size_t num_bytes_per_element, size_t num_elements) {
  for (int i = 0; i < num_elements; i++) {
    int a = 0;
    int b = num_bytes_per_element - 1;
    while (b > a) {
      char tmp = elements[b];
      elements[b] = elements[a];
      elements[a] = tmp;
      a++;
      b--;
    }
    // move to the next element
    elements += num_bytes_per_element;
  }
}

int read_mean_header (ifstream &infile) {
  int *num_mfcs = new int[1];
  infile.seekg (0);
  infile.read ((char*)num_mfcs, sizeof(int));
  if (!infile) {
    std::cout << "Error reading from file!\n";
    exit(1);
  }
  swap_bytes((char*)num_mfcs, sizeof(int), 1);
  int num_mfcs_tmp = (int)*num_mfcs;
  delete [] num_mfcs;
  return num_mfcs_tmp;
}

void read_mean_content (ifstream &infile, int num_mfcs, float *init_mean) {
  infile.read ((char*)init_mean, num_mfcs * sizeof(float));
  swap_bytes((char*)init_mean, sizeof(float), num_mfcs);
  infile.close();
}

void read_htk_mfcc_header (ifstream &infile, int *num_samples,
                           int *sample_period, short *sample_size,
                           short *parm_kind) {
  infile.seekg (0);
  infile.read ((char*)num_samples, 4);
  infile.read ((char*)sample_period, 4);
  infile.read ((char*)sample_size, 2);
  infile.read ((char*)parm_kind, 2);
  if (!infile) {
    std::cout << "Error reading htk header!\n";
    exit(1);
  }

  if ((int)((short)*sample_size/sizeof(float)) != 39) {
    NATURALREADORDER = false;
    swap_bytes((char*)sample_size, sizeof(short), 1);
    if ((int)((short)*sample_size/sizeof(float)) != 39) {
      cout << "ERROR: Expected '39' mfccs. Got '" << (int)((short)*sample_size/sizeof(float)) << "' instead!\n";
      exit(1);
    }
  } else {
    NATURALREADORDER = true;
  }

  if (!NATURALREADORDER) {
    swap_bytes((char*)num_samples, sizeof(int), 1);
    swap_bytes((char*)sample_period, sizeof(int), 1);
    swap_bytes((char*)parm_kind, sizeof(short), 1);
  }

#ifdef DEBUG
  short *parm_kind_tmp = new short[1]; // DBG
  std::cout << "Header information:\n";
  std::cout << "# samples:\t" << (int)*num_samples << "\n";
  std::cout << "sample_period:\t" << (int)*sample_period << "\n";
  std::cout << "sample size:\t" << (short)*sample_size << "\n";
  std::cout << "parm kind bits:\t" << (short)*parm_kind << "\n";
#endif
}

void read_htk_mfcc_content (ifstream &infile, int num_samples,
                            short sample_size, float *data) {
  size_t size_float = sizeof(float);
  // Read the number of samples
  infile.read ((char*)data, num_samples * sample_size);
  if (!NATURALREADORDER)
    swap_bytes((char*)data, size_float, num_samples*sample_size/size_float);
}

void write_htk_mfcc_to_file (string fn, int *num_samples, int *sample_period,
                             short *sample_size, short *parm_kind, float *data) {
  int tmp_num_samples = *num_samples;
  short tmp_sample_size = *sample_size;
  fstream ofile (fn.c_str(), ios::out | ios::binary);
  if (!ofile.is_open()) {
    cout << "Failed to open '" << fn << "'!\n";
    exit (1);
  }
  ofile.seekg(0);
 
  if ((NATURALREADORDER == false)) {
    swap_bytes((char*)num_samples, sizeof(int), 1);
    swap_bytes((char*)sample_period, sizeof(int), 1);
    swap_bytes((char*)sample_size, sizeof(short), 1);
    swap_bytes((char*)parm_kind, sizeof(short), 1);
    swap_bytes((char*)data, sizeof(float), tmp_num_samples*tmp_sample_size/sizeof(float));
  } 

  ofile.write((char*)num_samples, 4);
  ofile.write((char*)sample_period, 4);
  ofile.write((char*)sample_size, 2);
  ofile.write((char*)parm_kind, 2);
  ofile.write((char*)data, tmp_num_samples * tmp_sample_size);

  ofile.close();
}

void cmn_live (int num_samples, short sample_size, float cweight,
               float *mean, float *data) {
  int num_features = (int)(sample_size/sizeof(float));
  vector<float> now_mfcc_sum(13, 0.0);
  float x = 0;

  for (int i = 0; i < num_samples; i++) {
    // Perform CMN on first 13 (static) coefficients only!
    for (int j = 0; j < 13; j++) {
      now_mfcc_sum[j] += data[i*num_features + j];
      x = now_mfcc_sum[j] + cweight * mean[j];
      data[i*num_features + j] -= x/((i+1.0) + cweight);
    }
  }
}

int main( int argc, char *argv[] ) {
  if(argc !=4) {
    cout << "Usage: ./cmn_realtime <w> <in:mean> <in:hcopy_style_list>\n";
    cout << "  w                - weight in cmn equation, controlling how long initial means stays significant (Julius default = 100)\n";
    cout << "  mean             - mean in binary format (see cmn_save)\n";
    cout << "  hcopy_style_list - file with \"src dest\" per line\n\n";
    cout << "Info: subtracts a given mean from mfccs by applying the following equation for all static coefficients:\n";
    cout << "c_j = c_j - (sum_{i=0}^j( ci ) + u_init*w) / (j + 1.0 + w)\n";
    exit(1);
  }

  string cweight_str 		= argv[1];  
  string file_mean 		= argv[2];
  string file_hcopy_list 	= argv[3];

  float cweight = (float) atof(cweight_str.c_str());

  // read and store the mean
  ifstream fp_mean (file_mean.c_str(), ios::in | ios::binary);
  int num_mfcs = read_mean_header(fp_mean);
  float *init_mean = new float[num_mfcs];
  read_mean_content(fp_mean, num_mfcs, init_mean);
  fp_mean.close();

  // read the hcopy list
  string line;
  vector<string> files;
  ifstream fh_hcopy_list (file_hcopy_list.c_str());
  if (fh_hcopy_list.is_open()) {
    while (getline(fh_hcopy_list, line)) {
      files.clear();
      istringstream buf(line);
      copy(istream_iterator<string>(buf), istream_iterator<string>(),
           back_inserter<vector<string> >(files));
      cout << files[0] << " --> " << files[1] << "\n";

      // read and store the mfcc
      ifstream fp_mfcc (files[0].c_str(), ios::in | ios::binary);
      int *num_samples = new int[1];
      int *sample_period = new int[1];
      short *sample_size = new short[1];
      short *parm_kind = new short[1];
      read_htk_mfcc_header(fp_mfcc, num_samples, sample_period, sample_size, parm_kind);

      float *data = new float[(int)*num_samples * (short)*sample_size/sizeof(float)];
      read_htk_mfcc_content(fp_mfcc, (int)*num_samples, (short)*sample_size, data);

      // perform cmn
      cmn_live ((int)*num_samples, (short)*sample_size, cweight, init_mean, data);

      // write the modified mfccs to file
      write_htk_mfcc_to_file(files[1], num_samples, sample_period,
                          sample_size, parm_kind, data);
      fp_mfcc.close();

      delete [] num_samples;
      delete [] sample_period;
      delete [] sample_size;
      delete [] parm_kind;
      delete [] data;
    }
  } else {
    cout << "Failed to open '" << file_hcopy_list << "'!\n";
    exit(1);
  }
  fh_hcopy_list.close();
  

  return 0;
}
