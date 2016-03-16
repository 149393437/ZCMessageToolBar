# ZCMessageToolBar
解决写聊天时候输入框和cell的问题
包含语音\图片\定位\文字\表情的一系列封装,实现了一句话调用
 toolBar=[[ZCMessageToolBar alloc]initWithBlock:^(NSString *sign, NSString *message) {
        NSLog(@"%@~~%@",sign,message);
       
       MessageModel*model=[[MessageModel alloc]init];
       model.body=[NSString stringWithFormat:@"%@%@",sign,message];
       model.isOutgoing=YES;
       model.timestamp=[NSDate date];
       [self.dataArray addObject:model];
       [_tableView reloadData];
       
       [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
       
       
       //每一次进行自动回复这次所发送的内容
       [self performSelector:@selector(backMessage) withObject:nil afterDelay:1];
    }];
    [self.view addSubview:toolBar];
    
    
    完整示例
    - (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"chat_bg_default"]];
    /*
    需要加上支持http和定位NSLocationWhenInUseUsageDescription
    本工程主要是2个类
     ZCFaceToolBar和MessageCell这2个类
     所依赖相关库的支持,包含以下
     BQMM  表情
     VoiceContvert 语音
     Photo  图片
     
     */
    [self createToolBar];

    [self createTableView];
    
    
//    NSLocationWhenInUseUsageDescription
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)createToolBar{
    self.dataArray=[NSMutableArray array];
    
   toolBar=[[ZCMessageToolBar alloc]initWithBlock:^(NSString *sign, NSString *message) {
        NSLog(@"%@~~%@",sign,message);
       
       MessageModel*model=[[MessageModel alloc]init];
       model.body=[NSString stringWithFormat:@"%@%@",sign,message];
       model.isOutgoing=YES;
       model.timestamp=[NSDate date];
       [self.dataArray addObject:model];
       [_tableView reloadData];
       
       [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
       
       
       //每一次进行自动回复这次所发送的内容
       [self performSelector:@selector(backMessage) withObject:nil afterDelay:1];
    }];
    [self.view addSubview:toolBar];
}
-(void)backMessage{
   MessageModel*model= [self.dataArray lastObject];
    MessageModel*model1=[[MessageModel alloc]init];
    model1.isOutgoing=NO;
    model1.body=model.body;
    model1.timestamp=[NSDate date];
    [self.dataArray addObject:model1];
    [_tableView reloadData];
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}
-(void)createTableView{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-45) style:UITableViewStylePlain];
    _tableView.backgroundColor=[UIColor clearColor];
    //去掉线
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    //设置观察者,观察toolBar
    [toolBar addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel*model=self.dataArray[indexPath.row];
    return [MessageCell contentStrToHeight:model.body];

}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    _tableView.frame=CGRectMake(0, 0, WIDTH, toolBar.frame.origin.y);

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell*cell=[tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (cell==nil) {
        cell=[[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    }
    MessageModel*model=self.dataArray[indexPath.row];
    [cell configWithCustomModel:model leftImage:nil rightImage:nil];
    
    return cell;
}

    
    
    
    
