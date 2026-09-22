import { useState } from "react";

// ─── Design tokens (HarmonyOS spec) ──────────────────────────────────────────
const C = {
  primary: "#007DFF",
  primaryLight: "#E8F3FF",
  primaryHover: "#0070E6",
  text: "#182431",
  textSecondary: "#6B7280",
  textMuted: "#9CA3AF",
  border: "#E5E7EB",
  borderLight: "#F3F4F6",
  bg: "#F5F7FA",
  card: "#FFFFFF",
  success: "#34C759",
  warning: "#FF9500",
  danger: "#FF4D4F",
  purple: "#7C3AED",
  green: "#059669",
};

// ─── Outline SVG icons (HarmonyOS spec: 1.5px stroke, round caps) ─────────────
const s = { fill: "none", stroke: "currentColor", strokeWidth: 1.5, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };

const Ic = {
  // Single project folder
  Folder:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>,
  // Repository: back folder peeking behind front folder
  FolderGroup: () => (
    <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}>
      {/* back folder — shifted up-right */}
      <path d="M6 5h5.5l1.5 2H21a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H6" strokeOpacity={0.45}/>
      {/* front folder */}
      <path d="M2 8h6l1.5 2.5H18a1 1 0 0 1 1 1v6.5a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"/>
    </svg>
  ),
  Grid:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>,
  // Single template: file with lines + folded corner — identical everywhere
  Template:   () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="16" y2="17"/><line x1="8" y1="9" x2="10" y2="9"/></svg>,
  // My templates: back doc peeking behind front doc
  TemplateGroup: () => (
    <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}>
      {/* back document — shifted right */}
      <path d="M9 2h8l3 3v13a1 1 0 0 1-1 1H9" strokeOpacity={0.45}/>
      <polyline points="17 2 17 5 20 5" strokeOpacity={0.45}/>
      {/* front document */}
      <path d="M5 5h8l3 3v11a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z"/>
      <polyline points="13 5 13 8 16 8"/>
      <line x1="7" y1="12" x2="14" y2="12"/>
      <line x1="7" y1="15" x2="14" y2="15"/>
    </svg>
  ),
  Person:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>,
  Bell:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>,
  AI:         () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>,
  Cloud:      () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>,
  Upload:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polyline points="16 16 12 12 8 16"/><line x1="12" y1="12" x2="12" y2="21"/><path d="M20.39 18.39A5 5 0 0 0 18 10h-1.26A8 8 0 1 0 3 16.3"/></svg>,
  Share:      () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>,
  Eye:        () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>,
  EyeOff:    () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>,
  Phone:      () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 1.27h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.91a16 16 0 0 0 6 6l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21.73 16.92z"/></svg>,
  Lock:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>,
  Shield:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>,
  Edit:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>,
  Logout:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>,
  Collapse:   () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polyline points="11 17 6 12 11 7"/><polyline points="18 17 13 12 18 7"/></svg>,
  Expand:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polyline points="13 17 18 12 13 7"/><polyline points="6 17 11 12 6 7"/></svg>,
  Location:   () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>,
  Mail:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>,
  Search:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>,
  Check:      () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polyline points="20 6 9 17 4 12"/></svg>,
  ChevronRight: () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polyline points="9 18 15 12 9 6"/></svg>,
  ExternalLink: () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>,
  WeChat:     () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M8 12.5c0-3.314 3.134-6 7-6s7 2.686 7 6-3.134 6-7 6a8.3 8.3 0 0 1-2.5-.384l-2.5 1 .7-2.1A5.5 5.5 0 0 1 8 12.5z"/><path d="M3 8.5c0-2.485 2.35-4.5 5.25-4.5.896 0 1.74.208 2.473.574"/><circle cx="11" cy="12" r="0.8" fill="currentColor" stroke="none"/><circle cx="15" cy="12" r="0.8" fill="currentColor" stroke="none"/></svg>,
  QR:         () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="3" height="3"/><rect x="19" y="14" width="2" height="2"/><rect x="14" y="19" width="2" height="2"/><rect x="18" y="18" width="3" height="3"/></svg>,
  Fingerprint:() => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M2 12C2 6.5 6.5 2 12 2a10 10 0 0 1 8 4"/><path d="M5 19.5C5.5 18 6 15 6 12c0-3.3 2.7-6 6-6 1.8 0 3.4.8 4.5 2"/><path d="M11 12c0 3.5-1 6.5-3 8"/><path d="M12 12c0 2 .5 3.8 1.4 5.3"/><path d="M18 12a6 6 0 0 0-.9-3.2"/><path d="M18 12c0 4-1.5 7.5-4 9.5"/><path d="M22 9.5a13.5 13.5 0 0 1 0 6"/></svg>,
  Plus:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>,
  Chat:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 0 2 2z"/></svg>,
  Sync:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>,
  Home:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>,
  Sparkle:    () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><path d="M12 2v4m0 12v4M4.93 4.93l2.83 2.83m8.48 8.48l2.83 2.83M2 12h4m12 0h4M4.93 19.07l2.83-2.83m8.48-8.48l2.83-2.83"/></svg>,
  Image:      () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>,
  Info:       () => <svg viewBox="0 0 24 24" width="100%" height="100%" {...s}><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>,
};

// ─── Types ────────────────────────────────────────────────────────────────────
type AppView = "home" | "projects" | "marketplace" | "myTemplates" | "profile" | "messages" | "ai";
type ProfileTab = "info" | "sharing" | "storage" | "uploads" | "security";
type MessageTab = "interaction" | "admin" | "system";

// ─── Mock Data ─────────────────────────────────────────────────────────────────
const user = {
  name: "用户gf", role: "天线工程师 · 华为终端 BG",
  email: "gf@antenna.local", location: "深圳研发中心",
  phone: "+86 138 xxxx 8888", avatar: "用", avatarColor: "#E91E8C",
  level: "专业版", joinDate: "2024年9月",
  usedStorage: 12.5, totalStorage: 50,
  projects: 23, templates: 12, shares: 38,
};

const sharingRecords = [
  { id: 1, name: "5G毫米波无线阵列设计", type: "项目" as const, sharer: "team_lead", date: "2026-07-15" },
  { id: 2, name: "调试天线仿真模板", type: "模板" as const, sharer: "rf_engineer", date: "2026-07-12" },
  { id: 3, name: "S11 圆波损耗对比图", type: "图片" as const, sharer: "lucky123", date: "2026-07-08" },
  { id: 4, name: "MIMO 平板天线", type: "项目" as const, sharer: "rf_engineer", date: "2026-06-30" },
  { id: 5, name: "贴片天线增益方向图", type: "图片" as const, sharer: "team_lead", date: "2026-06-22" },
  { id: 6, name: "偶极子天线模板", type: "模板" as const, sharer: "lucky123", date: "2026-06-15" },
  { id: 7, name: "微带贴片阵列仿真项目", type: "项目" as const, sharer: "antenna_lab", date: "2026-06-05" },
  { id: 8, name: "天线增益测量图集", type: "图片" as const, sharer: "rf_engineer", date: "2026-05-28" },
];

const uploadRecords = [
  { id: 1, name: "毫米波波束成形阵列模板", category: "天线阵列", size: "8.4 MB", time: "2026-08-30 14:32", status: "已发布", downloads: 312, views: 2140 },
  { id: 2, name: "5G NR 天线参数计算模板", category: "参数工具", size: "3.2 MB", time: "2026-08-15 09:15", status: "审核中", downloads: 0, views: 28 },
  { id: 3, name: "微带馈线网络设计模板", category: "馈线网络", size: "5.7 MB", time: "2026-07-28 16:45", status: "已发布", downloads: 89, views: 670 },
  { id: 4, name: "远场辐射方向图分析工具", category: "分析工具", size: "12.1 MB", time: "2026-07-10 11:20", status: "已下架", downloads: 204, views: 1520 },
  { id: 5, name: "同轴天线仿真入门模板", category: "教学模板", size: "2.8 MB", time: "2026-06-22 08:50", status: "已发布", downloads: 531, views: 3870 },
];

const msgs = {
  interaction: [
    { id: 1, av: "李M", color: "#34C759", title: "李明 回复了你的评论", desc: "「这个阵列间距设置非常合理，S11参数...」", time: "10分钟前", unread: true },
    { id: 2, av: "王H", color: "#FF9500", title: "王浩 赞了你的模板", desc: "「毫米波波束成形阵列模板」获得新赞", time: "2小时前", unread: true },
    { id: 3, av: "赵X", color: "#7C3AED", title: "赵雪 关注了你", desc: "赵雪开始关注你的天线设计作品", time: "昨天", unread: false },
    { id: 4, av: "刘Y", color: "#FF4D4F", title: "刘洋 在你的项目上评论", desc: "「请问微带馈线的阻抗匹配是怎么做的？」", time: "2天前", unread: false },
  ],
  admin: [
    { id: 1, av: "官", color: C.primary, title: "平台公告：CST 联动功能上线", desc: "优天线现已支持 CST Studio Suite 仿真文件直接导入，点击体验。", time: "今天 09:00", unread: true, tag: "公告" },
    { id: 2, av: "运", color: "#7C3AED", title: "限时活动：专业版五折优惠", desc: "9月会员日活动，专业版订阅享受5折优惠，仅限3天。", time: "昨天 14:00", unread: false, tag: "活动" },
    { id: 3, av: "系", color: "#6B7280", title: "服务维护通知", desc: "将于9月5日 02:00–04:00 进行系统维护，期间服务暂时不可用。", time: "3天前", unread: false, tag: "维护" },
  ],
  system: [
    { id: 1, av: "✓", color: "#059669", title: "AI优化任务已完成", desc: "「毫米波阵列交叉极化优化」已完成，隔离度提升 4.2 dB，点击查看报告。", time: "刚刚", unread: true, tag: "完成" },
    { id: 2, av: "!", color: "#FF9500", title: "存储空间预警", desc: "您的云盘空间已使用 25%，建议定期清理仿真缓存。", time: "1小时前", unread: true, tag: "预警" },
    { id: 3, av: "✓", color: "#059669", title: "文件导出成功", desc: "「5G天线设计规范_v2.pdf」导出完成，可下载。", time: "昨天", unread: false, tag: "完成" },
    { id: 4, av: "✗", color: "#FF4D4F", title: "仿真任务执行异常", desc: "「宽带偶极子远场仿真」任务在 03:15 执行失败，请检查配置。", time: "2天前", unread: false, tag: "异常" },
  ],
};

const typeConfig = {
  "项目": { color: C.primary, bg: C.primaryLight, action: "打开项目", Icon: Ic.Folder },
  "模板": { color: C.green,   bg: "#ECFDF5",      action: "使用模板", Icon: Ic.Template },
  "图片": { color: C.purple,  bg: "#F5F3FF",      action: "查看图片", Icon: Ic.Image },
};

const statusStyle: Record<string, { color: string; bg: string }> = {
  "已发布": { color: "#059669", bg: "#077DFF" },
  "审核中": { color: "#D97706", bg: "#34C759" },
  "已下架": { color: "#6B7280", bg: "#6B7280" },
};

const tagStyle: Record<string, { color: string; bg: string }> = {
  "完成":  { color: "#059669", bg: "#ECFDF5" },
  "预警":  { color: "#D97706", bg: "#FFFBEB" },
  "异常":  { color: "#FF4D4F", bg: "#FEF2F2" },
  "公告":  { color: C.primary, bg: C.primaryLight },
  "活动":  { color: "#7C3AED", bg: "#F5F3FF" },
  "维护":  { color: "#6B7280", bg: "#F3F4F6" },
};

// ─── Login ────────────────────────────────────────────────────────────────────
function LoginView({ onLogin, goRegister }: { onLogin: () => void; goRegister: () => void }) {
  const [tab, setTab] = useState<"phone" | "password">("phone");
  const [showPwd, setShowPwd] = useState(false);
  const [countdown, setCountdown] = useState(0);
  const sendCode = () => {
    if (countdown > 0) return;
    setCountdown(60);
    const t = setInterval(() => setCountdown(p => { if (p <= 1) { clearInterval(t); return 0; } return p - 1; }), 1000);
  };
  const inputCls = "w-full px-3.5 py-3 rounded-xl outline-none text-sm transition-all";
  const inputStyle = { border: `1px solid ${C.border}`, color: C.text };
  const onFocus = (e: React.FocusEvent<HTMLInputElement>) => (e.target.style.borderColor = C.primary);
  const onBlur  = (e: React.FocusEvent<HTMLInputElement>) => (e.target.style.borderColor = C.border);

  return (
    <div className="min-h-screen flex" style={{ background: C.bg }}>
      {/* Brand panel */}
      <div className="hidden lg:flex flex-col justify-center px-16 flex-1" style={{ background: `linear-gradient(150deg, ${C.primary} 0%, #0060CC 100%)` }}>
        <div className="flex items-center gap-3 mb-10">
          <AppLogo size={36} />
          <span className="text-white text-xl font-bold">优天线</span>
        </div>
        <h2 className="text-4xl font-bold text-white leading-tight mb-4">天线工程师的<br />协作设计平台</h2>
        <p className="text-lg" style={{ color: "rgba(255,255,255,0.75)" }}>集成仿真、设计、共享与模板管理<br />覆盖 PC · iPad · 手机三端</p>
        <div className="flex gap-10 mt-12">
          {[["12,000+", "工程师用户"], ["50,000+", "天线模板"], ["200+", "企业团队"]].map(([n, l]) => (
            <div key={l}>
              <div className="text-2xl font-bold text-white">{n}</div>
              <div className="text-sm mt-0.5" style={{ color: "rgba(255,255,255,0.65)" }}>{l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Form panel */}
      <div className="flex flex-col justify-center items-center px-8 py-12 w-full lg:w-96 lg:max-w-md" style={{ background: C.card }}>
        <div className="w-full max-w-sm">
          <div className="flex items-center gap-2.5 mb-8 lg:hidden">
            <AppLogo size={28} />
            <span className="font-bold text-lg" style={{ color: C.text }}>优天线</span>
          </div>
          <h1 className="text-2xl font-bold mb-1" style={{ color: C.text }}>欢迎登录</h1>
          <p className="text-sm mb-7" style={{ color: C.textSecondary }}>统一账号，全场景互通</p>

          <div className="flex border-b mb-6" style={{ borderColor: C.border }}>
            {(["phone", "password"] as const).map(t => (
              <button key={t} onClick={() => setTab(t)} className="pb-2.5 px-1 mr-6 text-sm font-medium"
                style={{ color: tab === t ? C.primary : C.textSecondary, borderBottom: `2px solid ${tab === t ? C.primary : "transparent"}`, marginBottom: -1 }}>
                {t === "phone" ? "手机号登录" : "账号密码"}
              </button>
            ))}
          </div>

          {tab === "phone" ? (
            <div className="flex flex-col gap-3">
              <div className="flex gap-2">
                <div className="flex items-center gap-1.5 px-3 py-3 rounded-xl border flex-shrink-0 text-sm" style={{ border: `1px solid ${C.border}`, color: C.text }}>
                  <div className="w-3.5 h-3.5" style={{ color: C.textMuted }}><Ic.Phone /></div>
                  <span className="font-medium">+86</span>
                </div>
                <input className={inputCls} style={inputStyle} placeholder="请输入手机号" onFocus={onFocus} onBlur={onBlur} />
              </div>
              <div className="flex gap-2">
                <input className={inputCls} style={inputStyle} placeholder="请输入验证码" onFocus={onFocus} onBlur={onBlur} />
                <button onClick={sendCode} className="px-4 rounded-xl text-sm font-medium flex-shrink-0 transition-colors"
                  style={{ background: countdown > 0 ? C.borderLight : C.primaryLight, color: countdown > 0 ? C.textMuted : C.primary, minWidth: 96 }}>
                  {countdown > 0 ? `${countdown}s` : "获取验证码"}
                </button>
              </div>
            </div>
          ) : (
            <div className="flex flex-col gap-3">
              <div className="relative">
                <div className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4" style={{ color: C.textMuted }}><Ic.Person /></div>
                <input className={inputCls} style={{ ...inputStyle, paddingLeft: 36 }} placeholder="账号 / 手机号 / 邮箱" onFocus={onFocus} onBlur={onBlur} />
              </div>
              <div className="relative">
                <div className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4" style={{ color: C.textMuted }}><Ic.Lock /></div>
                <input type={showPwd ? "text" : "password"} className={inputCls} style={{ ...inputStyle, paddingLeft: 36, paddingRight: 40 }} placeholder="请输入密码" onFocus={onFocus} onBlur={onBlur} />
                <button className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4" style={{ color: C.textMuted }} onClick={() => setShowPwd(!showPwd)}>
                  {showPwd ? <Ic.Eye /> : <Ic.EyeOff />}
                </button>
              </div>
              <div className="flex justify-end"><button className="text-xs" style={{ color: C.primary }}>忘记密码？</button></div>
            </div>
          )}

          <button onClick={onLogin} className="w-full py-3 rounded-2xl text-white font-semibold text-sm mt-5 transition-opacity active:opacity-80"
            style={{ background: C.primary, boxShadow: `0 4px 12px ${C.primary}40` }}>
            登录
          </button>

          <div className="flex items-center gap-3 my-5">
            <div className="flex-1 h-px" style={{ background: C.border }} />
            <span className="text-xs" style={{ color: C.textMuted }}>其他方式</span>
            <div className="flex-1 h-px" style={{ background: C.border }} />
          </div>

          <div className="flex justify-center gap-8">
            {[{ l: "微信", i: <Ic.WeChat />, c: "#34C759" }, { l: "扫码", i: <Ic.QR />, c: C.primary }, { l: "生物识别", i: <Ic.Fingerprint />, c: "#7C3AED" }].map(item => (
              <button key={item.l} onClick={onLogin} className="flex flex-col items-center gap-1.5">
                <div className="w-10 h-10 rounded-2xl flex items-center justify-center p-2.5" style={{ background: item.c + "15", color: item.c }}>{item.i}</div>
                <span className="text-xs" style={{ color: C.textMuted }}>{item.l}</span>
              </button>
            ))}
          </div>

          <div className="text-center mt-6">
            <span className="text-sm" style={{ color: C.textSecondary }}>还没有账号？</span>
            <button className="text-sm font-semibold ml-1" style={{ color: C.primary }} onClick={goRegister}>立即注册</button>
          </div>
          <p className="text-center text-xs mt-4" style={{ color: C.textMuted }}>
            登录即代表同意 <span style={{ color: C.primary }}>用户协议</span> 和 <span style={{ color: C.primary }}>隐私政策</span>
          </p>
        </div>
      </div>
    </div>
  );
}

// ─── Register ─────────────────────────────────────────────────────────────────
function RegisterView({ onBack, onDone }: { onBack: () => void; onDone: () => void }) {
  const [step, setStep] = useState(1);
  const [showPwd, setShowPwd] = useState(false);
  const inputStyle = { border: `1px solid ${C.border}`, color: C.text };
  const onFocus = (e: React.FocusEvent<HTMLInputElement>) => (e.target.style.borderColor = C.primary);
  const onBlur  = (e: React.FocusEvent<HTMLInputElement>) => (e.target.style.borderColor = C.border);

  return (
    <div className="min-h-screen flex items-center justify-center" style={{ background: C.bg }}>
      <div className="w-full max-w-sm mx-4 rounded-3xl p-8" style={{ background: C.card, boxShadow: "0 16px 48px rgba(0,0,0,0.10)" }}>
        <div className="flex items-center gap-2.5 mb-6"><AppLogo size={28} /><span className="font-bold text-lg" style={{ color: C.text }}>优天线</span></div>
        <h1 className="text-xl font-bold mb-1" style={{ color: C.text }}>创建账号</h1>
        <p className="text-sm mb-6" style={{ color: C.textSecondary }}>开启你的天线设计之旅</p>

        <div className="flex items-center gap-2 mb-6">
          {[1, 2].map(s => (
            <div key={s} className="flex items-center gap-2">
              <div className="w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold"
                style={{ background: s <= step ? C.primary : C.borderLight, color: s <= step ? "#fff" : C.textMuted }}>
                {s < step ? <span className="w-3 h-3"><Ic.Check /></span> : s}
              </div>
              <span className="text-xs" style={{ color: s === step ? C.text : C.textMuted }}>{s === 1 ? "验证手机号" : "完善信息"}</span>
              {s < 2 && <div className="w-6 h-px" style={{ background: step > 1 ? C.primary : C.border }} />}
            </div>
          ))}
        </div>

        {step === 1 ? (
          <div className="flex flex-col gap-3">
            <div className="flex gap-2">
              <div className="flex items-center gap-1 px-3 py-3 rounded-xl border text-sm flex-shrink-0" style={{ border: `1px solid ${C.border}` }}>
                <div className="w-3.5 h-3.5" style={{ color: C.textMuted }}><Ic.Phone /></div>
                <span className="font-medium" style={{ color: C.text }}>+86</span>
              </div>
              <input className="flex-1 px-3.5 py-3 rounded-xl outline-none text-sm" style={inputStyle} placeholder="请输入手机号" onFocus={onFocus} onBlur={onBlur} />
            </div>
            <div className="flex gap-2">
              <input className="flex-1 px-3.5 py-3 rounded-xl outline-none text-sm" style={inputStyle} placeholder="请输入验证码" onFocus={onFocus} onBlur={onBlur} />
              <button className="px-4 rounded-xl text-sm font-medium flex-shrink-0" style={{ background: C.primaryLight, color: C.primary, minWidth: 96 }}>获取验证码</button>
            </div>
            <button onClick={() => setStep(2)} className="w-full py-3 rounded-2xl text-white font-semibold text-sm mt-1" style={{ background: C.primary }}>下一步</button>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            <input className="px-3.5 py-3 rounded-xl outline-none text-sm" style={inputStyle} placeholder="设置昵称" onFocus={onFocus} onBlur={onBlur} />
            <div className="relative">
              <input type={showPwd ? "text" : "password"} className="w-full px-3.5 pr-10 py-3 rounded-xl outline-none text-sm" style={inputStyle} placeholder="设置密码（8位以上）" onFocus={onFocus} onBlur={onBlur} />
              <button className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4" style={{ color: C.textMuted }} onClick={() => setShowPwd(!showPwd)}>
                {showPwd ? <Ic.Eye /> : <Ic.EyeOff />}
              </button>
            </div>
            <button onClick={onDone} className="w-full py-3 rounded-2xl text-white font-semibold text-sm mt-1" style={{ background: C.primary }}>完成注册</button>
          </div>
        )}
        <div className="text-center mt-4">
          <button className="text-sm" style={{ color: C.textSecondary }} onClick={onBack}>已有账号，<span style={{ color: C.primary }}>直接登录</span></button>
        </div>
      </div>
    </div>
  );
}

// ─── App Logo ─────────────────────────────────────────────────────────────────
function AppLogo({ size = 32 }: { size?: number }) {
  return (
    <div className="flex items-center justify-center flex-shrink-0" style={{ width: size, height: size, background: C.primary, borderRadius: 16 }}>
      <svg viewBox="0 0 40 40" style={{ width: size * 0.6, height: size * 0.6 }} fill="none">
        <path d="M8 30V12l12-6 12 6v18l-12 6-12-6z" stroke="white" strokeWidth="1.8" strokeLinejoin="round" strokeLinecap="round"/>
        <path d="M20 6v28M8 12l12 8 12-8" stroke="white" strokeWidth="1.8" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

// ─── Profile Tabs ─────────────────────────────────────────────────────────────
function ProfileInfo() {
  const [name, setName] = useState(user.name);
  const [bio, setBio] = useState("专注毫米波天线阵列设计与仿真优化");
  const onFocus = (e: React.FocusEvent<HTMLInputElement>) => (e.target.style.borderColor = C.primary);
  const onBlur  = (e: React.FocusEvent<HTMLInputElement>) => (e.target.style.borderColor = C.border);

  return (
    <div className="rounded-2xl p-5" style={{ border: `1px solid #FFFFFF`, background: C.card }}>
      <div className="flex items-center gap-4 mb-5 pb-5" style={{ borderBottom: `1px solid ${C.borderLight}` }}>
        <div className="w-16 h-16 rounded-2xl flex items-center justify-center text-white text-xl font-bold flex-shrink-0" style={{ background: C.primary }}>{user.avatar}</div>
        <div>
          <div className="font-semibold" style={{ color: C.text }}>{user.name}</div>
          <div className="text-sm mt-0.5" style={{ color: C.textSecondary }}>{user.role}</div>
          <button className="text-xs mt-1.5 font-medium" style={{ color: C.primary }}>更换头像</button>
        </div>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {[
          { label: "昵称", value: name, onChange: setName, editable: true },
          { label: "个人简介", value: bio, onChange: setBio, editable: true, full: true },
          { label: "手机号", value: user.phone, editable: false },
          { label: "邮箱", value: user.email, editable: false },
          { label: "所在地", value: user.location, editable: false },
        ].map(field => (
          <div key={field.label} className={field.full ? "sm:col-span-2" : ""}>
            <label className="block text-xs font-medium mb-1.5" style={{ color: C.textMuted }}>{field.label}</label>
            {field.editable ? (
              <input className="w-full px-1 py-2.5 outline-none text-sm" style={{ background: '#FFFFFF', color: C.text, borderBottom: `1.5px solid ${C.border}` }}
                value={field.value} onChange={e => field.onChange?.(e.target.value)} onFocus={onFocus} onBlur={onBlur} />
            ) : (
              <div className="w-full px-1 py-2.5 text-sm" style={{ background: 'transparent', color: C.textSecondary, borderBottom: `1.5px dashed ${C.border}` }}>{field.value}</div>
            )}
          </div>
        ))}
      </div>
      <button className="mt-5 px-6 py-2.5 rounded-xl text-white text-sm font-semibold" style={{ background: C.primary }}>保存修改</button>
    </div>
  );
}

function ProfileSecurity() {
  return (
    <div className="flex flex-col gap-2.5">
      {[
        { label: "登录密码", desc: "上次修改：2026年6月", Icon: Ic.Lock, color: C.primary, action: "修改" },
        { label: "手机号绑定", desc: user.phone, Icon: Ic.Phone, color: C.green, action: "更换" },
        { label: "生物识别", desc: "指纹/面容 ID 已开启", Icon: Ic.Fingerprint, color: "#7C3AED", action: "管理" },
        { label: "两步验证", desc: "未开启", Icon: Ic.Shield, color: "#D97706", action: "开启" },
      ].map(item => (
        <div key={item.label} className="flex items-center gap-3 px-4 py-3.5" style={{ borderBottom: `1px solid ${C.borderLight}`, background: C.card }}>
          <div className="w-9 h-9 rounded-xl flex items-center justify-center p-2 flex-shrink-0" style={{ background: item.color + "15", color: item.color }}><item.Icon /></div>
          <div className="flex-1">
            <div className="text-sm font-medium" style={{ color: C.text }}>{item.label}</div>
            <div className="text-xs mt-0.5" style={{ color: C.textMuted }}>{item.desc}</div>
          </div>
          <button className="text-sm font-medium" style={{ color: C.primary }}>{item.action}</button>
        </div>
      ))}
    </div>
  );
}

function ProfileSharing() {
  return (
    <div className="flex flex-col gap-2">
      {sharingRecords.map(item => {
        const cfg = typeConfig[item.type];
        return (
          <div key={item.id} className="flex items-center gap-4 transition-colors"
            style={{ background: C.card, borderBottom: `1px solid ${C.borderLight}`, padding: '10px 20px' }}>
            <div className="w-9 h-9 rounded-xl flex items-center justify-center p-2 flex-shrink-0" style={{ background: cfg.bg, color: cfg.color }}>
              <cfg.Icon />
            </div>
            <div className="flex-1 min-w-0 flex items-center gap-2.5 flex-wrap">
              <span className="text-sm font-medium truncate" style={{ color: C.text }}>{item.name}</span>
            </div>
            <div className="hidden sm:flex flex-col items-end gap-0.5 flex-shrink-0 min-w-36">
              <span className="text-xs" style={{ color: C.textSecondary }}>{item.sharer} 分享</span>
              <span className="text-xs" style={{ color: C.textMuted }}>{item.date}</span>
            </div>
            <button className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg text-xs font-medium flex-shrink-0 transition-colors"
              style={{ border: '1px solid #FFFFFF', color: C.primary, background: '#FFFFFF' }}
              onMouseEnter={e => { e.currentTarget.style.background = C.primary; e.currentTarget.style.color = "#fff"; }}
              onMouseLeave={e => { e.currentTarget.style.background = '#FFFFFF'; e.currentTarget.style.color = C.primary; }}>
              <div className="w-3 h-3"><Ic.ExternalLink /></div>
              {cfg.action}
            </button>
          </div>
        );
      })}
    </div>
  );
}

function DonutChart({ pct, size = 100 }: { pct: number; size?: number }) {
  const r = (size - 16) / 2;
  const circ = 2 * Math.PI * r;
  const dash = circ * (pct / 100);
  const cx = size / 2, cy = size / 2;
  return (
    <svg width={size} height={size} style={{ transform: "rotate(-90deg)", background: "#FFFFFF" }}>
      <circle cx={cx} cy={cy} r={r} fill="none" stroke={C.borderLight} strokeWidth={14} />
      <circle cx={cx} cy={cy} r={r} fill="none" stroke={C.primary} strokeWidth={14}
        strokeDasharray={`${dash} ${circ}`} strokeLinecap="round" style={{ transition: "stroke-dasharray 0.6s ease" }} />
    </svg>
  );
}

function ProfileStorage() {
  const used = user.usedStorage, total = user.totalStorage, pct = (used / total) * 100;
  const breakdown = [
    { label: "项目与模板", size: 7.2, color: C.primary },
    { label: "仿真结果",   size: 4.1, color: C.green },
    { label: "图表",       size: 1.2, color: C.purple },
  ];
  const quickActions = [
    { label: "清理缓存文件", sub: "清理缓存和仿真数据额", Icon: Ic.Cloud, color: C.primary },
    { label: "导出开源版",   sub: "下载社区版应用程序",   Icon: Ic.Upload, color: C.green },
    { label: "自动清理设置", sub: "配置乐动清理频率",     Icon: Ic.Sync,   color: C.purple },
  ];

  return (
    <div className="flex flex-col gap-4">
      {/* Main panel: donut + bars + quick actions */}
      <div className="flex gap-4" style={{ alignItems: "stretch" }}>
        {/* Left: overview */}
        <div className="flex-1 rounded-2xl p-5" style={{ border: `1px solid ${C.border}`, background: C.card }}>
          <div className="flex items-center justify-between mb-4">
            <span className="text-sm font-semibold" style={{ color: C.text }}>存储空间总览</span>
            <span className="text-xs" style={{ color: C.textMuted }}>{used} GB / {total} GB</span>
          </div>

          <div className="flex items-center gap-5">
            {/* Donut */}
            <div className="relative flex-shrink-0 flex items-center justify-center" style={{ width: 96, height: 96 }}>
              <DonutChart pct={pct} size={96} />
              <div className="absolute inset-0 flex flex-col items-center justify-center" style={{ width: 24 }}>
                <span className="text-lg font-bold leading-none" style={{ color: C.text }}>{pct.toFixed(0)}%</span>
                <span className="text-xs mt-0.5" style={{ color: C.textMuted }}>已使用</span>
              </div>
            </div>

            {/* Category bars */}
            <div className="flex-1 flex flex-col gap-3">
              {breakdown.map((b) => {
                const barPct = (b.size / total) * 100;
                return (
                  <div key={b.label}>
                    <div className="flex items-center justify-between mb-1">
                      <div className="flex items-center gap-1.5">
                        <div className="w-2.5 h-2.5 rounded-sm flex-shrink-0" style={{ background: b.color }} />
                        <span className="text-xs" style={{ color: C.text }}>{b.label}</span>
                      </div>
                      <span className="text-xs font-medium" style={{ color: C.textSecondary }}>{b.size} GB</span>
                    </div>
                    <div className="h-1.5 rounded-full overflow-hidden" style={{ background: C.borderLight }}>
                      <div className="h-full rounded-full transition-all duration-500" style={{ width: `${barPct}%`, background: b.color }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Right: quick actions */}
        <div className="rounded-2xl p-4 flex flex-col gap-1" style={{ border: `1px solid ${C.border}`, background: C.card, minWidth: 200 }}>
          <span className="text-sm font-semibold mb-2" style={{ color: C.text }}>快捷操作</span>
          {quickActions.map((a, i) => (
            <button key={a.label}
              className="flex items-center gap-3 px-3 py-3 rounded-xl text-left w-full transition-colors"
              style={{ borderBottom: i < quickActions.length - 1 ? `1px solid ${C.borderLight}` : "none" }}
              onMouseEnter={e => (e.currentTarget.style.background = C.primaryLight)}
              onMouseLeave={e => (e.currentTarget.style.background = "transparent")}>
              <div className="w-8 h-8 rounded-xl flex items-center justify-center p-2 flex-shrink-0" style={{ background: a.color + "15", color: a.color }}>
                <a.Icon />
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-sm font-medium" style={{ color: C.text }}>{a.label}</div>
                <div className="text-xs mt-0.5 truncate" style={{ color: C.textMuted }}>{a.sub}</div>
              </div>
              <div className="w-3.5 h-3.5 flex-shrink-0" style={{ color: C.textMuted }}><Ic.ChevronRight /></div>
            </button>
          ))}
        </div>
      </div>

    </div>
  );
}

function ProfileUploads() {
  return (
    <div className="flex flex-col gap-3">
      {uploadRecords.map(item => {
        const sc = statusStyle[item.status];
        return (
          <div key={item.id} className="rounded-xl p-4" style={{ border: 'none', background: C.card }}>
            <div className="flex items-start gap-3">
              {/* Same template icon as sharing records */}
              <div className="w-9 h-9 rounded-xl flex items-center justify-center p-2 flex-shrink-0" style={{ background: C.primaryLight, color: C.primary }}>
                <Ic.Template />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="text-sm font-medium" style={{ color: C.text }}>{item.name}</span>
                  <span className="px-2 py-0.5 rounded text-xs font-medium flex-shrink-0" style={{ background: sc.bg, color: sc.color }}>{item.status}</span>
                </div>
                <div className="flex items-center gap-2 mt-1 flex-wrap text-xs" style={{ color: C.textMuted }}>
                  <span>{item.category}</span><span>·</span><span>{item.size}</span><span>·</span><span>{item.time}</span>
                </div>
              </div>
            </div>
            <div className="flex items-center gap-4 mt-3 pt-3 text-xs" style={{ borderTop: `1px solid ${C.borderLight}` }}>
              <span style={{ color: C.textMuted }}>{item.views.toLocaleString()} 次浏览</span>
              <span style={{ color: C.textMuted }}>{item.downloads} 次下载</span>
              <div className="flex-1" />
              <button style={{ color: C.textMuted }}>编辑</button>
              <button className="font-medium" style={{ color: C.primary }}>查看详情</button>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ─── Personal Center (PC/iPad) ────────────────────────────────────────────────
function PersonalCenter() {
  const [tab, setTab] = useState<ProfileTab>("info");
  const tabs: { key: ProfileTab; label: string }[] = [
    { key: "info", label: "基本信息" }, { key: "sharing", label: "共享记录" },
    { key: "storage", label: "存储空间" }, { key: "uploads", label: "上传记录" },
    { key: "security", label: "账号安全" },
  ];
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <div className="flex-shrink-0" style={{ background: C.card, borderBottom: `1px solid ${C.border}`, padding: '24px 32px 0px 32px' }}>
        <div className="flex items-start gap-5 mb-5">
          <div className="w-16 h-16 rounded-2xl flex items-center justify-center text-white text-xl font-bold flex-shrink-0" style={{ background: C.primary }}>{user.avatar}</div>
          <div className="flex-1 min-w-0 pt-1">
            <h2 className="text-lg font-bold" style={{ color: C.text }}>{user.name}</h2>
            <p className="text-sm mt-0.5" style={{ color: C.textSecondary }}>{user.role}</p>
            <div className="flex items-center gap-4 mt-1.5 flex-wrap">
              {[{ i: <Ic.Mail />, v: user.email }, { i: <Ic.Location />, v: user.location }, { i: <Ic.Phone />, v: user.phone }].map((f, i) => (
                <span key={i} className="flex items-center gap-1 text-xs" style={{ color: C.textMuted }}>
                  <span className="w-3 h-3">{f.i}</span>{f.v}
                </span>
              ))}
            </div>
          </div>
          <button className="flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm flex-shrink-0 transition-colors"
            style={{ border: `1px solid ${C.border}`, color: C.textSecondary }}>
            <div className="w-3.5 h-3.5"><Ic.Logout /></div>退出登录
          </button>
        </div>
        <div className="flex gap-1">
          {tabs.map(t => (
            <button key={t.key} onClick={() => setTab(t.key)} className="px-4 py-2.5 text-sm font-medium transition-colors"
              style={{ color: tab === t.key ? C.primary : C.textSecondary, borderBottom: `2px solid ${tab === t.key ? C.primary : "transparent"}` }}>
              {t.label}
            </button>
          ))}
        </div>
      </div>
      <div className="tab-scroll overflow-y-scroll" style={{ width: '100%', height: 'fit-content', padding: '24px 0 240px 0', background: C.card, scrollbarWidth: 'thin', scrollbarColor: `${C.border} transparent` }}>
        {tab === "info"     && <ProfileInfo />}
        {tab === "sharing"  && <ProfileSharing />}
        {tab === "storage"  && <ProfileStorage />}
        {tab === "uploads"  && <ProfileUploads />}
        {tab === "security" && <ProfileSecurity />}
      </div>
    </div>
  );
}

// ─── Messages Center ──────────────────────────────────────────────────────────
// Shared messages content — works both as PC full-panel and phone embedded child
function MessagesList({ tab }: { tab: MessageTab }) {
  return (
    <div className="flex flex-col gap-2.5" style={{ background: '#FFFFFF' }}>
      {(msgs[tab] as any[]).map(msg => (
        <div key={msg.id} className="flex gap-3 px-4 py-4"
          style={{ background: '#FFFFFF', borderBottom: `1px solid ${C.borderLight}` }}>
          <div className="flex items-start gap-1.5 flex-shrink-0 mt-0.5">
            {msg.unread && <div className="w-2 h-2 rounded-full mt-1 flex-shrink-0" style={{ background: C.primary }} />}
            {!msg.unread && <div className="w-2 flex-shrink-0" />}
            <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-semibold text-white" style={{ background: msg.color }}>{msg.av}</div>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-sm font-medium" style={{ color: C.text }}>{msg.title}</span>
              {msg.tag && <span className="px-1.5 py-0.5 rounded text-xs font-medium" style={{ background: tagStyle[msg.tag]?.bg, color: tagStyle[msg.tag]?.color }}>{msg.tag}</span>}
            </div>
            <p className="text-xs mt-1 leading-relaxed" style={{ color: C.textSecondary }}>{msg.desc}</p>
            <span className="text-xs mt-1 inline-block" style={{ color: C.textMuted }}>{msg.time}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

function MessagesTabs() {
  const [tab, setTab] = useState<MessageTab>("interaction");
  const tabs = [
    { key: "interaction" as MessageTab, label: "互动消息", count: msgs.interaction.filter(m => m.unread).length },
    { key: "admin" as MessageTab, label: "管理员消息", count: msgs.admin.filter(m => m.unread).length },
    { key: "system" as MessageTab, label: "系统通知", count: msgs.system.filter(m => m.unread).length },
  ];
  return (
    <>
      <div className="flex items-center justify-between mb-4">
        <div className="flex gap-1 flex-1">
          {tabs.map(t => (
            <button key={t.key} onClick={() => setTab(t.key)} className="px-4 py-2 text-sm font-medium flex items-center gap-1.5"
              style={{ color: tab === t.key ? C.primary : C.textSecondary, borderBottom: `2px solid ${tab === t.key ? C.primary : "transparent"}` }}>
              {t.label}
              {t.count > 0 && <span className="flex items-center justify-center rounded-full text-white" style={{ background: "#FF4D4F", fontSize: 10, width: 16, height: 16 }}>{t.count}</span>}
            </button>
          ))}
        </div>
        <button className="text-sm font-medium ml-auto" style={{ color: C.primary }}>全部已读</button>
      </div>
      <MessagesList tab={tab} />
    </>
  );
}

function MessagesCenter() {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <div className="px-8 pt-6 pb-4 flex-shrink-0" style={{ background: C.card, borderBottom: `1px solid ${C.border}` }}>
        <h2 className="text-lg font-bold" style={{ color: C.text }}>消息中心</h2>
      </div>
      <div className="flex-1 overflow-y-auto px-8 py-5 max-w-2xl">
        <MessagesTabs />
      </div>
    </div>
  );
}

type PhoneProfileView = "home" | "info" | "sharing" | "storage" | "uploads" | "messages" | "security";

// ─── Phone Personal Center (card grid layout per image-1) ─────────────────────
function PhonePersonalCenter({ onNavigate }: { onNavigate: (v: PhoneProfileView) => void }) {
  const pct = (user.usedStorage / user.totalStorage) * 100;
  const unreadCount = msgs.interaction.filter(m => m.unread).length + msgs.admin.filter(m => m.unread).length + msgs.system.filter(m => m.unread).length;

  return (
    <div className="flex flex-col gap-3 p-4 pb-6">
      {/* Profile card */}
      <div className="rounded-2xl p-4" style={{ background: C.card, border: `1px solid ${C.borderLight}` }}>
        <div className="flex items-center gap-3">
          <div className="w-14 h-14 rounded-2xl flex items-center justify-center text-white text-lg font-bold flex-shrink-0" style={{ background: user.avatarColor }}>{user.avatar}</div>
          <div className="flex-1 min-w-0">
            <div className="font-semibold text-base" style={{ color: C.text }}>{user.name}</div>
            <div className="text-sm mt-0.5 truncate" style={{ color: C.textSecondary }}>{user.role}</div>
            <span className="inline-block mt-1 px-2 py-0.5 rounded-full text-xs font-medium" style={{ background: C.primaryLight, color: C.primary }}>{user.level}</span>
          </div>
          <div className="w-5 h-5 flex-shrink-0" style={{ color: C.textMuted }}><Ic.ChevronRight /></div>
        </div>

      </div>

      {/* Cross-device sync */}
      <div className="rounded-2xl px-4 py-3 flex items-center gap-3" style={{ background: C.card, border: `1px solid ${C.borderLight}` }}>
        <div className="w-8 h-8 rounded-xl flex items-center justify-center p-2 flex-shrink-0" style={{ background: C.primaryLight, color: C.primary }}><Ic.Sync /></div>
        <div className="flex-1">
          <div className="text-xs font-medium" style={{ color: C.textMuted }}>跨设备同步</div>
          <div className="text-sm font-medium" style={{ color: C.text }}>HarmonyOS 手机</div>
        </div>
        <div className="flex items-center gap-1 text-xs font-medium" style={{ color: C.green }}>
          <div className="w-1.5 h-1.5 rounded-full" style={{ background: C.green }} />
          已同步
        </div>
      </div>

      {/* Quick functions */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm font-semibold" style={{ color: C.text }}>常用功能</span>
          {unreadCount > 0 && <span className="text-xs" style={{ color: C.textMuted }}>{unreadCount} 条未读</span>}
        </div>
        <div className="grid grid-cols-2 gap-2.5">
          {[
            { label: "个人资料", sub: "昵称、邮箱与组织", dest: "info" as PhoneProfileView, badge: 0 },
            { label: "消息通知", sub: `${unreadCount} 条未读`, dest: "messages" as PhoneProfileView, badge: unreadCount },
            { label: "共享记录", sub: `收到 ${sharingRecords.filter((_, i) => i % 2 === 0).length} 发出 ${sharingRecords.filter((_, i) => i % 2 !== 0).length}`, dest: "sharing" as PhoneProfileView, badge: 0 },
            { label: "上传记录", sub: `${uploadRecords.length} 条记录`, dest: "uploads" as PhoneProfileView, badge: 0 },
            { label: "账号安全", sub: "密码、验证与生物识别", dest: "security" as PhoneProfileView, badge: 0 },
          ].map(item => (
            <button key={item.label}
              onClick={() => onNavigate(item.dest)}
              className="rounded-2xl p-4 flex flex-col gap-1.5 text-left relative transition-colors"
              style={{ background: C.card, border: `1px solid ${C.borderLight}` }}>
              {item.badge > 0 && (
                <div className="absolute top-3 right-3 flex items-center justify-center rounded-full text-white" style={{ background: "#FF4D4F", fontSize: 9, minWidth: 16, height: 16, padding: "0 3px" }}>{item.badge}</div>
              )}
              <div className="text-sm font-semibold" style={{ color: C.text }}>{item.label}</div>
              <div className="text-xs" style={{ color: C.textMuted }}>{item.sub}</div>
            </button>
          ))}
        </div>
      </div>

      {/* Storage */}
      <div className="rounded-2xl p-4" style={{ background: C.card, border: `1px solid ${C.borderLight}` }}>
        <div className="flex items-center justify-between mb-3">
          <span className="text-sm font-semibold" style={{ color: C.text }}>云端存储空间</span>
          <button className="text-xs font-medium" style={{ color: C.primary }} onClick={() => onNavigate("storage")}>管理空间 →</button>
        </div>
        <div className="flex items-center justify-between mb-1.5">
          <span className="text-xs" style={{ color: C.textMuted }}>{user.usedStorage.toFixed(2)} GB / {user.totalStorage}.00 GB</span>
          <span className="text-xs font-medium" style={{ color: C.primary }}>{pct.toFixed(0)}%</span>
        </div>
        <div className="h-2 rounded-full overflow-hidden mb-3" style={{ background: C.borderLight }}>
          <div className="h-full rounded-full" style={{ width: `${pct}%`, background: C.primary }} />
        </div>
        <div className="grid grid-cols-3 gap-2">
          {[
            { label: "项目与模板", size: "7.20 GB", Icon: Ic.Folder,   color: C.primary },
            { label: "仿真结果",   size: "4.10 GB", Icon: Ic.Cloud,    color: C.green   },
            { label: "图表",       size: "1.20 GB", Icon: Ic.Grid,     color: C.purple  },
          ].map(item => (
            <div key={item.label} className="rounded-xl p-2.5 flex flex-col gap-1.5" style={{ background: C.borderLight }}>
              <div className="w-5 h-5" style={{ color: item.color }}><item.Icon /></div>
              <div className="text-xs font-semibold" style={{ color: C.text }}>{item.size}</div>
              <div className="text-xs" style={{ color: C.textMuted }}>{item.label}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Phone sub-view wrapper (back button + shared content) ───────────────────
function PhoneSubView({ title, onBack, children }: { title: string; onBack: () => void; children: React.ReactNode }) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <div className="flex items-center gap-2 px-4 h-11 flex-shrink-0" style={{ background: C.card, borderBottom: `1px solid ${C.border}` }}>
        <button onClick={onBack} className="w-7 h-7 flex items-center justify-center rounded-lg flex-shrink-0" style={{ color: C.primary }}>
          <svg viewBox="0 0 24 24" className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
        <span className="text-sm font-semibold flex-1" style={{ color: C.text }}>{title}</span>
      </div>
      <div className="tab-scroll flex-1 overflow-y-scroll px-4 py-4" style={{ scrollbarWidth: 'thin', scrollbarColor: `${C.border} transparent` }}>{children}</div>
    </div>
  );
}

// ─── Sidebar (PC / iPad) ──────────────────────────────────────────────────────
function Sidebar({ view, onNavigate, collapsed, onToggle }: {
  view: AppView; onNavigate: (v: AppView) => void; collapsed: boolean; onToggle: () => void;
}) {
  const pct = (user.usedStorage / user.totalStorage) * 100;
  const groups = [
    { label: "项目", items: [
      { view: "home" as AppView, label: "项目仓库", Icon: Ic.FolderGroup },
      { view: "marketplace" as AppView, label: "模板广场", Icon: Ic.Grid },
      { view: "myTemplates" as AppView, label: "我的模板", Icon: Ic.TemplateGroup },
    ]},
    { label: "账号", items: [
      { view: "profile" as AppView, label: "个人中心", Icon: Ic.Person },
      { view: "messages" as AppView, label: "消息中心", Icon: Ic.Bell, badge: 4 },
      { view: "ai" as AppView, label: "AI助手", Icon: Ic.Sparkle },
    ]},
  ];

  return (
    <div className="flex flex-col h-full overflow-hidden transition-all duration-200"
      style={{ width: collapsed ? 64 : 200, background: C.card, borderRight: `1px solid ${C.border}`, flexShrink: 0 }}>

      {/* Logo */}
      <div className="flex items-center gap-2.5 px-3.5 h-14 flex-shrink-0" style={{ borderBottom: `1px solid ${C.borderLight}`, background: C.bg }}>
        <AppLogo size={28} />
        {!collapsed && <span className="font-bold text-sm whitespace-nowrap" style={{ color: C.text }}>优天线</span>}
      </div>

      {/* Nav */}
      <div className="flex-1 overflow-y-auto py-3 px-2 flex flex-col gap-4" style={{ background: C.bg }}>
        {groups.map(group => (
          <div key={group.label}>
            {!collapsed && <div className="px-2 mb-1.5 text-xs font-medium" style={{ color: C.textMuted }}>{group.label}</div>}
            <div className="flex flex-col gap-0.5">
              {group.items.map(item => {
                const active = view === item.view;
                return (
                  <button key={item.view} onClick={() => onNavigate(item.view)}
                    className="relative flex items-center gap-2.5 px-2.5 py-2.5 rounded-xl transition-colors w-full text-left"
                    style={{ background: active ? C.primaryLight : "transparent", color: active ? C.primary : "#8C8C8C" }}
                    onMouseEnter={e => { if (!active) e.currentTarget.style.background = "#F5F9FF"; }}
                    onMouseLeave={e => { if (!active) e.currentTarget.style.background = "transparent"; }}>
                    <div className="w-[22px] h-[22px] flex-shrink-0"><item.Icon /></div>
                    {!collapsed && <span className="text-sm font-medium whitespace-nowrap">{item.label}</span>}
                    {(item as any).badge && (
                      <div className="absolute flex items-center justify-center text-white rounded-full"
                        style={{ background: "#FF4D4F", fontSize: 9, width: 14, height: 14,
                          top: collapsed ? 4 : 6, right: collapsed ? 4 : 8 }}>
                        {(item as any).badge}
                      </div>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Storage + collapse */}
      <div className="flex-shrink-0 px-2 pb-3" style={{ borderTop: `1px solid ${C.borderLight}`, background: C.bg }}>
        {!collapsed && (
          <button onClick={() => onNavigate("profile")} className="w-full rounded-xl px-3 py-2.5 mt-2 text-left transition-colors"
            style={{ background: C.borderLight }}
            onMouseEnter={e => (e.currentTarget.style.background = "#EAF0F9")}
            onMouseLeave={e => (e.currentTarget.style.background = C.borderLight)}>
            <div className="flex justify-between mb-1.5">
              <span className="text-xs font-medium" style={{ color: C.text }}>存储空间</span>
              <span className="text-xs font-medium" style={{ color: C.primary }}>{pct.toFixed(0)}%</span>
            </div>
            <div className="h-1.5 rounded-full overflow-hidden" style={{ background: '#FFFFFF' }}>
              <div className="h-full rounded-full" style={{ width: `${pct}%`, background: C.primary }} />
            </div>
            <div className="text-xs mt-1" style={{ color: C.textMuted }}>{user.usedStorage} GB / {user.totalStorage} GB</div>
          </button>
        )}
        <button onClick={onToggle}
          className="w-full flex items-center gap-2 px-2.5 py-2 rounded-xl mt-1 transition-colors"
          style={{ color: C.textMuted }}
          onMouseEnter={e => (e.currentTarget.style.background = C.borderLight)}
          onMouseLeave={e => (e.currentTarget.style.background = "transparent")}>
          <div className="w-4 h-4 flex-shrink-0">{collapsed ? <Ic.Expand /> : <Ic.Collapse />}</div>
          {!collapsed && <span className="text-xs">折叠侧边栏</span>}
        </button>
      </div>
    </div>
  );
}

// ─── Phone Bottom Nav (5-item with center AI button) ─────────────────────────
function PhoneBottomNav({ view, onNavigate }: { view: AppView; onNavigate: (v: AppView) => void }) {
  const items = [
    { view: "home" as AppView, label: "首页", Icon: Ic.Home },
    { view: "projects" as AppView, label: "项目", Icon: Ic.Folder, hideLabel: true },
    { view: "ai" as AppView, label: "AI助手", Icon: Ic.Sparkle, center: true },
    { view: "marketplace" as AppView, label: "模板", Icon: Ic.Grid, hideLabel: true },
    { view: "profile" as AppView, label: "个人中心", Icon: Ic.Person },
  ];

  return (
    <div className="flex items-center justify-around px-2 py-1" style={{ background: C.card, borderTop: `1px solid ${C.border}` }}>
      {items.map(item => {
        const isProfile = item.view === "profile" && ["profile", "messages"].includes(view);
        const active = isProfile || view === item.view;
        if (item.center) {
          return (
            <button key={item.view} onClick={() => onNavigate(item.view)}
              className="flex flex-col items-center -mt-5">
              <div className="w-12 h-12 rounded-full flex items-center justify-center shadow-lg"
                style={{ background: C.primary, color: "#fff", boxShadow: `0 4px 14px ${C.primary}50` }}>
                <div className="w-5 h-5"><item.Icon /></div>
              </div>
              <span className="text-xs font-medium mt-0.5" style={{ color: active ? C.primary : C.textMuted }}>AI助手</span>
            </button>
          );
        }
        return (
          <button key={item.view} onClick={() => onNavigate(item.view)}
            className="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl relative"
            style={{ color: active ? C.primary : "#8C8C8C" }}>
            <div className="w-5 h-5"><item.Icon /></div>
            {!(item as any).hideLabel && <span className="text-xs font-medium" style={{ fontSize: 10 }}>{item.label}</span>}
            {item.view === "profile" && msgs.interaction.filter(m => m.unread).length > 0 && (
              <div className="absolute top-1 right-2 w-2 h-2 rounded-full" style={{ background: "#FF4D4F" }} />
            )}
          </button>
        );
      })}
    </div>
  );
}

// ─── Placeholder views ─────────────────────────────────────────────────────────
function PlaceholderView({ title, desc, Icon }: { title: string; desc: string; Icon: () => React.ReactElement }) {
  return (
    <div className="flex-1 flex flex-col items-center justify-center gap-4 text-center px-8">
      <div className="w-16 h-16 rounded-2xl flex items-center justify-center p-4" style={{ background: C.primaryLight, color: C.primary }}><Icon /></div>
      <div>
        <h3 className="text-base font-semibold" style={{ color: C.text }}>{title}</h3>
        <p className="text-sm mt-1" style={{ color: C.textMuted }}>{desc}</p>
      </div>
    </div>
  );
}

// ─── Main App ─────────────────────────────────────────────────────────────────
export default function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [authView, setAuthView] = useState<"login" | "register">("login");
  const [view, setView] = useState<AppView>("profile");
  const [collapsed, setCollapsed] = useState(false);

  // Phone: messages is a sub-view within personal center flow
  const [phoneProfileView, setPhoneProfileView] = useState<PhoneProfileView>("home");

  const handlePhoneNavTab = (v: AppView) => {
    setView(v);
    setPhoneProfileView("home");
  };

  if (!loggedIn) {
    if (authView === "register") return <RegisterView onBack={() => setAuthView("login")} onDone={() => { setLoggedIn(true); setView("profile"); }} />;
    return <LoginView onLogin={() => setLoggedIn(true)} goRegister={() => setAuthView("register")} />;
  }

  const renderDesktopMain = () => {
    switch (view) {
      case "profile": return <PersonalCenter />;
      case "messages": return <MessagesCenter />;
      case "home": return <PlaceholderView title="项目仓库" desc="管理你的天线仿真设计项目" Icon={Ic.FolderGroup} />;
      case "projects": return <PlaceholderView title="项目仓库" desc="管理你的天线仿真设计项目" Icon={Ic.FolderGroup} />;
      case "marketplace": return <PlaceholderView title="模板广场" desc="探索社区共享的天线设计模板" Icon={Ic.Grid} />;
      case "myTemplates": return <PlaceholderView title="我的模板" desc="查看和管理你上传的设计模板" Icon={Ic.TemplateGroup} />;
      case "ai": return <PlaceholderView title="AI助手" desc="智能天线参数优化与仿真建议" Icon={Ic.Sparkle} />;
    }
  };

  const goBackToProfile = () => setPhoneProfileView("home");

  const renderPhoneMain = () => {
    if (view === "profile") {
      if (phoneProfileView === "home") return <PhonePersonalCenter onNavigate={setPhoneProfileView} />;
      if (phoneProfileView === "info")     return <PhoneSubView title="基本信息" onBack={goBackToProfile}><ProfileInfo /></PhoneSubView>;
      if (phoneProfileView === "sharing")  return <PhoneSubView title="共享记录" onBack={goBackToProfile}><ProfileSharing /></PhoneSubView>;
      if (phoneProfileView === "storage")  return <PhoneSubView title="存储空间" onBack={goBackToProfile}><ProfileStorage /></PhoneSubView>;
      if (phoneProfileView === "uploads")  return <PhoneSubView title="上传记录" onBack={goBackToProfile}><ProfileUploads /></PhoneSubView>;
      if (phoneProfileView === "messages")  return <PhoneSubView title="消息中心" onBack={goBackToProfile}><MessagesTabs /></PhoneSubView>;
      if (phoneProfileView === "security")  return <PhoneSubView title="账号安全" onBack={goBackToProfile}><ProfileSecurity /></PhoneSubView>;
    }
    const titles: Record<AppView, string> = { home: "首页", projects: "项目仓库", marketplace: "模板广场", myTemplates: "我的模板", ai: "AI助手", profile: "个人中心", messages: "消息中心" };
    const icons:  Record<AppView, () => React.ReactElement> = { home: Ic.FolderGroup, projects: Ic.FolderGroup, marketplace: Ic.Grid, myTemplates: Ic.TemplateGroup, ai: Ic.Sparkle, profile: Ic.Person, messages: Ic.Bell };
    return <PlaceholderView title={titles[view]} desc="功能开发中" Icon={icons[view]} />;
  };

  return (
    <div className="h-full flex flex-col overflow-hidden" style={{ background: C.bg, fontFamily: "'Noto Sans SC', 'Inter', -apple-system, sans-serif" }}>

      {/* ── PC / iPad ── */}
      <div className="hidden md:flex h-full overflow-hidden">
        <Sidebar view={view} onNavigate={setView} collapsed={collapsed} onToggle={() => setCollapsed(!collapsed)} />
        <div className="flex-1 flex overflow-hidden" style={{ alignItems: 'flex-start', justifyContent: 'center', padding: 0 }}>
          <div className="flex-1 flex flex-col overflow-hidden" style={{ background: C.card }}>
            {renderDesktopMain()}
          </div>
        </div>
        {/* Floating AI button */}
        <button onClick={() => setView("ai")} className="fixed bottom-6 right-6 w-12 h-12 rounded-full flex items-center justify-center text-white z-50 transition-transform hover:scale-105"
          style={{ background: C.primary, boxShadow: `0 4px 16px ${C.primary}50` }}>
          <div className="w-5 h-5"><Ic.Chat /></div>
        </button>
      </div>

      {/* ── Phone ── */}
      <div className="flex md:hidden flex-col h-full overflow-hidden">
        {/* Header */}
        <div className="flex items-center gap-3 px-4 h-12 flex-shrink-0" style={{ background: C.card, borderBottom: `1px solid ${C.border}` }}>
          <AppLogo size={24} />
          <span className="font-bold text-sm flex-1" style={{ color: C.text }}>优天线</span>
          <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-semibold" style={{ background: user.avatarColor }}>{user.avatar}</div>
        </div>
        {/* Content */}
        <div className="flex-1 overflow-y-auto">
          {renderPhoneMain()}
        </div>
        {/* Bottom nav */}
        <PhoneBottomNav view={view} onNavigate={handlePhoneNavTab} />
      </div>
    </div>
  );
}
