// @author Simon Toens 01/24/14

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSourceTest : XCTestCase

@end

@interface MPMediaDataSource()
- (id)initWithQuery:(MPMediaQuery *)query itemProperty:(NSString *)itemProperty showAllSongs:(BOOL)showAllSongs;
@end

@implementation MPMediaDataSourceTest

- (void)testArtistList
{
    NSArray *artists = @[@"Oasis", @"Blur", @"Dodgy"];
    MPMediaQuery *query = [self mockQuery:@{MPMediaItemPropertyArtist : artists} groupingType:MPMediaGroupingArtist];
    MPMediaDataSource *dataSource = [[MPMediaDataSource alloc] initWithQuery:query itemProperty:MPMediaItemPropertyArtist showAllSongs:NO];
    [self assertDataSource:dataSource expectedItems:artists expectedDescriptions:nil];
}

- (void)testAlbumsList
{
    NSArray *albums = @[@"Definitely Maybe", @"Parklife", @"Homegrown"];
    NSArray *artists = @[@"Oasis", @"Blur", @"Dodgy"];
    MPMediaQuery *query = [self mockQuery:@{MPMediaItemPropertyAlbumTitle : albums,
                                            MPMediaItemPropertyArtwork : [NSNull null],
                                            MPMediaItemPropertyArtist : artists}
                             groupingType:MPMediaGroupingAlbum];
    MPMediaDataSource *dataSource = [[MPMediaDataSource alloc] initWithQuery:query itemProperty:MPMediaItemPropertyAlbumTitle showAllSongs:NO];
    [self assertDataSource:dataSource expectedItems:albums expectedDescriptions:artists];
}

- (void)testSongsList
{
    NSArray *songs = @[@"Telegraph Road", @"Flick of the Finger", @"Recoil"];
    NSArray *albums = @[@"Love Over Gold", @"Be", @"Lost Sirens"];
    NSArray *artists = @[@"Dire Straits", @"Beady Eye", @"No Order"];
    MPMediaQuery *query = [self mockQuery:@{MPMediaItemPropertyTitle : songs,
                                            MPMediaItemPropertyAlbumTitle : albums,
                                            MPMediaItemPropertyArtwork : [NSNull null],
                                            MPMediaItemPropertyArtist : artists}
                             groupingType:MPMediaGroupingTitle];
    MPMediaDataSource *dataSource = [[MPMediaDataSource alloc] initWithQuery:query itemProperty:MPMediaItemPropertyTitle showAllSongs:YES];
    NSArray *expectedDescriptions = @[@"Dire Straits - Love Over Gold", @"Beady Eye - Be", @"No Order - Lost Sirens"];
    [self assertDataSource:dataSource expectedItems:songs expectedDescriptions:expectedDescriptions];
}

- (void)testSongsListWithMissingArtistsAndAlbums
{
    NSArray *songs = @[@"Telegraph Road", @"Flick of the Finger", @"Recoil"];
    NSArray *albums = @[@"Love Over Gold", [NSNull null], @"Lost Sirens"];
    NSArray *artists = @[[NSNull null], [NSNull null], @"No Order"];
    MPMediaQuery *query = [self mockQuery:@{MPMediaItemPropertyTitle : songs,
                                            MPMediaItemPropertyAlbumTitle : albums,
                                            MPMediaItemPropertyArtwork : [NSNull null],
                                            MPMediaItemPropertyArtist : artists}
                             groupingType:MPMediaGroupingTitle];
    MPMediaDataSource *dataSource = [[MPMediaDataSource alloc] initWithQuery:query itemProperty:MPMediaItemPropertyTitle showAllSongs:YES];
    NSArray *expectedDescriptions = @[@"Love Over Gold", @"", @"No Order - Lost Sirens"];
    [self assertDataSource:dataSource expectedItems:songs expectedDescriptions:expectedDescriptions];
}

- (void)assertDataSource:(MPMediaDataSource *)dataSource expectedItems:(NSArray *)expectedItems expectedDescriptions:(NSArray *)expectedDescriptions
{
    for (int i = 0; i < [expectedItems count]; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        [dataSource initForRange:range];
        
        NSArray *items = [dataSource getItemsInRange:range];
        XCTAssertEqual([items count], (NSUInteger)1, @"Bad number of items returned");
        XCTAssertEqualObjects([items objectAtIndex:0], expectedItems[i], @"Bad item value");

        NSArray *descriptions = [dataSource getItemDescriptionsInRange:range];
        if (expectedDescriptions)
        {
            XCTAssertEqual([descriptions count], (NSUInteger)1, @"Bad number of descriptions returned");
            XCTAssertEqualObjects([descriptions objectAtIndex:0], expectedDescriptions[i], @"Bad description value");
        }
        else
        {
            XCTAssertNil(descriptions, @"Expected descriptions to be nil but they were %@", descriptions);
        }
    }
}

- (MPMediaQuery *)mockQuery:(NSDictionary *)propertyNameToPropertyValues groupingType:(NSUInteger)groupingType
{
    int itemIndex = 0;
    NSMutableArray *collections = [[NSMutableArray alloc] init];
    BOOL done = NO;
    while (!done)
    {
        MPMediaItem *mediaItem = [OCMockObject mockForClass:[MPMediaItem class]];
        MPMediaItemCollection *collection = [self mockMediaItemCollectionWithRepresentativeItem:mediaItem];
        [collections addObject:collection];
        for (NSString *propertyName in [propertyNameToPropertyValues keyEnumerator])
        {
            NSArray *propertyValues = [propertyNameToPropertyValues objectForKey:propertyName];
            if (![propertyValues isEqual:[NSNull null]] && itemIndex == [propertyValues count])
            {
                done = YES;
                break;
            }
            NSString *propertyValue = [propertyValues isEqual:[NSNull null]] ? nil : [propertyValues objectAtIndex:itemIndex];
            propertyValue = [propertyValue isEqual:[NSNull null]] ? nil : propertyValue;
            [[[((id)mediaItem) stub] andReturn:propertyValue] valueForProperty:propertyName];
        }
        itemIndex += 1;
    }
    return [self mockMediaQueryWithCollections:collections groupingType:groupingType];
}

- (MPMediaQuery *)mockMediaQueryWithCollections:(NSArray *)collections groupingType:(MPMediaGrouping)grouping
{
    MPMediaQuery *query = [OCMockObject mockForClass:[MPMediaQuery class]];
    [[[((id)query) stub] andReturn:collections] collections];
    [[[((id)query) stub] andReturnValue:[NSNumber numberWithInt:grouping]] groupingType];
    [[[((id)query) stub] andReturn:[NSArray array]] filterPredicates];
    return query;
}

- (MPMediaItemCollection *)mockMediaItemCollectionWithRepresentativeItem:(MPMediaItem *)representativeItem
{
    MPMediaItemCollection *mediaCollection = [OCMockObject mockForClass:[MPMediaItemCollection class]];
    [[[((id)mediaCollection) stub] andReturn:representativeItem] representativeItem];
    return mediaCollection;
}

@end
