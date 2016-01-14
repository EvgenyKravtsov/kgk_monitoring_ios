//
//  KGKHistoryScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKHistoryScreenViewController.h"
#import "KGKTrackScreenViewController.h"
#import "KGKPeriodScreenViewController.h"
#import "KGKSignalStore.h"
#import "KGKDispatcher.h"
#import "Tolo.h"
#import "ActionCreator.h"
#import "KGKDispatcher.h"
#import "KGKStoreChangeEvent.h"
#import "KGKMapScreenViewController.h"
#import "KGKActisHistoryCell.h"
#import "AppDelegate.h"

@interface KGKHistoryScreenViewController ()

@property (weak, nonatomic) IBOutlet UITableView *signalsTableView;
@property (nonatomic) NSArray *signals;
@property (nonatomic) NSMutableDictionary *sections;
@property (nonatomic) NSMutableArray *sectionsAsArray;
@property (weak, nonatomic) IBOutlet UIButton *periodButton;
@property (weak, nonatomic) IBOutlet UIButton *trackButton;

@end

@implementation KGKHistoryScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    REGISTER();
    [self.navigationItem setTitle:NSLocalizedString(@"History", nil)];
    
    [self.periodButton setTitle:NSLocalizedString(@"Period", nil) forState:UIControlStateNormal];
    [self.trackButton setTitle:NSLocalizedString(@"Track", nil) forState:UIControlStateNormal];
    
    self.signalsTableView.dataSource = self;
    self.signalsTableView.delegate = self;
    self.signals = [KGKSignalStore getInstance:[KGKDispatcher getInstance]].signalsForHistory;
    
    NSInteger defaultNumOfSignalsForHistory = 10;
    [[ActionCreator getInstance:[KGKDispatcher getInstance]] getSignalsFromDatabase:defaultNumOfSignalsForHistory];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshTableContent:[KGKSignalStore getInstance:[KGKDispatcher getInstance]].signalsForHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToPeriod:(id)sender {
    KGKPeriodScreenViewController *periodScreenViewController = [[KGKPeriodScreenViewController alloc] init];
    [self.navigationController pushViewController:periodScreenViewController
                                         animated:YES];
}

- (IBAction)goToTrack:(id)sender {
    KGKTrackScreenViewController *trackScreenViewController = [[KGKTrackScreenViewController alloc] init];
    [self.navigationController pushViewController:trackScreenViewController
                                         animated:YES];
}

SUBSCRIBE(KGKStoreChangeEvent) {
    self.signals = [KGKSignalStore getInstance:[KGKDispatcher getInstance]].signalsForHistory;
    [self refreshTableContent:self.signals];
    
}

- (void)refreshTableContent:(NSArray *)signals {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    if (self.sections == nil) {
        self.sections = [[NSMutableDictionary alloc] init];
    }
    
    if (self.sectionsAsArray == nil) {
        self.sectionsAsArray = [[NSMutableArray alloc] init];
    }
    
    [self.sections removeAllObjects];
    [self.sectionsAsArray removeAllObjects];
    
    for (int i = 0; i < [self.signals count]; i++) {
        KGKSignal *signal = self.signals[i];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:signal.date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMMM yyyy"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *dateString = [formatter stringFromDate:date];
        
        if ([self.sections objectForKey:dateString] == nil) {
            [self.sections setObject:[[NSMutableArray alloc] init] forKey:dateString];
        }
        [[self.sections objectForKey:dateString] addObject:signal];
    }
    
    [self sortSectionsDictionaryKeys];
    
    for (NSString *key in self.sections) {
        [self.sectionsAsArray addObject:[self.sections objectForKey:key]];
    }
    
    [self.signalsTableView reloadData];
}

- (void)sortSectionsDictionaryKeys {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    
    for (NSString *dateString in [self.sections allKeys]) {
        NSDate *date = [formatter dateFromString:dateString];
        [dates addObject:date];
    }
    
    for (int i = 0; i < [dates count]; i++) {
        for (int j = i; j > 0 && dates[j - 1] > dates[j]; j--) {
            [dates exchangeObjectAtIndex:j - 1 withObjectAtIndex:j];
        }
    }
    
    NSLog(@"%@", dates);
}

// Table view protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView
        numberOfRowsInSection:(NSInteger)section {
    return [self.sectionsAsArray[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [[NSString alloc] init];
    NSArray *ethalon = self.sectionsAsArray[section];
    for (NSString *key in self.sections) {
        if (ethalon == [self.sections objectForKey:key]) {
            title = key;
        }
    }
    return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [[NSString alloc] init];
    NSArray *ethalon = self.sectionsAsArray[section];
    for (NSString *key in self.sections) {
        if (ethalon == [self.sections objectForKey:key]) {
            title = key;
        }
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 24)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 24)];
    [label setFont:[UIFont boldSystemFontOfSize:20]];
    NSString *string = title;
    [label setText:string];
    label.autoresizingMask = 20 | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view setAlpha:0.65];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KGKActisHistoryCell *cell = (KGKActisHistoryCell *) [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KGKActisHistoryCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:120 green:179 blue:222 alpha:0.65];
    
    KGKSignal *signal = [self.signals objectAtIndex:indexPath.row];
    NSString *detailsString = [NSString stringWithFormat:NSLocalizedString(@"%ldst | %ldkm/h | %ld°C | %.1fV | %.1frub", nil), (long)signal.satellites, (long)signal.speed, (long)signal.temperature, signal.voltage, signal.balance];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:signal.date];
    NSString *dateString = [NSString stringWithFormat:@"%@  Actis", [AppDelegate formatTime:date]];
    
    cell.date.text = dateString;
    cell.details.text = detailsString;
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
//    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65f];
//    cell.contentView.alpha = 0.65f;
//    cell.textLabel.text = [self.signals[indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [KGKSignalStore getInstance:[KGKDispatcher getInstance]].signalForMap = [self.signals objectAtIndex:indexPath.row];
    KGKMapScreenViewController *mapScreenViewController = [[KGKMapScreenViewController alloc] init];
    [self.navigationController pushViewController:mapScreenViewController
                                         animated:YES];
}

@end
