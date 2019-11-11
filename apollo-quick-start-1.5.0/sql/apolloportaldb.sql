/*
 Navicat Premium Data Transfer

 Source Server         : docker本地的mysql56
 Source Server Type    : MySQL
 Source Server Version : 50728
 Source Host           : localhost
 Source Database       : ApolloPortalDB

 Target Server Type    : MySQL
 Target Server Version : 50728
 File Encoding         : utf-8

 Date: 11/11/2019 14:31:14 PM
*/


CREATE DATABASE IF NOT EXISTS ApolloPortalDB DEFAULT CHARACTER SET = utf8mb4;

Use ApolloPortalDB;

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `App`
-- ----------------------------
DROP TABLE IF EXISTS `App`;
CREATE TABLE `App` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `AppId` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `Name` varchar(500) NOT NULL DEFAULT 'default' COMMENT '应用名',
  `OrgId` varchar(32) NOT NULL DEFAULT 'default' COMMENT '部门Id',
  `OrgName` varchar(64) NOT NULL DEFAULT 'default' COMMENT '部门名字',
  `OwnerName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'ownerName',
  `OwnerEmail` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'ownerEmail',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `AppId` (`AppId`(191)),
  KEY `DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_Name` (`Name`(191))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='应用表';

-- ----------------------------
--  Records of `App`
-- ----------------------------
BEGIN;
INSERT INTO `App` VALUES ('1', 'SampleApp', 'Sample App', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'default', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('2', 'com.jingoufish.apigateway', 'apigateway-server', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('3', 'com.jingoufish.auth', 'auth-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('4', 'com.jingoufish.product', 'product-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('5', 'com.jingoufish.order', 'order-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('6', 'com.404abc.apigateway', 'apigateway-server', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('7', 'com.404abc.auth', 'auth-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('8', 'com.404abc.product', 'product-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('9', 'com.404abc.order', 'order-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `AppNamespace`
-- ----------------------------
DROP TABLE IF EXISTS `AppNamespace`;
CREATE TABLE `AppNamespace` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `Name` varchar(32) NOT NULL DEFAULT '' COMMENT 'namespace名字，注意，需要全局唯一',
  `AppId` varchar(32) NOT NULL DEFAULT '' COMMENT 'app id',
  `Format` varchar(32) NOT NULL DEFAULT 'properties' COMMENT 'namespace的format类型',
  `IsPublic` bit(1) NOT NULL DEFAULT b'0' COMMENT 'namespace是否为公共',
  `Comment` varchar(64) NOT NULL DEFAULT '' COMMENT '注释',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT '' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_AppId` (`AppId`),
  KEY `Name_AppId` (`Name`,`AppId`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='应用namespace定义';

-- ----------------------------
--  Records of `AppNamespace`
-- ----------------------------
BEGIN;
INSERT INTO `AppNamespace` VALUES ('1', 'application', 'SampleApp', 'properties', b'0', 'default app namespace', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('2', 'application', 'com.jingoufish.apigateway', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('3', 'application', 'com.jingoufish.auth', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('4', 'application', 'com.jingoufish.product', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('5', 'application', 'com.jingoufish.order', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('6', 'application', 'com.404abc.apigateway', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('7', 'application', 'com.404abc.auth', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('8', 'application', 'com.404abc.product', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('9', 'application', 'com.404abc.order', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `Authorities`
-- ----------------------------
DROP TABLE IF EXISTS `Authorities`;
CREATE TABLE `Authorities` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `Username` varchar(64) NOT NULL,
  `Authority` varchar(50) NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Records of `Authorities`
-- ----------------------------
BEGIN;
INSERT INTO `Authorities` VALUES ('1', 'apollo', 'ROLE_user');
COMMIT;

-- ----------------------------
--  Table structure for `Consumer`
-- ----------------------------
DROP TABLE IF EXISTS `Consumer`;
CREATE TABLE `Consumer` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `AppId` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `Name` varchar(500) NOT NULL DEFAULT 'default' COMMENT '应用名',
  `OrgId` varchar(32) NOT NULL DEFAULT 'default' COMMENT '部门Id',
  `OrgName` varchar(64) NOT NULL DEFAULT 'default' COMMENT '部门名字',
  `OwnerName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'ownerName',
  `OwnerEmail` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'ownerEmail',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `AppId` (`AppId`(191)),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='开放API消费者';

-- ----------------------------
--  Table structure for `ConsumerAudit`
-- ----------------------------
DROP TABLE IF EXISTS `ConsumerAudit`;
CREATE TABLE `ConsumerAudit` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `ConsumerId` int(11) unsigned DEFAULT NULL COMMENT 'Consumer Id',
  `Uri` varchar(1024) NOT NULL DEFAULT '' COMMENT '访问的Uri',
  `Method` varchar(16) NOT NULL DEFAULT '' COMMENT '访问的Method',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_ConsumerId` (`ConsumerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='consumer审计表';

-- ----------------------------
--  Table structure for `ConsumerRole`
-- ----------------------------
DROP TABLE IF EXISTS `ConsumerRole`;
CREATE TABLE `ConsumerRole` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `ConsumerId` int(11) unsigned DEFAULT NULL COMMENT 'Consumer Id',
  `RoleId` int(10) unsigned DEFAULT NULL COMMENT 'Role Id',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) DEFAULT '' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_RoleId` (`RoleId`),
  KEY `IX_ConsumerId_RoleId` (`ConsumerId`,`RoleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='consumer和role的绑定表';

-- ----------------------------
--  Table structure for `ConsumerToken`
-- ----------------------------
DROP TABLE IF EXISTS `ConsumerToken`;
CREATE TABLE `ConsumerToken` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `ConsumerId` int(11) unsigned DEFAULT NULL COMMENT 'ConsumerId',
  `Token` varchar(128) NOT NULL DEFAULT '' COMMENT 'token',
  `Expires` datetime NOT NULL DEFAULT '2099-01-01 00:00:00' COMMENT 'token失效时间',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_Token` (`Token`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='consumer token表';

-- ----------------------------
--  Table structure for `Favorite`
-- ----------------------------
DROP TABLE IF EXISTS `Favorite`;
CREATE TABLE `Favorite` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `UserId` varchar(32) NOT NULL DEFAULT 'default' COMMENT '收藏的用户',
  `AppId` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `Position` int(32) NOT NULL DEFAULT '10000' COMMENT '收藏顺序',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `AppId` (`AppId`(191)),
  KEY `IX_UserId` (`UserId`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COMMENT='应用收藏表';

-- ----------------------------
--  Table structure for `Permission`
-- ----------------------------
DROP TABLE IF EXISTS `Permission`;
CREATE TABLE `Permission` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `PermissionType` varchar(32) NOT NULL DEFAULT '' COMMENT '权限类型',
  `TargetId` varchar(256) NOT NULL DEFAULT '' COMMENT '权限对象类型',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT '' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_TargetId_PermissionType` (`TargetId`(191),`PermissionType`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COMMENT='permission表';

-- ----------------------------
--  Records of `Permission`
-- ----------------------------
BEGIN;
INSERT INTO `Permission` VALUES ('1', 'CreateCluster', 'SampleApp', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('2', 'CreateNamespace', 'SampleApp', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('3', 'AssignRole', 'SampleApp', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('4', 'ModifyNamespace', 'SampleApp+application', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('5', 'ReleaseNamespace', 'SampleApp+application', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('6', 'CreateApplication', 'SystemRole', b'0', 'apollo', '2019-11-04 11:05:29', 'apollo', '2019-11-04 11:05:29'), ('7', 'CreateNamespace', 'com.jingoufish.apigateway', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('8', 'AssignRole', 'com.jingoufish.apigateway', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('9', 'CreateCluster', 'com.jingoufish.apigateway', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('10', 'ManageAppMaster', 'com.jingoufish.apigateway', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('11', 'ModifyNamespace', 'com.jingoufish.apigateway+application', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('12', 'ReleaseNamespace', 'com.jingoufish.apigateway+application', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('13', 'ModifyNamespace', 'com.jingoufish.apigateway+application+DEV', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('14', 'ReleaseNamespace', 'com.jingoufish.apigateway+application+DEV', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 04:48:43'), ('15', 'CreateNamespace', 'com.jingoufish.auth', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('16', 'AssignRole', 'com.jingoufish.auth', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('17', 'CreateCluster', 'com.jingoufish.auth', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('18', 'ManageAppMaster', 'com.jingoufish.auth', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('19', 'ModifyNamespace', 'com.jingoufish.auth+application', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('20', 'ReleaseNamespace', 'com.jingoufish.auth+application', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('21', 'ModifyNamespace', 'com.jingoufish.auth+application+DEV', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('22', 'ReleaseNamespace', 'com.jingoufish.auth+application+DEV', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('23', 'AssignRole', 'com.jingoufish.product', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('24', 'CreateCluster', 'com.jingoufish.product', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('25', 'CreateNamespace', 'com.jingoufish.product', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('26', 'ManageAppMaster', 'com.jingoufish.product', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('27', 'ModifyNamespace', 'com.jingoufish.product+application', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('28', 'ReleaseNamespace', 'com.jingoufish.product+application', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('29', 'ModifyNamespace', 'com.jingoufish.product+application+DEV', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('30', 'ReleaseNamespace', 'com.jingoufish.product+application+DEV', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('31', 'CreateCluster', 'com.jingoufish.order', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('32', 'CreateNamespace', 'com.jingoufish.order', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('33', 'AssignRole', 'com.jingoufish.order', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('34', 'ManageAppMaster', 'com.jingoufish.order', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('35', 'ModifyNamespace', 'com.jingoufish.order+application', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('36', 'ReleaseNamespace', 'com.jingoufish.order+application', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('37', 'ModifyNamespace', 'com.jingoufish.order+application+DEV', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('38', 'ReleaseNamespace', 'com.jingoufish.order+application+DEV', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('39', 'CreateCluster', 'com.404abc.apigateway', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('40', 'AssignRole', 'com.404abc.apigateway', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('41', 'CreateNamespace', 'com.404abc.apigateway', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('42', 'ManageAppMaster', 'com.404abc.apigateway', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('43', 'ModifyNamespace', 'com.404abc.apigateway+application', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('44', 'ReleaseNamespace', 'com.404abc.apigateway+application', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('45', 'ModifyNamespace', 'com.404abc.apigateway+application+DEV', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('46', 'ReleaseNamespace', 'com.404abc.apigateway+application+DEV', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('47', 'CreateCluster', 'com.404abc.auth', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('48', 'CreateNamespace', 'com.404abc.auth', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('49', 'AssignRole', 'com.404abc.auth', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('50', 'ManageAppMaster', 'com.404abc.auth', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('51', 'ModifyNamespace', 'com.404abc.auth+application', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('52', 'ReleaseNamespace', 'com.404abc.auth+application', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('53', 'ModifyNamespace', 'com.404abc.auth+application+DEV', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('54', 'ReleaseNamespace', 'com.404abc.auth+application+DEV', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('55', 'CreateNamespace', 'com.404abc.product', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('56', 'AssignRole', 'com.404abc.product', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('57', 'CreateCluster', 'com.404abc.product', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('58', 'ManageAppMaster', 'com.404abc.product', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('59', 'ModifyNamespace', 'com.404abc.product+application', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('60', 'ReleaseNamespace', 'com.404abc.product+application', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('61', 'ModifyNamespace', 'com.404abc.product+application+DEV', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('62', 'ReleaseNamespace', 'com.404abc.product+application+DEV', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('63', 'AssignRole', 'com.404abc.order', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('64', 'CreateNamespace', 'com.404abc.order', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('65', 'CreateCluster', 'com.404abc.order', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('66', 'ManageAppMaster', 'com.404abc.order', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('67', 'ModifyNamespace', 'com.404abc.order+application', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('68', 'ReleaseNamespace', 'com.404abc.order+application', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('69', 'ModifyNamespace', 'com.404abc.order+application+DEV', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('70', 'ReleaseNamespace', 'com.404abc.order+application+DEV', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `Role`
-- ----------------------------
DROP TABLE IF EXISTS `Role`;
CREATE TABLE `Role` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `RoleName` varchar(256) NOT NULL DEFAULT '' COMMENT 'Role name',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_RoleName` (`RoleName`(191)),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- ----------------------------
--  Records of `Role`
-- ----------------------------
BEGIN;
INSERT INTO `Role` VALUES ('1', 'Master+SampleApp', b'0', 'default', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('2', 'ModifyNamespace+SampleApp+application', b'0', 'default', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('3', 'ReleaseNamespace+SampleApp+application', b'0', 'default', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('4', 'CreateApplication+SystemRole', b'0', 'apollo', '2019-11-04 11:05:29', 'apollo', '2019-11-04 11:05:29'), ('5', 'Master+com.jingoufish.apigateway', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('6', 'ManageAppMaster+com.jingoufish.apigateway', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('7', 'ModifyNamespace+com.jingoufish.apigateway+application', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('8', 'ReleaseNamespace+com.jingoufish.apigateway+application', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('9', 'ModifyNamespace+com.jingoufish.apigateway+application+DEV', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('10', 'ReleaseNamespace+com.jingoufish.apigateway+application+DEV', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 04:48:43'), ('11', 'Master+com.jingoufish.auth', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('12', 'ManageAppMaster+com.jingoufish.auth', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('13', 'ModifyNamespace+com.jingoufish.auth+application', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('14', 'ReleaseNamespace+com.jingoufish.auth+application', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('15', 'ModifyNamespace+com.jingoufish.auth+application+DEV', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('16', 'ReleaseNamespace+com.jingoufish.auth+application+DEV', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('17', 'Master+com.jingoufish.product', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('18', 'ManageAppMaster+com.jingoufish.product', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('19', 'ModifyNamespace+com.jingoufish.product+application', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('20', 'ReleaseNamespace+com.jingoufish.product+application', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('21', 'ModifyNamespace+com.jingoufish.product+application+DEV', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('22', 'ReleaseNamespace+com.jingoufish.product+application+DEV', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('23', 'Master+com.jingoufish.order', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('24', 'ManageAppMaster+com.jingoufish.order', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('25', 'ModifyNamespace+com.jingoufish.order+application', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('26', 'ReleaseNamespace+com.jingoufish.order+application', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('27', 'ModifyNamespace+com.jingoufish.order+application+DEV', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('28', 'ReleaseNamespace+com.jingoufish.order+application+DEV', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('29', 'Master+com.404abc.apigateway', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('30', 'ManageAppMaster+com.404abc.apigateway', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('31', 'ModifyNamespace+com.404abc.apigateway+application', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('32', 'ReleaseNamespace+com.404abc.apigateway+application', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('33', 'ModifyNamespace+com.404abc.apigateway+application+DEV', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('34', 'ReleaseNamespace+com.404abc.apigateway+application+DEV', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('35', 'Master+com.404abc.auth', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('36', 'ManageAppMaster+com.404abc.auth', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('37', 'ModifyNamespace+com.404abc.auth+application', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('38', 'ReleaseNamespace+com.404abc.auth+application', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('39', 'ModifyNamespace+com.404abc.auth+application+DEV', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('40', 'ReleaseNamespace+com.404abc.auth+application+DEV', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('41', 'Master+com.404abc.product', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('42', 'ManageAppMaster+com.404abc.product', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('43', 'ModifyNamespace+com.404abc.product+application', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('44', 'ReleaseNamespace+com.404abc.product+application', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('45', 'ModifyNamespace+com.404abc.product+application+DEV', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('46', 'ReleaseNamespace+com.404abc.product+application+DEV', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('47', 'Master+com.404abc.order', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('48', 'ManageAppMaster+com.404abc.order', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('49', 'ModifyNamespace+com.404abc.order+application', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('50', 'ReleaseNamespace+com.404abc.order+application', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('51', 'ModifyNamespace+com.404abc.order+application+DEV', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('52', 'ReleaseNamespace+com.404abc.order+application+DEV', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `RolePermission`
-- ----------------------------
DROP TABLE IF EXISTS `RolePermission`;
CREATE TABLE `RolePermission` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `RoleId` int(10) unsigned DEFAULT NULL COMMENT 'Role Id',
  `PermissionId` int(10) unsigned DEFAULT NULL COMMENT 'Permission Id',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) DEFAULT '' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_RoleId` (`RoleId`),
  KEY `IX_PermissionId` (`PermissionId`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COMMENT='角色和权限的绑定表';

-- ----------------------------
--  Records of `RolePermission`
-- ----------------------------
BEGIN;
INSERT INTO `RolePermission` VALUES ('1', '1', '1', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('2', '1', '2', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('3', '1', '3', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('4', '2', '4', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('5', '3', '5', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('6', '4', '6', b'0', 'apollo', '2019-11-04 11:05:29', 'apollo', '2019-11-04 11:05:29'), ('7', '5', '7', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('8', '5', '8', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('9', '5', '9', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('10', '6', '10', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('11', '7', '11', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('12', '8', '12', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('13', '9', '13', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('14', '10', '14', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 04:48:43'), ('15', '11', '16', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('16', '11', '17', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('17', '11', '15', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('18', '12', '18', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('19', '13', '19', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('20', '14', '20', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('21', '15', '21', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('22', '16', '22', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('23', '17', '23', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('24', '17', '24', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('25', '17', '25', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('26', '18', '26', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('27', '19', '27', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('28', '20', '28', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('29', '21', '29', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('30', '22', '30', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('31', '23', '32', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('32', '23', '33', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('33', '23', '31', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('34', '24', '34', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('35', '25', '35', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('36', '26', '36', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('37', '27', '37', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('38', '28', '38', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('39', '29', '39', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('40', '29', '40', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('41', '29', '41', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('42', '30', '42', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('43', '31', '43', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('44', '32', '44', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('45', '33', '45', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('46', '34', '46', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('47', '35', '48', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('48', '35', '49', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('49', '35', '47', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('50', '36', '50', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('51', '37', '51', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('52', '38', '52', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('53', '39', '53', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('54', '40', '54', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('55', '41', '55', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('56', '41', '56', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('57', '41', '57', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('58', '42', '58', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('59', '43', '59', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('60', '44', '60', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('61', '45', '61', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('62', '46', '62', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('63', '47', '64', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('64', '47', '65', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('65', '47', '63', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('66', '48', '66', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('67', '49', '67', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('68', '50', '68', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('69', '51', '69', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('70', '52', '70', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `ServerConfig`
-- ----------------------------
DROP TABLE IF EXISTS `ServerConfig`;
CREATE TABLE `ServerConfig` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `Key` varchar(64) NOT NULL DEFAULT 'default' COMMENT '配置项Key',
  `Value` varchar(2048) NOT NULL DEFAULT 'default' COMMENT '配置项值',
  `Comment` varchar(1024) DEFAULT '' COMMENT '注释',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_Key` (`Key`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COMMENT='配置服务自身配置';

-- ----------------------------
--  Records of `ServerConfig`
-- ----------------------------
BEGIN;
INSERT INTO `ServerConfig` VALUES ('1', 'apollo.portal.envs', 'dev', '可支持的环境列表', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21'), ('2', 'organizations', '[{\"orgId\":\"TEST1\",\"orgName\":\"样例部门1\"},{\"orgId\":\"TEST2\",\"orgName\":\"样例部门2\"}]', '部门列表', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21'), ('3', 'superAdmin', 'apollo', 'Portal超级管理员', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21'), ('4', 'api.readTimeout', '10000', 'http接口read timeout', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21'), ('5', 'consumer.token.salt', 'someSalt', 'consumer token salt', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21'), ('6', 'admin.createPrivateNamespace.switch', 'true', '是否允许项目管理员创建私有namespace', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21'), ('7', 'configView.memberOnly.envs', 'dev', '只对项目成员显示配置信息的环境列表，多个env以英文逗号分隔', b'0', 'default', '2019-11-04 02:58:21', '', '2019-11-04 02:58:21');
COMMIT;

-- ----------------------------
--  Table structure for `UserRole`
-- ----------------------------
DROP TABLE IF EXISTS `UserRole`;
CREATE TABLE `UserRole` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `UserId` varchar(128) DEFAULT '' COMMENT '用户身份标识',
  `RoleId` int(10) unsigned DEFAULT NULL COMMENT 'Role Id',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) DEFAULT '' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_RoleId` (`RoleId`),
  KEY `IX_UserId_RoleId` (`UserId`,`RoleId`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COMMENT='用户和role的绑定表';

-- ----------------------------
--  Records of `UserRole`
-- ----------------------------
BEGIN;
INSERT INTO `UserRole` VALUES ('1', 'apollo', '1', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('2', 'apollo', '2', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('3', 'apollo', '3', b'0', '', '2019-11-04 02:58:22', '', '2019-11-04 02:58:22'), ('4', 'apollo', '5', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 04:48:43'), ('5', 'apollo', '7', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 04:48:43'), ('6', 'apollo', '8', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 04:48:43'), ('7', 'apollo', '11', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('8', 'apollo', '13', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('9', 'apollo', '14', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 04:49:49'), ('10', 'apollo', '17', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('11', 'apollo', '19', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('12', 'apollo', '20', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 04:52:51'), ('13', 'apollo', '23', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('14', 'apollo', '25', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('15', 'apollo', '26', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('16', 'apollo', '29', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('17', 'apollo', '31', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('18', 'apollo', '32', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('19', 'apollo', '35', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('20', 'apollo', '37', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('21', 'apollo', '38', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('22', 'apollo', '41', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('23', 'apollo', '43', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('24', 'apollo', '44', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('25', 'apollo', '47', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('26', 'apollo', '49', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40'), ('27', 'apollo', '50', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `Users`
-- ----------------------------
DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `Username` varchar(64) NOT NULL DEFAULT 'default' COMMENT '用户名',
  `Password` varchar(64) NOT NULL DEFAULT 'default' COMMENT '密码',
  `Email` varchar(64) NOT NULL DEFAULT 'default' COMMENT '邮箱地址',
  `Enabled` tinyint(4) DEFAULT NULL COMMENT '是否有效',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
--  Records of `Users`
-- ----------------------------
BEGIN;
INSERT INTO `Users` VALUES ('1', 'apollo', '$2a$10$7r20uS.BQ9uBpf3Baj3uQOZvMVvB1RN3PYoKE94gtz2.WAOuiiwXS', 'apollo@acme.com', '1');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
