 //
//  ChatWithRedPacketViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/23.
//


#import "RedPacketChatViewController.h"
#import "EaseRedBagCell.h"
#import "UIImageView+EMWebCache.h"
#import "RedpacketMessageCell.h"
#import "RedpacketViewControl.h"
#import "RedpacketMessageModel.h"
#import "RedPacketUserConfig.h"
#import "RedpacketOpenConst.h"
#import "YZHRedpacketBridge.h"
#import "UserProfileManager.h"
#import "RedpacketDefines.h"


/** 红包单击事件索引 */
static NSInteger const redpacketSendIndex       = 6;

/** 零钱单击事件索引 */
static NSInteger const redpacketTransferIndex   = 7;


@interface RedPacketChatViewController () < EaseMessageCellDelegate,
                                            EaseMessageViewControllerDataSource,
                                            RedpacketViewControlDelegate>
/** 发红包的控制器 */
@property (nonatomic, strong)   RedpacketViewControl *viewControl;

@end

@implementation RedPacketChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** 红包功能的控制器， 产生用户单击红包后的各种动作 */
    _viewControl = [[RedpacketViewControl alloc] init];
    
    /** 需要当前的聊天窗口 */
    _viewControl.conversationController = self;
    
    /** 群红包需要的返回成员列表 */
    _viewControl.delegate = self;
    
    /** 需要当前聊天窗口的会话ID */
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = self.conversation.chatter;
    _viewControl.converstationInfo = userInfo;
    
    __weak typeof(self) weakSelf = self;
    /** 用户抢红包和用户发送红包的回调 */
    [_viewControl setRedpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
        /** 小额随机红包没有推送消息 */
        if (messageModel.redpacketType != RedpacketTypeAmount) {
            /** 发送通知到发送红包者处 */
            [weakSelf sendRedpacketHasBeenTaked:messageModel];
        }
    } andRedpacketBlock:^(RedpacketMessageModel *model) {
        /** 发送红包 */
        [weakSelf sendRedPacketMessage:model];
    }];
    
    /** 设置用户头像大小 */
    [[EaseRedBagCell appearance] setAvatarSize:40.f];
    /** 设置头像圆角 */
    [[EaseRedBagCell appearance] setAvatarCornerRadius:20.f];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                               NSFontAttributeName : [UIFont systemFontOfSize:18]};
    
    if ([self.chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        /** 红包按钮 */
        [self.chatBarMoreView insertItemWithImage:RedpacketImage(@"redpacket_redpacket")
                                 highlightedImage:RedpacketImage(@"redpacket_redpacket_high")
                                            title:@"红包"];
        /** 转账按钮 */
        [self.chatBarMoreView insertItemWithImage:RedpacketImage(@"redpacket_transfer_high")
                                 highlightedImage:RedpacketImage(@"redpacket_transfer_high")
                                            title:@"转账"];
    }
    
    /** 抢红包红包提示消息视图 */
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RedpacketMessageCell class]) bundle:nil]forCellReuseIdentifier:NSStringFromClass([RedpacketMessageCell class])];
    
}

/** 长时间按在某条Cell上的动作 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object conformsToProtocol:NSProtocolFromString(@"IMessageModel")]) {
        id <IMessageModel> messageModel = object;
        NSDictionary *ext = messageModel.message.ext;
        
        /** 如果是红包，则只显示删除按钮 */
        if ([RedpacketMessageModel isRedpacket:ext]) {
            
            EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            self.menuIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:eMessageBodyType_Command];
            return NO;
            
        }else if ([RedpacketMessageModel isRedpacketTakenMessage:ext]) {
            return NO;
        }
    }
    return [super messageViewController:viewController canLongPressRowAtIndexPath:indexPath];
}

#pragma mark - EaseMessageCellDelegate 单击了Cell 事件
- (void)messageCellSelected:(id<IMessageModel>)model
{
    NSDictionary *dict = model.message.ext;
    
    if ([RedpacketMessageModel isRedpacket:dict]) {
        
        [self.viewControl redpacketCellTouchedWithMessageModel:[self toRedpacketMessageModel:model]];
        
    }else if([RedpacketMessageModel isRedpacketTransferMessage:dict]){
        
        [self.viewControl presentTransferDetailViewController:[RedpacketMessageModel redpacketMessageModelWithDic:dict]];
        
    }else {
        
        [super messageCellSelected:model];
        
    }
}

#pragma mrak - 自定义红包的Cell
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel
{
    NSDictionary *ext = messageModel.message.ext;
    
    if ([RedpacketMessageModel isRedpacketRelatedMessage:ext]) {
        if ([RedpacketMessageModel isRedpacket:ext] || [RedpacketMessageModel isRedpacketTransferMessage:ext]) {
            EaseRedBagCell *cell = [tableView dequeueReusableCellWithIdentifier:[EaseRedBagCell cellIdentifierWithModel:messageModel]];
            if (!cell) {
                cell = [[EaseRedBagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EaseRedBagCell cellIdentifierWithModel:messageModel] model:messageModel];
                cell.delegate = self;
            }
            
            cell.model = messageModel;
            return cell;
        }
        
        RedpacketMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RedpacketMessageCell class])];
        cell.model = messageModel;
        
        return cell;
    }
    
    return [super messageViewController:tableView cellForMessageModel:messageModel];
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    
    if ([RedpacketMessageModel isRedpacket:ext] || [RedpacketMessageModel isRedpacketTransferMessage:ext])    {
        return [EaseRedBagCell cellHeightWithModel:messageModel];
        
    }else if ([RedpacketMessageModel isRedpacketTakenMessage:ext]) {
        return 36;
    }
    
    return [super messageViewController:viewController heightForMessageModel:messageModel withCellWidth:cellWidth];
}

#pragma mark - DataSource
/** 未读消息回执 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
shouldSendHasReadAckForMessage:(EMMessage *)message
                         read:(BOOL)read
{
    NSDictionary *ext = message.ext;
    if ([RedpacketMessageModel isRedpacketRelatedMessage:ext]) {
        return YES;
    }
    return [super shouldSendHasReadAckForMessage:message read:read];
}

#pragma mark - 发送红包消息
- (void)messageViewController:(EaseMessageViewController *)viewController didSelectMoreView:(EaseChatBarMoreView *)moreView AtIndex:(NSInteger)index
{
    if (index == redpacketSendIndex || index == 3) {
        if (self.conversation.conversationType == eConversationTypeChat) {
            /** 单聊发送界面 */
            [self.viewControl presentRedPacketViewControllerWithType:RPSendRedPacketViewControllerRand memberCount:0];
        }else {
            /** 群聊红包发送界面 */
            NSArray *groupArray = [EMGroup groupWithId:self.conversation.chatter].occupants;
            [self.viewControl presentRedPacketViewControllerWithType:RPSendRedPacketViewControllerMember memberCount:groupArray.count];
        }
    } else if (index == redpacketTransferIndex) {
        /** 转账页面 */
        RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
        userInfo = [self profileEntityWith:self.conversation.chatter];
        [self.viewControl presentTransferViewControllerWithReceiver:userInfo];
        
    }else {
        [self.chatToolbar endEditing:YES];
    }
}

#pragma mark - Delegate RedpacketViewControlDelegate
- (void)getGroupMemberListCompletionHandle:(void (^)(NSArray<RedpacketUserInfo *> * groupMemberList))completionHandle
{
    NSArray *groupArray = [[[EaseMob sharedInstance] chatManager] fetchOccupantList:self.conversation.chatter error:nil];
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    for (NSString *username in groupArray) {
        /** 创建一个用户模型 并赋值 */
        RedpacketUserInfo *userInfo = [self profileEntityWith:username];
        [mArray addObject:userInfo];
    }
    completionHandle(mArray);
}

- (void)sendRedPacketMessage:(RedpacketMessageModel *)model
{
    NSDictionary *dic = [model redpacketMessageModelToDic];
    NSString *message = [NSString stringWithFormat:@"[%@]%@", model.redpacket.redpacketOrgName, model.redpacket.redpacketGreeting];
    if ([RedpacketMessageModel isRedpacketTransferMessage:dic]) {
        message = [NSString stringWithFormat:@"[转账]转账%@元",model.redpacket.redpacketMoney];
    }
    [self sendTextMessage:message withExt:dic];
}

#pragma mark -  发送红包被抢的消息
- (void)sendRedpacketHasBeenTaked:(RedpacketMessageModel *)messageModel
{
    NSString *text = nil;
    NSMutableDictionary *dict = [messageModel.redpacketMessageModelToDic mutableCopy];
    /** 当前用户的用户ID */
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    if (self.conversation.conversationType == eConversationTypeChat) {
        /** 忽略推送 */
        [dict setValue:@(YES) forKey:@"em_ignore_notification"];
        NSString *receiver = messageModel.redpacketReceiver.userNickname;
        if (receiver.length > 18) {
            receiver = [[receiver substringToIndex:18] stringByAppendingString:@"..."];
        }
        text = [NSString stringWithFormat:@"%@领取了你的红包", receiver];
        [self sendTextMessage:text withExt:dict];
    }else {
        if ([messageModel.redpacketSender.userId isEqualToString:currentUserId]) {
            text = @"你领取了自己的红包";
        }else {
            NSString *sender = messageModel.redpacketSender.userNickname;
            if (sender.length > 18) {
               sender = [[sender substringToIndex:18] stringByAppendingString:@"..."];
            }
            text = [NSString stringWithFormat:@"你领取了%@的红包", sender];
            [[EaseMob sharedInstance].chatManager asyncSendMessage:[self createCmdMessageWithModel:messageModel] progress:nil];
        }
        EMMessage *redpacketGroupMessage = [self createTextMessageWithText:text receiver:self.conversation.chatter andExt:dict];
        [self addMessageToDataSource:redpacketGroupMessage progress:nil];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:redpacketGroupMessage append2Chat:YES];
    }
}

- (EMMessage *)createCmdMessageWithModel:(RedpacketMessageModel *)model
{
    NSMutableDictionary *dict = [model.redpacketMessageModelToDic mutableCopy];
    EMChatCommand *cmdChat = [[EMChatCommand alloc] init];
    cmdChat.cmd = RedpacketKeyRedapcketCmd;
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmdChat];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:model.redpacketSender.userId bodies:@[body]];
    message.ext = dict;
    message.messageType = eMessageTypeChat;
    return message;
}

- (RedpacketMessageModel *)toRedpacketMessageModel:(id <IMessageModel>)model
{
    RedpacketMessageModel *messageModel = [RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext];
    BOOL isGroup = self.conversation.conversationType == eConversationTypeGroupChat;
    if (isGroup) {
        /** 如果群支持自定义头像 和 昵称 可以根据单独赋值 */
        messageModel.redpacketSender= [self profileEntityWith:model.message.groupSenderName];
        /** 此处需根据专属红包接收者的ID  给起头像地址  和  昵称赋值 */
        messageModel.toRedpacketReceiver = [self profileEntityWith:messageModel.toRedpacketReceiver.userId];
    }else {
        /** 如果群支持自定义头像 和 昵称 可以根据单独赋值 */
        messageModel.redpacketSender = [self profileEntityWith:model.message.from];
    }
    return messageModel;
}

/** 要在此处根据userID获得用户昵称,和头像地址 */
- (RedpacketUserInfo *)profileEntityWith:(NSString *)userId
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:userId];
    if (profileEntity) {
        if (profileEntity.nickname && profileEntity.nickname.length > 0) {
            userInfo.userNickname = profileEntity.nickname;
        } else {
            userInfo.userNickname = userId;
        }
    } else {
        userInfo.userNickname = userId;
    }
    userInfo.userAvatar = profileEntity.imageUrl;
    userInfo.userId = userId;
    return userInfo;
}

#pragma mark - EMChatManagerChatDelegate
- (void)didReceiveCmdMessage:(EMMessage *)message
{
    NSString *currentUserId = [[[[EaseMob sharedInstance] chatManager] loginInfo] objectForKey:kSDKUsername];
    NSString *senderId = message.ext[RedpacketKeyRedpacketSenderId];
    /** 为了兼容老版本传过来的Cmd消息，必须做一下判断 */
    BOOL isRedpacketSender = [currentUserId isEqualToString:senderId];
    EMCommandMessageBody * body = (EMCommandMessageBody *)message.messageBodies[0];
    if ([body.action isEqualToString:RedpacketKeyRedapcketCmd] && isRedpacketSender) {
        NSString *receiver = message.ext[RedpacketKeyRedpacketCmdToGroup];
        /** 红包消息属于当前聊天窗口 */
        if(receiver.length == 0) {
            receiver = message.from;
        }
        if ([receiver isEqualToString:self.conversation.chatter]) {
            [self addMessageToDataSource:[self cmdMessageBodyToTextMessageBody:message toReceiver:receiver] progress:nil];
        }
    }
}

- (EMMessage *)cmdMessageBodyToTextMessageBody:(EMMessage *)message
                                    toReceiver:(NSString *)receiver
{
    NSDictionary *dict = message.ext;
    NSString *receiverNick = [dict valueForKey:RedpacketKeyRedpacketReceiverNickname];
    
    if (receiverNick.length > 18) {
        receiverNick = [[receiverNick substringToIndex:18] stringByAppendingString:@"..."];
    }
    
    NSString *text = [NSString stringWithFormat:@"%@领取了你的红包",receiverNick];
    return [self createTextMessageWithText:text receiver:receiver andExt:message.ext];
}

- (EMMessage *)createTextMessageWithText:(NSString *)text
                                receiver:(NSString *)receiverId
                                  andExt:(NSDictionary *)ext
{
    NSString *willSendText = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    EMChatText *textChat = [[EMChatText alloc] initWithText:willSendText];
    EMTextMessageBody *body1 = [[EMTextMessageBody alloc] initWithChatObject:textChat];
    EMMessage *redpacketGroupMessage = [[EMMessage alloc] initWithReceiver:receiverId bodies:[NSArray arrayWithObject:body1]];
    redpacketGroupMessage.requireEncryption = NO;
    redpacketGroupMessage.messageType = eMessageTypeGroupChat;
    redpacketGroupMessage.ext = ext;
    redpacketGroupMessage.deliveryState = eMessageDeliveryState_Delivered;
    redpacketGroupMessage.isRead = YES;
    return redpacketGroupMessage;
}

@end
