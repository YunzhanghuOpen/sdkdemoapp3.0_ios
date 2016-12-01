//
//  EaseRedBagCell.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/23.
//


#import "EaseRedBagCell.h"
#import "RedpacketOpenConst.h"
#import "UIImageView+EMWebCache.h"
#import "RedpacketView.h"
#import "RedPacketLuckView.h"
#import "RedpacketMessageModel.h"
#import "RedpacketMessageModel.h"

@interface EaseRedBagCell()

@property (nonatomic, strong) RedpacketView *redpacketView;
@property (nonatomic, strong) RedPacketLuckView *repacketLuckView;
@property (nonatomic, strong) RedpacketMessageModel *redpacketMessageModel;

@end

@implementation EaseRedBagCell

#pragma mark - IModelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    
    if (self) {
        self.hasRead.hidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _redpacketMessageModel = [RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext];
        if (_redpacketMessageModel.redpacketType == RedpacketTypeAmount) {
            [self.bubbleView.backgroundImageView addSubview:self.repacketLuckView];
        }else {
            [self.bubbleView.backgroundImageView addSubview: self.redpacketView];
        }
    }
    
    return self;
}

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    _bubbleView.translatesAutoresizingMaskIntoConstraints = YES;
    
    if (model.isSender) {
        if (_redpacketMessageModel.redpacketType == RedpacketTypeAmount) {
            _bubbleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 175, 8, 116, 140);
        }else {
            _bubbleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 273.5, 2, 213, 94);
        }
    }else {
        if (_redpacketMessageModel.redpacketType == RedpacketTypeAmount) {
            _bubbleView.frame = CGRectMake(55, 8, 116, 140);
        }else {
            _bubbleView.frame = CGRectMake(55, 2, 213, 94);
        }
    }
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender ? @"__redPacketCellSendIdentifier__" : @"__redPacketCellReceiveIdentifier__";
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    RedpacketMessageModel *messageModel = [RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext];
    if (messageModel.redpacketType == RedpacketTypeAmount) {
        return [RedPacketLuckView heightForRedpacketMessageCell] + 20;
    }else {
        return [RedpacketView redpacketViewHeight] + 20;
    }
}

- (void)setModel:(id<IMessageModel>)model
{
    [super setModel:model];
    if (_redpacketMessageModel.redpacketType == RedpacketTypeAmount) {
        [_repacketLuckView configWithRedpacketMessageModel:[RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext]];
    }else {
        [_redpacketView configWithRedpacketMessageModel:[RedpacketMessageModel redpacketMessageModelWithDic:model.message.ext]
                                        andRedpacketDic:model.message.ext];
    }
    /** 红包消息不显示已读 */
    _hasRead.hidden = YES;
    /** 不显示姓名 */
    _nameLabel = nil;
}

- (RedpacketView *)redpacketView
{
    if (!_redpacketView) {
        _redpacketView = [[RedpacketView alloc]init];
    }
    return _redpacketView;
}

- (RedPacketLuckView *)repacketLuckView
{
    if (!_repacketLuckView) {
        _repacketLuckView = [[RedPacketLuckView alloc]init];
    }
    return _repacketLuckView;
}

@end
