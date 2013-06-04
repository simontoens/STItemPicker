// @author Simon Toens 03/03/13

#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "MPMediaDataSource.h"
#import "SampleMediaDataSource.h"
#import "SampleCityDataSource.h"
#import "TestViewController.h"


@interface TestViewController()
@property(nonatomic, weak) IBOutlet UILabel *pickLabel;
@property(nonatomic, strong) ItemPicker *sampleMediaItemPicker;
- (ItemPicker *)getItemPickerWithDataSources:(NSArray *)dataSources;
@end

@implementation TestViewController

@synthesize pickLabel;
@synthesize sampleMediaItemPicker;

- (IBAction)onSampleCityDataSource:(id)sender
{
    ItemPicker *itemPicker = [self getItemPickerWithDataSources:[NSArray arrayWithObject:[[SampleCityDataSource alloc] init]]];
    itemPicker.showCancelButton = YES;
    [self.navigationController presentModalViewController:itemPicker.viewController animated:YES];        
}

- (IBAction)onSampleMediaDataSource:(id)sender 
{
    if (!self.sampleMediaItemPicker)
    {
        self.sampleMediaItemPicker = [self getItemPickerWithDataSources:
                                         [NSArray arrayWithObjects:
                                             [SampleMediaDataSource artistsDataSource], 
                                             [SampleMediaDataSource albumsDataSource],
                                             [SampleMediaDataSource songsDataSource], 
                                             nil]];
        self.sampleMediaItemPicker.maxSelectableItems = 3;
    }

    [self.navigationController presentModalViewController:self.sampleMediaItemPicker.viewController animated:YES];    
}

- (IBAction)onMPMediaDataSource:(id)sender
{
    ItemPicker *itemPicker = [self getItemPickerWithDataSources:
                                 [NSArray arrayWithObjects:
                                     [[MPMediaDataSource alloc] initArtistsDataSource],
                                     [[MPMediaDataSource alloc] initAlbumsDataSource],
                                     [[MPMediaDataSource alloc] initSongsDataSource],
                                     nil]];
    [self.navigationController presentModalViewController:itemPicker.viewController animated:YES];        
}

- (ItemPicker *)getItemPickerWithDataSources:(NSArray *)dataSources
{
    ItemPicker *itemPicker = [[ItemPicker alloc] initWithDataSources:dataSources];
    itemPicker.delegate = self;
    return itemPicker;
}

- (void)onPickItems:(NSArray *)pickedItemContexts
{
    self.pickLabel.text = @"";
    [self.navigationController dismissModalViewControllerAnimated:YES];
    int selectionCounter = 1;
    for (NSArray *selections in pickedItemContexts)
    {
        NSString *s = [NSString stringWithFormat:@"%@Selection %i: ", self.pickLabel.text, selectionCounter++];
        for (ItemPickerContext *ctx in selections)
        {
            s = [NSString stringWithFormat:@"%@->%@ (index %i)\n", s, ctx.selectedItem, ctx.selectedIndex];
        }
        self.pickLabel.text = s;
    }
}

- (void)onCancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];    
}

@end