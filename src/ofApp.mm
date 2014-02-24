
#import <AVFoundation/AVFoundation.h>

#include "ofApp.h"

//  IMPORTANT!!! if your sound doesn't work in the simulator
//	read this post => http://www.cocos2d-iphone.org/forum/topic/4159
//  which requires you set the input stream to 24bit!!

//--------------------------------------------------------------
void ofApp::setup(){
    ofSetFrameRate(60);
    ofBackground(255);
	ofSetOrientation(OF_ORIENTATION_90_RIGHT);//Set iOS to Orientation Landscape Right

	//for some reason on the iphone simulator 256 doesn't work - it comes in as 512!
	//so we do 512 - otherwise we crash
	initialBufferSize = 512;
	sampleRate = 44100;
	drawCounter = 0;
	bufferCounter = 0;
	
	buffer = new float[initialBufferSize];
	memset(buffer, 0, initialBufferSize * sizeof(float));
    
    //ofSoundStreamListDevices();

	// 0 output channels,
	// 1 input channels
	// 44100 samples per second
	// 512 samples per buffer
	// 1 buffer
    
	ofSoundStreamSetup(0, 1, this, sampleRate, BUFFER_SIZE, 1);
    audioInput = new float[ BUFFER_SIZE ];
    
    sound.loadSound("sounds/mix.wav");
    sound.setLoop(true);
    sound.play();
    sound.setVolume(0);
    
    for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
        snapMag[ i ] = 0;
        avgMag[ i ] = 0;
    }
    
    for (int i = 0; i < NUM_WINDOWS; i++)
	{
		for (int j = 0; j < BUFFER_SIZE / 2; j++)
		{
			freq[ i ][ j ] = 0;
		}
	}
	
    bTakeSnapshot = false;
    bClear = false;
    

    cout << ofGetWidth() << endl;
    cout << ofGetHeight() << endl;
   
}

//--------------------------------------------------------------
void ofApp::update(){
    ofBackground( 60, 102, 128 );
    
    static int index = 0;
	float avg_power = 0.0f;
	
	if( index < 80 )
		index += 1;
	else
		index = 0;
	
	/* do the FFT	*/
	myfft.powerSpectrum( 0, (int)BUFFER_SIZE / 2, audioInput, BUFFER_SIZE, &magnitude[0], &phase[0], &power[0], &avg_power);
	
	/* start from 1 because mag[0] = DC component */
	/* and discard the upper half of the buffer */
	for( int j = 1; j < BUFFER_SIZE / 2; j++ ) {
		freq[ index ][ j ] = magnitude[ j ];
	}

    
    //snapShot calculations
    if ( bTakeSnapshot ) {
        for ( int count = 0; count < 500; count ++ ) {
            for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
                snapMag[ i ] += magnitude[ i ];
                avgMag[ i ] = snapMag[ i ] / count;
            }
        }
        for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
            snapMag[ i ] = 0;
        }
        bTakeSnapshot = false;
    }
    if ( bClear ) {
        for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
            snapMag[ i ] = 0;
            avgMag[ i ] = 0;
        }
        bClear = false;
    }
   


}

//--------------------------------------------------------------
void ofApp::draw(){
    
    
    //draw the FFT
    //ofPushMatrix();
    //ofTranslate( 40, 100, 0 );
    //ofDrawBitmapString("Input", 0, 18 );
	for ( int i = 1; i < (int)(BUFFER_SIZE / 2); i++ ){
		ofLine( 64 + (i * 7), 200, 64 + (i * 7), 200 - magnitude[ i ] * 15.0f + 1 );
	}
    //ofPopMatrix();
    
    //draw the FFT snapshot
    //ofPushMatrix();
    //ofTranslate( 40, 200, 0 );
    //ofDrawBitmapString("Input Snapshot", 0, 18 );
    for ( int i = 1; i < (int)(BUFFER_SIZE / 2); i++ ){
		ofLine( 64 + (i * 7), 400, 64 + (i * 7), 400 - avgMag[ i ] * 15.0f + 1 );
	}
    //ofPopMatrix();
    
   /* drawCounter++;
    
    ofPushStyle();
	ofSetColor(0);
    ofDrawBitmapString("touch to play sound.", 20, ofGetHeight() - 60);
	ofDrawBitmapString("buffers received: " + ofToString(bufferCounter), 20, ofGetHeight() - 40);
    ofDrawBitmapString("draw routines called: " + ofToString(drawCounter), 20, ofGetHeight() - 20);
    ofPopStyle();
    */
}

//--------------------------------------------------------------
void ofApp::exit(){
    //
}

//--------------------------------------------------------------
void ofApp::audioIn(float * input, int bufferSize, int nChannels){
    
    
    for ( int i = 0; i < bufferSize; i++ ){
		audioInput[ i ] = input[ i * 2 ];
	}


	if(initialBufferSize < bufferSize){
		ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", initialBufferSize, bufferSize);
	}	

	int minBufferSize = MIN(initialBufferSize, bufferSize);
	for(int i=0; i<minBufferSize; i++) {
		buffer[i] = input[i];
	}
	bufferCounter++;
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    sound.setVolume(1.0);
    
    bTakeSnapshot = true;
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
	
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    sound.setVolume(0.0);
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}

