// @author Simon Toens 04/21/13

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSString *itemProperty;
@property(nonatomic, strong) MPMediaQuery *query;
- (id)initWithQuery:(MPMediaQuery *)runQuery itemProperty:(NSString *)itemProperty;
- (BOOL)isArtistList;
- (BOOL)isAlbumList;
- (BOOL)isSongList;
- (NSArray *)getItemProperties:(NSArray *)properties inRange:(NSRange)range;

@end

@implementation MPMediaDataSource

static UIImage *kDefaultArtwork;

@synthesize itemProperty = _itemProperty;
@synthesize query = _query;

+ (void)initialize
{
    kDefaultArtwork = [UIImage imageNamed:@"DefaultNoArtwork.png"];
}

+ (id)artistsDataSource
{
    return [[MPMediaDataSource alloc] initWithQuery:[MPMediaQuery artistsQuery] itemProperty:MPMediaItemPropertyArtist];    
}

+ (id)albumsDataSource
{
    return [[MPMediaDataSource alloc] initWithQuery:[MPMediaQuery albumsQuery] itemProperty:MPMediaItemPropertyAlbumTitle];
}

+ (id)songsDataSource
{
    return [[MPMediaDataSource alloc] initWithQuery:[MPMediaQuery songsQuery] itemProperty:MPMediaItemPropertyTitle];
}

- (id)initWithQuery:(MPMediaQuery *)query itemProperty:(NSString *)itemProperty
{
    if (self = [super init])
    {
        _itemProperty = itemProperty;
        _query = query;
    }
    return self;
}

- (NSUInteger)count
{
    return [self.query.collections count];
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self getItemProperties:[NSArray arrayWithObject:self.itemProperty] inRange:range];
}

- (UIImage *)headerImage
{
    if ([self isSongList] && [self.query.filterPredicates count] > 1)
    {
        for (UIImage *image in [self getItemImagesInRange:NSMakeRange(0, self.count)])
        {
            if (image != kDefaultArtwork)
            {
                return image;
            }
        }
        return kDefaultArtwork;
        
    }
    return nil;
}

- (BOOL)itemsAlreadySorted
{
    return YES;
}

- (BOOL)itemImagesEnabled
{
    return [self isAlbumList];
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    NSArray *items = [self getItemProperties:[NSArray arrayWithObject:MPMediaItemPropertyArtwork] inRange:range];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[items count]];
    for (MPMediaItemArtwork *artwork in items)
    {
        CGSize size = artwork.bounds.size;
        UIImage *image = [artwork imageWithSize:CGSizeMake(size.height, size.width)];
        [images addObject:image ? image : kDefaultArtwork];
    }
    return images;
}

- (BOOL)itemDescriptionsEnabled
{
    return [self isAlbumList] || ([self isSongList] && [self.query.filterPredicates count] == 1);
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    if ([self isAlbumList])
    {
        return [self getItemProperties:[NSArray arrayWithObject:MPMediaItemPropertyArtist] inRange:range];
        
    } 
    else
    {
        NSMutableArray *descriptions = [NSMutableArray arrayWithCapacity:range.length * 2];
        NSArray *properties = [NSArray arrayWithObjects:MPMediaItemPropertyArtist, MPMediaItemPropertyAlbumTitle, nil];
        NSArray *values = [self getItemProperties:properties inRange:range];
        for (int i = 0; i < [values count]; i+=2)
        {
            [descriptions addObject:[NSString stringWithFormat:@"%@ - %@", [values objectAtIndex:i], [values objectAtIndex:i+1]]];
        }
        return descriptions;
    }
    
    return nil;
}

- (NSString *)title
{
    if ([self isArtistList])
    {
        return @"Artists";
    }
    else if ([self isAlbumList])
    {
        return @"Albums";
    }
    else 
    {
        return @"Songs";
    }
}

- (BOOL)sectionsEnabled
{
    return [self.query.collections count] > 50;
}

- (NSArray *)sections
{
    return self.query.collectionSections;
}

- (BOOL)autoSelectSingleItem
{
    return [self isAlbumList];
}

- (UIImage *)tabImage
{
    if ([self isArtistList])
    {
        return [UIImage imageNamed:@"Artists.png"];
    }
    else if ([self isAlbumList])
    {
        return [UIImage imageNamed:@"Albums.png"];        
    } 
    else
    {
        return [UIImage imageNamed:@"Songs.png"];                
    }
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context 
                                       previousSelections:(NSArray *)previousSelections
{
    if ([self isArtistList])
    {
        MPMediaQuery *nextQuery = [MPMediaQuery albumsQuery];
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:context.selectedItem 
                                                                       forProperty:MPMediaItemPropertyArtist]];
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyAlbumTitle];
    }
    else if ([self isAlbumList])
    {
        MPMediaQuery *nextQuery = [MPMediaQuery songsQuery];        
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:context.selectedItem 
                                                                       forProperty:MPMediaItemPropertyAlbumTitle]];
        
        if ([previousSelections count] > 0)
        {
            [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[[previousSelections lastObject] selectedItem]
                                                                           forProperty:MPMediaItemPropertyArtist]];
        }
        
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyTitle];
    }
    return nil;
}

- (NSArray *)getItemProperties:(NSArray *)properties inRange:(NSRange)range
{
    NSMutableArray *itemProperties = [NSMutableArray arrayWithCapacity:range.length * [properties count]];
    for (int i = range.location; i < range.location + range.length; i++)
    {
        MPMediaItemCollection *collection  = [self.query.collections objectAtIndex:i];
        MPMediaItem *item = [collection representativeItem];
        for (NSString *property in properties)
        {
            [itemProperties addObject:[item valueForProperty:property]];
        }
    }
    return itemProperties;
}

- (BOOL)isArtistList
{
    return self.query.groupingType == MPMediaGroupingArtist;
}

- (BOOL)isAlbumList
{
    return self.query.groupingType == MPMediaGroupingAlbum;
}

- (BOOL)isSongList 
{
    return self.query.groupingType == MPMediaGroupingTitle;
}

@end