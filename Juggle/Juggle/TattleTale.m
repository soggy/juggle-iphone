//
//  TattleTale.m
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 Sog.gy. All rights reserved.
//

#import "TattleTale.h"

#define kGKSessionID    @"juggle"

@implementation TattleTale

-(TattleTale *)initForGameKitWithHand:(NSString *)hand
{
    self = [super init];
    if (self != nil) {
        whichHand = [hand retain];
        socket = nil;
        
        GKPeerPickerController *picker;
        
        picker = [[GKPeerPickerController alloc] init];
        picker.delegate = self;
        [picker show];
    }
    return self;
}


-(TattleTale *)initWithHand:(NSString *)hand forServer:(NSString *)serverName
{
    self = [super init];
    if (self != nil) {
        whichHand = [hand retain];
        serverAddress = [serverName retain];
        accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
        accelerometer.updateInterval = 1.0/20.0;
        accelerometer.delegate = self;
        socket = [[[AsyncUdpSocket alloc] init] retain];

        // setup the location manager
        locationManager = [[[CLLocationManager alloc] init] retain];
        
        // check if the hardware has a compass
        if ([CLLocationManager headingAvailable] == NO) {
            // No compass is available. This application cannot function without a compass, 
            // so a dialog will be displayed and no magnetic data will be measured.
            locationManager = nil;
            UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass!" message:@"This device does not have the ability to measure magnetic fields. We'll forge ahead regardless." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [noCompassAlert show];
            [noCompassAlert release];
        } else {
            // heading service configuration
            locationManager.headingFilter = kCLHeadingFilterNone;
            
            // setup delegate callbacks
            locationManager.delegate = self;
            
            // start the compass
            [locationManager startUpdatingHeading];
        }
        
        lastOrientationX = lastOrientationY = lastOrientationZ = 0.0;
    }
    return self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    NSString *jsonDataFormat = \
@"{\n\
    \"type\":\"sensor\",\n\
    \"sensor_data\":\n\
    {\n\
      \"hand\":\"%@\",\n\
      \"x\":\"%6.4f\",\n\
      \"y\":\"%6.4f\",\n\
      \"z\":\"%6.4f\",\n\
      \"azimuth\":\"%6.4f\",\n\
      \"pitch\":\"%6.4f\",\n\
      \"roll\":\"%6.4f\"\n\
    }\n\
}";

    NSString *jsonData = [NSString stringWithFormat:jsonDataFormat, whichHand, acceleration.x, acceleration.y, acceleration.z, lastOrientationX, lastOrientationY, lastOrientationZ];

    [socket sendData:[jsonData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] toHost:serverAddress port:12345 withTimeout:-1 tag:1];
}

- (void)cancel
{
    if (accelerometer != nil)
        accelerometer.delegate = nil;
}

#pragma mark - CLLocationManagerDelegate methods

// This delegate method is invoked when the location manager has heading data.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    // Update the labels with the raw x, y, and z values.
	lastOrientationX = heading.x;
    lastOrientationY = heading.y;
	lastOrientationZ = heading.z;
}

// This delegate method is invoked when the location managed encounters an error condition.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        // This error indicates that the user has denied the application's request to use location services.
        [manager stopUpdatingHeading];
    } else if ([error code] == kCLErrorHeadingFailure) {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}

#pragma mark - GKPeerPickerControllerDelegate methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if(gameKitSession != nil)	{
		[self invalidateSession:gameKitSession];
		gameKitSession = nil;
	}
	
	// go back to start mode
//	self.gameState = kStateStartGame;
} 

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
	GKSession *session = [[GKSession alloc] initWithSessionID:kGKSessionID displayName:/*@"Juggle"*/nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
	// Remember the current peer.
	gameKitPeerId = [peerID copy];
	
	// Make sure we have a reference to the game session and it is set up
	gameKitSession = [session retain];
	gameKitSession.delegate = (id)self; 
	[gameKitSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
//	self.gameState = kStateMultiplayerCointoss;
} 

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

#pragma mark - GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state 
{ 
//	if(gameKitState == kStatePicker) {
//		return;				// only do stuff if we're in multiplayer, otherwise it is probably for Picker
//	}
//	
//	if(state == GKPeerStateDisconnected) {
//		// We've been disconnected from the other peer.
//		
//		// Update user alert or throw alert if it isn't already up
//		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
//		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
//			self.connectionAlert.message = message;
//		}
//		else {
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
//			self.connectionAlert = alert;
//			[alert show];
//			[alert release];
//		}
//		
//		// go back to start mode
//		self.gameState = kStateStartGame; 
//	} 
} 



- (void)dealloc
{
    accelerometer.delegate = nil;
    [accelerometer release];
    [whichHand release];
    [serverAddress release];
    [socket release];
    [locationManager stopUpdatingHeading];
    [locationManager release];
    [super dealloc];
}

@end
