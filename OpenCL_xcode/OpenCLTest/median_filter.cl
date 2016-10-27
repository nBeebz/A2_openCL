/**
 * THIS CODE IS MADE AVAILABLE “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, 
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 * AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

#define R (1)
#define LEN ((R*2+1)*(R*2+1))

inline void bubbleSort(uint data[LEN]) {
  for (int i = (LEN - 1); i > 0; i--) {
    for (int j = 1; j <= i; j++) {
      if (data[j-1]>data[j]) {             
        uint tmp = data[j];           
        data[j] = data[j-1];          
        data[j-1] = tmp;
      }    
    }
  }
}

__kernel void krnl_median_filter(
    const __global uint *  inputImage, 
    __global uint*  outputImage, 
    const int width, const int heigth)
{
	const int indx   = get_global_id(0);
	const int indy   = get_global_id(1);
	const int center = indy * width + indx;

	// on edges, the original pixel is preserved
	uint newPixel = inputImage[center];

	// straightforward case: inner image only
	if (indx >= R && indx < width-R && indy >= R  && indy < heigth - R) {
	    newPixel = 0;
	    // select block of pixels
	    uint blockRGB[LEN]; 
	    int k=0;
	    for (int i=-R; i<=R; ++i) {
	        for (int j=-R; j<=R; ++j) {
	            blockRGB[k++] = inputImage[center+i*width+j];
		}
            }

 	    uint mask = 0xFF;
	    for (int channel = 0; channel < 3; channel++) {

		// extract color components for next channel
		uint block[LEN];
		for (int j = 0; j<LEN; ++j) 
		  block[j]=blockRGB[j] & mask;

		// sort		
		bubbleSort(block);

		// save median for this channel
		newPixel |= block[LEN/2+1];

		// mask for the next channel
		mask <<= 8;
	    }
	}

	// store the new pixel
	outputImage[center] = newPixel;
}
