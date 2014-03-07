
#import <AVFoundation/AVFoundation.h>

#include "ofApp.h"


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
    
	ofSoundStreamSetup(0, 1, this, sampleRate, BUFFER_SIZE, 1);
    ofSoundStreamStart();
    audioInput = new float[ BUFFER_SIZE ];
    
    noise.loadSound("sounds/noise.wav");
    noise.setLoop(true);
    noise.play();
    noise.setVolume(0);
    
    tone.loadSound("sounds/tone.wav");
    tone.setLoop(true);
    tone.play();
    tone.setVolume(0);
    
    toneToNoiseRatio = .50;
    
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
	
    bTakeSnapshot = true;
    bClear = false;
    
    volume = 0.0;
    noiseShape.assign( BUFFER_SIZE, 0.0);
    
    logo.loadImage("logoWhiteSmall.png");
    buttonPressed.loadImage("buttonPressed.png");
    buttonUnpressed.loadImage("buttonUnpressed.png");
    listening.loadImage("listening.png");
    filtering.loadImage("filtering.png");
    volumeControl.loadImage("volume.png");
    backButtonPressed.loadImage("backButtonPressed.png");
    backButtonUnpressed.loadImage("backButtonUnpressed.png");
    secondPage.loadImage("secondPageText.png");
    
    //gui stuff
    sliderMinX = 160;
    sliderMaxX = 865; 
    sliderMinY = 525;
    sliderMaxY = 535;
    sliderX = sliderMinX;
    sliderY = 510;
    sliderWidth = 10;
    sliderHeight = 40;
    sliderDestination = 0;
    sliderSpeed = 1.0;
    
    
    buttonX = 690;
    buttonY = 665;
    buttonWidth = 204;
    buttonHeight = 35;
     
    
    bSliderTouch = false;
    bSliderGlide = false;
    bButtonTouch = false;
    bSecondPage = false;
    
    indentX = 160;
    secondPageTimeout = 120;
    
    startTime = ofGetUnixTime();
    
    
   
}

//--------------------------------------------------------------
void ofApp::update(){
    ofBackground( 0, 51, 102 );
    currentTime = ofGetUnixTime();
    
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
    
    for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
        noiseShape[ i ] = ofRandom(0, 1) * avgMag[ int( i / 2 ) ]; //* volume;
    }

    
    //snapShot calculations
    if ( bTakeSnapshot ) {
        for ( int count = 0; count < 1000; count ++ ) {
            for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
                snapMag[ i ] += magnitude[ i ];
                avgMag[ i ] = snapMag[ i ] / count;
            }
        }
        for ( int i = 0; i < BUFFER_SIZE; i ++ ) {
            snapMag[ i ] = 0;
            //noiseShape[ i ] = ofRandom(0, 1) * avgMag[ int( i / 2 ) ]; //* volume;
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
   
    

    //slider
    volume = ofMap( sliderX, sliderMinX, sliderMinY, 0.0, 1.0 );
    noise.setVolume( volume );
    tone.setVolume( volume * toneToNoiseRatio );
    
    if ( bSecondPage ) {
        if ( currentTime - buttonTime >= secondPageTimeout ) {
            bSecondPage = false;
        }
    }

}

//--------------------------------------------------------------
void ofApp::draw(){
    
    logo.draw( 896, 42, 79, 77 );
    
    if ( bSecondPage ) {
        secondPage.draw( 214, 192 ); //210, 138 );
        if ( bButtonTouch ) {
            backButtonPressed.draw(buttonX, buttonY );
        }
        else {
            backButtonUnpressed.draw( buttonX, buttonY );
        }
    }
    
    else {
        //draw the FFT
        ofPushMatrix();
        ofTranslate( indentX, 200 );
        for ( int i = 1; i < (int)(BUFFER_SIZE / 2); i++ ){
            ofLine((i * 5.5), 0,(i * 5.5), -sqrt( magnitude[ i ] ) * 50.0f + 1 );
        }
        ofPopMatrix();
        
        listening.draw( indentX + 5, 215 );
        
        //draw the noise signal
        ofNoFill();
        ofPushStyle();
        ofPushMatrix();
        ofTranslate( indentX, 375 );
        ofSetLineWidth(2);
        ofBeginShape();
        for (unsigned int i = 0; i < noiseShape.size(); i++){
            float x =  ofMap( i, 0, noiseShape.size(), 0, 704, true);
            ofVertex( x, -sqrt( noiseShape[i] ) * 50.0f );
        }
        ofEndShape(false);
        ofPopMatrix();
        ofPopStyle();
        
        filtering.draw( indentX + 5, 390 );
        
        //draw volume gui
        ofPushMatrix();
        ofTranslate( indentX, 550 );
        ofFill();
        ofRectRounded( 0, -23, 704, 8, 10 );
        ofSetColor( 220, 220, 220 );
        ofRectRounded( 0, -23, sliderX - indentX + 3, 8, 10 );
        ofSetColor( 255, 255, 255 );
        ofRectRounded( sliderX - indentX, -40, sliderWidth, sliderHeight, 10 );
        ofPopMatrix();
        volumeControl.draw( indentX + 5, 570, 216, 15 );
        
        if ( bButtonTouch ) {
            buttonPressed.draw(buttonX, buttonY );
        }
        else {
            buttonUnpressed.draw( buttonX, buttonY );
        }
    }
    
    drawCounter++;
    
    
}

//--------------------------------------------------------------
void ofApp::exit(){
    
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
     
    //cout << "down (touchX, touchY): (" << touch.x << ", " << touch.y << " )"<< endl;
    
    
    if ( touch.x >= sliderX - 5 && touch.x <= sliderX + sliderWidth + 5) {
        if ( touch.y >= sliderY && touch.y <= sliderY + sliderHeight ) {
            bSliderTouch = true;
        }
    }
    
    if ( touch.x >= buttonX && touch.x <= buttonX + buttonWidth ) {
        if ( touch.y >= buttonY && touch.y <= buttonY + buttonHeight ) {
            bButtonTouch = true;
        }
    }
    
    

    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    if (!bSliderTouch ) {
        if ( touch.x >= sliderX - 5 && touch.x <= sliderX + sliderWidth + 5 ) {
            if ( touch.y >= sliderY && touch.y <= sliderY + sliderHeight ) {
                bSliderTouch = true;
                //cout << "slider Touched" << endl;
            }
        }
    }
    
    //cout << "moved (touchX, touchY): (" << touch.x << ", " << touch.y << " )"<< endl;
    
    if ( bSliderTouch ) {
        sliderX = touch.x - sliderWidth / 2;
        if ( sliderX < sliderMinX ) { sliderX = sliderMinX; }
        if ( sliderX > sliderMaxX - sliderWidth ) { sliderX = sliderMaxX - sliderWidth; }
    }
    
    if ( !bButtonTouch ) {
        if ( touch.x >= buttonX && touch.x <= buttonX + buttonWidth ) {
            if ( touch.y >= buttonY && touch.y <= buttonY + buttonHeight ) {
                bButtonTouch = true;
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    //cout << "up (touchX, touchY): (" << touch.x << ", " << touch.y << " )"<< endl;
    
    bSliderTouch = false;
    bButtonTouch = false;
    
    if ( bSecondPage ) {
        if ( touch.x >= buttonX && touch.x <= buttonX + buttonWidth ) {
            if ( touch.y >= buttonY && touch.y <= buttonY + buttonHeight ) {
                bSecondPage = false;
                //ofSoundStreamStart();
            }
        }
    }
    
    else {
        if ( touch.x >= buttonX && touch.x <= buttonX + buttonWidth ) {
            if ( touch.y >= buttonY && touch.y <= buttonY + buttonHeight ) {
                bSecondPage = true;
                buttonTime = currentTime;
            }
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
    if ( touch.x >= 0 && touch.x <= 100) {
        if ( touch.y >= 700 && touch.y <= 768 ) {
            bTakeSnapshot = true;
        }
    }
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

