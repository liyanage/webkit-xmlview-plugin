//
//  XMLWebKitPluginView.m
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 06.02.09.
//  Copyright Marc Liyanage <http://www.entropy.ch> 2009. All rights reserved.
//

#import "XMLWebKitPluginView.h"
#import "XmlDataFormatterTidy.h";
#import "XmlDataFormatterXslt.h";

@implementation XMLWebKitPluginView

@synthesize softwareUpdater;
@synthesize xmlContentView;
@synthesize notificationMessage;
@synthesize notificationMessageDetail;
@synthesize textView;
@synthesize webView;
@synthesize tabView;
@synthesize aboutPanel;
@synthesize aboutPanelVersionLabel;
@synthesize documentURL;
@synthesize documentData;
@synthesize parentFrame;
@synthesize domElement;


#pragma mark WebPlugInViewFactory protocol

// The principal class of the plug-in bundle must implement this protocol.
+ (NSView *)plugInViewWithArguments:(NSDictionary *)newArguments {
//	return nil;

    XMLWebKitPluginView *view = [[[self alloc] initWithArguments:newArguments] autorelease];
	return view;
}


#pragma mark lifecycle methods

- (id)initWithArguments:(NSDictionary *)newArguments {

#ifdef CONFIGURATION_DEBUG
	NSLog(@"XML View Plugin: arguments: %@", newArguments);
#endif

    if (!(self = [super initWithFrame:NSZeroRect])) return nil;
	[NSBundle loadNibNamed:@"XMLWebKitUI" owner:self];

	DOMHTMLElement *element = [newArguments objectForKey:@"WebPlugInContainingElementKey"];
	self.domElement = element;

/*
typedef enum {
    WebPlugInModeEmbed = 0,
    WebPlugInModeFull  = 1
} WebPlugInMode;
*/
	
    [self setupDefaults];
	[self setupSubviews];
	[self setupUpdateCheck];
	[self applyTextViewWrapping:self];

	NSString *bundleVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleVersion"];
	[aboutPanelVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@", bundleVersion]];

	hasAcquiredFirstResponder = NO;
	[self loadDataWithArguments:newArguments];

    return self;
}


- (void)setupUpdateCheck {
	self.softwareUpdater = [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
	[softwareUpdater resetUpdateCycle];
}


- (IBAction)checkForUpdates:(id)sender {
	[softwareUpdater checkForUpdates:sender];
	[self refreshLayout];
}

- (void)dealloc {
	// NIB toplevel objects
	self.xmlContentView = nil;
	self.aboutPanel = nil;

	self.softwareUpdater = nil;
	self.notificationMessage = nil;
	self.notificationMessageDetail = nil;
	self.textView = nil;
	self.webView = nil;
	self.tabView = nil;
	self.documentURL = nil;
	self.aboutPanelVersionLabel = nil;
	self.documentData = nil;
	self.parentFrame = nil;
	self.domElement = nil;

	[super dealloc];
}


# pragma mark setup methods

- (void)setupDefaults {
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], @"ch_entropy_xmlViewPlugin_WrapLines",
		[NSNumber numberWithBool:YES], @"ch_entropy_xmlViewPlugin_PrettyPrintXml",
		nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (void)setupSubviews {
	// toplevel NIB objects start with retain count of 1 so we release them here
	[xmlContentView release];
	[self addSubview:xmlContentView];

	// TODO: crashes if we do the release on this one, check for leaks here
	// [aboutPanel release];

}


- (void)drawRect:(NSRect)aRect {
	if (!hasAcquiredFirstResponder) {
		// FIXME: there should be a better way/time/place to get first reponder status
		[[self window] makeFirstResponder:textView];
		hasAcquiredFirstResponder = YES;
	}
	[super drawRect:aRect];
}



# pragma mark IBActions

- (IBAction)visitWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.entropy.ch/software/macosx/#xmlviewplugin"]];
}


- (IBAction)applyTextViewWrapping:(id)sender {
	BOOL shouldWrap = [[NSUserDefaults standardUserDefaults] boolForKey:@"ch_entropy_xmlViewPlugin_WrapLines"];
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		shouldWrap = ![sender state]; // the state isn't yet updated at the time of action method invocation
	}

	// This is harder than it should be
	// http://lists.apple.com/archives/Cocoa-dev/2003/Dec/msg01352.html
	NSSize layoutSize = [textView maxSize];
	layoutSize.width = shouldWrap ? [self bounds].size.width : layoutSize.height;
	[textView setMaxSize:layoutSize];
	NSTextContainer *tc = [textView textContainer];
	[tc setWidthTracksTextView:shouldWrap];
	[tc setContainerSize:layoutSize];

	[self refreshLayout];
}


- (IBAction)showAboutPanel:(id)sender {
	[aboutPanel makeKeyAndOrderFront:sender];
	[self refreshLayout];
}


- (IBAction)updateDataDisplay:(id)sender {

	if (!documentData) return;
	
	BOOL shouldPrettyPrint = [[NSUserDefaults standardUserDefaults] boolForKey:@"ch_entropy_xmlViewPlugin_PrettyPrintXml"];
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		shouldPrettyPrint = ![sender state]; // the state isn't yet updated at the time of action method invocation
	}

	XmlDataFormatterXslt *xdf = [[[XmlDataFormatterXslt alloc] initWithData:documentData] autorelease];
	xdf.prettyPrint = shouldPrettyPrint;

	NSData *result = nil;
	if (shouldPrettyPrint) {
		result = [xdf prettyPrintedData];
	}
	
	if (result) {
		[[webView mainFrame] loadData:result MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
		[tabView selectTabViewItemAtIndex:1];
	} else {
		NSString *xmlText = [xdf formattedString];
		NSTextView *tv = [self valueForKey:@"textView"];
		NSAttributedString *xmlAttributedString = [[[NSAttributedString alloc] initWithString:xmlText] autorelease];
		[[tv textStorage] setAttributedString:xmlAttributedString];
		[self setupTextViewFont:tv];
		[tabView selectTabViewItemAtIndex:0];
	}

	self.notificationMessage = xdf.errorMessage ? xdf.errorMessage : nil;
	self.notificationMessageDetail = xdf.errorMessageDetail ? xdf.errorMessageDetail : nil;

	[self refreshLayout];
}


- (void)setupTextViewFont:(NSTextView *)tv {
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	CGFloat fixedWidthFontSize = [ud floatForKey:@"WebKitDefaultFixedFontSize"];
	if (!fixedWidthFontSize) fixedWidthFontSize = 12;
	NSString *fixedWidthFontName = [ud stringForKey:@"WebKitFixedFont"];

	NSFont *fixedWidthFont = nil;
	if (fixedWidthFontName) {
		fixedWidthFont = [NSFont fontWithName:fixedWidthFontName size:fixedWidthFontSize];
	}
	if (!fixedWidthFont) fixedWidthFont = [NSFont fontWithName:@"Courier" size:12];
	if (fixedWidthFont) [tv setFont:fixedWidthFont];
}


#pragma mark find panel actions

// This one doesn't work, somehow we never see this on the responder chain
/*
- (IBAction)takeFindStringFromSelection:(id)sender {
	NSLog(@"XML View Plugin: find string action");
	tag = NSFindPanelActionSetFindString;
	[textView performFindPanelAction:self];
}
*/

// Instead we do this. Because we invoke the superclass version in any case, the
// selection string is used both for Safari's custom search bear as well as in 
// our text view's find panel.
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"]) {
		tag = NSFindPanelActionSetFindString;
		[textView performFindPanelAction:self];
	}
	return [super performKeyEquivalent:theEvent];
}

- (IBAction)showFindPanel:(id)sender {
	tag = NSFindPanelActionShowFindPanel;
	[textView performFindPanelAction:self];
}

- (IBAction)findNext:(id)sender {
	tag = NSFindPanelActionNext;
	[textView performFindPanelAction:self];
}

- (IBAction)findPrevious:(id)sender {
	tag = NSFindPanelActionPrevious;
	[textView performFindPanelAction:self];
}

- (NSInteger)tag {
	return tag;
}



/*
- (BOOL)respondsToSelector:(SEL)aSelector {
	NSLog(@"XML View Plugin: selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}
*/


# pragma mark display / interaction methods

- (void)refreshLayout {
	// A bit of voodoo coding.
	// If I don't do this, part of the text view blacks out in some
	// cases when it's wider than the longest line of text.
	// Resizing the window fixes it so I'm forcing a redraw like this
	// until I find out what the proper solution is. setNeedsDisplay alone doesn't do it...
	[self setFrameOrigin:NSMakePoint(1, 1)];
	[self setFrameOrigin:NSMakePoint(0, 0)];
}


// propagate frame change to the NIB based content view
- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[xmlContentView setFrame:[self bounds]];
}


- (void)loadDataWithArguments:(NSDictionary *)arguments {

	self.documentURL = [NSURL URLWithString:[arguments valueForKeyPath:@"WebPlugInAttributesKey.src"]];

	id pluginShouldLoad = [arguments objectForKey:@"WebPlugInShouldLoadMainResourceKey"];
	if (![pluginShouldLoad boolValue]) {
		// if the key is present and tells us not to load the data, this
		// method should not continue. Instead, the webPlugInMainResourceDidReceiveData:
		// method gets the data already loaded.
//		NSLog(@"XML View Plugin: plugin should not load data");
		return;
	}

#ifdef CONFIGURATION_DEBUG
	NSLog(@"XML View Plugin: WebPlugInShouldLoadMainResourceKey is YES");
#endif

	if (!documentURL) {
		self.notificationMessage = @"Unable to load XML data, no URL";
		NSLog(@"XML View Plugin: %@", notificationMessage);
		return;
	}

	self.documentData = [NSData dataWithContentsOfURL:documentURL];
	if (!documentData) {
		self.notificationMessage = [NSString stringWithFormat:@"Unable to load XML data from %@", documentURL];
		NSLog(@"XML View Plugin: %@", notificationMessage);
		return;
	}

/*
	NSURL *baseUrl = [arguments valueForKey:@"WebPlugInBaseURLKey"];
	NSLog(@"XML View Plugin: baseurl: %@", baseUrl);
	self.parentFrame = [[arguments valueForKey:@"WebPlugInContainerKey"] webFrame];
	NSLog(@"XML View Plugin: parentframe: %@, %@", parentFrame, [parentFrame name]);
*/

//	[parentFrame loadData:[@"test" dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/plain" textEncodingName:@"utf-8" baseURL:baseUrl];
//	[parentFrame loadData:self.documentData MIMEType:@"text/plain" textEncodingName:@"utf-8" baseURL:baseUrl];

	[self updateDataDisplay:self];

}


# pragma mark save methods

- (IBAction)saveDocumentTo:(id)sender {
	if (!documentData) return;
	savePanel = [[NSSavePanel savePanel] retain];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath =  [paths objectAtIndex:0];
	NSString *fileName = [[documentURL path] lastPathComponent];
	[savePanel beginSheetForDirectory:documentPath file:fileName modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	[self refreshLayout];
}


- (void)savePanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSOKButton) {
		[documentData writeToFile:[savePanel filename] atomically:YES];
	}
	[savePanel release];
	savePanel = nil;
}


/*
- (BOOL)respondsToSelector:(SEL)sel {
	NSLog(@"XML View Plugin: selector query: %@", NSStringFromSelector(sel));
	return [super respondsToSelector:sel];
}
*/


#pragma mark WebPlugIn informal protocol

- (void)webPlugInMainResourceDidReceiveData:(NSData *)data {
//	self.documentData = data;
//	self.documentData = [[data copy] autorelease];

	if (self.documentData) {
#ifdef CONFIGURATION_DEBUG
		NSLog(@"XML View Plugin: additional data arrived, appending to existing data");
#endif
		[self.documentData appendData:data];
	} else {
#ifdef CONFIGURATION_DEBUG
		NSLog(@"XML View Plugin: initial data arrived");
#endif
		self.documentData = [NSMutableData dataWithData:data]; // if we don't create a copy but instead just retain, the data suddenly changes to garbage when we look at it again at a later time.
	}
}


/* It appears that this method from the protocol *must* be implemented, otherwise webPlugInMainResourceDidFailWithError is
 * called with a "WebKitErrorDomain error 204" and webPlugInMainResourceDidReceiveData: is only called once for
 * large responses, when it should be called several times (see the append logic there).
 */
- (void)webPlugInMainResourceDidReceiveResponse:(NSURLResponse *)response {
}


- (void)webPlugInMainResourceDidFinishLoading {
#ifdef CONFIGURATION_DEBUG
	NSLog(@"XML View Plugin: finish loading, data length %u", [self.documentData length]);
#endif
	[self updateDataDisplay:self];
}


- (void)webPlugInMainResourceDidFailWithError:(NSError *)error {
	NSLog(@"XML View Plugin: Error: %@", error);
}

/*
- (void)webPlugInInitialize
{
    // This method will be only called once per instance of the plug-in object, and will be called
    // before any other methods in the WebPlugIn protocol.
    // You are not required to implement this method.  It may safely be removed.
}

- (void)webPlugInStart
{
    // The plug-in usually begins drawing, playing sounds and/or animation in this method.
    // You are not required to implement this method.  It may safely be removed.
//	NSLog(@"XML View Plugin: webPlugInStart: %@", NSStringFromRect([self frame]));

}

- (void)webPlugInStop
{
    // The plug-in normally stop animations/sounds in this method.
    // You are not required to implement this method.  It may safely be removed.
	NSLog(@"XML View Plugin: webPlugInStop");
}

- (void)webPlugInDestroy
{
    // Perform cleanup and prepare to be deallocated.
    // You are not required to implement this method.  It may safely be removed.
	NSLog(@"XML View Plugin: webPlugInDestroy");
}

- (void)webPlugInSetIsSelected:(BOOL)isSelected
{
    // This is typically used to allow the plug-in to alter its appearance when selected.
    // You are not required to implement this method.  It may safely be removed.
}

- (id)objectForWebScript
{
    // Returns the object that exposes the plug-in's interface.  The class of this object can implement
    // methods from the WebScripting informal protocol.
    // You are not required to implement this method.  It may safely be removed.
    return self;
}
*/

@end

