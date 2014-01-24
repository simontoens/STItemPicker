// @author Simon Toens 01/24/14

#import <OCMock/OCMock.h>
#import <SenTestingKit/SenTestingKit.h>
#import "MPMediaDataSource.h"

@interface MPMediaDataSourceTest : SenTestCase

@end

@interface MPMediaDataSource()
- (id)initWithQuery:(MPMediaQuery *)query itemProperty:(NSString *)itemProperty;
@end

@implementation MPMediaDataSourceTest

- (void)testNilItem
{
    NSString * const property = MPMediaItemPropertyArtist;
    
    MPMediaItem *mediaItem = [OCMockObject mockForClass:[MPMediaItem class]];
    [[[((id)mediaItem) stub] andReturn:nil] valueForProperty:property];
    
    MPMediaItemCollection *mediaCollection = [OCMockObject mockForClass:[MPMediaItemCollection class]];
    [[[((id)mediaCollection) stub] andReturn:mediaItem] representativeItem];
    NSArray *mediaCollections = @[mediaCollection];
    
    MPMediaQuery *query = [OCMockObject mockForClass:[MPMediaQuery class]];
    [[[((id)query) stub] andReturn:mediaCollections] collections];
    [[[((id)query) stub] andReturnValue:[NSNumber numberWithInt:MPMediaGroupingAlbum]] groupingType];
    
    MPMediaDataSource *dataSource = [[MPMediaDataSource alloc] initWithQuery:query itemProperty:property];

    [dataSource description];
    //[dataSource initForRange:NSMakeRange(0, 1)];
}

@end
