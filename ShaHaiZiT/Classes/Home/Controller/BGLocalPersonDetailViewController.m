//
//  BGLocalPersonDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/25.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalPersonDetailViewController.h"
#import "BGAirApi.h"
#import "BGLocalPersonModel.h"
#import <UIImageView+WebCache.h>
#import "BGChatViewController.h"
#import <SDCycleScrollView.h>
#import "BGLocalSpecialDetailViewController.h"
#import "BGLocalSpecialModel.h"
#import "BGLocalRecommendLineCell.h"
#import "BGAirProductModel.h"
#import "BGLineDetailViewController.h"
#import "BGLocalPersonMemoryDetailViewController.h"

@interface BGLocalPersonDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UIImageView *faceImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *englishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn;
@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UITextView *introductionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introductionViewHeight;
@property (weak, nonatomic) IBOutlet UIView *specialView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) NSString *pageNum;
@property (nonatomic, strong) NSMutableArray *cellDataArr;
@property(nonatomic,copy) NSString *regionIDStr;
@property (weak, nonatomic) IBOutlet UIView *travelRecommendView;
@property (weak, nonatomic) IBOutlet UIView *yearView;
@property(nonatomic,strong) NSString *yearStr;
@property(nonatomic,strong) BGLocalPersonModel *fModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *travelMemoryViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *travelTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelCityLabel;
@property (weak, nonatomic) IBOutlet UITextView *travelContentTextView;
@property (weak, nonatomic) IBOutlet UIImageView *travelOneImgView;
@property (weak, nonatomic) IBOutlet UIImageView *travelTwoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *travelThreeImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewTop;

@end

@implementation BGLocalPersonDetailViewController

-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self loadSubViews];
    [self loadData];
}

-(void)loadSubViews{
    self.navigationItem.title = @"当地达人";
    self.view.backgroundColor = kAppBgColor;
    self.serviceBtn.enabled = NO;
    
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = (SCREEN_WIDTH-60)*2/3.0+77;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGLocalRecommendLineCell" bundle:nil] forCellReuseIdentifier:@"BGLocalRecommendLineCell"];
    self.regionIDStr = @"";
    _pageNum = @"1";
    self.yearStr = @"2019";
    self.travelContentTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_personID forKey:@"talent_id"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getLocalPersonDetails:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonDetails sucess]:%@",response);
        [weakSelf hideNodateView];
        BGLocalPersonModel *model = [BGLocalPersonModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        weakSelf.fModel = model;
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonDetails failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.scrollView.mj_header.automaticallyChangeAlpha = YES;
        weakSelf.pageNum = @"1";
        [weakSelf loadData];
        [weakSelf.scrollView.mj_header endRefreshing];
    }];
    // 上拉刷新
    self.scrollView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadLineData];
        //        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
    [self loadLineData];
}
-(void)loadLineData{
   
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (![Tool isBlankString:_regionIDStr]) {
        [param setObject:_regionIDStr forKey:@"region_id"];
    }
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"4" forKey:@"product_set_cd"];
    [param setObject:@"10" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getLineGoodsList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLineGoodsList sucess]:%@",response);
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.scrollView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGAirProductModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        [weakSelf.tableView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.scrollView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.scrollView.mj_footer endRefreshing];
        }
        [weakSelf changeViewFrame];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getLineGoodsList failure]:%@",response);
    }];
}
-(void)updateSubViewsWithModel:(BGLocalPersonModel *)model{
    self.regionIDStr = model.region_id;
    [self refreshView];
    [self.faceImgView sd_setImageWithURL:[NSURL URLWithString:model.talent_face]];
    self.nameLabel.text = model.talent_name;
    self.englishNameLabel.text = model.talent_english_name;
    self.tagLabel.text = [NSString stringWithFormat:@"%@%@ · %@",model.country_name,model.region_name,model.talent_tag];
    self.travelCountLabel.text = [NSString stringWithFormat:@"%@个目的地",model.travel_count];
    if (![Tool isBlankString:model.service_name] && ![Tool isBlankString:model.service_id]) {
        self.serviceBtn.enabled = YES;
        @weakify(self);
        [[self.serviceBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
            conversationVC.conversationType = ConversationType_PRIVATE;
            
            conversationVC.targetId = [NSString stringWithFormat:@"%@",model.service_id];
            conversationVC.title = [NSString stringWithFormat:@"%@",model.service_name];
            [self.navigationController pushViewController:conversationVC animated:YES];
        }];
    }
    
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.imageURLStringsGroup = model.talent_banner_picture;
    self.cycleScrollView.currentPageDotColor = kAppMainColor;
    self.cycleScrollView.pageDotColor = kAppWhiteColor;
    CGFloat btnAll = 0.0;
    for (int i = 0; i<model.tags.count; i++) {
        CGSize tagSize =[Tool textSizeWithText:model.tags[i] Font:kFont(9) limitWidth:100];
        CGFloat btnWith = tagSize.width+16;
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(btnAll+4*i, 0, btnWith, 19);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 9.5;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = UIColorFromRGB(0xFFB644).CGColor;
        [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:9]];
        [btn setTitleColor:UIColorFromRGB(0xFFB644) forState:(UIControlStateNormal)];
        btn.backgroundColor = kAppWhiteColor;
        [btn setTitle:model.tags[i] forState:(UIControlStateNormal)];
        btn.userInteractionEnabled = NO;
        [_btnView addSubview:btn];
        btnAll += btnWith;
    }
    _introductionTextView.text = model.talent_introduction;
    self.introductionViewHeight.constant = [self heightForString:self.introductionTextView andWidth:SCREEN_WIDTH-12-20]+58;
    
    CGFloat specialBtnAll = 0.0;
    for (int i = 0; i<model.characteristic_ids.count; i++) {
        NSDictionary *dic = model.characteristic_ids[i];
        CGSize tagSize =[Tool textSizeWithText:BGdictSetObjectIsNil(dic[@"name"]) Font:kFont(14) limitWidth:100];
        CGFloat btnWith = tagSize.width+18;
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(specialBtnAll+14*i, 0, btnWith, 25);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 6;
        btn.layer.borderWidth = 0.5;
        if (i == 0) {
            btn.layer.borderColor = kAppMainColor.CGColor;
            [btn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
            btn.backgroundColor = kAppMainColor;
        }else{
            btn.layer.borderColor = kAppDefaultLabelColor.CGColor;
            [btn setTitleColor:kAppDefaultLabelColor forState:(UIControlStateNormal)];
            btn.backgroundColor = kAppWhiteColor;
        }
        btn.tag = 2000+i;
        [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14]];
        [btn setTitle:BGdictSetObjectIsNil(dic[@"name"]) forState:(UIControlStateNormal)];
        [_specialView addSubview:btn];
        specialBtnAll += btnWith;
        @weakify(self);
        [[btn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            for (int i = 0; i<model.characteristic_ids.count; i++) {
                 UIButton *allBtn = (UIButton *)[self.specialView viewWithTag:2000+i];
                allBtn.layer.borderColor = kAppDefaultLabelColor.CGColor;
                [allBtn setTitleColor:kAppDefaultLabelColor forState:(UIControlStateNormal)];
                allBtn.backgroundColor = kAppWhiteColor;
            }
            btn.layer.borderColor = kAppMainColor.CGColor;
            [btn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
            btn.backgroundColor = kAppMainColor;
            
            [ProgressHUDHelper showLoading];
            NSString *typeIDStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"id"])];
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:self.personID forKey:@"talent_id"];
            [param setObject:typeIDStr forKey:@"recommend_type"];
            __weak __typeof(self) weakSelf = self;
            [BGAirApi getLocalPersonRecommendNew:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[getLocalPersonRecommendNew sucess]:%@",response);
               BGLocalSpecialDetailViewController *detailVC = BGLocalSpecialDetailViewController.new;
                BGLocalSpecialModel *specialModel = [BGLocalSpecialModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
                detailVC.specialModel = specialModel;
                detailVC.typeID = typeIDStr;
                [weakSelf.navigationController pushViewController:detailVC animated:YES];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[getLocalPersonRecommendNew failure]:%@",response);
            }];
        }];
    }
    for (int i = 0; i<7; i++) {
        UIView *view = (UIView *)[self.yearView viewWithTag:2001+i];
        view.hidden = YES;
    }
    if (![Tool arrayIsNotEmpty:model.year_line]) {
        self.travelMemoryViewHeight.constant = 0;
        self.lineViewTop.constant = 10;
         self.contentCenterY.constant = (self.tableView.y+self.tableView.contentSize.height+self.introductionViewHeight.constant-100-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight)*0.5;
        return;
    }
    for (int i = 0; i<model.year_line.count; i++) {
        UIView *view = (UIView *)[self.yearView viewWithTag:2001+i];
        view.hidden = NO;
        UIImageView *imgView = (UIImageView *)[view viewWithTag:1001+i];
        [imgView setImage:BGImage(@"home_local_person_unselected")];
        UILabel *lab = (UILabel *)[view viewWithTag:4001+i];
        NSDictionary *dic = BGdictSetObjectIsNil(model.year_line[i]);
        lab.text = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil([dic objectForKey:@"create_year"])];
        if (i == model.year_line.count-1) {
            [imgView setImage:BGImage(@"home_local_person_selected")];
            self.yearStr = lab.text;
            [self loadTravelMemoryAction];
        }
    }
    
    [self changeViewFrame];
    
}
-(void)loadTravelMemoryAction{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_personID forKey:@"talent_id"];
    [param setObject:self.yearStr forKey:@"year"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getLocalPersonMemoryByYear:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonMemoryByYear sucess]:%@",response);
        BGLocalPersonModel *model = [BGLocalPersonModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateTravelMemoryWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonMemoryByYear failure]:%@",response);
    }];
}
-(void)updateTravelMemoryWithModel:(BGLocalPersonModel *)model{
    if (model.create_time.length>8) {
         self.travelTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd"];
    }else{
      self.travelTimeLabel.text = @"0000-00-00";
    }
    self.travelCityLabel.text = [NSString stringWithFormat:@"%@%@",model.country_name,model.region_name];
    _travelOneImgView.hidden = YES;
    _travelTwoImgView.hidden = YES;
    _travelThreeImgView.hidden = YES;
    if ([Tool arrayIsNotEmpty:model.landscape_picture]) {
        for (int i = 0; i<model.landscape_picture.count; i++) {
            if (i==0) {
                _travelOneImgView.hidden = NO;
                [_travelOneImgView sd_setImageWithURL:[NSURL URLWithString:model.landscape_picture[i]]];
            }else if (i == 2){
                _travelTwoImgView.hidden = NO;
                [_travelTwoImgView sd_setImageWithURL:[NSURL URLWithString:model.landscape_picture[i-1]]];
                _travelThreeImgView.hidden = NO;
                [_travelThreeImgView sd_setImageWithURL:[NSURL URLWithString:model.landscape_picture[i]]];
            }
        }
    }
    
    self.travelContentTextView.text = model.content;
    self.travelMemoryViewHeight.constant = [self heightForString:self.travelContentTextView andWidth:SCREEN_WIDTH-40]+120+37+15+(SCREEN_WIDTH-40)*90/335.0*2+5;
    self.lineViewTop.constant = self.travelMemoryViewHeight.constant+20;
    [self changeViewFrame];
}
-(void)changeViewFrame{
    self.contentCenterY.constant = (self.tableView.y+self.tableView.contentSize.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    BGAirProductModel *model = _cellDataArr[indexPath.section];
    BGLocalRecommendLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGLocalRecommendLineCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        [cell updataWithCellArr:model];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BGAirProductModel *model = _cellDataArr[indexPath.section];
    BGLineDetailViewController *detailVC = BGLineDetailViewController.new;
    detailVC.product_id = model.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 0.01:6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (SCREEN_WIDTH-60)*2/3.0+77;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}
- (IBAction)selectTravelYearAction:(UIButton *)sender {
    NSInteger selectNum = sender.tag-3001;
    UIView *view = (UIView *)[self.yearView viewWithTag:2001+selectNum];
    UILabel *lab = (UILabel *)[view viewWithTag:4001+selectNum];
    if ([lab.text isEqualToString:self.yearStr]) {
        return;
    }
    
    for (int i = 0; i<self.fModel.year_line.count; i++) {
        UIView *view = (UIView *)[self.yearView viewWithTag:2001+i];
        UIImageView *imgView = (UIImageView *)[view viewWithTag:1001+i];
        [imgView setImage:BGImage(@"home_local_person_unselected")];
        NSDictionary *dic = BGdictSetObjectIsNil(self.fModel.year_line[i]);
        if (i == selectNum) {
            [imgView setImage:BGImage(@"home_local_person_selected")];
           self.yearStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil([dic objectForKey:@"create_year"])];
            [self loadTravelMemoryAction];
        }
    }
}
- (IBAction)jumpToMemoryDetailAction:(UIButton *)sender {
    BGLocalPersonMemoryDetailViewController *detailVC = BGLocalPersonMemoryDetailViewController.new;
    detailVC.talent_id = _personID;
    detailVC.yearStr = _yearStr;
    detailVC.yearArr = [NSArray arrayWithArray:_fModel.year_line];
    [self.navigationController pushViewController:detailVC animated:YES];
}


- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
