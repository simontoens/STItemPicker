// @author Simon Toens 03/03/13

#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "MPMediaDataSource.h"
#import "SampleMediaDataSource.h"
#import "SampleCityDataSource.h"
#import "TestViewController.h"


@interface TestViewController()
@property(nonatomic, weak) IBOutlet UILabel *pickLabel;
- (void)showItemPickerWithDataSources:(NSArray *)dataSources showCancelButton:(BOOL)showCancelButton;
@end

@implementation TestViewController

@synthesize pickLabel;

- (IBAction)onSampleMediaDataSource:(id)sender 
{
    [self showItemPickerWithDataSources:
        [NSArray arrayWithObjects:
            [SampleMediaDataSource artistsDataSource], 
            [SampleMediaDataSource albumsDataSource],
            [SampleMediaDataSource songsDataSource], 
            nil] showCancelButton:NO];
}

- (IBAction)onSampleCityDataSource:(id)sender
{
    [self showItemPickerWithDataSources:[NSArray arrayWithObject:[[SampleCityDataSource alloc] init]] showCancelButton:YES];
}

- (IBAction)onMPMediaDataSource:(id)sender
{
    [self showItemPickerWithDataSources:[NSArray arrayWithObject:[[MPMediaDataSource alloc] init]] showCancelButton:NO];    
}

- (void)showItemPickerWithDataSources:(NSArray *)dataSources showCancelButton:(BOOL)showCancelButton
{
    ItemPicker *mediaPicker = [[ItemPicker alloc] initWithDataSources:dataSources];
    mediaPicker.delegate = self;
    mediaPicker.showCancelButton = showCancelButton;
    [self.navigationController presentModalViewController:mediaPicker.viewController animated:YES];    
}

- (void)onPickItem:(NSArray *)pickedItemContexts
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    NSString *selectionChain = @"";
    for (ItemPickerContext *ctx in pickedItemContexts)
    {
        selectionChain = [NSString stringWithFormat:@"%@->%@ (index %i)\n", selectionChain, ctx.selectedItem, ctx.selectedIndex];
    }
    [self.pickLabel setText:selectionChain];
}

- (void)onCancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];    
}

@end