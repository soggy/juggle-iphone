//
//  ViewController.m
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 RogueMinds.net. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize connectViaLabel;
@synthesize connectionMethodSwitch;
@synthesize serverLabel;
@synthesize serverAddress;
@synthesize connectMessage;
@synthesize connectAsLabel;
@synthesize localDataLabel;
@synthesize localData;
@synthesize remoteDataLabel;
@synthesize remoteData;
@synthesize leftButton;
@synthesize rightButton;
@synthesize cancelButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    useBluetooth = YES;
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setRightButton:nil];
    [self setLeftButton:nil];
    [self setRemoteData:nil];
    [self setRemoteDataLabel:nil];
    [self setLocalData:nil];
    [self setLocalDataLabel:nil];
    [self setConnectAsLabel:nil];
    [self setConnectMessage:nil];
    [self setServerAddress:nil];
    [self setServerLabel:nil];
    [self setConnectionMethodSwitch:nil];
    [self setConnectViaLabel:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    connectViaLabel.hidden = NO;
    connectionMethodSwitch.hidden = NO;
    serverLabel.hidden = YES;
    serverAddress.hidden = YES;
    connectMessage.hidden = YES;
    connectAsLabel.hidden = NO;
    localDataLabel.hidden = YES;
    localData.hidden = YES;
    remoteDataLabel.hidden = YES;
    remoteData.hidden = YES;
    leftButton.hidden = NO;
    rightButton.hidden = NO;
    cancelButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}


//  If the text field has enough characters to potentially be a server name/address, enable the "connect" buttons
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self validateServerName] == YES) 
    {
        [serverAddress resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
#pragma unused(textField)
    assert(textField == self.serverAddress);
    [self.serverAddress resignFirstResponder];
    return NO;
}

- (IBAction)selectMethod:(UISegmentedControl *)sender {
    if (sender == nil)
        return;
    
    switch (sender.selectedSegmentIndex) {
        case 0:         //  Peer-to-peer selected
            connectAsLabel.hidden = NO;
            leftButton.hidden = NO;
            rightButton.hidden = NO;
            serverLabel.hidden = YES;
            serverAddress.hidden = YES;
            cancelButton.hidden = YES;
            connectMessage.hidden = NO;
            connectMessage.text = @"Will attempt to pair with another device when you choose a hand...";
            useBluetooth = YES;
            break;
            
        case 1:         //  Server-based connection selected
            connectAsLabel.hidden = YES;
            leftButton.hidden = YES;
            rightButton.hidden = YES;
            serverLabel.hidden = NO;
            serverAddress.hidden = NO;
            connectMessage.hidden = YES;
            cancelButton.hidden = YES;
            useBluetooth = NO;
            
            // Fiddle with control visibility if there's already text in the server address field
            [self validateServerName];
            break;
            
        default:
            break;
    }
}

- (BOOL)validateServerName
{
    if (serverAddress.text.length > 7) 
    {
        connectAsLabel.hidden = NO;
        leftButton.hidden = NO;
        cancelButton.hidden = YES;
        rightButton.hidden = NO;
        connectMessage.text = [NSString stringWithFormat:@"Ready to connect to \n%@...", serverAddress.text];
        return YES;
    }
    
    connectAsLabel.hidden = YES;
    leftButton.hidden = YES;
    cancelButton.hidden = YES;
    rightButton.hidden = YES;
    connectMessage.text = [NSString stringWithFormat:@"%@\ndoes not look like a valid server name or address...", serverAddress.text];
    return NO;
}


- (IBAction)connect:(id)sender {
    NSString *hand;
    connectMessage.hidden = NO;
    
    if (sender == leftButton) {
        hand = @"left";
    } else if (sender == rightButton) {
        hand = @"right";
    } else {
        connectMessage.text = @"That wasn't a button I recognize.";
        return;
    }
    
    if (talker != nil) {
        [talker cancel];
        [talker release];
    }
    
    cancelButton.hidden = NO;
    leftButton.hidden = YES;
    rightButton.hidden = YES;
    connectAsLabel.hidden = YES;
    
    if (useBluetooth == YES) {
        connectMessage.text = [NSString stringWithFormat:@"Pairing as\n%@ hand...", hand];
        talker = [[[TattleTale alloc] initForGameKitWithHand:hand localDisplayField:localData remoteDisplayField:remoteData] retain];
    } else {
        connectMessage.text = [NSString stringWithFormat: @"Connecting to \n%@\nas %@ hand...", serverAddress.text, hand];
        connectMessage.text = [NSString stringWithFormat:@"Sending data to\n%@...\nTap 'Cancel' to stop", serverAddress.text];
        talker = [[[TattleTale alloc] initWithHand:hand forServer:serverAddress.text localDisplayField:localData remoteDisplayField:remoteData] retain];
    }
    connectViaLabel.hidden = YES;
    connectionMethodSwitch.hidden = YES;
    serverLabel.hidden = YES;
    serverAddress.hidden = YES;
    connectMessage.hidden = YES;
    localDataLabel.hidden = NO;
    localData.hidden = NO;
    remoteDataLabel.hidden = NO;
    remoteData.hidden = NO;
}

- (IBAction)stopSending:(id)sender 
{
    if (talker != nil) {
        [talker cancel];
    }
    leftButton.hidden = NO;
    cancelButton.hidden = YES;
    rightButton.hidden = NO;
    connectMessage.text = @"";
    connectMessage.hidden = YES;
    localDataLabel.hidden = YES;
    localData.hidden = YES;
    remoteDataLabel.hidden = YES;
    remoteData.hidden = YES;
    connectionMethodSwitch.hidden = NO;
    connectViaLabel.hidden = NO;
}


- (void)dealloc {
    [connectAsLabel release];
    [connectMessage release];
    [leftButton release];
    [cancelButton release];
    [rightButton release];
    if (talker != nil)
    {
        [talker cancel];
        [talker release];
    }
    [serverLabel release];
    [connectionMethodSwitch release];
    [connectViaLabel release];
    
    [super dealloc];
}
@end
