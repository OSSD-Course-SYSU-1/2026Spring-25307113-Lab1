鸿蒙应用项目完整解析
一、项目整体架构
这是一个名为 WindowOrientation 的鸿蒙应用，主要演示窗口旋转功能。项目采用 HAR模块化架构，包含一个主入口模块和多个功能模块。

二、文件结构及作用说明
1. 根目录核心文件
文件	作用
app.json5	应用全局配置文件，定义应用包名、版本号、图标等基本信息
module.json5	入口模块配置，定义Ability、页面路由、设备类型等
EntryAbility.ets	应用入口Ability，负责应用生命周期管理和窗口初始化
Index.ets	应用主页面，展示功能列表入口
2. features copy 文件夹结构
这是功能模块集合目录，包含6个独立的HAR模块：

(1) home 模块 - 首页功能

code
 
features copy/home/
├── src/main/ets/
│   ├── views/Home.ets          # 首页主视图，展示瀑布流布局和底部Tab导航
│   ├── model/TabBarModel.ets   # Tab栏数据模型定义
│   └── viewmodel/
│       ├── TabBarViewModel.ets      # Tab栏视图模型
│       └── WaterFlowDataSource.ets  # 瀑布流数据源
└── oh_modules/base/            # 公共基础模块
功能说明：

展示瀑布流布局
支持响应式布局（根据屏幕宽度调整Tab位置）
窗口方向：跟随桌面方向 (FOLLOW_DESKTOP)
(2) landscape 模块 - 横屏游戏

code
 
features copy/landscape/
├── src/main/ets/views/
│   └── LandscapeModeGame.ets   # 横屏游戏页面
└── oh_modules/base/
功能说明：

强制横屏显示 (LANDSCAPE)
展示游戏控制按钮布局
退出时恢复默认方向
(3) portrait 模块 - 竖屏游戏

code
 
features copy/portrait/
├── src/main/ets/
│   ├── views/PortraitModeGame.ets      # 竖屏游戏页面
│   └── constants/PortraitConstants.ets # 竖屏游戏常量
└── oh_modules/base/
功能说明：

强制竖屏显示 (PORTRAIT)
展示8x8网格游戏界面
退出时恢复默认方向
(4) photos 模块 - 相册功能

code
 
features copy/photos/
├── src/main/ets/
│   ├── views/Photos.ets              # 相册主页面
│   ├── model/PhotsTabBarModel.ets    # 相册Tab栏模型
│   └── viewmodel/
│       ├── ListDataSource.ets        # 列表数据源
│       └── PhotoTabBarViewModel.ets  # Tab栏视图模型
└── oh_modules/base/
功能说明：

展示图片网格布局（4列）
支持自动旋转 (AUTO_ROTATION_UNSPECIFIED)
响应式Tab导航
(5) video 模块 - 视频播放

code
 
features copy/video/
├── src/main/ets/
│   ├── views/
│   │   ├── VideoDetail.ets       # 视频详情页（处理旋转逻辑）
│   │   └── VideoDetailView.ets   # 视频详情视图
│   ├── components/
│   │   ├── VideoPlayer.ets       # 视频播放器组件
│   │   ├── AllComments.ets       # 评论组件
│   │   └── RelatedList.ets       # 相关视频列表
│   └── viewmodel/
│       ├── RelatedVideoViewModel.ets  # 相关视频视图模型
│       └── UserViewModel.ets          # 用户视图模型
└── oh_modules/base/
功能说明：

视频播放器（支持全屏、半屏）
根据窗口大小自动切换横竖屏
支持折叠屏适配
全屏时强制横屏 (AUTO_ROTATION_LANDSCAPE_RESTRICTED)
(6) stock 模块 - 股票详情

code
 
features copy/stock/
├── src/main/ets/
│   ├── views/
│   │   ├── StockDetail.ets        # 股票详情主页面
│   │   ├── StockDealDetails.ets   # 交易详情
│   │   ├── StockDetailsInfo.ets   # 股票信息
│   │   ├── ABAWindow.ets          # 分屏窗口
│   │   └── CommonViews.ets        # 公共视图组件
│   ├── model/DataModel.ets        # 数据模型
│   └── chartmodels/
│       ├── LineChartModel.ets     # 折线图模型
│       ├── BarChartView.ets       # 柱状图视图
│       └── ChartAxisFormatter.ets # 图表轴格式化
└── oh_modules/
    ├── base/
    └── @ohos/mpchart/             # 图表库
功能说明：

股票信息展示（折线图、柱状图）
支持分屏显示
跟随桌面方向 (FOLLOW_DESKTOP)
响应式布局适配
3. oh_modules/base 公共模块
每个功能模块都依赖的公共基础模块：


code
 
oh_modules/base/src/main/ets/
├── constants/
│   ├── CommonConstants.ets       # 通用常量（断点、播放状态等）
│   ├── BreakpointConstants.ets   # 断点常量
│   └── DetailConstants.ets       # 详情页常量
└── utils/
    ├── Logger.ets                # 日志工具
    ├── DisplayUtil.ets           # 显示工具（折叠屏检测）
    ├── DeviceScreen.ets          # 设备屏幕尺寸获取
    ├── BreakpointType.ets        # 断点类型工具
    ├── AvPlayerUtil.ets          # 视频播放器工具
    └── CurrentOffsetUtil.ets     # 偏移量工具