// @author Simon Toens 03/03/13

#import "ItemPickerSelection.h"
#import "ItemPickerViewController.h"
#import "MPMediaDataSource.h"
#import "SampleMediaDataSource.h"
#import "SampleCityDataSource.h"
#import "TestViewController.h"


@interface TestViewController()
@property(nonatomic, weak) IBOutlet UILabel *pickLabel;
@property(nonatomic, strong) ItemPicker *sampleCityItemPicker;
@property(nonatomic, strong) ItemPicker *sampleMediaItemPicker;
- (ItemPicker *)getItemPickerWithDataSources:(NSArray *)dataSources;
@end

@implementation TestViewController

@synthesize pickLabel;
@synthesize sampleCityItemPicker;
@synthesize sampleMediaItemPicker;

- (IBAction)onSampleCityDataSource:(id)sender
{
    if (!self.sampleCityItemPicker)
    {
        self.sampleCityItemPicker = [self getItemPickerWithDataSources:@[[[SampleCityDataSource alloc] init]]];
    }
    
    [self.navigationController presentViewController:self.sampleCityItemPicker.viewController animated:YES completion:NULL];
}

- (IBAction)onAddCityToSampleCityDataSource:(id)sender
{
    NSString *city = [SampleCityDataSource addCityToOregon];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Added city"
                                message:city
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onRemoveCityToSampleCityDataSource:(id)sender
{
    NSString *city = [SampleCityDataSource removeCityFromOregon];
    UIAlertController *alert;
    if (city)
    {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Removed city"
                 message:city
                 preferredStyle:UIAlertControllerStyleAlert];
    }
    else
    {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Error"
                 message:@"No city left to remove"
                 preferredStyle:UIAlertControllerStyleAlert];
    }

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

    
}

- (IBAction)onSampleMediaDataSource:(id)sender 
{
    if (!self.sampleMediaItemPicker)
    {
        self.sampleMediaItemPicker = [self getItemPickerWithDataSources:
                                         @[[SampleMediaDataSource artistsDataSource],
                                           [SampleMediaDataSource albumsDataSource],
                                           [SampleMediaDataSource songsDataSource]]];
        self.sampleMediaItemPicker.maxSelectableItems = 3;
    }

    [self.navigationController presentViewController:self.sampleMediaItemPicker.viewController animated:YES completion:NULL];
}

- (IBAction)onMPMediaDataSource:(id)sender
{
    ItemPicker *itemPicker = [self getItemPickerWithDataSources:
                                 @[[[MPMediaDataSource alloc] initArtistDataSource],
                                    [[MPMediaDataSource alloc] initAlbumDataSource],
                                    [[MPMediaDataSource alloc] initSongDataSource],
                                    [[MPMediaDataSource alloc] initPlaylistDataSource]]];
    itemPicker.showDoneButton = YES;
    itemPicker.itemLoadRangeLength = 100;
    [self.navigationController presentViewController:itemPicker.viewController animated:YES completion:NULL];
}

- (IBAction)onReloadDataSource:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ItemPickerDataSourceDidChangeNotification object:nil];
}

- (ItemPicker *)getItemPickerWithDataSources:(NSArray *)dataSources
{
    ItemPicker *itemPicker = [[ItemPicker alloc] initWithDataSources:dataSources];
    itemPicker.delegate = self;
    return itemPicker;
}

- (void)onItemPickerPickedItems:(NSArray *)pickedItemSelections
{
    self.pickLabel.text = @"";
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    int selectionCounter = 1;
    for (NSArray *selections in pickedItemSelections)
    {
        NSString *s = [NSString stringWithFormat:@"%@Selection %i: ", self.pickLabel.text, selectionCounter++];
        for (ItemPickerSelection *ctx in selections)
        {
            s = [NSString stringWithFormat:@"%@->%@ (index %lu%@)\n", s, ctx.selectedItem, (unsigned long)ctx.selectedIndex, ctx.autoSelected ? @" auto" : @""];
        }
        self.pickLabel.text = s;
    }
}

- (void)onItemPickerCanceled
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
