// @author Simon Toens 03/03/13

#import "ItemPickerViewController.h"
#import "SampleMediaDataSource.h"
#import "SampleCityDataSource.h"
#import "TestViewController.h"


@interface TestViewController()
@property(nonatomic, weak) IBOutlet UILabel *pickLabel;
- (void)showItemPickerWithDataSources:(NSArray *)dataSources;
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
            nil]];
}

- (IBAction)onSampleCityDataSource:(id)sender
{
    [self showItemPickerWithDataSources:[NSArray arrayWithObject:[[SampleCityDataSource alloc] init]]];
}

- (void)showItemPickerWithDataSources:(NSArray *)dataSources
{
    ItemPicker *mediaPicker = [[ItemPicker alloc] initWithDataSources:dataSources];
    mediaPicker.delegate = self;
    [self.navigationController presentModalViewController:mediaPicker.viewController animated:YES];    
}

- (void)pickedItem:(NSString *)item atIndex:(NSUInteger)index; 
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    if ([self.pickLabel.text length] == 0) {
        [self.pickLabel setText:@"Picked:"];
    }
    [self.pickLabel setText:[NSString stringWithFormat:@"%@\n%@ at %i", self.pickLabel.text, item, index]];
}

@end