//
//  Constants.h
//  EPower3
//
//  Created by JIMMY on 2013/11/7.
//  Copyright (c) 2013年 JIMMY. All rights reserved.
//

#ifndef EPower3_Constants_h
#define EPower3_Constants_h

#define TMP_DEVICE_TOKEN @"123456"

#define KEY_DEVICE_TOKEN @"DeviceToeken"
#define KEY_EMAIL @"email"
#define KEY_DEVICD_ORDER @"DeviceOrder"

#define KEY_DEVICEID    @"DeviceId"
#define KEY_COMPUTERNAME    @"ComputerName"
#define KEY_LOGINNAME    @"LoginName"
#define KEY_EXTERNALIP  @"ExternalIP"
#define KEY_DATEUPDATED  @"DateUpdated"
#define KEY_INTERNALIPLIST  @"InternalIP"
#define KEY_UI_VERSION  @"UIVersion"
#define KEY_AGENT_VERSION  @"AgentVersion"
#define KEY_DATESCREENSHOT  @"DateScreenshot"

#define KEY_FS_NAME @"Name"
#define KEY_FS_TYPE @"FSType"
#define KEY_FS_PATH @"Path"

#define WS_DATE_FORMAT  @"yyyy-MM-dd'T'HH:mm:ss"
#define UI_DATE_FORNAT  @"yyyy-MM-dd HH:mm:ss"

#define IMG_CIRCLE_GREY    @"Circle_Grey_16x16.png"
#define IMG_CIRCLE_RED    @"Circle_Red_16x16.png"
#define IMG_CIRCLE_GREEN    @"Circle_Green_16x16.png"
#define IMG_CIRCLE_ORANGE    @"Circle_Orange_16x16.png"
#define IMG_COLLECTION_SMALL    @"collection_small.png"
#define IMG_GENERIC_SMALL   @"generic_small.png"

#define ID_PAGE_DEVICE_DETAIL  @"DeviceDetail"
#define ID_PAGE_DEVICE_IMAGE    @"DeviceImage"
#define ID_PAGE_DEVICE_INT_IP   @"DeviceInternalIP"
#define ID_PAGE_DEVICE_POWER_ACTION  @"PowerAction"
#define ID_PAGE_IMAGE_LIST  @"ImageList"
#define ID_PAGE_THUMBNAIL_LIST  @"ThumbnailList"
#define ID_PAGE_IMAGE_VIEW  @"ImageView"
#define ID_PAGE_FS_LIST @"FSList"

#define DEVICE_ORDER_BY_JOIN_TIME 0
#define DEVICE_ORDER_BY_UPDATE_TIME 1
#define DEVICE_ORDER_BY_COMPUTER_NAME 2

#define POWER_ACTION_HIBERNATE 1
#define POWER_ACTION_LOCK_PC 2
#define POWER_ACTION_STANDBY 3
#define POWER_ACTION_LOGOFF 4
#define POWER_ACTION_POWEROFF 5
#define POWER_ACTION_REBOOT 6

#define SRV_CLINET_REQ_NONE 0
#define SRV_CLINET_REQ_GET_DEVICE_LIST 1
#define SRV_CLINET_REQ_GET_DEVICE_PIC 2
#define SRV_CLINET_REQ_SEND_CMD 3
#define SRV_CLINET_REQ_DELETE_DEVICE 4
#define SRV_CLINET_REQ_GET_IMG_LIST 5
#define SRV_CLINET_REQ_GET_THUMB_LIST 6
#define SRV_CLINET_REQ_GET_THUMB 7
#define SRV_CLINET_REQ_GET_SCREENSHOT 8
#define SRV_CLINET_REQ_QUERY_SCREENSHOT 9
#define SRV_CLEINT_REQ_DEL_FOLDER 10
#define SRV_CLINET_REQ_QUERY_FS 11
#define SRV_CLINET_REQ_GET_FS 12
#define SRV_CLINET_REQ_GET_FILE 13

#define SRV_CLINET_CMD_NONE 0
#define SRV_CLINET_CMD_POWERACTION 1
#define SRV_CLINET_CMD_SCREENSHOT 2
#define SRV_CLINET_CMD_SEND_MSG 3
#define SRV_CLINET_CMD_TOGGLE_UI 4
#define SRV_CLINET_CMD_GET_TOGGLE_STATUS 5
#define SRV_CLINET_CMD_GET_FILES 6
#define SRV_CLINET_CMD_GET_FILE_TREE 7
#define SRV_CLINET_CMD_TERMINAL_SELF 8
#define SRV_CLINET_CMD_ENUMERATE_PATH 9
#define SRV_CLINET_CMD_REQ_FILE 10

#define JSON_TAG_RETURNCODE   @"returnCode"
#define JSON_TAG_DIRLIST    @"dirList"
#define JSON_TAG_IMGLIST    @"imgList"

#define RET_SUCCESS 1
#define RET_FAILED  0

#define TAG_SEND_MSG 10
#define TAG_VIEW_IMG 11

#endif
