// @author Simon Toens 04/21/13

#import "ItemPickerHeader.h"
#import "MPMediaDataSource.h"

@interface MPMediaDataSource() 
@property(nonatomic, strong) NSString *itemProperty;
- (id)initWithQuery:(MPMediaQuery *)runQuery itemProperty:(NSString *)itemProperty;
- (void)addFilterPredicates:(NSArray *)itemProperties toQuery:(MPMediaQuery *)query basedOnSelection:(ItemPickerContext *)selection;
- (void)addFilterPredicatesFromQuery:(MPMediaQuery *)fromQuery toQuery:(MPMediaQuery *)toQuery;
- (NSArray *)getItemImagesInRangeInternal:(NSRange)range;
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

- (ItemPickerHeader *)header
{
    if ([self songList] && [self.query.filterPredicates count] > 1)
    {
        int numSongs = self.count;
        NSRange range = NSMakeRange(0, numSongs);
        ItemPickerHeader *header = [[ItemPickerHeader alloc] init];
        header.defaultNilLabels = NO;
        header.image = kDefaultArtwork;
        for (UIImage *image in [self getItemImagesInRangeInternal:range])
        {
            if (image != kDefaultArtwork)
            {
                header.image = image;
                break;
            }
        }
        
        NSArray *properties = [NSArray arrayWithObjects:
            MPMediaItemPropertyArtist, MPMediaItemPropertyArtist, MPMediaItemPropertyAlbumTitle, nil];
        NSArray *values = [self getItemProperties:properties inRange:range];
        
        for (int i = 0; i < [values count]; i+=3)
        {
            if ([values objectAtIndex:i] != [NSNull null])
            {
                header.boldLabel = [values objectAtIndex:i];
            }
            if ([values objectAtIndex:i+1] != [NSNull null] && !header.boldLabel)
            {
                header.boldLabel = [values objectAtIndex:i+1];
            }
            if ([values objectAtIndex:i+2] != [NSNull null])
            {
                header.label = [values objectAtIndex:i+2];
            }
            if (header.boldLabel && header.label)
            {
                break;
            }
        }        
        header.smallerLabel = [NSString stringWithFormat:@"%i %@%@", numSongs, @"Song", numSongs > 1 ? @"s" : @""];
        return header;
    }
    return nil;
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    return [self albumList] ? [self getItemImagesInRangeInternal:range] : nil;
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    if ([self albumList])
    {
        return [self getItemProperties:[NSArray arrayWithObject:MPMediaItemPropertyArtist] inRange:range];
        
    } 
    else if ([self songList] && [self.query.filterPredicates count] == 1)
    {
        NSMutableArray *descriptions = [NSMutableArray arrayWithCapacity:range.length * 2];
        NSArray *properties = [NSArray arrayWithObjects:MPMediaItemPropertyArtist, MPMediaItemPropertyAlbumTitle, nil];
        NSArray *values = [self getItemProperties:properties inRange:range];
        for (int i = 0; i < [values count]; i+=2)
        {
            id artist = [values objectAtIndex:i];
            id album = [values objectAtIndex:i+1];
            artist = artist == [NSNull null] ? @"" : artist;
            album = album == [NSNull null] ? @"" : album;
            if ([artist length] == 0 || [album length] == 0)
            {
                [descriptions addObject:[artist length] > 0 ? artist : [album length] > 0 ? album : @""];
            }
            else 
            {
                [descriptions addObject:[NSString stringWithFormat:@"%@ - %@", artist, album]];
            }
        }
        return descriptions;
    }
    
    return nil;
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

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context 
                                       previousSelections:(NSArray *)previousSelections
{
    MPMediaQuery *nextQuery = nil;
    NSString *nextItemProperty = nil;
    if ([self artistList])
    {
        nextQuery = [MPMediaQuery albumsQuery];
        [self addFilterPredicates:[NSArray arrayWithObjects:MPMediaItemPropertyAlbumArtist, MPMediaItemPropertyArtist, nil] 
                          toQuery:nextQuery basedOnSelection:context];
        nextItemProperty = MPMediaItemPropertyAlbumTitle;
    }
    else if ([self albumList])
    {
        nextQuery = [MPMediaQuery songsQuery];
        [self addFilterPredicates:[NSArray arrayWithObject:MPMediaItemPropertyAlbumTitle] toQuery:nextQuery basedOnSelection:context];
        nextItemProperty = MPMediaItemPropertyTitle;
    }
    
    if (nextQuery)
    {        
        if ([previousSelections count] > 0)
        {
            // not a top level data source, carry over previous filters
            [self addFilterPredicatesFromQuery:self.query toQuery:nextQuery];
        }

        return [[MPMediaDataSource alloc] initWithQuery:nextQuery itemProperty:nextItemProperty];
    }

    return nil;
}

# pragma mark - Private methods

- (NSArray *)getItemImagesInRangeInternal:(NSRange)range
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

- (void)addFilterPredicates:(NSArray *)itemProperties toQuery:(MPMediaQuery *)query basedOnSelection:(ItemPickerContext *)selection
{
    MPMediaDataSource *dataSource = selection.dataSource;
    NSArray *propValues = [dataSource getItemProperties:itemProperties inRange:NSMakeRange(selection.selectedIndex, 1)];
    for (int i = 0; i < [itemProperties count]; i++)
    {
        id propValue = [propValues objectAtIndex:i];
        if (propValue == [NSNull null]) 
        {
            continue;
        }
        [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[propValues objectAtIndex:i]
                                                                   forProperty:[itemProperties objectAtIndex:i]]];
    }
}

- (void)addFilterPredicatesFromQuery:(MPMediaQuery *)fromQuery toQuery:(MPMediaQuery *)toQuery
{
    for (MPMediaPropertyPredicate *predicate in fromQuery.filterPredicates)
    {
        [toQuery addFilterPredicate:predicate];
    }
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
            id propVal = [item valueForProperty:property];
            [itemProperties addObject:propVal ? propVal : [NSNull null]];            
        }
    }
    
    return itemProperties;
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

@end
