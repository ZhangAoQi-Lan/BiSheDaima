-- 帮助中心 - 分类表
CREATE TABLE IF NOT EXISTS `help_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `description` varchar(255) DEFAULT NULL COMMENT '分类描述',
  `icon` varchar(50) NOT NULL COMMENT 'Element Plus 图标名称',
  `gradient` varchar(255) NOT NULL COMMENT 'CSS渐变色',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帮助中心分类表';

-- 帮助中心 - 文章表
CREATE TABLE IF NOT EXISTS `help_article` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `category_id` bigint(20) NOT NULL COMMENT '分类ID',
  `title` varchar(255) NOT NULL COMMENT '文章标题',
  `content` longtext COMMENT '文章HTML内容',
  `tags` json DEFAULT NULL COMMENT '标签JSON数组',
  `views` int(11) NOT NULL DEFAULT 0 COMMENT '阅读次数',
  `read_time` int(11) NOT NULL DEFAULT 3 COMMENT '预计阅读时间(分钟)',
  `helpful_count` int(11) NOT NULL DEFAULT 0 COMMENT '有帮助数',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帮助中心文章表';

-- 帮助中心 - 反馈表
CREATE TABLE IF NOT EXISTS `help_feedback` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `article_id` bigint(20) NOT NULL COMMENT '文章ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `feedback_type` varchar(10) NOT NULL COMMENT '反馈类型: up-有帮助, down-没帮助',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_article_user` (`article_id`, `user_id`),
  KEY `idx_article_id` (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帮助中心反馈表';

-- ===== 种子数据 =====

INSERT IGNORE INTO `help_category` (`id`, `name`, `description`, `icon`, `gradient`, `sort_order`) VALUES
(1, '新手指南', '从注册到完成第一笔印刷订单', 'Guide', 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', 1),
(2, '印刷知识', '纸张、工艺、色彩与设计规范', 'Reading', 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)', 2),
(3, '文件处理规范', 'PDF转曲、色彩管理、大墨位处理', 'Files', 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', 3),
(4, '订单与交付', '支付方式、发票与物流时效', 'Wallet', 'linear-gradient(135deg, #f6d365 0%, #fda085 100%)', 4),
(5, '售后与保障', '质量投诉、退换货、赔付标准', 'InfoFilled', 'linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)', 5);

INSERT IGNORE INTO `help_article` (`id`, `category_id`, `title`, `content`, `tags`, `views`, `read_time`, `helpful_count`) VALUES
(1, 1, '如何使用在线报价系统？', '<h2 id="step1">第一步：选择产品</h2><p>在首页左侧分类导航中，将鼠标悬停在产品大类上，展开二级分类后选择您需要印刷的具体产品类型，右侧即会加载对应的动态报价表单。</p><div class="article-illustration compare"><span class="illu-label">产品大厅 → 分类导航 → 选择产品</span></div><h2 id="step2">第二步：配置规格</h2><p>根据您的需求填写或选择各项规格参数，包括纸张材质、印刷尺寸、数量、印后工艺等。表单左侧为公共配置区，右侧为实时估价面板。系统会根据您的每一项选择实时更新预估总价。</p><h2 id="step3">第三步：提交订单</h2><p>确认报价无误后，点击"加入暂存箱"可暂存当前配置（有效期10分钟），或直接提交订单。提交后可在"我的订单"中追踪状态。</p>', '["入门", "报价"]', 3280, 4, 128),
(2, 1, '报价单各项参数含义说明', '<h2 id="base">基础底价</h2><p>基础底价是每个产品的起步价格，包含最基本的材料和人工成本。不同产品的基础底价不同，例如铜版名片起步价约¥15，精品画册起步价约¥40。</p><h2 id="addon">选配加价</h2><p>当您选择特殊纸张、额外工艺（如UV、烫金）、非标尺寸时，系统会在基础底价上累加对应的选配费用。每个选项的加价金额由后台管理端预设。</p><h2 id="qty">数量倍数</h2><p>最终价格 = (基础底价 + 所有选配加价) × 印刷数量。例如：底价¥20 + 选配¥5 = ¥25，印刷200份，总价 = ¥25 × 200 = ¥5,000。</p>', '["报价", "参数"]', 2450, 5, 96),
(3, 1, '第一次下单需要准备什么？', '<h2 id="files">准备设计文件</h2><p>请准备好符合印刷规范的源文件或PDF文件。推荐使用Adobe Illustrator、InDesign或CorelDRAW等专业设计软件。文件分辨率不低于300dpi，颜色模式为CMYK。</p><div class="article-illustration compare"><span class="illu-label">RGB（屏幕显示） vs CMYK（印刷色彩）对比示意图</span></div><h2 id="specs">确认规格需求</h2><p>在下单前请确认好以下关键规格：成品尺寸、纸张种类与克重、印刷色数（单面/双面）、是否需要特殊工艺（覆膜/烫金/UV等）、交货数量与交期要求。</p>', '["新手", "文件准备"]', 1890, 3, 74),
(4, 2, '什么是出血线？为什么必须留出血？', '<h2 id="bleed-def">出血 (Bleed) 的定义</h2><p>在印刷设计中，<strong>出血</strong>是指为了避免裁切误差导致成品边缘出现白边，而将设计内容向外延伸出的额外区域。标准出血位为<strong>3mm</strong>。</p><div class="article-illustration compare"><span class="illu-label">左：无出血设计，裁切后有白边 | 右：有出血设计，裁切后边缘完整</span></div><h2 id="bleed-why">为什么必须留出血</h2><p>印刷后期裁切工序存在±1-2mm的机械误差。如果不留出血位，裁切刀稍有偏移就会在成品边缘露出白纸底色，严重影响成品质量。尤其是满版底色或图片延伸到边缘的设计，出血是必须的。</p><h2 id="bleed-how">如何设置出血</h2><p>在AI或ID中，新建文档时将出血设为3mm（四周）；将背景色/图片向外延伸至出血线；重要文字和Logo保持在安全线以内（距裁切线至少5mm）。</p>', '["基础知识", "设计规范"]', 5620, 4, 203),
(5, 2, '常见印后工艺详解：覆膜、UV、烫金、压纹', '<h2 id="lamination">覆膜</h2><p>覆膜分为<strong>亮膜</strong>和<strong>哑膜</strong>两种。亮膜使印刷品表面光亮鲜艳，增加色彩饱和度；哑膜呈现细腻的磨砂质感，手感高级。覆膜同时具有防水、防污、增加耐折度的保护功能。</p><h2 id="uv">UV工艺</h2><p>UV上光是利用紫外线固化油墨，在特定区域形成光亮凸起效果。常见的有<strong>局部UV</strong>（仅Logo或图案部分亮光）和<strong>满版UV</strong>（整面亮光）。UV工艺可大幅提升名品、包装盒的档次感。</p><div class="article-illustration process"><span class="illu-label">印刷 → 覆膜 → UV上光 → 烫金 → 模切 工艺流程示意图</span></div><h2 id="hot-stamp">烫金/烫银</h2><p>烫金是将金属箔通过高温压印到纸张表面，形成金属光泽的文字或图案。常见的颜色有亮金、哑金、银、红金、蓝金等。烫金的成本由烫印面积和金属箔种类决定。</p><h2 id="emboss">压纹/击凸</h2><p>通过模具在纸张上压出凹凸纹理，增加立体触感。击凸是局部凸起，压纹是整面纹理。常用于高档名片、请柬、包装盒封面。</p>', '["工艺", "印后"]', 4320, 6, 187),
(6, 2, '纸张种类与克重选择指南', '<h2 id="copper">铜版纸</h2><p>表面光滑、白度高、色彩还原好，是最常用的印刷纸张。常见克重：<strong>128g</strong>（薄款）、<strong>157g</strong>（标准）、<strong>200g</strong>（厚款）、<strong>250g-300g</strong>（卡片类）。适用于名片、画册内页、单页。</p><h2 id="special">特种纸</h2><p>包括大地纸、刚古纸、珠光纸、莱尼纸等。特种纸自带纹理和色彩，不需要大面积印刷底色即可呈现独特质感。适合高档名片、邀请函、书封。</p><div class="article-illustration compare"><span class="illu-label">铜版纸 vs 特种纸 印刷效果对比</span></div>', '["纸张", "材料"]', 3890, 5, 156),
(7, 3, 'PDF转曲完整操作指南', '<h2 id="why-outline">为什么要转曲</h2><p>印刷厂的RIP（栅格化处理系统）可能不含您设计文件中使用的字体。如果字体未转曲，RIP会用默认字体替代，导致文字错位、乱码甚至缺失。<strong>转曲</strong>是将文字转为矢量路径，确保在任何设备上都能正确输出。</p><div class="article-illustration process"><span class="illu-label">未转曲（RIP报错） → 已转曲（正确输出）对比</span></div><h2 id="ai-outline">Illustrator 转曲方法</h2><p><strong>方法一：</strong>全选文字（Ctrl+A）→ 文字菜单 → 创建轮廓（Shift+Ctrl+O）。<br><strong>方法二：</strong>文件 → 另存为 → 选择 PDF → 在"高级"选项中勾选"将所有文字转为轮廓"。</p><h2 id="id-outline">InDesign 转曲方法</h2><p>InDesign 不支持直接转曲，推荐导出为 PDF/X-1a 或 PDF/X-4 标准，这些标准会嵌入全部字体子集。或使用 Acrobat Pro 的"印刷制作 → 拼合预览"功能将字体转为轮廓。</p><h2 id="check">如何检查是否已转曲</h2><p>在 Acrobat 中打开 PDF，文件 → 属性 → 字体标签页。如果列表中<strong>无任何字体</strong>（或所有字体后标注"(Embedded Subset)"），则说明转曲成功或已嵌入。</p>', '["PDF", "印前", "字体"]', 4850, 5, 210),
(8, 3, '大墨位防粘花与干燥指南', '<h2 id="ink-def">什么是大墨位</h2><p>当印刷品某个区域的油墨总覆盖率超过<strong>280%</strong>时，即被视为大墨位（也称"重墨区"）。常见于深色背景、大面积实地色块的设计。</p><h2 id="ink-risk">大墨位的风险</h2><p>1. <strong>粘花：</strong>油墨未干透时纸张堆叠，导致印张相互粘连，揭开时油墨被撕下。<br>2. <strong>干燥慢：</strong>厚墨层需要更长的干燥时间，影响后道工序。<br>3. <strong>透印：</strong>薄纸上的重墨可能透过纸张背面显现。</p><div class="article-illustration compare"><span class="illu-label">正常墨位 vs 大墨位粘花效果对比</span></div><h2 id="ink-solution">解决方案</h2><p>1. 设计时控制总墨量不超过280%（在PS中可用"色阶"检查）。<br>2. 使用<strong>喷粉</strong>工艺隔开纸张。<br>3. 选用吸墨性好的纸张（如哑粉纸比光面铜版纸干燥更快）。<br>4. 大墨位产品建议增加24小时干燥时间后再进行后道工序。</p>', '["墨位", "质量控制"]', 3120, 4, 134),
(9, 3, '专色（Pantone）与四色转换指南', '<h2 id="spot-def">什么是专色</h2><p>专色是预先调配好的特定颜色油墨，而非由CMYK四色叠印而成。Pantone（潘通）是最通用的专色体系，每种专色有唯一色号（如PANTONE 186 C）。</p><h2 id="spot-why">为什么要用专色</h2><p>1. 色彩准确：专色油墨预先调配，颜色一致性好。<br>2. 色域更广：专色可呈现CMYK无法复制的金属色、荧光色。<br>3. 品牌色：企业Logo的特定颜色通常要求专色印刷以确保品牌一致性。</p><div class="article-illustration compare"><span class="illu-label">CMYK四色模拟 vs 专色实印效果对比（色差示意）</span></div><h2 id="cmyk-convert">四色转换注意事项</h2><p>如果预算限制，可将专色转换为CMYK印刷，但需注意：<br>1. 在AI/ID中使用Pantone色板 → 右键 → 转换为CMYK。<br>2. 转换后的CMYK值仅供参考，实际颜色以印刷色谱为准。<br>3. 亮金属色、荧光色无法用CMYK模拟，建议保留专色。</p>', '["色彩", "专色", "Pantone"]', 2670, 4, 98),
(10, 4, '下单后多久可以发货？', '<h2 id="standard">标准交期</h2><p>标准产品通常在<strong>24-48小时</strong>内完成印刷并出货。具体交期取决于产品类型和工艺复杂度：</p><p>· 单页/名片类：12-24小时<br>· 画册/装订类：36-48小时<br>· 包装盒/精装类：48-72小时<br>· 含特殊工艺（烫金/UV等）：在标准交期上加12-24小时</p><h2 id="urgent">加急服务</h2><p>如需加急，可在报价时勾选"加急"选项。加急费通常为标准价的20%-50%，最快可缩短至6小时内出货（限部分产品）。</p>', '["交期", "物流"]', 5510, 3, 245),
(11, 4, '如何申请增值税专用发票？', '<h2 id="apply">开票流程</h2><p>在"我的订单"中选择已完成的订单，点击"申请开票"。填写开票信息（公司名称、税号、地址等）并提交。电子发票将在<strong>1-3个工作日</strong>内发送至您的注册邮箱；纸质发票将在5个工作日内寄出。</p><h2 id="timeline">开票时限</h2><p>请在订单完成后<strong>30天内</strong>申请开票，逾期将无法补开。</p>', '["发票", "财务"]', 2340, 2, 87),
(12, 4, '异地发货物流时效参考', '<h2 id="logistics">物流时效表</h2><p>· 省内：1-2天<br>· 华东/华南地区：2-3天<br>· 华中/华北地区：3-4天<br>· 西南/西北地区：4-6天<br>· 偏远地区（新疆、西藏等）：5-8天</p><p>以上为<span class="highlight">快递</span>时效，大件物流时效在此基础上增加1-2天。节假日顺延。</p>', '["物流", "发货"]', 1980, 2, 63),
(13, 5, '印刷质量问题的判定与处理', '<h2 id="claim-window">申诉时效</h2><p>请在收到货后<strong>7天内</strong>联系客服并提供清晰的实物照片（展示问题细节）。逾期将无法受理。</p><h2 id="valid-reasons">可受理的质量问题</h2><p>· 色差超过行业标准范围（ΔE > 5）<br>· 裁切偏差超过2mm<br>· 装订错页、漏页、倒装<br>· 大面积脏点、墨皮、白斑<br>· 工艺遗漏（如未覆膜、未烫金等）</p><h2 id="invalid">不受理的情况</h2><p>· 客户提供的文件本身存在色差<br>· 设计文件未留出血导致的裁切白边<br>· 屏幕RGB预览与印刷CMYK之间的合理色差<br>· 客户自行损坏</p>', '["售后", "质量"]', 3980, 4, 167),
(14, 5, '漏印/补印/错印的赔付标准', '<h2 id="compensation">赔付标准</h2><p>1. <strong>漏印/少数量：</strong>按缺少数量比例退款或免费补印。<br>2. <strong>错印/内容错误：</strong>如果错误在我方（如制版错误），全额退款或免费重印；如果错误在客户方（如文件发错版本），不予赔付但可享重印折扣。<br>3. <strong>严重质量事故：</strong>全额退款 + 免费重印 + 赠送优惠券。</p><h2 id="process">处理流程</h2><p>联系客服 → 提交照片证据 → 客服初审（24h内） → 确责 → 赔付/重印 → 回访</p>', '["赔付", "售后"]', 3120, 3, 142),
(15, 5, '纸张克重误差说明', '<h2 id="tolerance">国标允许误差</h2><p>根据国家标准GB/T 451.2，纸张克重允许误差范围为<strong>±5%</strong>。例如：标称157g的铜版纸，实际克重在149g-165g之间均为合格。</p><p>纸张克重受环境湿度影响较大，潮湿天气纸张吸湿后克重会增加。印刷厂通常在恒温恒湿环境下存储纸张，将误差控制在±3%以内。</p>', '["纸张", "标准"]', 1650, 2, 55);
