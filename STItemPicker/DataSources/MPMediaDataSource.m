// @author Simon Toens 04/21/13

#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSArray *sections;

@property(nonatomic, strong) NSString *itemProperty;
@property(nonatomic, strong) MPMediaQuery *query;
- (id)initWithQuery:(MPMediaQuery *)runQuery itemProperty:(NSString *)itemProperty;
- (void)runQuery;
@end

@implementation MPMediaDataSource

@synthesize  itemProperty = _itemProperty;
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

- (NSString *)title
{
    return @"Artists";
}

- (BOOL)sectionsEnabled
{
    BOOL sectionsEnabled = self.query.groupingType == MPMediaGroupingArtist;
    return sectionsEnabled;
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
    MPMediaGrouping grouping = self.query.groupingType;
    if (grouping == MPMediaGroupingArtist)
    {
        MPMediaQuery *nextQuery = [MPMediaQuery albumsQuery];
        [nextQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:item forProperty:MPMediaItemPropertyArtist]];
        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:MPMediaItemPropertyAlbumTitle];
    }
    return nil;
}

- (void)runQuery
{
    BOOL collections = [_query.filterPredicates count] > 0;
    NSArray *mediaItems = collections ? _query.collections : _query.items;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[mediaItems count]];    
    if (collections) 
    {
        _sections = _query.collectionSections;
        for (MPMediaItemCollection *collection in mediaItems)
        {
            MPMediaItem *item = [collection representativeItem];
            [items addObject:[item valueForProperty:_itemProperty]];
            continue;
        }
    }
    else
    {
        _sections = _query.itemSections;
        for (MPMediaItem *item in mediaItems)
        {
            [items addObject:[item valueForProperty:_itemProperty]];
        }
    }
    _items = items;
}

@end