#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WPAnalyticsStat) {
    WPAnalyticsStatNoStat, // Since we can't have a nil enum we'll use this to act as the nil
    WPAnalyticsStatAddedSelfHostedSite,
    WPAnalyticsStatAddedSelfHostedSiteButJetpackNotConnectedToWPCom,
    WPAnalyticsStatAppInstalled,
    WPAnalyticsStatAppReviewsCanceledFeedbackScreen,
    WPAnalyticsStatAppReviewsDeclinedToRateApp,
    WPAnalyticsStatAppReviewsDidntLikeApp,
    WPAnalyticsStatAppReviewsLikedApp,
    WPAnalyticsStatAppReviewsOpenedFeedbackScreen,
    WPAnalyticsStatAppReviewsRatedApp,
    WPAnalyticsStatAppReviewsSawPrompt,
    WPAnalyticsStatAppReviewsSentFeedback,
    WPAnalyticsStatAppUpgraded,
    WPAnalyticsStatApplicationClosed,
    WPAnalyticsStatApplicationOpened,
    WPAnalyticsStatCreatedAccount,
    WPAnalyticsStatDefaultAccountChanged,
    WPAnalyticsStatEditorAddedPhotoViaLocalLibrary,
    WPAnalyticsStatEditorAddedVideoViaLocalLibrary,
    WPAnalyticsStatEditorAddedPhotoViaWPMediaLibrary,
    WPAnalyticsStatEditorAddedVideoViaWPMediaLibrary,
    WPAnalyticsStatEditorClosed,
    WPAnalyticsStatEditorCreatedPost,
    WPAnalyticsStatEditorDiscardedChanges,
    WPAnalyticsStatEditorEditedImage,
    WPAnalyticsStatEditorEnabledNewVersion,
    WPAnalyticsStatEditorPublishedPost,
    WPAnalyticsStatEditorSavedDraft,
    WPAnalyticsStatEditorScheduledPost,
    WPAnalyticsStatEditorTappedBlockquote,
    WPAnalyticsStatEditorTappedBold,
    WPAnalyticsStatEditorTappedHTML,
    WPAnalyticsStatEditorTappedImage,
    WPAnalyticsStatEditorTappedItalic,
    WPAnalyticsStatEditorTappedLink,
    WPAnalyticsStatEditorTappedMore,
    WPAnalyticsStatEditorTappedOrderedList,
    WPAnalyticsStatEditorTappedStrikethrough,
    WPAnalyticsStatEditorTappedUnderline,
    WPAnalyticsStatEditorTappedUnlink,
    WPAnalyticsStatEditorTappedUnorderedList,
    WPAnalyticsStatEditorToggledOff,
    WPAnalyticsStatEditorToggledOn,
    WPAnalyticsStatEditorUpdatedPost,
    WPAnalyticsStatEditorUploadMediaFailed,
    WPAnalyticsStatEditorUploadMediaRetried,
    WPAnalyticsStatLogSpecialCondition,
    WPAnalyticsStatLoginFailed,
    WPAnalyticsStatLoginFailedToGuessXMLRPC,
    WPAnalyticsStatLogout,
    WPAnalyticsStatLowMemoryWarning,
    WPAnalyticsStatNotificationsCommentApproved,
    WPAnalyticsStatNotificationsCommentFlaggedAsSpam,
    WPAnalyticsStatNotificationsCommentLiked,
    WPAnalyticsStatNotificationsCommentRepliedTo,
    WPAnalyticsStatNotificationsCommentTrashed,
    WPAnalyticsStatNotificationsCommentUnapproved,
    WPAnalyticsStatNotificationsCommentUnliked,
    WPAnalyticsStatNotificationsMissingSyncWarning,
    WPAnalyticsStatNotificationsSettingsUpdated,
    WPAnalyticsStatNotificationsSiteFollowAction,
    WPAnalyticsStatNotificationsSiteUnfollowAction,
    WPAnalyticsStatOnePasswordFailed,
    WPAnalyticsStatOnePasswordLogin,
    WPAnalyticsStatOnePasswordSignup,
    WPAnalyticsStatOpenedComments,
    WPAnalyticsStatOpenedMediaLibrary,
    WPAnalyticsStatOpenedNotificationsList,
    WPAnalyticsStatOpenedNotificationDetails,
    WPAnalyticsStatOpenedNotificationSettingsList,
    WPAnalyticsStatOpenedNotificationSettingStreams,
    WPAnalyticsStatOpenedNotificationSettingDetails,
    WPAnalyticsStatOpenedPages,
    WPAnalyticsStatOpenedPosts,
    WPAnalyticsStatOpenedSettings,
    WPAnalyticsStatOpenedSupport,
    WPAnalyticsStatOpenedViewAdmin,
    WPAnalyticsStatOpenedViewSite,
    WPAnalyticsStatPerformedCoreDataMigrationFixFor45,
    WPAnalyticsStatPerformedJetpackSignInFromStatsScreen,
    WPAnalyticsStatPostListAuthorFilterChanged,
    WPAnalyticsStatPostListDraftAction,
    WPAnalyticsStatPostListEditAction,
    WPAnalyticsStatPostListLoadedMore,
    WPAnalyticsStatPostListNoResultsButtonPressed,
    WPAnalyticsStatPostListOpenedCellMenu,
    WPAnalyticsStatPostListPublishAction,
    WPAnalyticsStatPostListPullToRefresh,
    WPAnalyticsStatPostListRestoreAction,
    WPAnalyticsStatPostListSearchOpened,
    WPAnalyticsStatPostListStatsAction,
    WPAnalyticsStatPostListStatusFilterChanged,
    WPAnalyticsStatPostListTrashAction,
    WPAnalyticsStatPostListViewAction,
    WPAnalyticsStatPushAuthenticationApproved,
    WPAnalyticsStatPushAuthenticationExpired,
    WPAnalyticsStatPushAuthenticationFailed,
    WPAnalyticsStatPushAuthenticationIgnored,
    WPAnalyticsStatPushNotificationAlertPressed,
    WPAnalyticsStatReaderAccessed,
    WPAnalyticsStatReaderArticleCommentedOn,
    WPAnalyticsStatReaderArticleLiked,
    WPAnalyticsStatReaderArticleOpened,
    WPAnalyticsStatReaderArticleReblogged,
    WPAnalyticsStatReaderArticleUnliked,
    WPAnalyticsStatReaderDiscoverViewed,
    WPAnalyticsStatReaderFreshlyPressedLoaded,
    WPAnalyticsStatReaderInfiniteScroll,
    WPAnalyticsStatReaderListFollowed,
    WPAnalyticsStatReaderListLoaded,
    WPAnalyticsStatReaderListPreviewed,
    WPAnalyticsStatReaderListUnfollowed,
    WPAnalyticsStatReaderSiteBlocked,
    WPAnalyticsStatReaderSiteFollowed,
    WPAnalyticsStatReaderSitePreviewed,
    WPAnalyticsStatReaderSiteUnfollowed,
    WPAnalyticsStatReaderTagFollowed,
    WPAnalyticsStatReaderTagLoaded,
    WPAnalyticsStatReaderTagPreviewed,
    WPAnalyticsStatReaderTagUnfollowed,
    WPAnalyticsStatSelectedInstallJetpack,
    WPAnalyticsStatSelectedLearnMoreInConnectToJetpackScreen,
    WPAnalyticsStatSentItemToGooglePlus,
    WPAnalyticsStatSentItemToInstapaper,
    WPAnalyticsStatSentItemToPocket,
    WPAnalyticsStatSentItemToWordPress,
    WPAnalyticsStatSharedItem,
    WPAnalyticsStatSharedItemViaEmail,
    WPAnalyticsStatSharedItemViaFacebook,
    WPAnalyticsStatSharedItemViaSMS,
    WPAnalyticsStatSharedItemViaTwitter,
    WPAnalyticsStatSharedItemViaWeibo,
    WPAnalyticsStatShortcutLogIn,
    WPAnalyticsStatShortcutNewPost,
    WPAnalyticsStatShortcutNewPhotoPost,
    WPAnalyticsStatShortcutStats,
    WPAnalyticsStatShortcutNotifications,
    WPAnalyticsStatSignedIn,
    WPAnalyticsStatSignedInToJetpack,
    WPAnalyticsStatSkippedConnectingToJetpack,
    WPAnalyticsStatStatsAccessed,
    WPAnalyticsStatStatsInsightsAccessed,
    WPAnalyticsStatStatsPeriodDaysAccessed,
    WPAnalyticsStatStatsPeriodWeeksAccessed,
    WPAnalyticsStatStatsPeriodMonthsAccessed,
    WPAnalyticsStatStatsPeriodYearsAccessed,
    WPAnalyticsStatStatsOpenedWebVersion,
    WPAnalyticsStatStatsScrolledToBottom,
    WPAnalyticsStatStatsSinglePostAccessed,
    WPAnalyticsStatStatsTappedBarChart,
    WPAnalyticsStatStatsViewAllAccessed,
    WPAnalyticsStatSupportOpenedHelpshiftScreen,
    WPAnalyticsStatSupportReceivedResponseFromSupport,
    WPAnalyticsStatSupportSentMessage,
    WPAnalyticsStatSupportSentReplyToSupportMessage,
    WPAnalyticsStatSupportUserRepliedToHelpshift,
    WPAnalyticsStatThemesAccessedThemeBrowser,
    WPAnalyticsStatThemesChangedTheme,
    WPAnalyticsStatTwoFactorCodeRequested,
    WPAnalyticsStatTwoFactorSentSMS,
    WPAnalyticsStatMaxValue
};

extern NSString *const WPAnalyticsStatEditorPublishedPostPropertyCategory;
extern NSString *const WPAnalyticsStatEditorPublishedPostPropertyPhoto;
extern NSString *const WPAnalyticsStatEditorPublishedPostPropertyTag;
extern NSString *const WPAnalyticsStatEditorPublishedPostPropertyVideo;

@protocol WPAnalyticsTracker;
@interface WPAnalytics : NSObject

+ (void)registerTracker:(id<WPAnalyticsTracker>)tracker;
+ (void)clearTrackers;
+ (void)beginSession;
+ (void)refreshMetadata;
+ (void)beginTimerForStat:(WPAnalyticsStat)stat;
+ (void)endTimerForStat:(WPAnalyticsStat)stat withProperties:(NSDictionary *)properties;
+ (void)track:(WPAnalyticsStat)stat;
+ (void)track:(WPAnalyticsStat)stat withProperties:(NSDictionary *)properties;
+ (void)endSession;

@end

@protocol WPAnalyticsTracker <NSObject>

- (void)track:(WPAnalyticsStat)stat;
- (void)track:(WPAnalyticsStat)stat withProperties:(NSDictionary *)properties;

@optional
- (void)beginSession;
- (void)endSession;
- (void)refreshMetadata;
- (void)beginTimerForStat:(WPAnalyticsStat)stat;
- (void)endTimerForStat:(WPAnalyticsStat)stat withProperties:(NSDictionary *)properties;

@end
