// @author Simon Toens 04/21/13

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaDataSource.h"

@implementation MPMediaDataSource

- (NSArray *)items
{
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    NSArray *mediaItems = songsQuery.items;
    NSLog(@"%@", songsQuery.itemSections);
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
    return NO;
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