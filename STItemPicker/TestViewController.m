// @author Simon Toens 03/03/13

#import "ItemPickerViewController.h"
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

- (void)showItemPickerWithDataSources:(NSArray *)dataSources showCancelButton:(BOOL)showCancelButton
{
    ItemPicker *mediaPicker = [[ItemPicker alloc] initWithDataSources:dataSources];
    mediaPicker.delegate = self;
    mediaPicker.showCancelButton = showCancelButton;
    [self.navigationController presentModalViewController:mediaPicker.viewController animated:YES];    
}

- (void)onPickItem:(NSString *)item atIndex:(NSUInteger)index; 
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    if ([self.pickLabel.text length] == 0) {
        [self.pickLabel setText:@"Picked:"];
    }
    [self.pickLabel setText:[NSString stringWithFormat:@"%@\n%@ at %i", self.pickLabel.text, item, index]];
}

- (void)onCancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];    
}

@end