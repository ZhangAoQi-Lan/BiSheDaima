-- MySQL dump 10.13  Distrib 9.1.0, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: print_quote_db
-- ------------------------------------------------------
-- Server version	9.1.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cart_item`
--

DROP TABLE IF EXISTS `cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint DEFAULT NULL COMMENT '登录用户ID，未登录时为NULL',
  `session_id` varchar(64) NOT NULL COMMENT '前端本地生成的匿名会话ID（localStorage存储）',
  `product_id` bigint NOT NULL COMMENT '关联商品ID',
  `product_name` varchar(128) NOT NULL COMMENT '商品名称快照',
  `form_data` json NOT NULL COMMENT '表单配置快照（JSON）',
  `price` decimal(10,2) NOT NULL COMMENT '当时计算的预估价格',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `expires_at` datetime NOT NULL COMMENT '过期时间（创建时间 + 10分钟）',
  PRIMARY KEY (`id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='报价暂存箱';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_item`
--

LOCK TABLES `cart_item` WRITE;
/*!40000 ALTER TABLE `cart_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `parent_id` bigint DEFAULT NULL COMMENT '父分类ID，NULL=一级分类',
  `icon` varchar(100) DEFAULT NULL COMMENT '图标（预留）',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序权重，数值越小排越前',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品两级分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'名片卡片',NULL,NULL,1),(2,'画册',NULL,NULL,2),(3,'不干胶标签',NULL,NULL,3),(4,'单页',NULL,NULL,4),(5,'PVC制卡',NULL,NULL,5),(6,'包装盒',NULL,NULL,6),(7,'喷画条幅',NULL,NULL,7),(8,'制袋纸杯',NULL,NULL,8),(9,'办公用品',NULL,NULL,9),(10,'数码快印',NULL,NULL,10),(12,'精品名片',1,NULL,2),(13,'高档名片',1,NULL,3),(14,'纸质刮奖卡',1,NULL,4),(15,'爆款画册',2,NULL,1),(16,'商务画册',2,NULL,2),(17,'精装画册',2,NULL,3),(18,'皮革笔记本',2,NULL,4),(19,'图书出版服务',2,NULL,5),(20,'铜版纸不干胶',3,NULL,1),(21,'平张特材标签',3,NULL,2),(22,'卷筒标签',3,NULL,3),(23,'水晶标签',3,NULL,4),(24,'特款单页',4,NULL,1),(25,'优质单页',4,NULL,2),(29,'PVC标准卡',5,NULL,1),(30,'PVC异形卡',5,NULL,2),(31,'PVC数码卡',5,NULL,3),(32,'卡盒',6,NULL,1),(33,'吊耳卡盒',6,NULL,2),(34,'精品天地盖盒',6,NULL,3),(35,'精品书型盒',6,NULL,4),(36,'包装盒打样',6,NULL,5),(37,'喷绘',7,NULL,1),(38,'写真',7,NULL,2),(39,'展板',7,NULL,3),(40,'展架',7,NULL,4),(41,'锦旗绶带',7,NULL,5),(42,'彩旗条幅',7,NULL,6),(43,'标识标牌',7,NULL,7),(44,'纸袋',8,NULL,1),(45,'无纺布袋',8,NULL,2),(46,'帆布袋',8,NULL,3),(47,'纸杯',8,NULL,4),(48,'联单',9,NULL,1),(49,'票本',9,NULL,2),(50,'档案袋信封',9,NULL,3),(51,'封套卡套',9,NULL,4),(52,'纸抽',9,NULL,5),(53,'数码单页',10,NULL,1),(54,'数码不干胶',10,NULL,2),(55,'数码小卡',10,NULL,3),(56,'数码画册',10,NULL,4),(57,'数码精装画册',10,NULL,5),(58,'数码特价产品',10,NULL,6),(70,'铜版名片',1,NULL,1),(71,'铜版不覆膜',70,NULL,1),(72,'铜版哑膜',70,NULL,2),(73,'铜版亮膜',70,NULL,3),(74,'缤纷系列',12,NULL,1),(75,'美绘系列',12,NULL,2),(76,'星幻系列',12,NULL,3),(77,'爆款骑马钉画册',15,NULL,1),(78,'爆款无线胶装画册',15,NULL,2),(79,'铜版纸不干胶',20,NULL,1),(81,'双插盒',32,NULL,1),(82,'扣底盒',32,NULL,2),(83,'自锁底盒',32,NULL,3),(84,'飞机盒',32,NULL,4),(85,'吊耳双插盒',33,NULL,1),(86,'吊耳扣底盒',33,NULL,2),(87,'PVC名片',29,NULL,1),(88,'PVC会员卡',29,NULL,2),(89,'PVC智能卡',29,NULL,3),(90,'数码铜版纸单页',53,NULL,1),(91,'数码双胶纸单页',53,NULL,2),(92,'数码精品纸单页',53,NULL,3),(93,'数码铜版纸不干胶',54,NULL,1),(94,'数码精品纸不干胶',54,NULL,2),(95,'数码特材不干胶',54,NULL,3),(96,'臻脆加厚系列',13,NULL,1),(97,'名爵烫印系列',13,NULL,2),(98,'抽奖刮刮乐',14,NULL,1),(111,'骑马钉画册',16,NULL,1),(112,'无线胶装画册',16,NULL,2),(113,'锁线胶装画册',16,NULL,3),(114,'YO环装画册',16,NULL,4),(115,'扎线装画册',16,NULL,5),(116,'硬壳锁线精装画册',17,NULL,1),(117,'双层革对折款',18,NULL,1),(118,'双层革整张款',18,NULL,2),(119,'单包套款',18,NULL,3),(120,'单包裱款',18,NULL,4),(121,'软裱款',18,NULL,5),(122,'图书出版定制服务',19,NULL,1),(125,'平张特材标签',21,NULL,1),(126,'封口签',21,NULL,2),(127,'贴画',21,NULL,3),(128,'卷筒标签产品',22,NULL,1),(129,'水晶标',23,NULL,1),(131,'不干胶海报',20,NULL,2),(132,'特款铜版纸单页',24,NULL,1),(133,'铜版纸单张',25,NULL,1),(134,'双胶纸单张',25,NULL,2),(135,'哑粉纸单张',25,NULL,3),(136,'白卡纸单张',25,NULL,4),(137,'精品纸单张',25,NULL,5),(138,'PVC名片',29,NULL,1),(139,'PVC会员卡',29,NULL,2),(140,'PVC智能卡',29,NULL,3),(141,'PVC圆卡',30,NULL,1),(142,'PVC异形卡产品',30,NULL,2),(143,'PVC背胶贴',30,NULL,3),(144,'PVC折弯卡',30,NULL,4),(145,'PVC尺子',30,NULL,5),(146,'PVC数码卡产品',31,NULL,1),(147,'PVC人像证件',31,NULL,2),(148,'PVC菜单',31,NULL,3),(150,'会员管理软件机器',5,NULL,4),(151,'软件',150,NULL,1),(152,'卡盒内托',6,NULL,6),(153,'清洁盒',32,NULL,5),(154,'披萨盒',32,NULL,6),(155,'平粘盒',32,NULL,7),(156,'抽屉盒',32,NULL,8),(157,'天地盖盒',32,NULL,9),(158,'其他盒型',32,NULL,10),(159,'天地盖',34,NULL,1),(160,'中缝天地盖',34,NULL,2),(161,'四片式书型盒',35,NULL,1),(162,'手提书型盒',35,NULL,2),(163,'三片式书型盒',35,NULL,3),(164,'白卡盒打样',36,NULL,1),(165,'精品盒打样',36,NULL,2),(166,'卡盒内托明细',152,NULL,1),(167,'UV卷材',7,NULL,8),(168,'普通喷绘',37,NULL,1),(169,'室内写真',38,NULL,1),(170,'户外写真',38,NULL,2),(171,'普通UV卷材',167,NULL,1),(172,'UV灯箱画面',167,NULL,2),(173,'UV彩白彩',167,NULL,3),(174,'UV防撞腰线',167,NULL,4),(175,'写真展板',39,NULL,1),(176,'UV平板打印',39,NULL,2),(177,'展架画面',40,NULL,1),(178,'现货展架',40,NULL,2),(181,'彩色旗帜',42,NULL,1),(182,'彩色条幅',42,NULL,2),(183,'红底条幅',42,NULL,3),(184,'水晶字',43,NULL,1),(185,'锦旗',41,NULL,1),(186,'绥带',41,NULL,2),(187,'白卡纸手提袋',44,NULL,1),(188,'环保型牛皮纸手提袋',44,NULL,2),(189,'现货环保纸袋',44,NULL,3),(190,'无纺布手提袋',45,NULL,1),(191,'无纺布平口袋',45,NULL,2),(192,'帆布袋产品',46,NULL,1),(193,'广告杯',47,NULL,1),(194,'中空杯',47,NULL,2),(195,'酒店专用纸杯',47,NULL,3),(196,'酒店专用纸杯通版现货',47,NULL,4),(197,'无碳联单',48,NULL,1),(198,'机打联单',48,NULL,2),(199,'双胶纸票本',49,NULL,1),(200,'红头文件',49,NULL,2),(201,'彩胶纸单张',49,NULL,3),(202,'档案袋',50,NULL,1),(203,'中式信封',50,NULL,2),(204,'西式信封',50,NULL,3),(205,'快递封',50,NULL,4),(206,'封套',51,NULL,1),(207,'折叠式房卡套',51,NULL,2),(208,'口袋式房卡套',51,NULL,3),(209,'精品纸抽',52,NULL,1),(210,'纸质三角立牌',58,NULL,1),(211,'特价吊旗',58,NULL,2),(212,'门票|优惠券',58,NULL,3),(213,'邀请函',58,NULL,4),(214,'数码票本',58,NULL,5),(215,'数码插卡',55,NULL,1),(216,'数码小卡明细',55,NULL,2),(217,'数码骑马钉画册',56,NULL,1),(218,'数码无线胶装画册',56,NULL,2),(219,'数码锁线胶装画册',56,NULL,3),(220,'数码YO环装画册',56,NULL,4),(221,'硬壳精装画册',57,NULL,1),(222,'蝴蝶对裱精装画册',57,NULL,2),(223,'数码铜版纸单页',53,NULL,1),(224,'数码双胶纸单页',53,NULL,2),(225,'数码精品纸单页',53,NULL,3),(226,'数码铜版纸不干胶',54,NULL,1),(227,'数码精品纸不干胶',54,NULL,2),(228,'数码特材不干胶',54,NULL,3);
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `help_article`
--

DROP TABLE IF EXISTS `help_article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `help_article` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `category_id` bigint NOT NULL COMMENT '分类ID',
  `title` varchar(255) NOT NULL COMMENT '文章标题',
  `content` longtext COMMENT '文章HTML内容',
  `tags` json DEFAULT NULL COMMENT '标签JSON数组',
  `views` int NOT NULL DEFAULT '0' COMMENT '阅读次数',
  `read_time` int NOT NULL DEFAULT '3' COMMENT '预计阅读时间(分钟)',
  `helpful_count` int NOT NULL DEFAULT '0' COMMENT '有帮助数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮助中心文章表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `help_article`
--

LOCK TABLES `help_article` WRITE;
/*!40000 ALTER TABLE `help_article` DISABLE KEYS */;
INSERT INTO `help_article` VALUES (1,1,'如何使用在线报价系统？','<h2 id=\"step1\">第一步：选择产品</h2><p>在首页左侧分类导航中，将鼠标悬停在产品大类上，展开二级分类后选择您需要印刷的具体产品类型，右侧即会加载对应的动态报价表单。</p><div class=\"article-illustration compare\"><span class=\"illu-label\">产品大厅 → 分类导航 → 选择产品</span></div><h2 id=\"step2\">第二步：配置规格</h2><p>根据您的需求填写或选择各项规格参数，包括纸张材质、印刷尺寸、数量、印后工艺等。表单左侧为公共配置区，右侧为实时估价面板。系统会根据您的每一项选择实时更新预估总价。</p><h2 id=\"step3\">第三步：提交订单</h2><p>确认报价无误后，点击\"加入暂存箱\"可暂存当前配置（有效期10分钟），或直接提交订单。提交后可在\"我的订单\"中追踪状态。</p>','[\"入门\", \"报价\"]',3280,4,129,'2026-05-10 14:36:45','2026-05-10 14:47:21'),(2,1,'报价单各项参数含义说明','<h2 id=\"base\">基础底价</h2><p>基础底价是每个产品的起步价格，包含最基本的材料和人工成本。不同产品的基础底价不同，例如铜版名片起步价约¥15，精品画册起步价约¥40。</p><h2 id=\"addon\">选配加价</h2><p>当您选择特殊纸张、额外工艺（如UV、烫金）、非标尺寸时，系统会在基础底价上累加对应的选配费用。每个选项的加价金额由后台管理端预设。</p><h2 id=\"qty\">数量倍数</h2><p>最终价格 = (基础底价 + 所有选配加价) × 印刷数量。例如：底价¥20 + 选配¥5 = ¥25，印刷200份，总价 = ¥25 × 200 = ¥5,000。</p>','[\"报价\", \"参数\"]',2450,5,96,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(3,1,'第一次下单需要准备什么？','<h2 id=\"files\">准备设计文件</h2><p>请准备好符合印刷规范的源文件或PDF文件。推荐使用Adobe Illustrator、InDesign或CorelDRAW等专业设计软件。文件分辨率不低于300dpi，颜色模式为CMYK。</p><div class=\"article-illustration compare\"><span class=\"illu-label\">RGB（屏幕显示） vs CMYK（印刷色彩）对比示意图</span></div><h2 id=\"specs\">确认规格需求</h2><p>在下单前请确认好以下关键规格：成品尺寸、纸张种类与克重、印刷色数（单面/双面）、是否需要特殊工艺（覆膜/烫金/UV等）、交货数量与交期要求。</p>','[\"新手\", \"文件准备\"]',1890,3,74,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(4,2,'什么是出血线？为什么必须留出血？','<h2 id=\"bleed-def\">出血 (Bleed) 的定义</h2><p>在印刷设计中，<strong>出血</strong>是指为了避免裁切误差导致成品边缘出现白边，而将设计内容向外延伸出的额外区域。标准出血位为<strong>3mm</strong>。</p><div class=\"article-illustration compare\"><span class=\"illu-label\">左：无出血设计，裁切后有白边 | 右：有出血设计，裁切后边缘完整</span></div><h2 id=\"bleed-why\">为什么必须留出血</h2><p>印刷后期裁切工序存在±1-2mm的机械误差。如果不留出血位，裁切刀稍有偏移就会在成品边缘露出白纸底色，严重影响成品质量。尤其是满版底色或图片延伸到边缘的设计，出血是必须的。</p><h2 id=\"bleed-how\">如何设置出血</h2><p>在AI或ID中，新建文档时将出血设为3mm（四周）；将背景色/图片向外延伸至出血线；重要文字和Logo保持在安全线以内（距裁切线至少5mm）。</p>','[\"基础知识\", \"设计规范\"]',5620,4,203,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(5,2,'常见印后工艺详解：覆膜、UV、烫金、压纹','<h2 id=\"lamination\">覆膜</h2><p>覆膜分为<strong>亮膜</strong>和<strong>哑膜</strong>两种。亮膜使印刷品表面光亮鲜艳，增加色彩饱和度；哑膜呈现细腻的磨砂质感，手感高级。覆膜同时具有防水、防污、增加耐折度的保护功能。</p><h2 id=\"uv\">UV工艺</h2><p>UV上光是利用紫外线固化油墨，在特定区域形成光亮凸起效果。常见的有<strong>局部UV</strong>（仅Logo或图案部分亮光）和<strong>满版UV</strong>（整面亮光）。UV工艺可大幅提升名品、包装盒的档次感。</p><div class=\"article-illustration process\"><span class=\"illu-label\">印刷 → 覆膜 → UV上光 → 烫金 → 模切 工艺流程示意图</span></div><h2 id=\"hot-stamp\">烫金/烫银</h2><p>烫金是将金属箔通过高温压印到纸张表面，形成金属光泽的文字或图案。常见的颜色有亮金、哑金、银、红金、蓝金等。烫金的成本由烫印面积和金属箔种类决定。</p><h2 id=\"emboss\">压纹/击凸</h2><p>通过模具在纸张上压出凹凸纹理，增加立体触感。击凸是局部凸起，压纹是整面纹理。常用于高档名片、请柬、包装盒封面。</p>','[\"工艺\", \"印后\"]',4320,6,187,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(6,2,'纸张种类与克重选择指南','<h2 id=\"copper\">铜版纸</h2><p>表面光滑、白度高、色彩还原好，是最常用的印刷纸张。常见克重：<strong>128g</strong>（薄款）、<strong>157g</strong>（标准）、<strong>200g</strong>（厚款）、<strong>250g-300g</strong>（卡片类）。适用于名片、画册内页、单页。</p><h2 id=\"special\">特种纸</h2><p>包括大地纸、刚古纸、珠光纸、莱尼纸等。特种纸自带纹理和色彩，不需要大面积印刷底色即可呈现独特质感。适合高档名片、邀请函、书封。</p><div class=\"article-illustration compare\"><span class=\"illu-label\">铜版纸 vs 特种纸 印刷效果对比</span></div>','[\"纸张\", \"材料\"]',3890,5,156,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(7,3,'PDF转曲完整操作指南','<h2 id=\"why-outline\">为什么要转曲</h2><p>印刷厂的RIP（栅格化处理系统）可能不含您设计文件中使用的字体。如果字体未转曲，RIP会用默认字体替代，导致文字错位、乱码甚至缺失。<strong>转曲</strong>是将文字转为矢量路径，确保在任何设备上都能正确输出。</p><div class=\"article-illustration process\"><span class=\"illu-label\">未转曲（RIP报错） → 已转曲（正确输出）对比</span></div><h2 id=\"ai-outline\">Illustrator 转曲方法</h2><p><strong>方法一：</strong>全选文字（Ctrl+A）→ 文字菜单 → 创建轮廓（Shift+Ctrl+O）。<br><strong>方法二：</strong>文件 → 另存为 → 选择 PDF → 在\"高级\"选项中勾选\"将所有文字转为轮廓\"。</p><h2 id=\"id-outline\">InDesign 转曲方法</h2><p>InDesign 不支持直接转曲，推荐导出为 PDF/X-1a 或 PDF/X-4 标准，这些标准会嵌入全部字体子集。或使用 Acrobat Pro 的\"印刷制作 → 拼合预览\"功能将字体转为轮廓。</p><h2 id=\"check\">如何检查是否已转曲</h2><p>在 Acrobat 中打开 PDF，文件 → 属性 → 字体标签页。如果列表中<strong>无任何字体</strong>（或所有字体后标注\"(Embedded Subset)\"），则说明转曲成功或已嵌入。</p>','[\"PDF\", \"印前\", \"字体\"]',4850,5,210,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(8,3,'大墨位防粘花与干燥指南','<h2 id=\"ink-def\">什么是大墨位</h2><p>当印刷品某个区域的油墨总覆盖率超过<strong>280%</strong>时，即被视为大墨位（也称\"重墨区\"）。常见于深色背景、大面积实地色块的设计。</p><h2 id=\"ink-risk\">大墨位的风险</h2><p>1. <strong>粘花：</strong>油墨未干透时纸张堆叠，导致印张相互粘连，揭开时油墨被撕下。<br>2. <strong>干燥慢：</strong>厚墨层需要更长的干燥时间，影响后道工序。<br>3. <strong>透印：</strong>薄纸上的重墨可能透过纸张背面显现。</p><div class=\"article-illustration compare\"><span class=\"illu-label\">正常墨位 vs 大墨位粘花效果对比</span></div><h2 id=\"ink-solution\">解决方案</h2><p>1. 设计时控制总墨量不超过280%（在PS中可用\"色阶\"检查）。<br>2. 使用<strong>喷粉</strong>工艺隔开纸张。<br>3. 选用吸墨性好的纸张（如哑粉纸比光面铜版纸干燥更快）。<br>4. 大墨位产品建议增加24小时干燥时间后再进行后道工序。</p>','[\"墨位\", \"质量控制\"]',3120,4,134,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(9,3,'专色（Pantone）与四色转换指南','<h2 id=\"spot-def\">什么是专色</h2><p>专色是预先调配好的特定颜色油墨，而非由CMYK四色叠印而成。Pantone（潘通）是最通用的专色体系，每种专色有唯一色号（如PANTONE 186 C）。</p><h2 id=\"spot-why\">为什么要用专色</h2><p>1. 色彩准确：专色油墨预先调配，颜色一致性好。<br>2. 色域更广：专色可呈现CMYK无法复制的金属色、荧光色。<br>3. 品牌色：企业Logo的特定颜色通常要求专色印刷以确保品牌一致性。</p><div class=\"article-illustration compare\"><span class=\"illu-label\">CMYK四色模拟 vs 专色实印效果对比（色差示意）</span></div><h2 id=\"cmyk-convert\">四色转换注意事项</h2><p>如果预算限制，可将专色转换为CMYK印刷，但需注意：<br>1. 在AI/ID中使用Pantone色板 → 右键 → 转换为CMYK。<br>2. 转换后的CMYK值仅供参考，实际颜色以印刷色谱为准。<br>3. 亮金属色、荧光色无法用CMYK模拟，建议保留专色。</p>','[\"色彩\", \"专色\", \"Pantone\"]',2670,4,98,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(10,4,'下单后多久可以发货？','<h2 id=\"standard\">标准交期</h2><p>标准产品通常在<strong>24-48小时</strong>内完成印刷并出货。具体交期取决于产品类型和工艺复杂度：</p><p>· 单页/名片类：12-24小时<br>· 画册/装订类：36-48小时<br>· 包装盒/精装类：48-72小时<br>· 含特殊工艺（烫金/UV等）：在标准交期上加12-24小时</p><h2 id=\"urgent\">加急服务</h2><p>如需加急，可在报价时勾选\"加急\"选项。加急费通常为标准价的20%-50%，最快可缩短至6小时内出货（限部分产品）。</p>','[\"交期\", \"物流\"]',5510,3,245,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(11,4,'如何申请增值税专用发票？','<h2 id=\"apply\">开票流程</h2><p>在\"我的订单\"中选择已完成的订单，点击\"申请开票\"。填写开票信息（公司名称、税号、地址等）并提交。电子发票将在<strong>1-3个工作日</strong>内发送至您的注册邮箱；纸质发票将在5个工作日内寄出。</p><h2 id=\"timeline\">开票时限</h2><p>请在订单完成后<strong>30天内</strong>申请开票，逾期将无法补开。</p>','[\"发票\", \"财务\"]',2340,2,87,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(12,4,'异地发货物流时效参考','<h2 id=\"logistics\">物流时效表</h2><p>· 省内：1-2天<br>· 华东/华南地区：2-3天<br>· 华中/华北地区：3-4天<br>· 西南/西北地区：4-6天<br>· 偏远地区（新疆、西藏等）：5-8天</p><p>以上为<span class=\"highlight\">快递</span>时效，大件物流时效在此基础上增加1-2天。节假日顺延。</p>','[\"物流\", \"发货\"]',1980,2,63,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(13,5,'印刷质量问题的判定与处理','<h2 id=\"claim-window\">申诉时效</h2><p>请在收到货后<strong>7天内</strong>联系客服并提供清晰的实物照片（展示问题细节）。逾期将无法受理。</p><h2 id=\"valid-reasons\">可受理的质量问题</h2><p>· 色差超过行业标准范围（ΔE > 5）<br>· 裁切偏差超过2mm<br>· 装订错页、漏页、倒装<br>· 大面积脏点、墨皮、白斑<br>· 工艺遗漏（如未覆膜、未烫金等）</p><h2 id=\"invalid\">不受理的情况</h2><p>· 客户提供的文件本身存在色差<br>· 设计文件未留出血导致的裁切白边<br>· 屏幕RGB预览与印刷CMYK之间的合理色差<br>· 客户自行损坏</p>','[\"售后\", \"质量\"]',3980,4,167,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(14,5,'漏印/补印/错印的赔付标准','<h2 id=\"compensation\">赔付标准</h2><p>1. <strong>漏印/少数量：</strong>按缺少数量比例退款或免费补印。<br>2. <strong>错印/内容错误：</strong>如果错误在我方（如制版错误），全额退款或免费重印；如果错误在客户方（如文件发错版本），不予赔付但可享重印折扣。<br>3. <strong>严重质量事故：</strong>全额退款 + 免费重印 + 赠送优惠券。</p><h2 id=\"process\">处理流程</h2><p>联系客服 → 提交照片证据 → 客服初审（24h内） → 确责 → 赔付/重印 → 回访</p>','[\"赔付\", \"售后\"]',3120,3,142,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(15,5,'纸张克重误差说明','<h2 id=\"tolerance\">国标允许误差</h2><p>根据国家标准GB/T 451.2，纸张克重允许误差范围为<strong>±5%</strong>。例如：标称157g的铜版纸，实际克重在149g-165g之间均为合格。</p><p>纸张克重受环境湿度影响较大，潮湿天气纸张吸湿后克重会增加。印刷厂通常在恒温恒湿环境下存储纸张，将误差控制在±3%以内。</p>','[\"纸张\", \"标准\"]',1650,2,55,'2026-05-10 14:36:45','2026-05-10 14:36:45');
/*!40000 ALTER TABLE `help_article` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `help_category`
--

DROP TABLE IF EXISTS `help_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `help_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `description` varchar(255) DEFAULT NULL COMMENT '分类描述',
  `icon` varchar(50) NOT NULL COMMENT 'Element Plus 图标名称',
  `gradient` varchar(255) NOT NULL COMMENT 'CSS渐变色',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮助中心分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `help_category`
--

LOCK TABLES `help_category` WRITE;
/*!40000 ALTER TABLE `help_category` DISABLE KEYS */;
INSERT INTO `help_category` VALUES (1,'新手指南','从注册到完成第一笔印刷订单','Guide','linear-gradient(135deg, #667eea 0%, #764ba2 100%)',1,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(2,'印刷知识','纸张、工艺、色彩与设计规范','Reading','linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',2,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(3,'文件处理规范','PDF转曲、色彩管理、大墨位处理','Files','linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',3,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(4,'订单与交付','支付方式、发票与物流时效','Wallet','linear-gradient(135deg, #f6d365 0%, #fda085 100%)',4,'2026-05-10 14:36:45','2026-05-10 14:36:45'),(5,'售后与保障','质量投诉、退换货、赔付标准','InfoFilled','linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)',5,'2026-05-10 14:36:45','2026-05-10 14:36:45');
/*!40000 ALTER TABLE `help_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `help_feedback`
--

DROP TABLE IF EXISTS `help_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `help_feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `feedback_type` varchar(10) NOT NULL COMMENT '反馈类型: up-有帮助, down-没帮助',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_user` (`article_id`,`user_id`),
  KEY `idx_article_id` (`article_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='帮助中心反馈表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `help_feedback`
--

LOCK TABLES `help_feedback` WRITE;
/*!40000 ALTER TABLE `help_feedback` DISABLE KEYS */;
INSERT INTO `help_feedback` VALUES (1,1,2,'up','2026-05-10 14:47:21');
/*!40000 ALTER TABLE `help_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_component`
--

DROP TABLE IF EXISTS `material_component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material_component` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '组件底层类型(number, select, radio, checkbox)',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '前端对外展示的组件名称',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Element Plus 对应的图标名',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：1正常，0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'elements' COMMENT '归属分类：materials、sizeGroup、crafts、elements',
  `options_json` json DEFAULT NULL COMMENT '预设的具体业务选项数据 (预设下拉项、价格体系等)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC COMMENT='基于低代码配置的物料组件字典表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_component`
--

LOCK TABLES `material_component` WRITE;
/*!40000 ALTER TABLE `material_component` DISABLE KEYS */;
INSERT INTO `material_component` VALUES (1,'number','数量/尺寸数字输入','Loading',0,'2026-03-08 12:16:59','2026-03-08 12:16:59','elements',NULL),(2,'select','纸张/工艺下拉单选','Document',0,'2026-03-08 12:16:59','2026-03-08 12:16:59','elements',NULL),(3,'radio','基础单选按钮组','Pointer',0,'2026-03-08 12:16:59','2026-03-08 12:16:59','elements',NULL),(4,'checkbox','复杂工艺复选组','Connection',0,'2026-03-08 12:16:59','2026-03-08 12:16:59','elements',NULL),(5,'radio','高级复选','List',0,'2026-03-08 12:25:57','2026-03-08 12:25:57','elements',NULL),(6,'select','test1','Pointer',0,'2026-03-23 15:33:50','2026-03-23 15:33:50','materials','[{\"id\": \"opt_1774251211386\", \"label\": \"默认通用项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(7,'select','11111','Pointer',0,'2026-03-23 15:42:27','2026-03-23 15:42:27','elements','[{\"id\": \"opt_1774251741034\", \"label\": \"默认通用项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(8,'select','test222','Pointer',0,'2026-03-23 15:46:35','2026-03-23 15:46:35','materials','[{\"id\": \"opt_1774251987434\", \"label\": \"默认通用项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(9,'select','物料','Pointer',1,'2026-03-23 16:44:04','2026-03-23 17:03:18','materials','[]'),(10,'select','板材','Pointer',1,'2026-03-23 16:44:35','2026-03-23 17:03:50','materials','[]'),(11,'number','数量','Setting',1,'2026-03-23 16:45:17','2026-03-23 16:45:17','sizeGroup','[{\"id\": \"opt_1774255484000\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(12,'checkbox','工艺','List',1,'2026-03-23 16:46:13','2026-03-23 17:04:00','crafts','[]'),(13,'radio','印面','Pointer',1,'2026-03-23 16:46:47','2026-03-23 17:04:04','elements','[]'),(14,'size-mix','尺寸','Pointer',1,'2026-03-23 18:58:02','2026-03-23 18:58:02','sizeGroup','[{\"id\": \"opt_1774263463784\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(15,'select','款数','Pointer',0,'2026-03-23 19:10:16','2026-03-23 19:10:16','sizeGroup','[{\"id\": \"opt_1774264199393\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(16,'select','印色','Pointer',0,'2026-03-23 19:10:46','2026-03-23 19:10:46','crafts','[{\"id\": \"opt_1774264236216\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(17,'number','款数','Setting',1,'2026-03-23 19:14:16','2026-03-23 19:14:16','sizeGroup','[{\"id\": \"opt_1774264447216\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(18,'radio','印色','Pointer',1,'2026-03-24 14:23:45','2026-03-24 14:23:45','crafts','[{\"id\": \"opt_1774333403521\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(19,'number','总张数','Setting',1,'2026-03-24 15:20:56','2026-03-24 15:20:56','sizeGroup','[{\"id\": \"opt_1774336823522\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(20,'number','奖项数','Setting',1,'2026-03-24 15:21:11','2026-03-24 15:21:11','sizeGroup','[{\"id\": \"opt_1774336859530\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(21,'radio','覆膜工艺','Pointer',1,'2026-03-24 15:40:58','2026-03-24 15:40:58','crafts','[{\"id\": \"opt_1774338032121\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(22,'radio','其他工艺','Pointer',0,'2026-03-24 15:41:32','2026-03-24 15:41:32','crafts','[{\"id\": \"opt_1774338060473\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(23,'checkbox','其他工艺','List',1,'2026-03-24 15:41:53','2026-03-24 15:41:53','crafts','[{\"id\": \"opt_1774338101506\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(24,'radio','成型工艺','Pointer',1,'2026-03-24 15:52:41','2026-03-24 15:52:41','crafts','[{\"id\": \"opt_1774338742665\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(25,'checkbox','固定工艺','List',1,'2026-03-24 16:10:15','2026-03-24 16:10:15','crafts','[{\"id\": \"opt_1774339801817\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(26,'radio','文件底色','Pointer',1,'2026-03-24 16:11:16','2026-03-24 16:11:16','materials','[{\"id\": \"opt_1774339846321\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(27,'radio','文件边框','Pointer',1,'2026-03-24 16:11:36','2026-03-24 16:11:36','materials','[{\"id\": \"opt_1774339877137\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(28,'checkbox','可选工艺','List',1,'2026-03-24 16:12:16','2026-03-24 16:12:16','crafts','[{\"id\": \"opt_1774339923897\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(29,'radio','芯片','Pointer',1,'2026-03-24 16:14:07','2026-03-24 16:14:07','materials','[{\"id\": \"opt_1774340035545\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(30,'radio','样品测试','Pointer',1,'2026-03-24 16:14:25','2026-03-24 16:14:25','materials','[{\"id\": \"opt_1774340052554\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(31,'checkbox','打码工艺','List',1,'2026-03-24 16:14:50','2026-03-24 16:14:50','crafts','[{\"id\": \"opt_1774340067634\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(32,'radio','喷印工艺','Pointer',1,'2026-03-24 16:21:55','2026-03-24 16:21:55','crafts','[{\"id\": \"opt_1774340500209\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(33,'radio','裁剪工艺','Pointer',1,'2026-03-24 16:22:06','2026-03-24 16:22:06','crafts','[{\"id\": \"opt_1774340516289\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(34,'select','握口','Pointer',1,'2026-03-24 16:23:14','2026-03-24 16:23:14','materials','[{\"id\": \"opt_1774340580186\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(35,'radio','文件内容','Pointer',1,'2026-03-24 16:23:37','2026-03-24 16:23:37','materials','[{\"id\": \"opt_1774340604146\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(36,'checkbox','必选工艺','List',1,'2026-03-24 16:24:26','2026-03-24 16:24:26','crafts','[{\"id\": \"opt_1774340627009\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(37,'radio','边类型','Pointer',1,'2026-03-24 16:25:28','2026-03-24 16:25:28','materials','[{\"id\": \"opt_1774340713450\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(38,'select','宽高厚','Pointer',1,'2026-03-24 16:26:21','2026-03-24 16:26:21','sizeGroup','[{\"id\": \"opt_1774340771265\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(39,'radio','每箱数量','Pointer',1,'2026-03-24 16:27:16','2026-03-24 16:27:16','sizeGroup','[{\"id\": \"opt_1774340814225\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(40,'radio','绳子','Pointer',1,'2026-03-24 16:27:30','2026-03-24 16:27:30','materials','[{\"id\": \"opt_1774340841634\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(41,'checkbox','图案','List',1,'2026-03-24 16:27:48','2026-03-24 16:27:48','materials','[{\"id\": \"opt_1774340856137\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(42,'select','丝印颜色','Pointer',1,'2026-03-24 16:28:50','2026-03-24 16:29:30','crafts','[{\"id\": \"opt_1774340912585\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(43,'radio','成型方式','Pointer',1,'2026-03-24 16:29:15','2026-03-24 16:29:15','crafts','[{\"id\": \"opt_1774340937448\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(44,'radio','袋型','Pointer',1,'2026-03-24 16:30:14','2026-03-24 16:30:14','crafts','[{\"id\": \"opt_1774340999505\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(45,'number','产品数量','Setting',1,'2026-03-24 20:11:40','2026-03-24 20:11:40','sizeGroup','[{\"id\": \"opt_1774354281122\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(46,'size-mix','成品尺寸','Pointer',1,'2026-03-24 20:11:56','2026-03-24 20:11:56','sizeGroup','[{\"id\": \"opt_1774354303738\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(47,'radio','文件顺序','Pointer',1,'2026-03-24 20:12:14','2026-03-24 20:12:14','sizeGroup','[{\"id\": \"opt_1774354319473\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(48,'checkbox','产品工艺','List',1,'2026-03-24 20:12:43','2026-03-24 20:12:43','crafts','[{\"id\": \"opt_1774354346481\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(49,'checkbox','包装工艺','List',1,'2026-03-24 20:12:54','2026-03-24 20:12:54','crafts','[{\"id\": \"opt_1774354365490\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(50,'number','P数','Setting',1,'2026-03-24 20:22:05','2026-03-24 20:22:05','sizeGroup','[{\"id\": \"opt_1774354909073\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(51,'radio','内容','Pointer',1,'2026-03-24 20:46:57','2026-03-24 20:46:57','materials','[{\"id\": \"opt_1774356409018\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]'),(52,'checkbox','封面工艺','List',1,'2026-03-24 20:48:17','2026-03-24 20:48:17','crafts','[{\"id\": \"opt_1774356485818\", \"label\": \"默认选项\", \"priceAdd\": 0, \"priceRatio\": 1}]');
/*!40000 ALTER TABLE `material_component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_info`
--

DROP TABLE IF EXISTS `order_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `user_id` bigint DEFAULT NULL COMMENT '登录用户ID，未登录时为NULL',
  `session_id` varchar(64) DEFAULT NULL COMMENT '匿名会话ID',
  `total_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单总价',
  `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING-待处理, CONFIRMED-已确认, CANCELLED-已取消',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_session_id` (`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_info`
--

LOCK TABLES `order_info` WRITE;
/*!40000 ALTER TABLE `order_info` DISABLE KEYS */;
INSERT INTO `order_info` VALUES (1,2,'sess-aedya4hv7t9mmhj1v56',0.00,'PENDING','2026-05-08 00:06:15','2026-05-08 00:06:15'),(2,2,'sess-aedya4hv7t9mmhj1v56',0.00,'COMPLETED','2026-05-08 00:06:41','2026-05-08 22:24:18'),(3,2,'sess-aedya4hv7t9mmhj1v56',0.00,'PROCESSED','2026-05-08 00:07:17','2026-05-08 22:24:13'),(4,1,'sess-aedya4hv7t9mmhj1v56',0.00,'CANCELLED','2026-05-08 21:32:02','2026-05-08 22:20:30'),(5,2,'sess-aedya4hv7t9mmhj1v56',1.00,'PENDING','2026-05-09 23:19:03','2026-05-09 23:19:03');
/*!40000 ALTER TABLE `order_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `product_name` varchar(128) NOT NULL COMMENT '产品名称快照',
  `form_data` json NOT NULL COMMENT '表单配置快照（JSON）',
  `price` decimal(10,2) NOT NULL COMMENT '单价',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (1,1,'铜版不覆膜','{\"印色\": \"彩色\", \"印面\": \"双面不同\", \"尺寸\": \"90x54mm\", \"工艺\": \"烫印\", \"数量\": \"1张/款\", \"款数\": \"1款\", \"物料\": \"名片专用铜版\"}',0.00,'2026-05-08 00:06:15'),(2,2,'铜版不覆膜','{\"尺寸\": \"90x54mm\", \"数量\": \"1张/款\", \"款数\": \"1款\", \"物料\": \"test\"}',0.00,'2026-05-08 00:06:41'),(3,3,'铜版不覆膜','{\"印面\": \"双面相同\", \"尺寸\": \"自定义: 90 x 54 mm\", \"工艺\": \"无色凸击\", \"数量\": \"2张/款\", \"款数\": \"2款\", \"物料\": \"test\"}',0.00,'2026-05-08 00:07:17'),(4,3,'铜版不覆膜','{\"尺寸\": \"90x54mm\", \"数量\": \"1张/款\", \"款数\": \"1款\"}',0.00,'2026-05-08 00:07:17'),(5,4,'铜版不覆膜','{\"尺寸\": \"90x54mm\", \"数量\": \"1张/款\", \"款数\": \"1款\"}',0.00,'2026-05-08 21:32:02'),(6,5,'铜版不覆膜','{\"印色\": \"彩色\", \"印面\": \"双面不同\", \"尺寸\": \"90x54mm\", \"工艺\": \"烫印\", \"数量\": \"1张/款\", \"款数\": \"1款\", \"物料\": \"名片专用铜版\"}',1.00,'2026-05-09 23:19:03');
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(128) NOT NULL COMMENT '产品名称，如：高级商务名片、宣传画册',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '商品封面图直链URL',
  `status` tinyint DEFAULT '1' COMMENT '状态：0下架，1上架',
  `base_price` decimal(10,2) DEFAULT '0.00' COMMENT '产品基础计价(起步价)',
  `category_id` bigint DEFAULT NULL COMMENT '所属二级分类ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='印刷产品基础表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (8,'名片卡片test','http://localhost:9000/graduationproject/a98f7dd16815417a804e49e0aecddec4.png',1,1.00,NULL,'2026-03-11 16:34:27','2026-03-11 16:34:27');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_schema`
--

DROP TABLE IF EXISTS `product_schema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_schema` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '图纸ID',
  `product_id` bigint NOT NULL COMMENT '关联的具体产品ID',
  `schema_json` longtext NOT NULL COMMENT '由低代码配置器生成的 Schema JSON 原文，驱动前端的一切',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品 Schema 动态配置表（低代码图纸池）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_schema`
--

LOCK TABLES `product_schema` WRITE;
/*!40000 ALTER TABLE `product_schema` DISABLE KEYS */;
INSERT INTO `product_schema` VALUES (23,77,'{\"categoryId\":77,\"productName\":\"爆款骑马钉画册\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[],\"sizeGroup\":[{\"id\":\"common_number_1774354420047\",\"type\":\"number\",\"name\":\"产品数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354281122\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"本/款\"},{\"id\":\"common_size-mix_1774354421699\",\"type\":\"size-mix\",\"name\":\"成品尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354303738\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"竖版285x210mm\",\"width\":90,\"height\":54}]},{\"id\":\"common_radio_1774354423833\",\"type\":\"radio\",\"name\":\"文件顺序\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354319473\",\"label\":\"翻书顺序\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774354423833_opt_1774354514722\",\"label\":\"连版顺序\",\"priceAdd\":0}]}],\"crafts\":[{\"id\":\"common_checkbox_1774354429521\",\"type\":\"checkbox\",\"name\":\"产品工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354346481\",\"label\":\"骑马钉\",\"priceAdd\":0}]},{\"id\":\"common_checkbox_1774354431145\",\"type\":\"checkbox\",\"name\":\"包装工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354365490\",\"label\":\"纸箱包装\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_checkbox_1774354431145_opt_1774354575914\",\"label\":\"指定打包\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774354617274\",\"name\":\"总包数\",\"type\":\"number\",\"required\":false,\"options\":[{\"id\":\"sopt_1774354617274\",\"label\":\"默认选项\"}]},{\"id\":\"sub_1774354647545\",\"name\":\"打包要求\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774354647545\",\"label\":\"均包\"},{\"id\":\"sopt_1774354669465\",\"label\":\"按明细\"}]}]}]}],\"elements\":[]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[{\"id\":\"sec_base_select_1774350314449\",\"type\":\"select\",\"name\":\"板材\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[]},{\"id\":\"sec_base_radio_1774350314993\",\"type\":\"radio\",\"name\":\"文件底色\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774339846321\",\"label\":\"默认选项\",\"priceAdd\":0}]}],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]},{\"id\":\"sec_1774351185627_856\",\"name\":\"封面\",\"sortOrder\":2,\"constraints\":[],\"materials\":[{\"id\":\"sec_1774351185627_856_select_1774351191234\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_select_1774351191234_opt_1774354746401\",\"label\":\"博汇 250g 铜版纸 23丝左右\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"sec_1774351185627_856_number_1774354949009\",\"type\":\"number\",\"name\":\"P数\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354909073\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]}],\"crafts\":[{\"id\":\"sec_1774351185627_856_radio_1774351199505\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]},{\"id\":\"sec_1774351185627_856_checkbox_1774351202494\",\"type\":\"checkbox\",\"name\":\"工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_checkbox_1774351202494_opt_1774351224443\",\"label\":\"封面封底哑膜\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_checkbox_1774351202494_opt_1774351238226\",\"label\":\"封面封底亮膜\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_checkbox_1774351202494_opt_1774351249690\",\"label\":\"烫印\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774354815946\",\"name\":\"颜色\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774354815946\",\"label\":\"红色\"},{\"id\":\"sopt_1774354825489\",\"label\":\"黄色\"}]},{\"id\":\"sub_1774354829970\",\"name\":\"宽\",\"type\":\"number\",\"required\":false,\"options\":[{\"id\":\"sopt_1774354829970\",\"label\":\"默认选项\"}]},{\"id\":\"sub_1774354842521\",\"name\":\"高\",\"type\":\"number\",\"required\":false,\"options\":[{\"id\":\"sopt_1774354842521\",\"label\":\"默认选项\"}]}]},{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_checkbox_1774351202494_opt_1774351254851\",\"label\":\"压纹\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"sec_1774351185627_856_radio_1774351197451\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_radio_1774351197451_opt_1774351273897\",\"label\":\"双面\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774351185627_856_radio_1774351197451_opt_1774351274547\",\"label\":\"单面\",\"priceAdd\":0}]}]},{\"id\":\"sec_1774351345883_471\",\"name\":\"内页\",\"sortOrder\":3,\"constraints\":[],\"materials\":[{\"id\":\"sec_1774351345883_471_select_1774351351761\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774351345883_471_select_1774351351761_opt_1774351387217\",\"label\":\"鲸王 157g铜版纸 12丝左右\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"sec_1774351345883_471_number_1774354961754\",\"type\":\"number\",\"name\":\"P数\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354909073\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]}],\"crafts\":[{\"id\":\"sec_1774351345883_471_radio_1774351356793\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"sec_1774351345883_471_radio_1774351358067\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774351345883_471_radio_1774351358067_opt_1774351424234\",\"label\":\"双面\",\"priceAdd\":0}]}]},{\"id\":\"sec_1774490238781_95\",\"name\":\"test\",\"sortOrder\":4,\"materials\":[],\"sizeGroup\":[{\"id\":\"sec_1774490238781_95_number_1774490239892\",\"type\":\"number\",\"name\":\"总张数\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774336823522\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]},{\"id\":\"sec_1774490238781_95_number_1774490240258\",\"type\":\"number\",\"name\":\"奖项数\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774336859530\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]},{\"id\":\"sec_1774490238781_95_radio_1774490240602\",\"type\":\"radio\",\"name\":\"每箱数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774340814225\",\"label\":\"默认选项\",\"priceAdd\":0}]},{\"id\":\"sec_1774490238781_95_number_1774490240963\",\"type\":\"number\",\"name\":\"产品数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354281122\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]},{\"id\":\"sec_1774490238781_95_size-mix_1774490241294\",\"type\":\"size-mix\",\"name\":\"成品尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354303738\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"90x54mm\",\"width\":90,\"height\":54}]},{\"id\":\"sec_1774490238781_95_number_1774490241579\",\"type\":\"number\",\"name\":\"P数\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354909073\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]}],\"crafts\":[],\"elements\":[],\"constraints\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-26 09:57:23'),(24,71,'{\"categoryId\":71,\"productName\":\"铜版不覆膜\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774352187185\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774352187185_opt_1774352210163\",\"label\":\"名片专用铜版\",\"priceAdd\":1}]}],\"sizeGroup\":[{\"id\":\"common_number_1774352189642\",\"type\":\"number\",\"name\":\"数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774255484000\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"张/款\"},{\"id\":\"common_number_1774352191593\",\"type\":\"number\",\"name\":\"款数\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774264447216\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"款\"},{\"id\":\"common_size-mix_1774352196233\",\"type\":\"size-mix\",\"name\":\"尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774263463784\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"90x54mm\",\"width\":90,\"height\":54,\"priceAdd\":0}]}],\"crafts\":[{\"id\":\"common_radio_1774352201857\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":6,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]},{\"id\":\"common_checkbox_1774352202545\",\"type\":\"checkbox\",\"name\":\"工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":7,\"options\":[{\"priceRatio\":1,\"id\":\"common_checkbox_1774352202545_opt_1774352340066\",\"label\":\"喷码\",\"priceAdd\":-1,\"subElements\":[{\"id\":\"sub_1774352393322\",\"name\":\"数量\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774352393322\",\"label\":\"10\"},{\"id\":\"sopt_1774352427474\",\"label\":\"20\"},{\"id\":\"sopt_1774352436209\",\"label\":\"30\"}]},{\"id\":\"sub_1774352415363\",\"name\":\"颜色\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774352415363\",\"label\":\"黑色\"},{\"id\":\"sopt_1774352443609\",\"label\":\"白色\"}]}]},{\"priceRatio\":1,\"id\":\"common_checkbox_1774352202545_opt_1774352344233\",\"label\":\"烫印\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_checkbox_1774352202545_opt_1774352348729\",\"label\":\"无色凸击\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_checkbox_1774352202545_opt_1774352361113\",\"label\":\"打孔\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"common_radio_1774352199411\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"common_radio_1774352199411_opt_1774352307226\",\"label\":\"双面不同\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774352199411_opt_1774352313794\",\"label\":\"双面相同\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774352199411_opt_1774352319738\",\"label\":\"单面\",\"priceAdd\":0}]}]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null,\"modelsElId\":null}}','2026-05-09 22:05:40'),(25,74,'{\"categoryId\":74,\"productName\":\"缤纷系列\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774353304276\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774353304276_opt_1774353326393\",\"label\":\"缤纷皮纹 350g\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353304276_opt_1774353340777\",\"label\":\"缤纷麻布纹 350g\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353304276_opt_1774353349873\",\"label\":\"缤纷细布纹 350g\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"common_number_1774353307193\",\"type\":\"number\",\"name\":\"数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774255484000\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"张/款\"},{\"id\":\"common_number_1774353308793\",\"type\":\"number\",\"name\":\"款数\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774264447216\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"款\"},{\"id\":\"common_size-mix_1774353311569\",\"type\":\"size-mix\",\"name\":\"尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774263463784\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"90x54mm\",\"width\":90,\"height\":54}]}],\"crafts\":[{\"id\":\"common_radio_1774353318673\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":6,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]},{\"id\":\"common_checkbox_1774353320298\",\"type\":\"checkbox\",\"name\":\"工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":7,\"options\":[{\"priceRatio\":1,\"id\":\"common_checkbox_1774353320298_opt_1774353464683\",\"label\":\"喷码\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774353478177\",\"name\":\"数量\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774353478177\",\"label\":\"10\"},{\"id\":\"sopt_1774353501193\",\"label\":\"20\"}]}]},{\"priceRatio\":1,\"id\":\"common_checkbox_1774353320298_opt_1774353468498\",\"label\":\"烫印\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"common_radio_1774353317138\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"common_radio_1774353317138_opt_1774353426873\",\"label\":\"双面不同\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774353317138_opt_1774353438394\",\"label\":\"双面相同\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774353317138_opt_1774353443690\",\"label\":\"单面\",\"priceAdd\":0}]}]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-24 19:58:37'),(26,96,'{\"categoryId\":96,\"productName\":\"臻脆加厚系列\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774353701138\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774353701138_opt_1774353762034\",\"label\":\"臻萃金宝星 500克\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353701138_opt_1774353764449\",\"label\":\"臻萃银宝星 500克\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353701138_opt_1774353772266\",\"label\":\"臻萃炫银 600克\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353701138_opt_1774353778306\",\"label\":\"臻萃珠滑影 600克\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"common_number_1774353702753\",\"type\":\"number\",\"name\":\"数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774255484000\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"张/款\"},{\"id\":\"common_number_1774353704450\",\"type\":\"number\",\"name\":\"款数\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774264447216\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"款\"},{\"id\":\"common_size-mix_1774353708418\",\"type\":\"size-mix\",\"name\":\"尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774263463784\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"90x54mm\",\"width\":90,\"height\":54}]}],\"crafts\":[{\"id\":\"common_checkbox_1774353721433\",\"type\":\"checkbox\",\"name\":\"工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"common_checkbox_1774353721433_opt_1774353878113\",\"label\":\"烫印\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774353894162\",\"name\":\"烫印面\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774353894162\",\"label\":\"正面\"},{\"id\":\"sopt_1774353916042\",\"label\":\"反面\"}]}]}]},{\"id\":\"common_radio_1774353721977\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":6,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"common_radio_1774353711169\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"common_radio_1774353711169_opt_1774353847417\",\"label\":\"单面\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774353711169_opt_1774353848049\",\"label\":\"双面\",\"priceAdd\":0}]}]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-24 20:05:24'),(27,98,'{\"categoryId\":98,\"productName\":\"抽奖刮刮乐\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774353991090\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774353991090_opt_1774354032506\",\"label\":\"名片专用铜版 300克\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353991090_opt_1774354034793\",\"label\":\"雅致象牙白 300克\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774353991090_opt_1774354044121\",\"label\":\"星幻白滑影 355克\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"common_number_1774353994177\",\"type\":\"number\",\"name\":\"总张数\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774336823522\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"张\"},{\"id\":\"common_number_1774353996547\",\"type\":\"number\",\"name\":\"奖项数\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774336859530\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"种\"},{\"id\":\"common_size-mix_1774353999033\",\"type\":\"size-mix\",\"name\":\"尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774263463784\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"90x54mm\",\"width\":90,\"height\":54}]}],\"crafts\":[{\"id\":\"common_radio_1774354005649\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":6,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]},{\"id\":\"common_checkbox_1774354007105\",\"type\":\"checkbox\",\"name\":\"工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":7,\"options\":[{\"priceRatio\":1,\"id\":\"common_checkbox_1774354007105_opt_1774354122747\",\"label\":\"涂银\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774354136753\",\"name\":\"形状\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774354136753\",\"label\":\"18x6mm矩形\"},{\"id\":\"sopt_1774354160233\",\"label\":\"20x10mm矩形\"},{\"id\":\"sopt_1774354169321\",\"label\":\"22x8mm矩形\"}]}]},{\"priceRatio\":1,\"id\":\"common_checkbox_1774354007105_opt_1774354130866\",\"label\":\"喷码\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"common_radio_1774354003481\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"common_radio_1774354003481_opt_1774354100033\",\"label\":\"双面\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774354003481_opt_1774354106042\",\"label\":\"单面\",\"priceAdd\":0}]}]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-24 20:09:44'),(28,111,'{\"categoryId\":111,\"productName\":\"骑马钉画册\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[],\"sizeGroup\":[{\"id\":\"common_number_1774355804401\",\"type\":\"number\",\"name\":\"产品数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354281122\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"本/款\"},{\"id\":\"common_size-mix_1774355806153\",\"type\":\"size-mix\",\"name\":\"成品尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354303738\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"博汇 250克 铜版纸 23丝左右\",\"width\":90,\"height\":54}]},{\"id\":\"common_radio_1774355808217\",\"type\":\"radio\",\"name\":\"文件顺序\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354319473\",\"label\":\"翻书顺序\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774355808217_opt_1774355925203\",\"label\":\"连版顺序\",\"priceAdd\":0}]}],\"crafts\":[{\"id\":\"common_checkbox_1774355821293\",\"type\":\"checkbox\",\"name\":\"产品工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354346481\",\"label\":\"纸箱包装\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_checkbox_1774355821293_opt_1774355951545\",\"label\":\"指定包装\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774356002026\",\"name\":\"总包数\",\"type\":\"number\",\"required\":false,\"options\":[{\"id\":\"sopt_1774356002026\",\"label\":\"默认选项\"}]},{\"id\":\"sub_1774356013202\",\"name\":\"打包要求\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774356013202\",\"label\":\"均包\"},{\"id\":\"sopt_1774356023225\",\"label\":\"按明细\"}]}]},{\"priceRatio\":1,\"id\":\"common_checkbox_1774355821293_opt_1774355957681\",\"label\":\"整本圆孔\",\"priceAdd\":0}]}],\"elements\":[]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]},{\"id\":\"sec_1774356046163_360\",\"name\":\"封面\",\"sortOrder\":2,\"constraints\":[],\"materials\":[{\"id\":\"sec_1774356046163_360_select_1774356049292\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[]}],\"sizeGroup\":[],\"crafts\":[{\"id\":\"sec_1774356046163_360_radio_1774356054201\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_radio_1774356054201_opt_1774356237593\",\"label\":\"单黑\",\"priceAdd\":0}]},{\"id\":\"sec_1774356046163_360_radio_1774356056034\",\"type\":\"radio\",\"name\":\"覆膜工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774338032121\",\"label\":\"封面封底哑膜\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_radio_1774356056034_opt_1774356175754\",\"label\":\"封面封底亮膜\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_radio_1774356056034_opt_1774356187882\",\"label\":\"封面封底星光膜\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_radio_1774356056034_opt_1774356201490\",\"label\":\"封面封底刮花膜\",\"priceAdd\":0}]},{\"id\":\"sec_1774356046163_360_checkbox_1774356514123\",\"type\":\"checkbox\",\"name\":\"封面工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774356485818\",\"label\":\"压纹\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774356561929\",\"name\":\"纹路\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774356561930\",\"label\":\"细布纹\"},{\"id\":\"sopt_1774356576713\",\"label\":\"粗布纹\"},{\"id\":\"sopt_1774356585250\",\"label\":\"碎皮纹\"}]}]},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_checkbox_1774356514123_opt_1774356521698\",\"label\":\"UV\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_checkbox_1774356514123_opt_1774356531465\",\"label\":\"烫印\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_checkbox_1774356514123_opt_1774356537529\",\"label\":\"击凸\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"sec_1774356046163_360_radio_1774356052057\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_radio_1774356052057_opt_1774356217730\",\"label\":\"双面\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356046163_360_radio_1774356052057_opt_1774356218674\",\"label\":\"单面\",\"priceAdd\":0}]}]},{\"id\":\"sec_1774356267195_594\",\"name\":\"内页\",\"sortOrder\":3,\"constraints\":[],\"materials\":[{\"id\":\"sec_1774356267195_594_select_1774356272465\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774356267195_594_select_1774356272465_opt_1774356307586\",\"label\":\"常用纸\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356267195_594_select_1774356272465_opt_1774356331586\",\"label\":\"精品纸\",\"priceAdd\":0}]},{\"id\":\"sec_1774356267195_594_radio_1774356427769\",\"type\":\"radio\",\"name\":\"内容\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774356409018\",\"label\":\"内容不同\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356267195_594_radio_1774356427769_opt_1774356442010\",\"label\":\"2P循环\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"sec_1774356267195_594_number_1774356275684\",\"type\":\"number\",\"name\":\"P数\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774354909073\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[]}],\"crafts\":[{\"id\":\"sec_1774356267195_594_radio_1774356282561\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"sec_1774356267195_594_radio_1774356282561_opt_1774356373290\",\"label\":\"单黑\",\"priceAdd\":0}]}],\"elements\":[{\"id\":\"sec_1774356267195_594_radio_1774356279601\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"sec_1774356267195_594_radio_1774356279601_opt_1774356386098\",\"label\":\"双面\",\"priceAdd\":0}]}]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-24 20:49:56'),(29,79,'{\"categoryId\":79,\"productName\":\"铜版纸不干胶\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774356825234\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774356825234_opt_1774356899417\",\"label\":\"标准铜版纸不干胶\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774356825234_opt_1774356901481\",\"label\":\"品质铜版纸不干胶\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774356825234_opt_1774356908979\",\"label\":\"铜版纸加胶不干胶\",\"priceAdd\":0}]}],\"sizeGroup\":[{\"id\":\"common_number_1774356827921\",\"type\":\"number\",\"name\":\"数量\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774255484000\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"张/款\"},{\"id\":\"common_number_1774356829545\",\"type\":\"number\",\"name\":\"款数\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774264447216\",\"label\":\"默认选项\",\"priceAdd\":0}],\"min\":1,\"max\":1000,\"step\":1,\"presets\":[],\"unit\":\"款\"},{\"id\":\"common_size-mix_1774356830794\",\"type\":\"size-mix\",\"name\":\"尺寸\",\"tip\":\"\",\"isRequired\":false,\"weight\":4,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774263463784\",\"label\":\"默认选项\",\"priceAdd\":0}],\"presets\":[{\"label\":\"90x54mm\",\"width\":90,\"height\":54}]}],\"crafts\":[{\"id\":\"common_radio_1774356836626\",\"type\":\"radio\",\"name\":\"印色\",\"tip\":\"\",\"isRequired\":false,\"weight\":6,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774333403521\",\"label\":\"彩色\",\"priceAdd\":0}]},{\"id\":\"common_radio_1774356839250\",\"type\":\"radio\",\"name\":\"覆膜工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":7,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774338032121\",\"label\":\"单面亮膜\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774356839250_opt_1774356975850\",\"label\":\"单面哑膜\",\"priceAdd\":0}]},{\"id\":\"common_checkbox_1774356841266\",\"type\":\"checkbox\",\"name\":\"其他工艺\",\"tip\":\"\",\"isRequired\":false,\"weight\":8,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774338101506\",\"label\":\"直角裁成品\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_checkbox_1774356841266_opt_1774357004538\",\"label\":\"模切\",\"priceAdd\":0,\"subElements\":[{\"id\":\"sub_1774357026914\",\"name\":\"刀版形状\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774357026914\",\"label\":\"圆形\"},{\"id\":\"sopt_1774357039426\",\"label\":\"异性\"},{\"id\":\"sopt_1774357051377\",\"label\":\"直角\"}]},{\"id\":\"sub_1774357056769\",\"name\":\"成型方式\",\"type\":\"select\",\"required\":false,\"options\":[{\"id\":\"sopt_1774357056769\",\"label\":\"裁单个\"},{\"id\":\"sopt_1774357072402\",\"label\":\"连多个\"}]}]}]}],\"elements\":[{\"id\":\"common_radio_1774356834105\",\"type\":\"radio\",\"name\":\"印面\",\"tip\":\"\",\"isRequired\":false,\"weight\":5,\"options\":[{\"priceRatio\":1,\"id\":\"common_radio_1774356834105_opt_1774356952290\",\"label\":\"单面\",\"priceAdd\":0}]}]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-24 20:58:08'),(30,73,'{\"categoryId\":73,\"productName\":\"铜版亮膜\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774453802783\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[]},{\"id\":\"common_select_1774453803182\",\"type\":\"select\",\"name\":\"板材\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[]},{\"id\":\"common_radio_1774453803533\",\"type\":\"radio\",\"name\":\"文件底色\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774339846321\",\"label\":\"默认选项\",\"priceAdd\":0}]},{\"id\":\"common_radio_1774453803878\",\"type\":\"radio\",\"name\":\"文件边框\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774339877137\",\"label\":\"默认选项\",\"priceAdd\":0}]}],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-25 23:50:06'),(31,87,'{\"categoryId\":87,\"productName\":\"PVC名片\",\"schemaVersion\":2,\"common\":{\"id\":\"common\",\"name\":\"\",\"sortOrder\":0,\"constraints\":[],\"materials\":[{\"id\":\"common_select_1774490575322\",\"type\":\"select\",\"name\":\"物料\",\"tip\":\"\",\"isRequired\":false,\"weight\":1,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774490575322_opt_1774490584844\",\"label\":\"test1\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774490575322_opt_1774490590211\",\"label\":\"test2\",\"priceAdd\":0}]},{\"id\":\"common_select_1774490575725\",\"type\":\"select\",\"name\":\"板材\",\"tip\":\"\",\"isRequired\":false,\"weight\":2,\"options\":[{\"priceRatio\":1,\"id\":\"common_select_1774490575725_opt_1774490603301\",\"label\":\"板材1\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_select_1774490575725_opt_1774490611402\",\"label\":\"板材2\",\"priceAdd\":0}]},{\"id\":\"common_radio_1774490576074\",\"type\":\"radio\",\"name\":\"文件底色\",\"tip\":\"\",\"isRequired\":false,\"weight\":3,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774339846321\",\"label\":\"文件底色1\",\"priceAdd\":0},{\"priceRatio\":1,\"id\":\"common_radio_1774490576074_opt_1774490621259\",\"label\":\"test2\",\"priceAdd\":0}]},{\"id\":\"common_radio_1774490576403\",\"type\":\"radio\",\"name\":\"芯片\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774340035545\",\"label\":\"默认选项\",\"priceAdd\":0}]},{\"id\":\"common_select_1774490577509\",\"type\":\"select\",\"name\":\"握口\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774340580186\",\"label\":\"默认选项\",\"priceAdd\":0}]},{\"id\":\"common_radio_1774490577835\",\"type\":\"radio\",\"name\":\"文件内容\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774340604146\",\"label\":\"默认选项\",\"priceAdd\":0}]},{\"id\":\"common_radio_1774490578210\",\"type\":\"radio\",\"name\":\"边类型\",\"tip\":\"\",\"isRequired\":false,\"weight\":0,\"options\":[{\"priceRatio\":1,\"id\":\"opt_1774340713450\",\"label\":\"默认选项\",\"priceAdd\":0}]}],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]},\"sections\":[{\"id\":\"sec_base\",\"name\":\"\",\"sortOrder\":1,\"constraints\":[],\"materials\":[],\"sizeGroup\":[],\"crafts\":[],\"elements\":[]}],\"constraints\":[],\"pricing\":{\"basePrice\":0,\"quantityElId\":null}}','2026-03-26 10:04:04');
/*!40000 ALTER TABLE `product_schema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quote_order`
--

DROP TABLE IF EXISTS `quote_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quote_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单主键',
  `user_id` bigint NOT NULL COMMENT '关联用户ID',
  `category_id` bigint DEFAULT NULL COMMENT '产品分类ID',
  `product_name` varchar(128) DEFAULT NULL COMMENT '产品名称快照',
  `form_data` longtext COMMENT '定制参数明细(JSON 字符串格式)',
  `raw_form_data` longtext COMMENT '原始配置数据(用于二次编辑或详细解析)',
  `price` decimal(10,2) DEFAULT '0.00' COMMENT '订单总价',
  `status` varchar(32) DEFAULT '待处理' COMMENT '订单状态：待处理、生产中、已发货、已取消',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定制报价订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quote_order`
--

LOCK TABLES `quote_order` WRITE;
/*!40000 ALTER TABLE `quote_order` DISABLE KEYS */;
/*!40000 ALTER TABLE `quote_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码 (建议哈希存储)',
  `email` varchar(50) DEFAULT NULL COMMENT '绑定的邮箱',
  `nickname` varchar(50) DEFAULT NULL COMMENT '显示昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `role` varchar(20) NOT NULL DEFAULT 'USER' COMMENT '角色：ADMIN-管理员，USER-普通用户',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','$2a$10$uDCJcbSyDQt91W3C/RUeUOHUxweaU54bpqNi.Do/IJTFpwaEhcM/q','admin@example.com',NULL,NULL,'ADMIN','2026-03-08 14:02:02','2026-03-08 14:44:18'),(2,'user','$2a$10$aQcyJ1fMetmYDxtMFtURnOugq9b8p1QQ1ZMa/70OGY3ZjwnD4pfc2','234234234234@example.com','xiaolanlan','http://localhost:9000/graduationproject/bf07fa1cbf794da497138db173f4e103.webp','USER','2026-03-08 14:02:02','2026-05-08 22:22:33'),(3,'test1','$2a$10$uDCJcbSyDQt91W3C/RUeUOHUxweaU54bpqNi.Do/IJTFpwaEhcM/q','15225794712@163.com',NULL,NULL,'USER','2026-03-08 14:33:31','2026-03-08 14:33:31'),(4,'test2','$2a$10$7KZYTzC1vhekcIyaXXfJxuCEyopH67YfIZZ4jVteuR/HJkiIrxeJK','xiaolanlan2003@gmail.com',NULL,NULL,'USER','2026-03-08 14:56:31','2026-03-08 14:56:31');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-10 15:55:58
