/*
 Navicat Premium Data Transfer

 Source Server         : docker本地的mysql56
 Source Server Type    : MySQL
 Source Server Version : 50728
 Source Host           : localhost
 Source Database       : ApolloConfigDB

 Target Server Type    : MySQL
 Target Server Version : 50728
 File Encoding         : utf-8

 Date: 11/11/2019 14:31:02 PM
*/

CREATE DATABASE IF NOT EXISTS ApolloConfigDB DEFAULT CHARACTER SET = utf8mb4;

Use ApolloConfigDB;

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
INSERT INTO `App` VALUES ('1', 'SampleApp', 'Sample App', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('2', 'com.jingoufish.apigateway', 'apigateway-server', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-08 10:44:04', 'apollo', '2019-11-11 12:48:44'), ('3', 'com.jingoufish.auth', 'auth-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-08 12:28:49', 'apollo', '2019-11-11 12:49:50'), ('4', 'com.jingoufish.product', 'product-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-10 16:41:17', 'apollo', '2019-11-11 12:52:52'), ('5', 'com.jingoufish.order', 'order-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 12:57:17'), ('6', 'com.404abc.apigateway', 'apigateway-server', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:45:25', 'apollo', '2019-11-11 12:45:25'), ('7', 'com.404abc.auth', 'auth-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('8', 'com.404abc.product', 'product-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('9', 'com.404abc.order', 'order-service', 'TEST1', '样例部门1', 'apollo', 'apollo@acme.com', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
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
INSERT INTO `AppNamespace` VALUES ('1', 'application', 'SampleApp', 'properties', b'0', 'default app namespace', b'0', '', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('2', 'application', 'com.jingoufish.apigateway', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 04:48:43'), ('3', 'application', 'com.jingoufish.auth', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-08 12:28:50', 'apollo', '2019-11-11 04:49:49'), ('4', 'application', 'com.jingoufish.product', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-10 16:41:18', 'apollo', '2019-11-11 04:52:52'), ('5', 'application', 'com.jingoufish.order', 'properties', b'0', 'default app namespace', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 04:57:16'), ('6', 'application', 'com.404abc.apigateway', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:45:26', 'apollo', '2019-11-11 12:45:26'), ('7', 'application', 'com.404abc.auth', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('8', 'application', 'com.404abc.product', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('9', 'application', 'com.404abc.order', 'properties', b'0', 'default app namespace', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `Audit`
-- ----------------------------
DROP TABLE IF EXISTS `Audit`;
CREATE TABLE `Audit` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `EntityName` varchar(50) NOT NULL DEFAULT 'default' COMMENT '表名',
  `EntityId` int(10) unsigned DEFAULT NULL COMMENT '记录ID',
  `OpName` varchar(50) NOT NULL DEFAULT 'default' COMMENT '操作类型',
  `Comment` varchar(500) DEFAULT NULL COMMENT '备注',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COMMENT='日志审计表';

-- ----------------------------
--  Records of `Audit`
-- ----------------------------
BEGIN;
INSERT INTO `Audit` VALUES ('1', 'Item', '1', 'UPDATE', null, b'0', 'apollo', '2019-11-04 11:17:49', null, '2019-11-04 11:17:49'), ('2', 'Release', '2', 'INSERT', null, b'0', 'apollo', '2019-11-04 11:17:52', null, '2019-11-04 11:17:52'), ('3', 'ReleaseHistory', '2', 'INSERT', null, b'0', 'apollo', '2019-11-04 11:17:52', null, '2019-11-04 11:17:52'), ('4', 'App', '2', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:44:05', null, '2019-11-08 10:44:05'), ('5', 'AppNamespace', '2', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:44:05', null, '2019-11-08 10:44:05'), ('6', 'Cluster', '2', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:44:05', null, '2019-11-08 10:44:05'), ('7', 'Namespace', '2', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:44:05', null, '2019-11-08 10:44:05'), ('8', 'Item', '2', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:46:05', null, '2019-11-08 10:46:05'), ('9', 'Release', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:46:20', null, '2019-11-08 10:46:20'), ('10', 'ReleaseHistory', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 10:46:20', null, '2019-11-08 10:46:20'), ('11', 'App', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 12:28:50', null, '2019-11-08 12:28:50'), ('12', 'AppNamespace', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 12:28:50', null, '2019-11-08 12:28:50'), ('13', 'Cluster', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 12:28:50', null, '2019-11-08 12:28:50'), ('14', 'Namespace', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 12:28:50', null, '2019-11-08 12:28:50'), ('15', 'Item', '3', 'INSERT', null, b'0', 'apollo', '2019-11-08 13:43:06', null, '2019-11-08 13:43:06'), ('16', 'Release', '4', 'INSERT', null, b'0', 'apollo', '2019-11-08 13:43:08', null, '2019-11-08 13:43:08'), ('17', 'ReleaseHistory', '4', 'INSERT', null, b'0', 'apollo', '2019-11-08 13:43:08', null, '2019-11-08 13:43:08'), ('18', 'Item', '4', 'INSERT', null, b'0', 'apollo', '2019-11-08 15:30:27', null, '2019-11-08 15:30:27'), ('19', 'Release', '5', 'INSERT', null, b'0', 'apollo', '2019-11-08 15:30:40', null, '2019-11-08 15:30:40'), ('20', 'ReleaseHistory', '5', 'INSERT', null, b'0', 'apollo', '2019-11-08 15:30:40', null, '2019-11-08 15:30:40'), ('21', 'App', '4', 'INSERT', null, b'0', 'apollo', '2019-11-10 16:41:18', null, '2019-11-10 16:41:18'), ('22', 'AppNamespace', '4', 'INSERT', null, b'0', 'apollo', '2019-11-10 16:41:18', null, '2019-11-10 16:41:18'), ('23', 'Cluster', '4', 'INSERT', null, b'0', 'apollo', '2019-11-10 16:41:18', null, '2019-11-10 16:41:18'), ('24', 'Namespace', '4', 'INSERT', null, b'0', 'apollo', '2019-11-10 16:41:19', null, '2019-11-10 16:41:19'), ('25', 'Release', '6', 'INSERT', null, b'0', 'apollo', '2019-11-10 16:41:38', null, '2019-11-10 16:41:38'), ('26', 'ReleaseHistory', '6', 'INSERT', null, b'0', 'apollo', '2019-11-10 16:41:38', null, '2019-11-10 16:41:38'), ('27', 'App', '5', 'INSERT', null, b'0', 'apollo', '2019-11-10 17:16:25', null, '2019-11-10 17:16:25'), ('28', 'AppNamespace', '5', 'INSERT', null, b'0', 'apollo', '2019-11-10 17:16:25', null, '2019-11-10 17:16:25'), ('29', 'Cluster', '5', 'INSERT', null, b'0', 'apollo', '2019-11-10 17:16:25', null, '2019-11-10 17:16:25'), ('30', 'Namespace', '5', 'INSERT', null, b'0', 'apollo', '2019-11-10 17:16:25', null, '2019-11-10 17:16:25'), ('31', 'Release', '7', 'INSERT', null, b'0', 'apollo', '2019-11-10 17:16:31', null, '2019-11-10 17:16:31'), ('32', 'ReleaseHistory', '7', 'INSERT', null, b'0', 'apollo', '2019-11-10 17:16:31', null, '2019-11-10 17:16:31'), ('33', 'Item', '4', 'DELETE', null, b'0', 'apollo', '2019-11-10 22:56:37', null, '2019-11-10 22:56:37'), ('34', 'Item', '5', 'INSERT', null, b'0', 'apollo', '2019-11-10 22:59:04', null, '2019-11-10 22:59:04'), ('35', 'Release', '8', 'INSERT', null, b'0', 'apollo', '2019-11-10 22:59:07', null, '2019-11-10 22:59:07'), ('36', 'ReleaseHistory', '8', 'INSERT', null, b'0', 'apollo', '2019-11-10 22:59:07', null, '2019-11-10 22:59:07'), ('37', 'Item', '6', 'INSERT', null, b'0', 'apollo', '2019-11-11 09:10:13', null, '2019-11-11 09:10:13'), ('38', 'Item', '7', 'INSERT', null, b'0', 'apollo', '2019-11-11 09:10:29', null, '2019-11-11 09:10:29'), ('39', 'Item', '8', 'INSERT', null, b'0', 'apollo', '2019-11-11 09:10:56', null, '2019-11-11 09:10:56'), ('40', 'Release', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 09:11:00', null, '2019-11-11 09:11:00'), ('41', 'ReleaseHistory', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 09:11:00', null, '2019-11-11 09:11:00'), ('42', 'App', '6', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:45:26', null, '2019-11-11 12:45:26'), ('43', 'AppNamespace', '6', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:45:26', null, '2019-11-11 12:45:26'), ('44', 'Cluster', '6', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:45:26', null, '2019-11-11 12:45:26'), ('45', 'Namespace', '6', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:45:26', null, '2019-11-11 12:45:26'), ('46', 'Item', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:45:54', null, '2019-11-11 12:45:54'), ('47', 'Item', '10', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:46:23', null, '2019-11-11 12:46:23'), ('48', 'Release', '10', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:46:27', null, '2019-11-11 12:46:27'), ('49', 'ReleaseHistory', '10', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:46:27', null, '2019-11-11 12:46:27'), ('50', 'Namespace', '2', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:48:44', null, '2019-11-11 12:48:44'), ('51', 'Cluster', '2', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:48:44', null, '2019-11-11 12:48:44'), ('52', 'App', '2', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:48:44', null, '2019-11-11 12:48:44'), ('53', 'App', '7', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:27', null, '2019-11-11 12:49:27'), ('54', 'AppNamespace', '7', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:27', null, '2019-11-11 12:49:27'), ('55', 'Cluster', '7', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:27', null, '2019-11-11 12:49:27'), ('56', 'Namespace', '7', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:27', null, '2019-11-11 12:49:27'), ('57', 'Item', '11', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:39', null, '2019-11-11 12:49:39'), ('58', 'Release', '11', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:42', null, '2019-11-11 12:49:42'), ('59', 'ReleaseHistory', '11', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:49:42', null, '2019-11-11 12:49:42'), ('60', 'Namespace', '3', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:49:50', null, '2019-11-11 12:49:50'), ('61', 'Cluster', '3', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:49:50', null, '2019-11-11 12:49:50'), ('62', 'App', '3', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:49:50', null, '2019-11-11 12:49:50'), ('63', 'App', '8', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:51:25', null, '2019-11-11 12:51:25'), ('64', 'AppNamespace', '8', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:51:25', null, '2019-11-11 12:51:25'), ('65', 'Cluster', '8', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:51:25', null, '2019-11-11 12:51:25'), ('66', 'Namespace', '8', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:51:25', null, '2019-11-11 12:51:25'), ('67', 'Release', '12', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:51:30', null, '2019-11-11 12:51:30'), ('68', 'ReleaseHistory', '12', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:51:30', null, '2019-11-11 12:51:30'), ('69', 'Namespace', '4', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:52:52', null, '2019-11-11 12:52:52'), ('70', 'Cluster', '4', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:52:52', null, '2019-11-11 12:52:52'), ('71', 'App', '4', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:52:52', null, '2019-11-11 12:52:52'), ('72', 'App', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:53:40', null, '2019-11-11 12:53:40'), ('73', 'AppNamespace', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:53:40', null, '2019-11-11 12:53:40'), ('74', 'Cluster', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:53:40', null, '2019-11-11 12:53:40'), ('75', 'Namespace', '9', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:53:40', null, '2019-11-11 12:53:40'), ('76', 'Item', '12', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:54:00', null, '2019-11-11 12:54:00'), ('77', 'Item', '13', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:54:19', null, '2019-11-11 12:54:19'), ('78', 'Item', '14', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:54:41', null, '2019-11-11 12:54:41'), ('79', 'Release', '13', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:54:44', null, '2019-11-11 12:54:44'), ('80', 'ReleaseHistory', '13', 'INSERT', null, b'0', 'apollo', '2019-11-11 12:54:44', null, '2019-11-11 12:54:44'), ('81', 'Namespace', '5', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:57:17', null, '2019-11-11 12:57:17'), ('82', 'Cluster', '5', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:57:17', null, '2019-11-11 12:57:17'), ('83', 'App', '5', 'DELETE', null, b'0', 'apollo', '2019-11-11 12:57:17', null, '2019-11-11 12:57:17');
COMMIT;

-- ----------------------------
--  Table structure for `Cluster`
-- ----------------------------
DROP TABLE IF EXISTS `Cluster`;
CREATE TABLE `Cluster` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `Name` varchar(32) NOT NULL DEFAULT '' COMMENT '集群名字',
  `AppId` varchar(32) NOT NULL DEFAULT '' COMMENT 'App id',
  `ParentClusterId` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '父cluster',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT '' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_AppId_Name` (`AppId`,`Name`),
  KEY `IX_ParentClusterId` (`ParentClusterId`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='集群';

-- ----------------------------
--  Records of `Cluster`
-- ----------------------------
BEGIN;
INSERT INTO `Cluster` VALUES ('1', 'default', 'SampleApp', '0', b'0', '', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('2', 'default', 'com.jingoufish.apigateway', '0', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 12:48:44'), ('3', 'default', 'com.jingoufish.auth', '0', b'1', 'apollo', '2019-11-08 12:28:50', 'apollo', '2019-11-11 12:49:50'), ('4', 'default', 'com.jingoufish.product', '0', b'1', 'apollo', '2019-11-10 16:41:18', 'apollo', '2019-11-11 12:52:52'), ('5', 'default', 'com.jingoufish.order', '0', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 12:57:17'), ('6', 'default', 'com.404abc.apigateway', '0', b'0', 'apollo', '2019-11-11 12:45:26', 'apollo', '2019-11-11 12:45:26'), ('7', 'default', 'com.404abc.auth', '0', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('8', 'default', 'com.404abc.product', '0', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('9', 'default', 'com.404abc.order', '0', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `Commit`
-- ----------------------------
DROP TABLE IF EXISTS `Commit`;
CREATE TABLE `Commit` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `ChangeSets` longtext NOT NULL COMMENT '修改变更集',
  `AppId` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `ClusterName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'ClusterName',
  `NamespaceName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'namespaceName',
  `Comment` varchar(500) DEFAULT NULL COMMENT '备注',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`),
  KEY `AppId` (`AppId`(191)),
  KEY `ClusterName` (`ClusterName`(191)),
  KEY `NamespaceName` (`NamespaceName`(191))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COMMENT='commit 历史表';

-- ----------------------------
--  Records of `Commit`
-- ----------------------------
BEGIN;
INSERT INTO `Commit` VALUES ('1', '{\"createItems\":[],\"updateItems\":[{\"oldItem\":{\"namespaceId\":1,\"key\":\"timeout\",\"value\":\"100\",\"comment\":\"sample timeout配置\",\"lineNum\":1,\"id\":1,\"isDeleted\":false,\"dataChangeCreatedBy\":\"default\",\"dataChangeCreatedTime\":\"2019-11-04 02:59:03\",\"dataChangeLastModifiedBy\":\"\",\"dataChangeLastModifiedTime\":\"2019-11-04 02:59:03\"},\"newItem\":{\"namespaceId\":1,\"key\":\"timeout\",\"value\":\"100000\",\"comment\":\"sample timeout配置\",\"lineNum\":1,\"id\":1,\"isDeleted\":false,\"dataChangeCreatedBy\":\"default\",\"dataChangeCreatedTime\":\"2019-11-04 02:59:03\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-04 11:17:48\"}}],\"deleteItems\":[]}', 'SampleApp', 'default', 'application', null, b'0', 'apollo', '2019-11-04 11:17:49', 'apollo', '2019-11-04 11:17:49'), ('2', '{\"createItems\":[{\"namespaceId\":2,\"key\":\"jwt.secret\",\"value\":\"OA%ttXrP4Bh33wZiUidGEw\\u0026xs#1s93Iutw^T%QQn\",\"lineNum\":1,\"id\":2,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-08 10:46:04\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-08 10:46:04\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.apigateway', 'default', 'application', null, b'1', 'apollo', '2019-11-08 10:46:05', 'apollo', '2019-11-11 04:48:43'), ('3', '{\"createItems\":[{\"namespaceId\":3,\"key\":\"timeout\",\"value\":\"1000\",\"lineNum\":1,\"id\":3,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-08 13:43:05\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-08 13:43:05\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.auth', 'default', 'application', null, b'1', 'apollo', '2019-11-08 13:43:06', 'apollo', '2019-11-11 04:49:49'), ('4', '{\"createItems\":[{\"namespaceId\":2,\"key\":\"ocelot\",\"value\":\"{\\n    \\\"ReRoutes\\\": [\\n      {\\n        \\\"UpstreamPathTemplate\\\": \\\"/apiservice/{controller}\\\",\\n        \\\"UpstreamHttpMethod\\\": [\\n          \\\"Get\\\"\\n        ],\\n        \\\"DownstreamPathTemplate\\\": \\\"/apiservice/{controller}\\\",\\n        \\\"DownstreamScheme\\\": \\\"http\\\",\\n        \\\"LoadBalancerOptions\\\": {\\n          \\\"Type\\\": \\\"LeastConnection\\\"\\n        },\\n        \\\"ServiceName\\\": \\\"MasterService\\\",\\n        \\\"UseServiceDiscovery\\\": true\\n      },\\n      {\\n        \\\"UpstreamPathTemplate\\\": \\\"/auth/{controller}\\\",\\n        \\\"UpstreamHttpMethod\\\": [\\n          \\\"Get\\\"\\n        ],\\n        \\\"DownstreamPathTemplate\\\": \\\"/auth/{controller}\\\",\\n        \\\"DownstreamScheme\\\": \\\"http\\\",\\n        \\\"LoadBalancerOptions\\\": {\\n          \\\"Type\\\": \\\"LeastConnection\\\"\\n        },\\n        \\\"ServiceName\\\": \\\"AuthService\\\",\\n        \\\"UseServiceDiscovery\\\": true\\n      }\\n    ],\\n    \\\"GlobalConfiguration\\\": {\\n        \\\"ServiceDiscoveryProvider\\\": {\\n            \\\"Host\\\": \\\"127.0.0.1\\\",\\n            \\\"Port\\\": 8500,\\n            \\\"Type\\\": \\\"Consul\\\"\\n        }\\n    }\\n}\",\"lineNum\":2,\"id\":4,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-08 15:30:26\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-08 15:30:26\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.apigateway', 'default', 'application', null, b'1', 'apollo', '2019-11-08 15:30:27', 'apollo', '2019-11-11 04:48:43'), ('5', '{\"createItems\":[],\"updateItems\":[],\"deleteItems\":[{\"namespaceId\":2,\"key\":\"ocelot\",\"value\":\"{\\n    \\\"ReRoutes\\\": [\\n      {\\n        \\\"UpstreamPathTemplate\\\": \\\"/apiservice/{controller}\\\",\\n        \\\"UpstreamHttpMethod\\\": [\\n          \\\"Get\\\"\\n        ],\\n        \\\"DownstreamPathTemplate\\\": \\\"/apiservice/{controller}\\\",\\n        \\\"DownstreamScheme\\\": \\\"http\\\",\\n        \\\"LoadBalancerOptions\\\": {\\n          \\\"Type\\\": \\\"LeastConnection\\\"\\n        },\\n        \\\"ServiceName\\\": \\\"MasterService\\\",\\n        \\\"UseServiceDiscovery\\\": true\\n      },\\n      {\\n        \\\"UpstreamPathTemplate\\\": \\\"/auth/{controller}\\\",\\n        \\\"UpstreamHttpMethod\\\": [\\n          \\\"Get\\\"\\n        ],\\n        \\\"DownstreamPathTemplate\\\": \\\"/auth/{controller}\\\",\\n        \\\"DownstreamScheme\\\": \\\"http\\\",\\n        \\\"LoadBalancerOptions\\\": {\\n          \\\"Type\\\": \\\"LeastConnection\\\"\\n        },\\n        \\\"ServiceName\\\": \\\"AuthService\\\",\\n        \\\"UseServiceDiscovery\\\": true\\n      }\\n    ],\\n    \\\"GlobalConfiguration\\\": {\\n        \\\"ServiceDiscoveryProvider\\\": {\\n            \\\"Host\\\": \\\"127.0.0.1\\\",\\n            \\\"Port\\\": 8500,\\n            \\\"Type\\\": \\\"Consul\\\"\\n        }\\n    }\\n}\",\"lineNum\":2,\"id\":4,\"isDeleted\":true,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-08 15:30:27\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-10 22:56:36\"}]}', 'com.jingoufish.apigateway', 'default', 'application', null, b'1', 'apollo', '2019-11-10 22:56:37', 'apollo', '2019-11-11 04:48:43'), ('6', '{\"createItems\":[{\"namespaceId\":2,\"key\":\"user.auth.urls\",\"value\":\"[\\n\\\"home/index\\\",\\n\\\"order/add\\\"\\n]\",\"lineNum\":2,\"id\":5,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-10 22:59:03\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-10 22:59:03\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.apigateway', 'default', 'application', null, b'1', 'apollo', '2019-11-10 22:59:04', 'apollo', '2019-11-11 04:48:43'), ('7', '{\"createItems\":[{\"namespaceId\":5,\"key\":\"consul.address\",\"value\":\"localhost\",\"lineNum\":1,\"id\":6,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 09:10:12\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 09:10:12\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.order', 'default', 'application', null, b'1', 'apollo', '2019-11-11 09:10:13', 'apollo', '2019-11-11 04:57:16'), ('8', '{\"createItems\":[{\"namespaceId\":5,\"key\":\"consul.port\",\"value\":\"8500\",\"lineNum\":2,\"id\":7,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 09:10:29\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 09:10:29\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.order', 'default', 'application', null, b'1', 'apollo', '2019-11-11 09:10:29', 'apollo', '2019-11-11 04:57:16'), ('9', '{\"createItems\":[{\"namespaceId\":5,\"key\":\"zipkin.address\",\"value\":\"http://localhost:9411\",\"lineNum\":3,\"id\":8,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 09:10:56\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 09:10:56\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.jingoufish.order', 'default', 'application', null, b'1', 'apollo', '2019-11-11 09:10:56', 'apollo', '2019-11-11 04:57:16'), ('10', '{\"createItems\":[{\"namespaceId\":6,\"key\":\"jwt.secret\",\"value\":\"OA%ttXrP4Bh33wZiUidGEw\\u0026xs#1s93Iutw^T%QQn\",\"lineNum\":1,\"id\":9,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 12:45:53\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 12:45:53\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.404abc.apigateway', 'default', 'application', null, b'0', 'apollo', '2019-11-11 12:45:54', 'apollo', '2019-11-11 12:45:54'), ('11', '{\"createItems\":[{\"namespaceId\":6,\"key\":\"user.auth.urls\",\"value\":\"[\\n\\\"home/index\\\",\\n\\\"order/add\\\"\\n]\",\"lineNum\":2,\"id\":10,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 12:46:22\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 12:46:22\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.404abc.apigateway', 'default', 'application', null, b'0', 'apollo', '2019-11-11 12:46:23', 'apollo', '2019-11-11 12:46:23'), ('12', '{\"createItems\":[{\"namespaceId\":7,\"key\":\"timeout\",\"value\":\"10000\",\"lineNum\":1,\"id\":11,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 12:49:38\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 12:49:38\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.404abc.auth', 'default', 'application', null, b'0', 'apollo', '2019-11-11 12:49:39', 'apollo', '2019-11-11 12:49:39'), ('13', '{\"createItems\":[{\"namespaceId\":9,\"key\":\"consul.address\",\"value\":\"localhost\",\"lineNum\":1,\"id\":12,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 12:53:59\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 12:53:59\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.404abc.order', 'default', 'application', null, b'0', 'apollo', '2019-11-11 12:54:00', 'apollo', '2019-11-11 12:54:00'), ('14', '{\"createItems\":[{\"namespaceId\":9,\"key\":\"consul.port\",\"value\":\"8500\",\"lineNum\":2,\"id\":13,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 12:54:19\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 12:54:19\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.404abc.order', 'default', 'application', null, b'0', 'apollo', '2019-11-11 12:54:19', 'apollo', '2019-11-11 12:54:19'), ('15', '{\"createItems\":[{\"namespaceId\":9,\"key\":\"zipkin.address\",\"value\":\"http://localhost:9411\",\"lineNum\":3,\"id\":14,\"isDeleted\":false,\"dataChangeCreatedBy\":\"apollo\",\"dataChangeCreatedTime\":\"2019-11-11 12:54:40\",\"dataChangeLastModifiedBy\":\"apollo\",\"dataChangeLastModifiedTime\":\"2019-11-11 12:54:40\"}],\"updateItems\":[],\"deleteItems\":[]}', 'com.404abc.order', 'default', 'application', null, b'0', 'apollo', '2019-11-11 12:54:41', 'apollo', '2019-11-11 12:54:41');
COMMIT;

-- ----------------------------
--  Table structure for `GrayReleaseRule`
-- ----------------------------
DROP TABLE IF EXISTS `GrayReleaseRule`;
CREATE TABLE `GrayReleaseRule` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `AppId` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `ClusterName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'Cluster Name',
  `NamespaceName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'Namespace Name',
  `BranchName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'branch name',
  `Rules` varchar(16000) DEFAULT '[]' COMMENT '灰度规则',
  `ReleaseId` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '灰度对应的release',
  `BranchStatus` tinyint(2) DEFAULT '1' COMMENT '灰度分支状态: 0:删除分支,1:正在使用的规则 2：全量发布',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_Namespace` (`AppId`,`ClusterName`,`NamespaceName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='灰度规则表';

-- ----------------------------
--  Table structure for `Instance`
-- ----------------------------
DROP TABLE IF EXISTS `Instance`;
CREATE TABLE `Instance` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `AppId` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `ClusterName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'ClusterName',
  `DataCenter` varchar(64) NOT NULL DEFAULT 'default' COMMENT 'Data Center Name',
  `Ip` varchar(32) NOT NULL DEFAULT '' COMMENT 'instance ip',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_UNIQUE_KEY` (`AppId`,`ClusterName`,`Ip`,`DataCenter`),
  KEY `IX_IP` (`Ip`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='使用配置的应用实例';

-- ----------------------------
--  Records of `Instance`
-- ----------------------------
BEGIN;
INSERT INTO `Instance` VALUES ('1', 'SampleApp', 'default', '', '192.168.31.38', '2019-11-04 11:08:14', '2019-11-04 11:08:14'), ('2', 'com.jingoufish.apigateway', 'default', '', '192.168.31.38', '2019-11-08 10:53:54', '2019-11-08 10:53:54'), ('3', 'com.jingoufish.auth', 'default', '', '192.168.31.38', '2019-11-08 14:07:28', '2019-11-08 14:07:28'), ('4', 'com.jingoufish.product', 'default', '', '192.168.31.38', '2019-11-10 16:51:13', '2019-11-10 16:51:13'), ('5', 'com.jingoufish.order', 'default', '', '192.168.31.38', '2019-11-10 17:21:40', '2019-11-10 17:21:40'), ('6', 'com.404abc.apigateway', 'default', '', '192.168.31.38', '2019-11-11 12:47:35', '2019-11-11 12:47:35'), ('7', 'com.404abc.auth', 'default', '', '192.168.31.38', '2019-11-11 12:50:30', '2019-11-11 12:50:30'), ('8', 'com.404abc.product', 'default', '', '192.168.31.38', '2019-11-11 12:53:06', '2019-11-11 12:53:06'), ('9', 'com.404abc.order', 'default', '', '192.168.31.38', '2019-11-11 12:55:22', '2019-11-11 12:55:22');
COMMIT;

-- ----------------------------
--  Table structure for `InstanceConfig`
-- ----------------------------
DROP TABLE IF EXISTS `InstanceConfig`;
CREATE TABLE `InstanceConfig` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `InstanceId` int(11) unsigned DEFAULT NULL COMMENT 'Instance Id',
  `ConfigAppId` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'Config App Id',
  `ConfigClusterName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'Config Cluster Name',
  `ConfigNamespaceName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'Config Namespace Name',
  `ReleaseKey` varchar(64) NOT NULL DEFAULT '' COMMENT '发布的Key',
  `ReleaseDeliveryTime` timestamp NULL DEFAULT NULL COMMENT '配置获取时间',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_UNIQUE_KEY` (`InstanceId`,`ConfigAppId`,`ConfigNamespaceName`),
  KEY `IX_ReleaseKey` (`ReleaseKey`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_Valid_Namespace` (`ConfigAppId`,`ConfigClusterName`,`ConfigNamespaceName`,`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='应用实例的配置信息';

-- ----------------------------
--  Records of `InstanceConfig`
-- ----------------------------
BEGIN;
INSERT INTO `InstanceConfig` VALUES ('1', '1', 'SampleApp', 'default', 'application', '20191104111751-1dc5c955128c04f7', '2019-11-04 11:17:52', '2019-11-04 11:08:14', '2019-11-08 11:53:21'), ('6', '6', 'com.404abc.apigateway', 'default', 'application', '20191111124627-eb4fc95512ecdfd4', '2019-11-11 12:47:34', '2019-11-11 12:47:34', '2019-11-11 12:47:34'), ('7', '7', 'com.404abc.auth', 'default', 'application', '20191111124941-03cdc95512ecdfd5', '2019-11-11 12:50:29', '2019-11-11 12:50:29', '2019-11-11 12:50:29'), ('8', '8', 'com.404abc.product', 'default', 'application', '20191111125130-58c6c95512ecdfd6', '2019-11-11 12:53:05', '2019-11-11 12:53:05', '2019-11-11 12:53:05'), ('9', '9', 'com.404abc.order', 'default', 'application', '20191111125444-65a5c95512ecdfd7', '2019-11-11 12:55:22', '2019-11-11 12:55:22', '2019-11-11 12:55:22');
COMMIT;

-- ----------------------------
--  Table structure for `Item`
-- ----------------------------
DROP TABLE IF EXISTS `Item`;
CREATE TABLE `Item` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `NamespaceId` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '集群NamespaceId',
  `Key` varchar(128) NOT NULL DEFAULT 'default' COMMENT '配置项Key',
  `Value` longtext NOT NULL COMMENT '配置项值',
  `Comment` varchar(1024) DEFAULT '' COMMENT '注释',
  `LineNum` int(10) unsigned DEFAULT '0' COMMENT '行号',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_GroupId` (`NamespaceId`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COMMENT='配置项目';

-- ----------------------------
--  Records of `Item`
-- ----------------------------
BEGIN;
INSERT INTO `Item` VALUES ('1', '1', 'timeout', '100000', 'sample timeout配置', '1', b'0', 'default', '2019-11-04 02:59:03', 'apollo', '2019-11-04 11:17:49'), ('2', '2', 'jwt.secret', 'OA%ttXrP4Bh33wZiUidGEw&xs#1s93Iutw^T%QQn', null, '1', b'1', 'apollo', '2019-11-08 10:46:05', 'apollo', '2019-11-11 04:48:43'), ('3', '3', 'timeout', '1000', null, '1', b'1', 'apollo', '2019-11-08 13:43:06', 'apollo', '2019-11-11 04:49:49'), ('4', '2', 'ocelot', '{\n    \"ReRoutes\": [\n      {\n        \"UpstreamPathTemplate\": \"/apiservice/{controller}\",\n        \"UpstreamHttpMethod\": [\n          \"Get\"\n        ],\n        \"DownstreamPathTemplate\": \"/apiservice/{controller}\",\n        \"DownstreamScheme\": \"http\",\n        \"LoadBalancerOptions\": {\n          \"Type\": \"LeastConnection\"\n        },\n        \"ServiceName\": \"MasterService\",\n        \"UseServiceDiscovery\": true\n      },\n      {\n        \"UpstreamPathTemplate\": \"/auth/{controller}\",\n        \"UpstreamHttpMethod\": [\n          \"Get\"\n        ],\n        \"DownstreamPathTemplate\": \"/auth/{controller}\",\n        \"DownstreamScheme\": \"http\",\n        \"LoadBalancerOptions\": {\n          \"Type\": \"LeastConnection\"\n        },\n        \"ServiceName\": \"AuthService\",\n        \"UseServiceDiscovery\": true\n      }\n    ],\n    \"GlobalConfiguration\": {\n        \"ServiceDiscoveryProvider\": {\n            \"Host\": \"127.0.0.1\",\n            \"Port\": 8500,\n            \"Type\": \"Consul\"\n        }\n    }\n}', null, '2', b'1', 'apollo', '2019-11-08 15:30:27', 'apollo', '2019-11-10 22:56:37'), ('5', '2', 'user.auth.urls', '[\n\"home/index\",\n\"order/add\"\n]', null, '2', b'1', 'apollo', '2019-11-10 22:59:04', 'apollo', '2019-11-11 04:48:43'), ('6', '5', 'consul.address', 'localhost', null, '1', b'1', 'apollo', '2019-11-11 09:10:12', 'apollo', '2019-11-11 04:57:16'), ('7', '5', 'consul.port', '8500', null, '2', b'1', 'apollo', '2019-11-11 09:10:29', 'apollo', '2019-11-11 04:57:16'), ('8', '5', 'zipkin.address', 'http://localhost:9411', null, '3', b'1', 'apollo', '2019-11-11 09:10:56', 'apollo', '2019-11-11 04:57:16'), ('9', '6', 'jwt.secret', 'OA%ttXrP4Bh33wZiUidGEw&xs#1s93Iutw^T%QQn', null, '1', b'0', 'apollo', '2019-11-11 12:45:54', 'apollo', '2019-11-11 12:45:54'), ('10', '6', 'user.auth.urls', '[\n\"home/index\",\n\"order/add\"\n]', null, '2', b'0', 'apollo', '2019-11-11 12:46:23', 'apollo', '2019-11-11 12:46:23'), ('11', '7', 'timeout', '10000', null, '1', b'0', 'apollo', '2019-11-11 12:49:39', 'apollo', '2019-11-11 12:49:39'), ('12', '9', 'consul.address', 'localhost', null, '1', b'0', 'apollo', '2019-11-11 12:54:00', 'apollo', '2019-11-11 12:54:00'), ('13', '9', 'consul.port', '8500', null, '2', b'0', 'apollo', '2019-11-11 12:54:19', 'apollo', '2019-11-11 12:54:19'), ('14', '9', 'zipkin.address', 'http://localhost:9411', null, '3', b'0', 'apollo', '2019-11-11 12:54:41', 'apollo', '2019-11-11 12:54:41');
COMMIT;

-- ----------------------------
--  Table structure for `Namespace`
-- ----------------------------
DROP TABLE IF EXISTS `Namespace`;
CREATE TABLE `Namespace` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `AppId` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `ClusterName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'Cluster Name',
  `NamespaceName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'Namespace Name',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `AppId_ClusterName_NamespaceName` (`AppId`(191),`ClusterName`(191),`NamespaceName`(191)),
  KEY `DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_NamespaceName` (`NamespaceName`(191))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='命名空间';

-- ----------------------------
--  Records of `Namespace`
-- ----------------------------
BEGIN;
INSERT INTO `Namespace` VALUES ('1', 'SampleApp', 'default', 'application', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('2', 'com.jingoufish.apigateway', 'default', 'application', b'1', 'apollo', '2019-11-08 10:44:05', 'apollo', '2019-11-11 12:48:44'), ('3', 'com.jingoufish.auth', 'default', 'application', b'1', 'apollo', '2019-11-08 12:28:50', 'apollo', '2019-11-11 12:49:50'), ('4', 'com.jingoufish.product', 'default', 'application', b'1', 'apollo', '2019-11-10 16:41:19', 'apollo', '2019-11-11 12:52:52'), ('5', 'com.jingoufish.order', 'default', 'application', b'1', 'apollo', '2019-11-10 17:16:25', 'apollo', '2019-11-11 12:57:17'), ('6', 'com.404abc.apigateway', 'default', 'application', b'0', 'apollo', '2019-11-11 12:45:26', 'apollo', '2019-11-11 12:45:26'), ('7', 'com.404abc.auth', 'default', 'application', b'0', 'apollo', '2019-11-11 12:49:27', 'apollo', '2019-11-11 12:49:27'), ('8', 'com.404abc.product', 'default', 'application', b'0', 'apollo', '2019-11-11 12:51:25', 'apollo', '2019-11-11 12:51:25'), ('9', 'com.404abc.order', 'default', 'application', b'0', 'apollo', '2019-11-11 12:53:40', 'apollo', '2019-11-11 12:53:40');
COMMIT;

-- ----------------------------
--  Table structure for `NamespaceLock`
-- ----------------------------
DROP TABLE IF EXISTS `NamespaceLock`;
CREATE TABLE `NamespaceLock` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `NamespaceId` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '集群NamespaceId',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT 'default' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `IsDeleted` bit(1) DEFAULT b'0' COMMENT '软删除',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `IX_NamespaceId` (`NamespaceId`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='namespace的编辑锁';

-- ----------------------------
--  Table structure for `Release`
-- ----------------------------
DROP TABLE IF EXISTS `Release`;
CREATE TABLE `Release` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `ReleaseKey` varchar(64) NOT NULL DEFAULT '' COMMENT '发布的Key',
  `Name` varchar(64) NOT NULL DEFAULT 'default' COMMENT '发布名字',
  `Comment` varchar(256) DEFAULT NULL COMMENT '发布说明',
  `AppId` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `ClusterName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'ClusterName',
  `NamespaceName` varchar(500) NOT NULL DEFAULT 'default' COMMENT 'namespaceName',
  `Configurations` longtext NOT NULL COMMENT '发布配置',
  `IsAbandoned` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否废弃',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `AppId_ClusterName_GroupName` (`AppId`(191),`ClusterName`(191),`NamespaceName`(191)),
  KEY `DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_ReleaseKey` (`ReleaseKey`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COMMENT='发布';

-- ----------------------------
--  Records of `Release`
-- ----------------------------
BEGIN;
INSERT INTO `Release` VALUES ('1', '20161009155425-d3a0749c6e20bc15', '20161009155424-release', 'Sample发布', 'SampleApp', 'default', 'application', '{\"timeout\":\"100\"}', b'0', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('2', '20191104111751-1dc5c955128c04f7', '20191104111750-release', '', 'SampleApp', 'default', 'application', '{\"timeout\":\"100000\"}', b'0', b'0', 'apollo', '2019-11-04 11:17:52', 'apollo', '2019-11-04 11:17:52'), ('3', '20191108104620-2b03c95512f5e866', '20191108104616-release', '', 'com.jingoufish.apigateway', 'default', 'application', '{\"jwt.secret\":\"OA%ttXrP4Bh33wZiUidGEw\\u0026xs#1s93Iutw^T%QQn\"}', b'0', b'1', 'apollo', '2019-11-08 10:46:20', 'apollo', '2019-11-11 04:48:43'), ('4', '20191108134308-1a81c95512f5e867', '20191108134306-release', '', 'com.jingoufish.auth', 'default', 'application', '{\"timeout\":\"1000\"}', b'0', b'1', 'apollo', '2019-11-08 13:43:08', 'apollo', '2019-11-11 04:49:49'), ('5', '20191108153039-2b03c95512f5e868', '20191108153037-release', '', 'com.jingoufish.apigateway', 'default', 'application', '{\"ocelot\":\"{\\n    \\\"ReRoutes\\\": [\\n      {\\n        \\\"UpstreamPathTemplate\\\": \\\"/apiservice/{controller}\\\",\\n        \\\"UpstreamHttpMethod\\\": [\\n          \\\"Get\\\"\\n        ],\\n        \\\"DownstreamPathTemplate\\\": \\\"/apiservice/{controller}\\\",\\n        \\\"DownstreamScheme\\\": \\\"http\\\",\\n        \\\"LoadBalancerOptions\\\": {\\n          \\\"Type\\\": \\\"LeastConnection\\\"\\n        },\\n        \\\"ServiceName\\\": \\\"MasterService\\\",\\n        \\\"UseServiceDiscovery\\\": true\\n      },\\n      {\\n        \\\"UpstreamPathTemplate\\\": \\\"/auth/{controller}\\\",\\n        \\\"UpstreamHttpMethod\\\": [\\n          \\\"Get\\\"\\n        ],\\n        \\\"DownstreamPathTemplate\\\": \\\"/auth/{controller}\\\",\\n        \\\"DownstreamScheme\\\": \\\"http\\\",\\n        \\\"LoadBalancerOptions\\\": {\\n          \\\"Type\\\": \\\"LeastConnection\\\"\\n        },\\n        \\\"ServiceName\\\": \\\"AuthService\\\",\\n        \\\"UseServiceDiscovery\\\": true\\n      }\\n    ],\\n    \\\"GlobalConfiguration\\\": {\\n        \\\"ServiceDiscoveryProvider\\\": {\\n            \\\"Host\\\": \\\"127.0.0.1\\\",\\n            \\\"Port\\\": 8500,\\n            \\\"Type\\\": \\\"Consul\\\"\\n        }\\n    }\\n}\",\"jwt.secret\":\"OA%ttXrP4Bh33wZiUidGEw\\u0026xs#1s93Iutw^T%QQn\"}', b'0', b'1', 'apollo', '2019-11-08 15:30:40', 'apollo', '2019-11-11 04:48:43'), ('6', '20191110164138-5592c95512fc9a39', '20191110164136-release', '', 'com.jingoufish.product', 'default', 'application', '{}', b'0', b'1', 'apollo', '2019-11-10 16:41:38', 'apollo', '2019-11-11 04:52:52'), ('7', '20191110171630-2571c95512fc9a3a', '20191110171629-release', '', 'com.jingoufish.order', 'default', 'application', '{}', b'0', b'1', 'apollo', '2019-11-10 17:16:31', 'apollo', '2019-11-11 04:57:16'), ('8', '20191110225906-2b03610fa01e57ee', '20191110225904-release', '', 'com.jingoufish.apigateway', 'default', 'application', '{\"jwt.secret\":\"OA%ttXrP4Bh33wZiUidGEw\\u0026xs#1s93Iutw^T%QQn\",\"user.auth.urls\":\"[\\n\\\"home/index\\\",\\n\\\"order/add\\\"\\n]\"}', b'0', b'1', 'apollo', '2019-11-10 22:59:07', 'apollo', '2019-11-11 04:48:43'), ('9', '20191111091059-2571c95512ecdfd3', '20191111091058-release', '', 'com.jingoufish.order', 'default', 'application', '{\"zipkin.address\":\"http://localhost:9411\",\"consul.address\":\"localhost\",\"consul.port\":\"8500\"}', b'0', b'1', 'apollo', '2019-11-11 09:11:00', 'apollo', '2019-11-11 04:57:16'), ('10', '20191111124627-eb4fc95512ecdfd4', '20191111124625-release', '', 'com.404abc.apigateway', 'default', 'application', '{\"jwt.secret\":\"OA%ttXrP4Bh33wZiUidGEw\\u0026xs#1s93Iutw^T%QQn\",\"user.auth.urls\":\"[\\n\\\"home/index\\\",\\n\\\"order/add\\\"\\n]\"}', b'0', b'0', 'apollo', '2019-11-11 12:46:27', 'apollo', '2019-11-11 12:46:27'), ('11', '20191111124941-03cdc95512ecdfd5', '20191111124940-release', '', 'com.404abc.auth', 'default', 'application', '{\"timeout\":\"10000\"}', b'0', b'0', 'apollo', '2019-11-11 12:49:42', 'apollo', '2019-11-11 12:49:42'), ('12', '20191111125130-58c6c95512ecdfd6', '20191111125129-release', '', 'com.404abc.product', 'default', 'application', '{}', b'0', b'0', 'apollo', '2019-11-11 12:51:30', 'apollo', '2019-11-11 12:51:30'), ('13', '20191111125444-65a5c95512ecdfd7', '20191111125442-release', '', 'com.404abc.order', 'default', 'application', '{\"zipkin.address\":\"http://localhost:9411\",\"consul.address\":\"localhost\",\"consul.port\":\"8500\"}', b'0', b'0', 'apollo', '2019-11-11 12:54:44', 'apollo', '2019-11-11 12:54:44');
COMMIT;

-- ----------------------------
--  Table structure for `ReleaseHistory`
-- ----------------------------
DROP TABLE IF EXISTS `ReleaseHistory`;
CREATE TABLE `ReleaseHistory` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `AppId` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'AppID',
  `ClusterName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'ClusterName',
  `NamespaceName` varchar(32) NOT NULL DEFAULT 'default' COMMENT 'namespaceName',
  `BranchName` varchar(32) NOT NULL DEFAULT 'default' COMMENT '发布分支名',
  `ReleaseId` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '关联的Release Id',
  `PreviousReleaseId` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '前一次发布的ReleaseId',
  `Operation` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '发布类型，0: 普通发布，1: 回滚，2: 灰度发布，3: 灰度规则更新，4: 灰度合并回主分支发布，5: 主分支发布灰度自动发布，6: 主分支回滚灰度自动发布，7: 放弃灰度',
  `OperationContext` longtext NOT NULL COMMENT '发布上下文信息',
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '1: deleted, 0: normal',
  `DataChange_CreatedBy` varchar(32) NOT NULL DEFAULT 'default' COMMENT '创建人邮箱前缀',
  `DataChange_CreatedTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `DataChange_LastModifiedBy` varchar(32) DEFAULT '' COMMENT '最后修改人邮箱前缀',
  `DataChange_LastTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `IX_Namespace` (`AppId`,`ClusterName`,`NamespaceName`,`BranchName`),
  KEY `IX_ReleaseId` (`ReleaseId`),
  KEY `IX_DataChange_LastTime` (`DataChange_LastTime`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COMMENT='发布历史';

-- ----------------------------
--  Records of `ReleaseHistory`
-- ----------------------------
BEGIN;
INSERT INTO `ReleaseHistory` VALUES ('1', 'SampleApp', 'default', 'application', 'default', '1', '0', '0', '{}', b'0', 'apollo', '2019-11-04 02:59:03', 'apollo', '2019-11-04 02:59:03'), ('2', 'SampleApp', 'default', 'application', 'default', '2', '1', '0', '{\"isEmergencyPublish\":false}', b'0', 'apollo', '2019-11-04 11:17:52', 'apollo', '2019-11-04 11:17:52'), ('3', 'com.jingoufish.apigateway', 'default', 'application', 'default', '3', '0', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-08 10:46:20', 'apollo', '2019-11-11 04:48:43'), ('4', 'com.jingoufish.auth', 'default', 'application', 'default', '4', '0', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-08 13:43:08', 'apollo', '2019-11-11 04:49:49'), ('5', 'com.jingoufish.apigateway', 'default', 'application', 'default', '5', '3', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-08 15:30:40', 'apollo', '2019-11-11 04:48:43'), ('6', 'com.jingoufish.product', 'default', 'application', 'default', '6', '0', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-10 16:41:38', 'apollo', '2019-11-11 04:52:52'), ('7', 'com.jingoufish.order', 'default', 'application', 'default', '7', '0', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-10 17:16:31', 'apollo', '2019-11-11 04:57:16'), ('8', 'com.jingoufish.apigateway', 'default', 'application', 'default', '8', '5', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-10 22:59:07', 'apollo', '2019-11-11 04:48:43'), ('9', 'com.jingoufish.order', 'default', 'application', 'default', '9', '7', '0', '{\"isEmergencyPublish\":false}', b'1', 'apollo', '2019-11-11 09:11:00', 'apollo', '2019-11-11 04:57:16'), ('10', 'com.404abc.apigateway', 'default', 'application', 'default', '10', '0', '0', '{\"isEmergencyPublish\":false}', b'0', 'apollo', '2019-11-11 12:46:27', 'apollo', '2019-11-11 12:46:27'), ('11', 'com.404abc.auth', 'default', 'application', 'default', '11', '0', '0', '{\"isEmergencyPublish\":false}', b'0', 'apollo', '2019-11-11 12:49:42', 'apollo', '2019-11-11 12:49:42'), ('12', 'com.404abc.product', 'default', 'application', 'default', '12', '0', '0', '{\"isEmergencyPublish\":false}', b'0', 'apollo', '2019-11-11 12:51:30', 'apollo', '2019-11-11 12:51:30'), ('13', 'com.404abc.order', 'default', 'application', 'default', '13', '0', '0', '{\"isEmergencyPublish\":false}', b'0', 'apollo', '2019-11-11 12:54:44', 'apollo', '2019-11-11 12:54:44');
COMMIT;

-- ----------------------------
--  Table structure for `ReleaseMessage`
-- ----------------------------
DROP TABLE IF EXISTS `ReleaseMessage`;
CREATE TABLE `ReleaseMessage` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `Message` varchar(1024) NOT NULL DEFAULT '' COMMENT '发布的消息内容',
  `DataChange_LastTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  PRIMARY KEY (`Id`),
  KEY `DataChange_LastTime` (`DataChange_LastTime`),
  KEY `IX_Message` (`Message`(191))
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COMMENT='发布消息';

-- ----------------------------
--  Records of `ReleaseMessage`
-- ----------------------------
BEGIN;
INSERT INTO `ReleaseMessage` VALUES ('1', 'SampleApp+default+application', '2019-11-04 11:17:52'), ('9', 'com.404abc.apigateway+default+application', '2019-11-11 12:46:27'), ('10', 'com.jingoufish.apigateway+default+application', '2019-11-11 12:48:44'), ('11', 'com.404abc.auth+default+application', '2019-11-11 12:49:42'), ('12', 'com.jingoufish.auth+default+application', '2019-11-11 12:49:50'), ('13', 'com.404abc.product+default+application', '2019-11-11 12:51:30'), ('14', 'com.jingoufish.product+default+application', '2019-11-11 12:52:52'), ('15', 'com.404abc.order+default+application', '2019-11-11 12:54:44'), ('16', 'com.jingoufish.order+default+application', '2019-11-11 12:57:17');
COMMIT;

-- ----------------------------
--  Table structure for `ServerConfig`
-- ----------------------------
DROP TABLE IF EXISTS `ServerConfig`;
CREATE TABLE `ServerConfig` (
  `Id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增Id',
  `Key` varchar(64) NOT NULL DEFAULT 'default' COMMENT '配置项Key',
  `Cluster` varchar(32) NOT NULL DEFAULT 'default' COMMENT '配置对应的集群，default为不针对特定的集群',
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COMMENT='配置服务自身配置';

-- ----------------------------
--  Records of `ServerConfig`
-- ----------------------------
BEGIN;
INSERT INTO `ServerConfig` VALUES ('1', 'eureka.service.url', 'default', 'http://localhost:8080/eureka/', 'Eureka服务Url，多个service以英文逗号分隔', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('2', 'namespace.lock.switch', 'default', 'false', '一次发布只能有一个人修改开关', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('3', 'item.value.length.limit', 'default', '20000', 'item value最大长度限制', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('4', 'config-service.cache.enabled', 'default', 'false', 'ConfigService是否开启缓存，开启后能提高性能，但是会增大内存消耗！', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03'), ('5', 'item.key.length.limit', 'default', '128', 'item key 最大长度限制', b'0', 'default', '2019-11-04 02:59:03', '', '2019-11-04 02:59:03');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
