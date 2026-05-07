# 商城界面视觉优化说明

我们将您的“图二”界面参考“图一”的行业标杆，进行了深度视觉重构。

## 核心优化点

### 1. 引导性空状态 (Empty State)
- **3D 插图引入**：定制了一张极简 3D 风格的“空包裹与人”插图，替代了单薄的文字提示。
- **完全居中排版**：利用 Flex 布局将插图与提示文字垂直水平居中，消除了视觉上的空旷感。
- **淡入动画**：为该区域添加了 `fadeIn` 过场动画，使进入页面时更具灵动感。

### 2. 侧边栏极简重构 (Simplified Sidebar)
- **图标瘦身**：移除了之前的文件夹图标，改为纯文字搭配侧面色块指示器，更符合现代扁平化设计趋势。
- **交互强化**：优化了鼠标悬停（Hover）和选中（Active）的背景色差，视觉反馈更轻盈。
- **阴影优化**：减弱了背景阴影深度，使其更自然地融入背景。

### 3. 内容区容器优化
- **圆角与深度**：调优了内容区域的 `border-radius` (12px) 和 `box-shadow`。
- **层级感**：背景色统一为浅灰蓝 (`#f2f5f8`)，突显白色功能面板。

## 资源文件说明
- 新插图已存放至：`src/assets/illustrations/empty-mall.png`

---

![优化后的空状态效果图](file:///d:/Graduationproject/GratuationFiles/lowcode-quote-platform/src/assets/illustrations/empty-mall.png)
