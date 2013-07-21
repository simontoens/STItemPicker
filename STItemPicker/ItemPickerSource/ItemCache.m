// @author Simon Toens 07/12/13

#import "ItemCache.h"
#import "Preconditions.h"

@interface ItemCache()
@property(nonatomic) BOOL initialized;
@property(nonatomic) NSRange range;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
- (NSRange)calculateNewRangeForIndex:(int)index;

/**
 * Calculates ranges for new data to load from the datasource and currently cached data to keep.
 * @return oldDataFirst  Whether the currently cached data is at the beginning or the end of the new data array being build.
 */
- (BOOL)calculateOldDataRange:(NSRange *)oldDataRange andNewDataRange:(NSRange *)newDataRange newRange:(NSRange)newRange;
- (void)loadDataWithNewDataRange:(NSRange)newDataRange oldDataRange:(NSRange)oldDataRange 
                        newRange:(NSRange)newRange oldDataFirst:(BOOL)oldDataFirst;
- (NSArray *)combineOldData:(NSArray *)oldData oldRange:(NSRange)oldRange withNewData:(NSArray *)newData oldDataFirst:(BOOL)oldDataFirst;

@end
@implementation ItemCache

@synthesize attributes = _attributes;
@synthesize descriptions = _descriptions;
@synthesize images = _images;
@synthesize items = _items;

@synthesize initialized = _initialized, size = _size, range = _range;
@synthesize dataSource = _dataSource;

- (id)initForDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (self = [super init])
    {
        _dataSource = dataSource;
        _initialized = NO;
        _range = NSMakeRange(0, 0);
        _size = 500;
    }
    return self;
}

- (NSUInteger)ensureAvailability:(NSUInteger)index
{
     if (!_initialized || index < self.range.location || index >= self.range.location + self.range.length)
     {  
         _initialized = YES;

         NSRange newRange = [self calculateNewRangeForIndex:index];
                           
         NSRange oldDataRange;
         NSRange newDataRange;
         BOOL oldDataFirst = [self calculateOldDataRange:&oldDataRange andNewDataRange:&newDataRange newRange:newRange];
                  
         [self loadDataWithNewDataRange:newDataRange oldDataRange:oldDataRange newRange:newRange oldDataFirst:oldDataFirst];
     }
    
     return index - _range.location;
}

- (void)setSize:(NSUInteger)size
{
    [Preconditions assert:size > 0 message:@"cache size must be larger than 0"];
    _size = size;
}

- (NSRange)calculateNewRangeForIndex:(int)index
{
    // index is the midpoint the cached arrays         
    int newLocation = MAX(0, (int)(index - (_size / 2)));
    int newLength = _size;
    
    int totalItemCount = _dataSource.count;
        
    if (newLocation + newLength > totalItemCount)
    {
        // if last index of the data to cache exceeds the total data size count,
        // move location back as far as possible
        newLocation -= newLocation + newLength - totalItemCount;
        
        if (newLocation < 0)
        {
            newLocation = 0;
            newLength = totalItemCount;
        }
    }
    
    return NSMakeRange(newLocation, newLength);
}

- (BOOL)calculateOldDataRange:(NSRange *)oldDataRange andNewDataRange:(NSRange *)newDataRange newRange:(NSRange)newRange
{
    // determine whether there is any overlap with data currently cached
    // if there is any overlap, it is either to the left or the right
    // calculate NSRanges for the old data we want to keep and the new data we
    // want to load from the datasource.
    
    int lastIndexExclusive = newRange.location + newRange.length;

    *newDataRange = newRange;
    BOOL oldDataFirst = NO;
    if (_range.location > newRange.location && _range.location < lastIndexExclusive)
    {
        // old data overlaps to the right
        *oldDataRange = NSMakeRange(0, lastIndexExclusive - _range.location);
        *newDataRange = NSMakeRange(newRange.location, _range.location - newRange.location);
    }
    else  
    {
        int currentLastIndexExclusive = _range.location + _range.length;
        if (_range.location < newRange.location && currentLastIndexExclusive > newRange.location)
        {
            // old data overlaps to the left
            oldDataFirst = YES;
            int oldDataLength = currentLastIndexExclusive - newRange.location;
            *oldDataRange = NSMakeRange(_range.length - oldDataLength, oldDataLength);                 
            *newDataRange = NSMakeRange(currentLastIndexExclusive, lastIndexExclusive - currentLastIndexExclusive);
        }
    }
    return oldDataFirst;
}

- (void)loadDataWithNewDataRange:(NSRange)newDataRange oldDataRange:(NSRange)oldDataRange 
                        newRange:(NSRange)newRange oldDataFirst:(BOOL)oldDataFirst
{
    [_dataSource initForRange:newDataRange];
    
    NSArray *newAttributes = [_dataSource getItemAttributesInRange:newDataRange];
    NSArray *newDescs = [_dataSource getItemDescriptionsInRange:newDataRange];
    NSArray *newItems = [_dataSource getItemsInRange:newDataRange];
    NSArray *newImages = [_dataSource getItemImagesInRange:newDataRange];
    
    if (newDataRange.location == newRange.location && newDataRange.length == newRange.length)
    {
        // there isn't any overlap between old and new data - replace old data with new data
        _range = newDataRange;
        _attributes = newAttributes;
        _descriptions = newDescs;
        _items = newItems;
        _images = newImages;
    }
    else
    {
        _range = newRange;
        
        if (_attributes)
        {
            _attributes = [self combineOldData:_attributes oldRange:oldDataRange withNewData:newAttributes oldDataFirst:oldDataFirst];
        }
        
        if (_descriptions)
        {
            _descriptions = [self combineOldData:_descriptions oldRange:oldDataRange withNewData:newDescs oldDataFirst:oldDataFirst];                 
        }
        
        if (_items)
        {
            _items = [self combineOldData:_items oldRange:oldDataRange withNewData:newItems oldDataFirst:oldDataFirst];                                  
        }
        
        if (_images)
        {
            _images = [self combineOldData:_images oldRange:oldDataRange withNewData:newImages oldDataFirst:oldDataFirst];                                                   
        }             
    }
}

- (NSArray *)combineOldData:(NSArray *)oldData oldRange:(NSRange)oldRange withNewData:(NSArray *)newData oldDataFirst:(BOOL)oldDataFirst
{
    NSMutableArray *combined = [NSMutableArray arrayWithCapacity:oldRange.length + [newData count]];
    if (oldDataFirst)
    {
        [combined addObjectsFromArray:[oldData subarrayWithRange:oldRange]];
        [combined addObjectsFromArray:newData];
    }
    else
    {
        [combined addObjectsFromArray:newData];
        [combined addObjectsFromArray:[oldData subarrayWithRange:oldRange]];
    }
    return combined;    
}

@end