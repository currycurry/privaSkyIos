#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "fft.h"

#define BUFFER_SIZE 256
#define NUM_WINDOWS 80

class ofApp : public ofxiOSApp{
	
public:
	void setup();
	void update();
	void draw();
	
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
	
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);

	void audioIn(float * input, int bufferSize, int nChannels);
    float * audioInput;
    vector <float> noiseShape;

	int	initialBufferSize;
	int	sampleRate;
	int	drawCounter;
    int bufferCounter;
	float * buffer;
	
    ofSoundPlayer sound;
    ofSoundPlayer noise;
    ofSoundPlayer tone;

    
    bool  bTakeSnapshot, bClear;
    float snapMag[BUFFER_SIZE];
    float avgMag[BUFFER_SIZE];
    
    float volume;
    int sliderX, sliderY, sliderMinX, sliderMinY, sliderMaxX, sliderMaxY, sliderWidth, sliderHeight, sliderDestination;
    int buttonX, buttonY, buttonWidth, buttonHeight;
    int indentX;
    float sliderSpeed;
    bool bSliderTouch, bButtonTouch, bSliderGlide, bSecondPage;
    
    int secondPageTimeout;
    
    int startTime, currentTime, buttonTime;
    
    ofImage logo;
    ofImage buttonPressed, buttonUnpressed, listening, filtering, volumeControl, backButtonPressed, backButtonUnpressed;
    ofImage secondPage;
    
    float toneToNoiseRatio;
    
private:
    
    fft	  myfft;
    
    float magnitude[BUFFER_SIZE];
    float phase[BUFFER_SIZE];
    float power[BUFFER_SIZE];
    
    float freq[NUM_WINDOWS][BUFFER_SIZE / 2];
    float freq_phase[NUM_WINDOWS][BUFFER_SIZE / 2];
    
    
    
};

