//
//  ViewController.m
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 RogueMinds.net. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize leftButton;
@synthesize rightButton;
@synthesize cancelButton;
@synthesize connectionMethodSwitch;
@synthesize serverLabel;
@synthesize serverAddress;
@synthesize connectMessage;
@synthesize connectAsLabel;

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
    [self setServerAddress:nil];
    [self setLeftButton:nil];
    [self setRightButton:nil];
    [self setConnectMessage:nil];
    [self setConnectAsLabel:nil];
    [self setCancelButton:nil];
    [self setServerLabel:nil];
    [self setConnectionMethodSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    serverLabel.hidden = YES;
    serverAddress.hidden = YES;
    connectMessage.hidden = YES;
    connectAsLabel.hidden = NO;
    leftButton.hidden = NO;
    cancelButton.hidden = YES;
    rightButton.hidden = NO;
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
    } else {
        return YES;
    }
}


//  If the text field has enough characters to potentially be a server name/address, enable the "connect" buttons
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (serverAddress.text.length > 7) 
    {
        connectAsLabel.hidden = NO;
        leftButton.hidden = NO;
        cancelButton.hidden = YES;
        rightButton.hidden = NO;
        connectMessage.text = [NSString stringWithFormat:@"Ready to connect to \n%@...", serverAddress.text];
    } else {
        connectAsLabel.hidden = YES;
        leftButton.hidden = YES;
        cancelButton.hidden = YES;
        rightButton.hidden = YES;
        connectMessage.text = [NSString stringWithFormat:@"%@\ndoes not look like a valid server name or address...", serverAddress.text];
    }
    [serverAddress resignFirstResponder];
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
            break;
            
        default:
            break;
    }
}

- (IBAction)connect:(id)sender {
    NSString *hand;
    connectMessage.hidden = NO;
    
    if (sender == leftButton)
    {
        hand = @"left";
    } else if (sender == rightButton)
    {
        hand = @"right";
    } else {
        connectMessage.text = @"That wasn't a button I recognize.";
        return;
    }

    if (talker != nil) {
        [talker cancel];
        [talker release];
    }

    if (useBluetooth == YES)
    {
        connectMessage.text = [NSString stringWithFormat:@"Pairing as\n%@ hand...", hand];
        talker = [[[TattleTale alloc] initForGameKitWithHand:hand] retain];
    } else 
    {
        connectMessage.text = [NSString stringWithFormat: @"Connecting to \n%@\nas %@ hand...", serverAddress.text, hand];
        connectMessage.text = [NSString stringWithFormat:@"Sending data to\n%@...\nTap 'Cancel' to stop", serverAddress.text];
        talker = [[[TattleTale alloc] initWithHand:hand forServer:serverAddress.text] retain];
    }
    cancelButton.hidden = NO;
    leftButton.hidden = YES;
    rightButton.hidden = YES;
    connectAsLabel.hidden = YES;
}

- (IBAction)stopSending:(id)sender {
    if (talker != nil) {
        [talker cancel];
    }
    leftButton.hidden = NO;
    cancelButton.hidden = YES;
    rightButton.hidden = NO;
    connectMessage.text = @"";
    connectMessage.hidden = YES;
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
    [super dealloc];
}
@end
