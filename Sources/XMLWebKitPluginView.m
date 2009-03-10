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
@synthesize actionMenu;
@synthesize webView;
@synthesize tabView;
@synthesize aboutPanel;
@synthesize findPanel;
@synthesize prefsPanel;
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
	[self setupActionMenu];
	[self setupUpdateCheck];
	[self applyTextViewWrapping:self];

	NSString *bundleVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleVersion"];
	[aboutPanelVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@", bundleVersion]];

	hasAcquiredFirstResponder = NO;
	[self loadDataWithArguments:newArguments];
	
    return self;
}



- (void)setupActionMenu {
	NSInteger selectedOptionTag = [[NSUserDefaults standardUserDefaults] integerForKey:@"ch_entropy_xmlViewPlugin_PrettyPrintOptionTag"];
	for (NSMenuItem *item in [actionMenu itemArray]) {
		if ([item tag] == selectedOptionTag) [item setState:NSOnState];
	}
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
	self.findPanel = nil;
	self.prefsPanel = nil;

	self.softwareUpdater = nil;
	self.notificationMessage = nil;
	self.notificationMessageDetail = nil;
	self.textView = nil;
	self.actionMenu = nil;
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

	NSString *defaultUserCss = [self stringForWebResource:@"default" ofType:@"css"];
	NSString *defaultUserJs = [self stringForWebResource:@"default" ofType:@"js"];

	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], @"ch_entropy_xmlViewPlugin_WrapLines",
		[NSNumber numberWithBool:YES], @"ch_entropy_xmlViewPlugin_PrettyPrintXml",
		[NSNumber numberWithInt:PRETTY_PRINT_OPTION_FANCY], @"ch_entropy_xmlViewPlugin_PrettyPrintOptionTag",
		defaultUserCss, @"ch_entropy_xmlViewPlugin_UserCss",
		defaultUserJs, @"ch_entropy_xmlViewPlugin_UserJs",
		nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (NSURL *)fileUrlForWebResource:(NSString *)resource ofType:(NSString *)type {
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	return [NSURL fileURLWithPath:[bundle pathForResource:resource ofType:type inDirectory:@"web-resources"]];
}

- (NSString *)stringForWebResource:(NSString *)resource ofType:(NSString *)type {
	return [NSString stringWithContentsOfURL:[self fileUrlForWebResource:resource ofType:type]];
}



- (void)setupSubviews {
	// toplevel NIB objects start with retain count of 1 so we release them here
	[xmlContentView release];
	[self addSubview:xmlContentView];

	// TODO: crashes if we do the release on this one, check for leaks here
	// [aboutPanel release];
	[findPanel release];
	[prefsPanel release];
}


- (void)drawRect:(NSRect)aRect {
	if (!hasAcquiredFirstResponder) {
		// FIXME: there should be a better way/time/place to get first reponder status
		[[self window] makeFirstResponder:[self currentFindPanelTarget]];
		hasAcquiredFirstResponder = YES;
	}
	[super drawRect:aRect];
}


// Return the web or text view, whatever is currently displayed
- (id)currentFindPanelTarget {
	if ([[self currentDataViewIdentifier] isEqualToString:@"textview"]) return textView;
	return webView;
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

/*
- (void)mouseMoved:(NSEvent *)theEvent {
	NSLog(@"mouse moved: %@", theEvent);
	[webView mouseMoved:theEvent];
//	[super mouseMoved:theEvent];
}
*/

- (IBAction)updateDataDisplay:(id)sender {

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if ([sender isKindOfClass:[NSPopUpButton class]]) {
		NSMenuItem *item = [sender selectedItem];
		for (id i in [[item menu] itemArray]) [i setState:NSOffState];
		[item setState:NSOnState];
		[defaults setInteger:[item tag] forKey:@"ch_entropy_xmlViewPlugin_PrettyPrintOptionTag"];
	}

	NSInteger prettyPrintOption = [defaults integerForKey:@"ch_entropy_xmlViewPlugin_PrettyPrintOptionTag"];

	if (!documentData) return;


	XmlDataFormatter *xdf;
	NSData *result = nil;
	if (prettyPrintOption == PRETTY_PRINT_OPTION_FANCY) {
		xdf = [[[XmlDataFormatterXslt alloc] initWithData:documentData] autorelease];
		xdf.prettyPrint = YES;
		result = [(XmlDataFormatterXslt *)xdf prettyPrintedData];
	} else {
		xdf = [[[XmlDataFormatterTidy alloc] initWithData:documentData] autorelease];
		xdf.prettyPrint = prettyPrintOption == PRETTY_PRINT_OPTION_SIMPLE;
	}

	
	if (result) {
		[[webView mainFrame] loadData:result MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
//		NSLog(@"window accepts mouse moved: %d", [[self window] acceptsMouseMovedEvents]);
//		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.sun.com"]]];

		[tabView selectTabViewItemAtIndex:1];
#ifdef CONFIGURATION_DEBUG
		[result writeToFile:@"/tmp/xmlviewplugin-debug.html" atomically:YES];
#endif
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



- (IBAction)resetUserCss:(id)sender {
	NSString *defaultUserCss = [self stringForWebResource:@"default" ofType:@"css"];
	[[NSUserDefaults standardUserDefaults] setValue:defaultUserCss forKey:@"ch_entropy_xmlViewPlugin_UserCss"];
}

- (IBAction)resetUserJs:(id)sender {
	NSString *defaultUserJs = [self stringForWebResource:@"default" ofType:@"js"];
	[[NSUserDefaults standardUserDefaults] setValue:defaultUserJs forKey:@"ch_entropy_xmlViewPlugin_UserJs"];
}


- (IBAction)showUserSettingsDocumentation:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.entropy.ch/software/macosx/xmlviewplugin/#customization"]];
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

// Instead we do this. Because we always invoke the superclass implementation,
// the selection string is used both by Safari's custom search bar as well as
// in our text view's find panel.
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"e"]) {
		tag = NSFindPanelActionSetFindString;
		if ([[self currentDataViewIdentifier] isEqualToString:@"textview"]) {
			[textView performFindPanelAction:self];
		}
		// Unfortunately the text view doesn't pick up the find pasteboard find string
		// if the user runs Cmd-E in the web view. It seems to maintain its own find string.
	}
	BOOL result = [super performKeyEquivalent:theEvent];
	return result;
}


// Safari 3 invokes this
- (IBAction)showFindPanel:(id)sender {
	tag = NSFindPanelActionShowFindPanel;
	if ([[self currentDataViewIdentifier] isEqualToString:@"textview"]) {
		[textView performFindPanelAction:self];
	} else {
		[[NSApplication sharedApplication] beginSheet:findPanel modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
		[[findPanel.contentView viewWithTag:FIND_PANEL_TAG_TEXTFIELD] setStringValue:[self findString]];
		[findPanel.contentView viewWithTag:FIND_PANEL_TAG_TEXTFIELD];
	}
}


- (IBAction)closeFindPanel:(id)sender {
	[[NSApplication sharedApplication] endSheet:findPanel];
	[findPanel orderOut:self];

	if ([sender tag] != FIND_PANEL_TAG_FIND) return;

	NSTextField *findField = [findPanel.contentView viewWithTag:FIND_PANEL_TAG_TEXTFIELD];
	NSString *findString = [findField stringValue];

	NSPasteboard *findPboard = [NSPasteboard pasteboardWithName:NSFindPboard];
	[findPboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[findPboard setString:findString forType:NSStringPboardType];
	[self findNext:self];
}


// Safari 4 invokes this
- (IBAction)focusWebViewSearchField:(id)sender {
	[self showFindPanel:sender];
}


- (IBAction)findNext:(id)sender {
	tag = NSFindPanelActionNext;
	if ([[self currentDataViewIdentifier] isEqualToString:@"textview"]) {
		[textView performFindPanelAction:self];
	} else {
		[webView searchFor:[self findString] direction:YES caseSensitive:NO wrap:YES];
	}
}


- (IBAction)findPrevious:(id)sender {
	tag = NSFindPanelActionPrevious;
	if ([[self currentDataViewIdentifier] isEqualToString:@"textview"]) {
		[textView performFindPanelAction:self];
	} else {
		[webView searchFor:[self findString] direction:NO caseSensitive:NO wrap:YES];
	}
}


- (NSInteger)tag {
	return tag;
}


- (NSString *)currentDataViewIdentifier {
	return [[tabView selectedTabViewItem] identifier];
}

- (NSString *)findString {
	NSPasteboard *findPboard = [NSPasteboard pasteboardWithName:NSFindPboard];
	[findPboard types];
	return [findPboard stringForType:NSStringPboardType];
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

- (void)webPlugInDestroy {
	[prefsPanel close];
	[aboutPanel close];
}



#pragma mark WebKit WebUIDelegate protocol methods

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	NSLog(@"User JavaScript alert message: %@", message);
	NSBeginAlertSheet(@"JavaScript Alert", nil, nil, nil, [self window], nil, nil, nil, nil, message);
}


// This one is undocumented, and might break in the future
//
// http://www.archivesat.com/A_discussion_list_for_developers_using_the_WebKit_SDK/thread371974.htm
//
- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)message {
	NSLog(@"XML View Plugin: js console message: %@", message);
	int line = [[message valueForKey:@"lineNumber"] intValue] - 1;
	int userJsDisplayLine = line + 1;
	[prefsPanel makeKeyAndOrderFront:self];
	NSTabView *prefsTabView = [[[prefsPanel contentView] subviews] objectAtIndex:0];
	NSTabViewItem *jsTab = [prefsTabView tabViewItemAtIndex:1];
	[prefsTabView selectTabViewItem:jsTab];
	NSArray *paras = [[prefsJsTextView textStorage] paragraphs];
	//we don't seem to get line numbers for JS exceptions
	BOOL errorInUserJs = line >= 0 && line < [paras count];
	NSString *msg = [NSString stringWithFormat:@"JavaScript error on line %@: %@", errorInUserJs ? [NSNumber numberWithInt:userJsDisplayLine] : @"(unknown)", [message valueForKey:@"message"]];
	if (errorInUserJs) {
		unsigned int i, rangeStart = 0;
		for (i = 0; i < line; i++) rangeStart += [[paras objectAtIndex:i] length];
		[prefsJsTextView setSelectedRange:NSMakeRange(rangeStart, [[paras objectAtIndex:i] length])];
	}
	[prefsPanel makeFirstResponder:prefsJsTextView];
	NSBeginAlertSheet(@"JavaScript Error", nil, nil, nil, prefsPanel, nil, nil, nil, nil, msg);
}



@end

