//
//  XMLWebKitPluginView.h
//  XMLWebKitPlugin
//
//  Created by Marc Liyanage on 06.02.09.
//  Copyright Marc Liyanage <http://www.entropy.ch> 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLWebKitPluginContentView.h"
#import "Sparkle/Sparkle.h"

#define PRETTY_PRINT_OPTION_RAW 1
#define PRETTY_PRINT_OPTION_SIMPLE 2
#define PRETTY_PRINT_OPTION_FANCY 3


@interface XMLWebKitPluginView : NSView <WebPlugInViewFactory> {
	IBOutlet XMLWebKitPluginContentView *xmlContentView;
	IBOutlet NSTextView *textView;
	IBOutlet NSWindow *aboutPanel;
	IBOutlet NSTextField *aboutPanelVersionLabel;
	IBOutlet WebView *webView;
	IBOutlet NSTabView *tabView;
	IBOutlet NSMenu *actionMenu;
	NSMutableData *documentData;
	NSURL *documentURL;
	NSSavePanel *savePanel;
	NSXMLDocument *xmlDocument;
	NSString *notificationMessage;
	NSString *notificationMessageDetail;
	SUUpdater *softwareUpdater;
	BOOL hasAcquiredFirstResponder;
	NSInteger tag;
	WebFrame *parentFrame;
	DOMHTMLElement *domElement;
}

@property(retain) SUUpdater *softwareUpdater;
@property(retain) IBOutlet NSView *xmlContentView;
@property(retain) NSString *notificationMessage;
@property(retain) NSString *notificationMessageDetail;
@property(retain) IBOutlet NSView *textView;
@property(retain) IBOutlet NSView *webView;
@property(retain) IBOutlet NSView *tabView;
@property(retain) IBOutlet NSMenu *actionMenu;
@property(retain) IBOutlet NSWindow *aboutPanel;
@property(retain) IBOutlet NSTextField *aboutPanelVersionLabel;
@property(retain) NSURL *documentURL;
@property(retain) NSMutableData *documentData;
@property(retain) WebFrame *parentFrame;
@property(retain) DOMHTMLElement *domElement;


- (id)initWithArguments:(NSDictionary *)arguments;
- (IBAction)updateDataDisplay:(id)sender;
- (IBAction)saveDocumentTo:(id)sender;
- (void)setupDefaults;
- (void)setupSubviews;
- (IBAction)visitWebsite:(id)sender;
- (IBAction)applyTextViewWrapping:(id)sender;
- (void)refreshLayout;
- (IBAction)showAboutPanel:(id)sender;
- (IBAction)checkForUpdates:(id)sender;
- (void)loadDataWithArguments:(NSDictionary *)arguments;
- (void)setupUpdateCheck;
- (void)setupTextViewFont:(NSTextView *)tv;
- (void)setupActionMenu;

@end
