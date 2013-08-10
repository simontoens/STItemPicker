// @author Simon Toens 04/21/13

#import "ItemPicker.h"
#import "ItemPickerHeader.h"
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSString *itemProperty;
- (id)initWithQuery:(MPMediaQuery *)runQuery itemProperty:(NSString *)itemProperty;
- (void)addFilterPredicates:(NSArray *)itemProperties toQuery:(MPMediaQuery *)query basedOnSelection:(ItemPickerSelection *)selection;
- (void)addFilterPredicatesFromQuery:(MPMediaQuery *)fromQuery toQuery:(MPMediaQuery *)toQuery;
- (UIImage *)getMediaItemAlbumImage:(MPMediaItem *)item;
- (void)registerForLibraryChangeNotifications;
- (void)unregisterForLibraryChangeNotifications;

@property(nonatomic, assign) BOOL showAllSongs;
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) NSMutableArray *itemDescriptions;
@property(nonatomic, strong) NSMutableArray *itemImages;

@end

@implementation MPMediaDataSource

@synthesize showAllSongs = _showAllSongs;
@synthesize items = _items;
@synthesize itemDescriptions = _itemDescriptions;
@synthesize itemImages = _itemImages;

static UIImage *kDefaultArtwork;

@synthesize itemProperty = _itemProperty;
@synthesize query = _query;


#pragma mark - Initializers/Dealloc

+ (void)initialize
{
    kDefaultArtwork = [UIImage imageNamed:@"DefaultNoArtwork.png"];
}

- (id)initArtistsDataSource
{
    return [self initWithQuery:[MPMediaQuery artistsQuery] itemProperty:MPMediaItemPropertyArtist];    
}

- (id)initAlbumsDataSource
{
    return [self initWithQuery:[MPMediaQuery albumsQuery] itemProperty:MPMediaItemPropertyAlbumTitle];
}

- (id)initSongsDataSource
{
    return [self initWithQuery:[MPMediaQuery songsQuery] itemProperty:MPMediaItemPropertyTitle];
}

- (id)initWithQuery:(MPMediaQuery *)query itemProperty:(NSString *)itemProperty
{
    if (self = [super init])
    {
        _showAllSongs = NO;
        _itemProperty = itemProperty;
        _query = query;
        [self registerForLibraryChangeNotifications];
        
    }
    return self;
}

- (void)dealloc
{
    [self unregisterForLibraryChangeNotifications];
}

#pragma mark - ItemPickerDataSource Protocol conformance

- (NSUInteger)count
{
    return [self.query.collections count];
}

- (ItemPickerHeader *)header
{
    if ([self songList] && [self.query.filterPredicates count] > 1 && !self.showAllSongs)
    {
        int numSongs = self.count;
        ItemPickerHeader *header = [[ItemPickerHeader alloc] init];
        header.defaultNilLabels = NO;
        MPMediaItemCollection *collection  = [self.query.collections objectAtIndex:0];
        MPMediaItem *item = [collection representativeItem];
        header.image = [self getMediaItemAlbumImage:item];
        header.boldLabel = [item valueForProperty:MPMediaItemPropertyArtist];
        header.label = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        header.smallerLabel = [NSString stringWithFormat:@"%i %@%@", numSongs, @"Song", numSongs > 1 ? @"s" : @""];
        return header;
    }
    return nil;
}

- (void)initForRange:(NSRange)range
{
    _items = [[NSMutableArray alloc] initWithCapacity:range.length];
    _itemDescriptions = [[NSMutableArray alloc] initWithCapacity:range.length];
    _itemImages = [[NSMutableArray alloc] initWithCapacity:range.length];
    
    for (int i = range.location; i < range.location + range.length; i++)
    {
        MPMediaItemCollection *collection  = [self.query.collections objectAtIndex:i];
        MPMediaItem *item = [collection representativeItem];
        [_items addObject:[item valueForProperty:_itemProperty]];
        
        NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
        NSString *album = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
        
        if ([self albumList]) 
        {
            [_itemImages addObject:[self getMediaItemAlbumImage:item]];
            
            [_itemDescriptions addObject:artist];
        }
        else if ([self songList] && ([self.query.filterPredicates count] == 1 || self.showAllSongs))
        {
            artist = artist ? artist : @"";
            album = album ? album : @"";
            if ([artist length] == 0 || [album length] == 0)
            {
                [_itemDescriptions addObject:[artist length] > 0 ? artist : [album length] > 0 ? album : @""];
            }
            else
            {
                [_itemDescriptions addObject:[NSString stringWithFormat:@"%@ - %@", artist, album]];
            }
        }
    }
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return self.items;
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    return [self.itemImages count] > 0 ? self.itemImages : nil;
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    return [self.itemDescriptions count] > 0 ? self.itemDescriptions : nil;
}

- (BOOL)isLeaf
{
    return [self songList];
}

- (NSString *)title
{
    if ([self artistList])
    {
        return @"Artists";
    }
    else if ([self albumList])
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
    return [self albumList];
}

- (NSString *)metaCellTitle
{
    return [self albumList] && [self.query.filterPredicates count] > 1 ? @"All Songs" : nil;
}

- (UIImage *)tabImage
{
    if ([self artistList])
    {
        return [UIImage imageNamed:@"Artists.png"];
    }
    else if ([self albumList])
    {
        return [UIImage imageNamed:@"Albums.png"];        
    } 
    else
    {
        return [UIImage imageNamed:@"Songs.png"];                
    }
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)selection 
                                       previousSelections:(NSArray *)previousSelections
{
    MPMediaQuery *nextQuery = nil;
    NSString *nextItemProperty = nil;
    if ([self artistList])
    {
        nextQuery = [MPMediaQuery albumsQuery];
        [self addFilterPredicates:[NSArray arrayWithObjects:MPMediaItemPropertyAlbumArtist, MPMediaItemPropertyArtist, nil] 
                          toQuery:nextQuery basedOnSelection:selection];
        nextItemProperty = MPMediaItemPropertyAlbumTitle;
    }
    else if ([self albumList])
    {
        nextQuery = [MPMediaQuery songsQuery];
        if (!selection.metaCell)
        {
            [self addFilterPredicates:[NSArray arrayWithObject:MPMediaItemPropertyAlbumTitle] 
                              toQuery:nextQuery basedOnSelection:selection];
        }
        nextItemProperty = MPMediaItemPropertyTitle;
    }
    
    if (nextQuery)
    {        
        if ([previousSelections count] > 0)
        {
            // not a top level data source, carry over previous filters
            [self addFilterPredicatesFromQuery:self.query toQuery:nextQuery];
        }

        MPMediaDataSource *nextDataSource = [[[self class] alloc] initWithQuery:nextQuery itemProperty:nextItemProperty];
        nextDataSource.showAllSongs = selection.metaCell;
        return nextDataSource;
    }

    return nil;
}

# pragma mark - Private methods

- (void)addFilterPredicates:(NSArray *)itemProperties toQuery:(MPMediaQuery *)query basedOnSelection:(ItemPickerSelection *)selection
{
    MPMediaDataSource *dataSource = selection.dataSource;    
    MPMediaItemCollection *collection  = [dataSource.query.collections objectAtIndex:selection.selectedIndex];
    MPMediaItem *item = [collection representativeItem];
    for (NSString *property in itemProperties)
    {
        NSString *propertyValue = [item valueForProperty:property];
        if (propertyValue)
        {
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:propertyValue forProperty:property]];
        }
    }
}

- (void)addFilterPredicatesFromQuery:(MPMediaQuery *)fromQuery toQuery:(MPMediaQuery *)toQuery
{
    for (MPMediaPropertyPredicate *predicate in fromQuery.filterPredicates)
    {
        [toQuery addFilterPredicate:predicate];
    }
}

- (UIImage *)getMediaItemAlbumImage:(MPMediaItem *)item
{
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    CGSize size = artwork.bounds.size;
    UIImage *image = [artwork imageWithSize:CGSizeMake(size.height, size.width)];
    return image ? image : kDefaultArtwork;
}

- (BOOL)artistList
{
    return self.query.groupingType == MPMediaGroupingArtist;
}

- (BOOL)albumList
{
    return self.query.groupingType == MPMediaGroupingAlbum;
}

- (BOOL)songList 
{
    return self.query.groupingType == MPMediaGroupingTitle;
}

- (void)onLibraryChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ItemPickerDataSourceDidChangeNotification object:nil];
}

- (void)registerForLibraryChangeNotifications
{
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(onLibraryChanged) name:MPMediaLibraryDidChangeNotification object:nil];
}

- (void)unregisterForLibraryChangeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
}

@end