// @author Simon Toens 03/23/13

#import <SenTestingKit/SenTestingKit.h>
#import "TableSectionHandler.h"
#import "Tuple.h"

@interface TableSectionHandlerTest : SenTestCase
- (void)runTestItems:(NSArray *)items 
    expectedSections:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts
  itemsAlreadySorted:(BOOL)itemsAlreadySorted;
@end

@implementation TableSectionHandlerTest

- (void)testBasicSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"a", @"b", @"c", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 1}
    itemsAlreadySorted:YES];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"bb", @"cc", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 1}
    itemsAlreadySorted:YES];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"bb", @"cc", @"ccc", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 2}
    itemsAlreadySorted:YES];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"AABB", @"AACC", @"cc", @"ccc", @"CCCAABB", nil]
      expectedSections:[NSArray arrayWithObjects:@"A",@"C", nil]
    expectedItemCounts:(int[]){3, 3}
    itemsAlreadySorted:YES];
}

- (void)testNonEnglishAlphabetSections
{
    [self runTestItems:[NSArray arrayWithObjects:@"äa", @"ÄB", @"üC", @"Ücc", @"あんまり覚えてないや", @"öc", @"ÖB", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"O", @"U", kTableSectionHandlerNonLatinLetterSymbolHeader, nil]
    expectedItemCounts:(int[]){2, 2, 2, 1}
    itemsAlreadySorted:NO];
    
    [self runTestItems:[NSArray arrayWithObjects:@"(äÄÜ)", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", nil]
    expectedItemCounts:(int[]){1}
    itemsAlreadySorted:NO];
}

- (void)testNumberSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"3", @"3003", nil]
      expectedSections:[NSArray arrayWithObjects:kTableSectionHandlerNumberHeader, nil]
    expectedItemCounts:(int[]){2}
    itemsAlreadySorted:YES];
}

- (void)testSymbolSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"*a", @"(zzz)", @"!44", @"@444", @"%$#", nil]
      expectedSections:[NSArray arrayWithObjects:kTableSectionHandlerSymbolHeader, kTableSectionHandlerNumberHeader, @"A", @"Z", nil]
    expectedItemCounts:(int[]){1, 2, 1, 1}
    itemsAlreadySorted:NO];    
}

- (void)testAllLetters 
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    STAssertEquals([alphabet length], (NSUInteger)26, @"bad number of letters");
    NSMutableArray *lowerCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    NSMutableArray *upperCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    int counts[[alphabet length]];
    for (int i = 0; i < [alphabet length]; i++) 
    {
        NSRange r;
        r.location = i;
        r.length = 1;
        counts[i] = 1;
        NSString *letter = [alphabet substringWithRange:r];
        [lowerCaseItems addObject:[letter lowercaseString]];
        [upperCaseItems addObject:[letter uppercaseString]];
    }

    [self runTestItems:lowerCaseItems expectedSections:upperCaseItems expectedItemCounts:counts itemsAlreadySorted:YES];
    [self runTestItems:upperCaseItems expectedSections:upperCaseItems expectedItemCounts:counts itemsAlreadySorted:YES];
}

- (void)testAllNumbers 
{
    NSString *numbers = @"0123456789";
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[numbers length]];
    for (int i = 0; i < [numbers length]; i++) {
        NSRange r;
        r.location = i;
        r.length = 1;
        [items addObject:[numbers substringWithRange:r]];
    }
    
    [self runTestItems:items 
      expectedSections:[NSArray arrayWithObject:kTableSectionHandlerNumberHeader] 
    expectedItemCounts:(int[]){10} itemsAlreadySorted:YES];
}

- (void)testItemImagesSort 
{
    NSArray *items = [NSArray arrayWithObjects:@"3", @"2", @"1", nil];
    NSArray *images = [NSArray arrayWithObjects:@"aa", @"bb", @"cc", nil];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.itemImages = images;

    NSArray *expectedItems = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedImages = [NSArray arrayWithObjects:@"cc", @"bb", @"aa", nil];
    STAssertEqualObjects(handler.itemImages, expectedImages, @"Bad sort order");
}

- (void)runTestItems:(NSArray *)items 
    expectedSections:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts 
  itemsAlreadySorted:(BOOL)itemsAlreadySorted
{
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.itemsAlreadySorted = itemsAlreadySorted;
    handler.sectionsEnabled = YES;

    STAssertEquals([handler.sections count], [expectedSections count], @"Unexpected number of sections");

    int expectedLocation = 0;
    for (int numSection = 0; numSection < [handler.sections count]; numSection++) {
        id section = [handler.sections objectAtIndex:numSection];
        NSString *title = [section title];
        NSRange range = [section range];
        STAssertEqualObjects(title, [expectedSections objectAtIndex:numSection], @"Unexpected section title for section: %@", section);        
        STAssertEquals(range.location, (NSUInteger)expectedLocation, @"Unexpected section location for section: %@", section);
        STAssertEquals(range.length, (NSUInteger)expectedItemCounts[numSection], @"Unexpected item count for section: %@", section);
        expectedLocation += range.length;
    }
    
    STAssertEqualObjects(handler.sectionTitles, expectedSections, @"Unexpected section titles");
}

@end