// @author Simon Toens 04/21/13

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSArray *sections;
@end

@implementation MPMediaDataSource

@synthesize sections = _sections;

- (NSArray *)items
{
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    NSArray *mediaItems = songsQuery.items;
    self.sections = songsQuery.itemSections;
    NSMutableArray *songTitles = [NSMutableArray arrayWithCapacity:[mediaItems count]];
    for (MPMediaItem *item in mediaItems)
    {
        [songTitles addObject:[item valueForProperty:MPMediaItemPropertyTitle]];
    }
    return songTitles;
}

- (NSString *)title
{
    return @"Songs";
}

- (BOOL)sectionsEnabled
{
    return YES;
}

- (NSArray *)sections
{
    return _sections;
}

- (BOOL)itemsAlreadySorted
{
    return YES;
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item
{
    return nil;
}

@end