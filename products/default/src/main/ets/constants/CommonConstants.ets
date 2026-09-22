// ---- 1. 原有的响应式布局接口 ----
interface CommonConstantsInterface {
  columnXs: number;
  columnSm: number;
  columnMd: number;
  columnLg: number;
  spanXs: number;
  spanSm: number;
  spanMd: number;
  spanLg: number;
  offsetXs: number;
  offsetSm: number;
  offsetMd: number;
  offsetLg: number;
  listFontWeight: number;
  listWidth: string;
  listItemWidth: string;
  columnHeight: string;
  bundleName: string;
  abilityName: string;
  breakpointsInitializeName: string;
  locationCapability: string;
  breakpointSystemName: string;
  systemColumnHeight: string;
  systemColumnWidth: string;
  systemRowWidth: string;
  textFontWeight: number;
  adaptiveColumnWidth: string;
  adaptiveColumnHeight: string;
  adaptiveFlexibleColumnWidth: string;
  adaptiveFlexShrink: number;
}

// ----主题颜色常量 (直接导出，方便各组件按需引入) ----
export const PRIMARY: string = '#007DFF';
export const PRIMARY_LIGHT: string = '#EAF1FF';
export const PAGE_BACKGROUND: string = '#FFFFFF';
export const SURFACE: string = '#FFFFFF';
export const TEXT_PRIMARY: string = '#182431';//正文、标题
export const TEXT_SECONDARY: string = '#6B7280';//按钮
export const TEXT_MUTED: string ='#9CA3AF';//辅助文字，标签，占位文字
export const DIVIDER: string = '#F3F4F6';//分割线
export const DANGER: string = '#C9342D';
export const BORDER: string ='#E5E7EB';//输入框、按钮

// 侧边栏专用颜色
export const SIDEBAR_BG: string = '#F7F7F7';
export const SIDEBAR_TEXT: string = '#333333';
export const SIDEBAR_ACTIVE_BG: string = '#E6F0FF';
export const SIDEBAR_ACTIVE_TEXT: string = '#007DFF';
export const SIDEBAR_GROUP_TITLE: string = '#9A9A9A';

export type Panel = 'home' | 'repos' | 'templates' | 'mytemplates' | 'profile' | 'messages' | 'assistant'
  | 'info' | 'sharing' | 'storage' | 'uploads' | 'security';

export interface MenuItem {
  label: string;
  icon: string;
  panel: Panel;
}

export interface NavItem {
  label: string;
  icon: string;
  panel: Panel;
  badge?: number;
}

export const PROJECT_ITEMS: NavItem[] = [
  { label: '项目仓库', icon: 'folder_group', panel: 'repos' },
  { label: '模板广场', icon: 'template_group', panel: 'templates' },
  { label: '我的模板', icon: 'template', panel: 'mytemplates' }
];

export const ACCOUNT_ITEMS: NavItem[] = [
  { label: '个人中心', icon: 'person', panel: 'profile' },
  { label: '消息中心', icon: 'bell', panel: 'messages', badge: 4 },
  { label: 'AI助手', icon: 'sparkle', panel: 'assistant' }
];

export const MENU_ITEMS: MenuItem[] = [
  { label: '基本信息', icon: 'info', panel: 'info' },
  { label: '共享记录', icon: 'share', panel: 'sharing' },
  { label: '存储空间', icon: 'cloud', panel: 'storage' },
  { label: '上传记录', icon: 'upload', panel: 'uploads' },
  { label: '账号安全', icon: 'lock', panel: 'security' }
];

// 左侧边栏一级导航：功能入口 + 个人中心（个人中心下展示二级菜单）
export const SIDEBAR_ITEMS: MenuItem[] = [
  { label: '项目仓库', icon: 'R', panel: 'repos' },
  { label: '模板广场', icon: 'T', panel: 'templates' },
  { label: '我的模板', icon: 'M', panel: 'mytemplates' },
  { label: '个人中心', icon: 'P', panel: 'profile' },
  { label: '消息中心', icon: 'N', panel: 'messages' },
  { label: 'AI助手', icon: 'A', panel: 'assistant' }
];

// ---- 4. 原有的通用配置对象 ----
export const commonConstants: CommonConstantsInterface = {
  /** XS设备列数 */
  columnXs: 4,
  /** SM设备列数 */
  columnSm: 4,
  /** MD设备列数 */
  columnMd: 8,
  /** LG设备列数 */
  columnLg: 12,

  /** XS设备跨度 */
  spanXs: 4,
  /** SM设备跨度 */
  spanSm: 4,
  /** MD设备跨度 */
  spanMd: 4,
  /** LG设备跨度 */
  spanLg: 4,

  /** XS设备偏移量 */
  offsetXs: 0,
  /** SM设备偏移量 */
  offsetSm: 0,
  /** MD设备偏移量 */
  offsetMd: 2,
  /** LG设备偏移量 */
  offsetLg: 4,

  /** 列表字体粗细 */
  listFontWeight: 500,
  /** 列表宽度 */
  listWidth: '100%',
  /** 列表项宽度占比 */
  listItemWidth: '100%',
  /** 列高度占比 */
  columnHeight: '100%',

  /** 应用包名 */
  bundleName: 'com.example.myapplication',
  /** Ability名称 */
  abilityName: 'ResponsiveLayoutItemAbility',

  /** 初始化断点 */
  breakpointsInitializeName: 'md',
  /** 定位能力 */
  locationCapability: 'SystemCapability.Location.Location.Core',
  /** 断点系统名称 */
  breakpointSystemName: 'mainBreakpoint',

  /** 系统列高度 */
  systemColumnHeight: '100%',
  /** 系统列宽度 */
  systemColumnWidth: '100%',
  /** 系统行宽度 */
  systemRowWidth: '100%',

  /** 文字字体粗细 */
  textFontWeight: 500,

  /** 自适应列宽度 */
  adaptiveColumnWidth: '100%',
  /** 自适应列高度 */
  adaptiveColumnHeight: '100%',
  /** 自适应弹性列宽度 */
  adaptiveFlexibleColumnWidth: '100%',
  /** 自适应弹性收缩值 */
  adaptiveFlexShrink: 1
};