// @author Simon Toens 12/14/12

#import "DataSourceAccess.h"
#import "ItemPickerCell.h"
#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "Stack.h"
#import "TableHeaderViewContainer.h"
#import "TableViewCellContainer.h"

@interface ItemPickerViewController()
- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack;
- (id)initWithNibName:(NSString *)nibName dataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack;

- (BOOL)moreCellsAreSelectable;
- (void)configureHeaderView;
- (void)configureNavigationItem;
- (void)configureTitle;

- (ItemPickerContext *)getPreviousContext;
- (void)handleSelection:(NSIndexPath *)indexPath;
- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource;
- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
            contextForSelection:(ItemPickerContext *)context
                     dataSource:(id<ItemPickerDataSource>)dataSource;
- (void)updateViewState;

@property(nonatomic, strong) Stack *contextStack;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) DataSourceAccess *dataSourceAccess;
@property(nonatomic, weak) UIBarButtonItem *doneButton;
@property(nonatomic, strong) NSMutableArray *selectedItems;


@end

@implementation ItemPickerViewController

UIColor *kGreyBackgroundColor;

@synthesize contextStack = _contextStack;
@synthesize dataSource = _dataSource;
@synthesize dataSourceAccess = _dataSourceAccess;
@synthesize doneButton;
@synthesize itemPickerDelegate;
@synthesize maxSelectableItems = _maxSelectableItems;
@synthesize selectedItems = _selectedItems;
@synthesize showCancelButton = _showCancelButton;


- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    return [self initWithDataSource:dataSource contextStack:[[Stack alloc] init]];    
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource contextStack:(Stack *)contextStack
{
    return [self initWithNibName:@"ItemPickerView" dataSource:dataSource contextStack:contextStack];
}

- (id)initWithNibName:(NSString *)nibName 
           dataSource:(id<ItemPickerDataSource>)dataSource 
         contextStack:(Stack *)contextStack
{
    if (self = [super initWithNibName:nibName bundle:nil]) 
    {
        _contextStack = contextStack;
        _dataSource = dataSource;
        _dataSourceAccess = [[DataSourceAccess alloc] initWithDataSource:dataSource];
        
        _maxSelectableItems = 1;
        _selectedItems = [[NSMutableArray alloc] init];
        _showCancelButton = NO;

        if (self.tabBarItem) 
        {
            self.title = dataSource.title;
            self.tabBarItem.image = dataSource.tabImage;
        }
    }
    return self;
}


#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self configureHeaderView];
    [self configureNavigationItem];
    [self configureTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewState];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) 
    {
        while ([[self.contextStack pop] autoSelected]);
    }
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    // hack to get rid of empty rows in table view (also see heightForFooterInSection)
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == [[self.dataSourceAccess getSectionTitles] count] - 1 ? 1 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    ItemPickerContext *context = [self.dataSourceAccess getItemPickerContext:indexPath autoSelected:NO];
    [self selectedItemAtIndexPath:indexPath contextForSelection:context dataSource:self.dataSource];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.dataSourceAccess getSectionTitles] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [[self.dataSourceAccess getSection:section] title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.dataSourceAccess getSection:section] range].length;
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    UIImage *image = nil;
    if (self.dataSource.itemImagesEnabled)
    {
        image = [self.dataSourceAccess getItemImage:indexPath];        
    }
    
    NSString *description = nil;
    if (self.dataSource.itemDescriptionsEnabled)
    {
        description = [self.dataSourceAccess getItemDescription:indexPath];
    }
    
    ItemPickerCell *cell = [TableViewCellContainer newCellForTableView:tableView image:image description:description];
    
    cell.label.text = [self.dataSourceAccess getItem:indexPath];
    
    BOOL isCellSelected = [self isCellSelectedAtIndexPath:indexPath]; 
    cell.accessoryType = isCellSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    cell.userInteractionEnabled = isCellSelected || [self moreCellsAreSelectable];
    
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return [self.dataSourceAccess getSectionTitles];
}

#pragma mark - Private methods

- (BOOL)moreCellsAreSelectable
{
    return [self.selectedItems count] < self.maxSelectableItems;    
}

- (void)updateViewState
{
    self.doneButton.enabled = [self.selectedItems count] > 0;
}

- (void)onMultiSelectDone
{
    [self.itemPickerDelegate onPickItems:self.selectedItems];
}

- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    // review how we determine that a cell has been previously selected - 
    // this is creating a lot of ItemPickerContext instances
    ItemPickerContext *ctx = [self.dataSourceAccess getItemPickerContext:indexPath autoSelected:NO];
    [self.contextStack push:ctx];
    NSArray *selectionPath = [self.contextStack allObjects];
    BOOL selected = [self.selectedItems containsObject:selectionPath];
    [self.contextStack pop];
    return selected;
}

- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
            contextForSelection:(ItemPickerContext *)context
                     dataSource:(id<ItemPickerDataSource>)dataSource 
{
    NSArray *prevSelections = [[self.contextStack allObjects] copy];
    id<ItemPickerDataSource> nextDataSource = [dataSource getNextDataSourceForSelection:context previousSelections:prevSelections];
    
    [self.contextStack push:context];

    if (nextDataSource)
    {
        [self pushDataSource:nextDataSource];    
    } 
    else
    {
        [self handleSelection:indexPath];
    }
}

- (void)handleSelection:(NSIndexPath *)indexPath
{
    if (self.maxSelectableItems > 1)
    {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];            
        NSArray *selectionPath = [self.contextStack allObjects];            
        if ([self.selectedItems containsObject:selectionPath])
        {
            [self.selectedItems removeObject:selectionPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.tableView reloadData];
        }
        else
        {
            if ([self moreCellsAreSelectable])
            {
                [self.selectedItems addObject:[selectionPath copy]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;    
            }
            else 
            {
                [self.tableView reloadData];
            }
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.contextStack pop];
        [self updateViewState];
    }
    else
    {
        [self.itemPickerDelegate onPickItems:[NSArray arrayWithObject:[self.contextStack allObjects]]];
    }
}

- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (dataSource.autoSelectSingleItem && dataSource.count == 1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        DataSourceAccess *access = [[DataSourceAccess alloc] initWithDataSource:dataSource];
        ItemPickerContext *context = [access getItemPickerContext:indexPath autoSelected:YES];
        [self selectedItemAtIndexPath:indexPath contextForSelection:context dataSource:dataSource];
    }
    else
    {    
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:dataSource 
                                                                                       contextStack:self.contextStack];
        controller.itemPickerDelegate = self.itemPickerDelegate;
        controller.maxSelectableItems = self.maxSelectableItems;
        controller.selectedItems = self.selectedItems;
        controller.showCancelButton = self.showCancelButton;
        [self.navigationController pushViewController:controller animated:YES];    
    }
}

- (ItemPickerContext *)getPreviousContext
{
    NSArray *contexts = [self.contextStack allObjects];
    return [contexts count] > 0 ? [contexts objectAtIndex:[contexts count] - 1] : nil;
}

- (ItemPickerContext *)getContextFrom:(NSArray *)contexts atOffsetFromEnd:(NSUInteger)offset
{
    return [contexts count] > offset ? [contexts objectAtIndex:[contexts count] - 1 - offset] : nil;
}

- (TableHeaderViewContainer *)getHeaderViewContainerWithImage:(UIImage *)image defaultLabels:(BOOL)defaultLabels
{
    TableHeaderViewContainer *container = [TableHeaderViewContainer newTableHeaderViewWithImage:image];
    if (defaultLabels)
    {
        NSArray *contexts = [self.contextStack allObjects];
        container.boldLabel.text = [self getContextFrom:contexts atOffsetFromEnd:1].selectedItem;        
        container.label.text = [self getContextFrom:contexts atOffsetFromEnd:0].selectedItem;
        container.smallerLabel.text = [NSString stringWithFormat:@"%i %@", self.dataSource.count, self.dataSource.title];
    }
    return container;
}

- (void)configureHeaderView 
{
    TableHeaderViewContainer *container = nil;
    
    ItemPickerHeader *header = self.dataSource.header;    
    if (header)
    {
        container = [self getHeaderViewContainerWithImage:header.image defaultLabels:header.defaultNilLabels];
        if (header.boldLabel) 
        {
            container.boldLabel.text = header.boldLabel;
        }
        if (header.label) 
        {
            container.label.text = header.label;
        }
        if (header.smallerLabel)
        {
            container.smallerLabel.text = header.smallerLabel;
        }
        if (header.smallestLabel)
        {
            container.smallestLabel.text = header.smallestLabel;
        }
    }
    else 
    {    
        UIImage *headerImage = self.dataSource.headerImage;
        if (headerImage)
        {
            container = [self getHeaderViewContainerWithImage:headerImage defaultLabels:YES];
        }
    }
    self.tableView.tableHeaderView = container.tableHeaderView;
}

- (void)configureTitle 
{
    ItemPickerContext *prevSelection = [self getPreviousContext];
    self.title = prevSelection ? prevSelection.selectedItem : self.dataSource.title;
}

- (void)configureNavigationItem
{
    UIBarButtonItem *button = nil, *cancelButton = nil;
    
    if (self.maxSelectableItems > 1)
    {
        button = self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered 
                                                                   target:self
                                                                   action:@selector(onMultiSelectDone)];
        [self updateViewState];
    }
    
    if (self.showCancelButton)
    {
        button = cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered 
                                                                target:self.itemPickerDelegate
                                                                action:@selector(onCancel)];
    }
    
    if (doneButton && cancelButton)
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, doneButton, nil];    
    }
    else
    {
        self.navigationItem.rightBarButtonItem = button;
    }
}

@end