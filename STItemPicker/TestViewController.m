// @author Simon Toens 03/03/13

#import "ItemPickerViewController.h"
#import "TestViewController.h"
#import "SampleItemPickerDataSource.h"

@interface TestViewController()
@property(nonatomic, weak) IBOutlet UILabel *pickLabel;
@end

@implementation TestViewController

@synthesize pickLabel;

- (IBAction)onClick:(id)sender 
{
    ItemPicker *mediaPicker = [[ItemPicker alloc] initWithDataSource:[[SampleItemPickerDataSource alloc] init]];
    mediaPicker.delegate = self;
    [self.navigationController presentModalViewController:mediaPicker.viewController animated:YES];
}

- (void)pickedItem:(NSString *)item 
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.pickLabel setText:[NSString stringWithFormat:@"%@\n%@", self.pickLabel.text, item]];
}

@end