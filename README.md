# asonicOFDM
An OFDM modulation commutation system on Android phones using sound wave

### NOTE
The original implementation is in Matlab, which changes the carrier frequency by moving non-zero part in FFT/IFFT. This is a reasonable approach but limits the performance as well as the carrier frequency itself.

We have a new design in `Matlab_2`, which implements direct modulation on carrier frequency by IQ modulation, check the code for the difference.