// @author Simon Toens 04/21/13

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSArray *images;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSArray *sections;

@property(nonatomic, strong) NSString *itemProperty;
@property(nonatomic, strong) MPMediaQuery *query;
- (id)initWithQuery:(MPMediaQuery *)runQuery itemProperty:(NSString *)itemProperty;
- (void)runQuery;
@end

@implementation MPMediaDataSource

@synthesize images = _images;
@synthesize itemProperty = _itemProperty;
@synthesize query = _query;

@synthesize items = _items;
@synthesize sections = _sections;

- (id)init
{
    return [self initWithQuery:[MPMediaQuery artistsQuery] itemProperty:MPMediaItemPropertyArtist];    
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

- (NSArray *)items
{
    [self runQuery];
    return _items;
}

- (NSArray *)itemImages
{
    [self runQuery];
    return _images;
}

- (NSString *)title
{
    return @"Artists";
}

- (BOOL)sectionsEnabled
{
    return self.query.groupingType == MPMediaGroupingArtist;
}

- (NSArray *)sections
{
    return _sections;
}

- (BOOL)itemsAlreadySorted
{
    return YES;
}

- (BOOL)autoSelectSingleItem
{
    return self.query.groupingType == MPMediaGroupingAlbum;
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item
{
    if (self.query.groupingType == MPMediaGroupingArtist)
    {
        MPMediaQuery *nextQuery = [MPMediaQuery albumsQuery];
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:item forProperty:MPMediaItemPropertyArtist]];
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyAlbumTitle];
    }
    else if (self.query.groupingType == MPMediaGroupingAlbum)
    {
        MPMediaQuery *nextQuery = [MPMediaQuery songsQuery];        
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:item forProperty:MPMediaItemPropertyAlbumTitle]];
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyTitle];
    }
    return nil;
}

- (void)runQuery
{
    if (_items)
    {
        // already ran the query
        return;    
    }
    
    NSArray *mediaItems = _query.collections;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[mediaItems count]];
    NSMutableArray *images = nil;
    BOOL loadImages = _query.groupingType == MPMediaGroupingAlbum;
    if (loadImages)
    {
        images = [NSMutableArray arrayWithCapacity:[mediaItems count]];
    }
    
    _sections = _query.collectionSections;
    for (MPMediaItemCollection *collection in mediaItems)
    {
        MPMediaItem *item = [collection representativeItem];
        [items addObject:[item valueForProperty:_itemProperty]];
        if (loadImages)
        {
            MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
            CGSize size = artwork.bounds.size;
            [images addObject:[artwork imageWithSize:CGSizeMake(size.height, size.width)]];
        }
    }
    
    _images = images;
    _items = items;
}

@end