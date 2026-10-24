# Maked · 11.16 生日页

双击 `index.html` 就能打开（不需要联网，也不需要装任何东西）。

```
birthday/
├─ index.html        页面本体（HTML + CSS + JS 全在这一个文件里）
└─ assets/
   ├─ avatar.webp     头像（138px 圆形，显示在顶部）
   ├─ bgm.m4a        背景音乐（从 舟友的酒.mp4 里提取的音轨，30 秒，循环播放）
   └─ covers/        19 张愿望单封面（Steam 官方 CDN 的 header.jpg，460×215）
```

> 封面说明：18 张直接用 Steam CDN 的 `header.jpg`；《极限竞速：地平线 6》的 AppID（2483190）在 CDN 上还没有 header 图，是从你给的截图里裁的，放大看会略糊。

## 怎么改

| 想改什么 | 改哪里 |
| --- | --- |
| 头像 | 直接替换 `assets/avatar.webp`（正方形最好） |
| 显示的名字 | `index.html` 里搜 `Maked`（标题、h1、footer 各一处） |
| 生日日期 | 搜 `new Date(now.getFullYear(), 10, 16` —— `10` 是 11 月（从 0 数），`16` 是日 |
| Steam 愿望单 | 搜 `const WISHLIST`，按同样格式改数组：`title / price / original / cut / tags / hue` |
| 音乐 | 换 `assets/bgm.m4a` 即可；注意换了音乐后节拍时间轴（`const BEATS`）就对不上了 |
| 初始祝福 | 搜 `SEED_WISHES` |

## 交互说明

- **音乐按钮**：右下角悬浮，默认不播放；点击后开始放歌。
  节拍不是随便估的：先把 mp4 的音轨转成单声道 22.05 kHz，做了频谱通量（spectral flux）起始点检测，估出 129 BPM，再按这个周期对齐出 65 个拍点，写进了页面。
- **旋转与拉伸**：播放时页面上的每个 `.beat-target`（头像、标题、文字、倒计时格子、按钮、祝福卡、愿望单卡片）都绕自己的竖轴做 **rotateY** 转身，**每小节（4 拍，约 1.85 秒）匀速转满 360°**：
  `transform: perspective(1100px) rotateY(0→360deg)`。小节起点正对观众，和视频里角色原地转一圈的节奏一致（视频约 2 秒一圈）。
  转到 90° / 270° 时会侧成一条线（宽 0），只持续一两帧，肉眼基本看不到；转到 180° 看到的是背面——平面卡片转过去必然是镜像的，这是完整一圈的代价。
  同时在每个拍点上有一次“横向拉伸 + 纵向压扁”的脉冲。
  角度和缩放都由 `applyFrame()` 每帧按 `audio.currentTime` 计算后写到 `style.transform`，所以是严格贴着音频走的，暂停就回正。
  在祝福输入框里打字时会自动停止转身（`document.activeElement` 判断），免得字打不准。
  想改成“刷一下回正”的转法，把 `const yaw = 360 * p` 换成 `const yaw = 60 * Math.sin(p * Math.PI * 2)` 即可。
- **戳一戳**：点一下计数 +1，并弹出随机颜文字，无限次。
- **吃蛋糕**：点一下蛋糕按钮点亮（烛光亮起 + 金色光晕），计数 +1。
- **祝福墙**：填名字和内容后提交，卡片会插到最前面。默认存在浏览器 `localStorage` 里，刷新还在，但只有本机看得到。
- **共享模式**：
  - 用 `server.js` 通过 http 打开时，自动走本地 API（`/api/wishes`），所有访客共用一面墙；
  - 填了 Supabase 地址和 anon key 时，走 Supabase；
  - 直接双击 file:// 打开时，退回本机 localStorage。
  每 20 秒自动刷新一次，后端挂了会退回本机并在标题旁标红提示。
- 戳一戳 / 吃蛋糕的次数目前仍然只存本机。

## Supabase 共享祝福（可选）

1. 在 <https://supabase.com> 注册并新建一个项目（区域选 Singapore，离国内近）。
2. 打开 SQL Editor，把 `supabase.sql` 整段粘进去运行。
3. 项目设置 → API，复制 **Project URL** 和 **anon public** key。
4. 填到 `index.html` 顶部（搜 `SUPABASE_URL`）：

```js
const SUPABASE_URL = "https://xxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOi...";
```

两项都留空 = 用本地 server.js 或本机模式；填了就自动切 Supabase，标题旁的胶囊会显示「共享 · 全站可见」。
anon key 本来就是公开的，安全靠 RLS 策略（`supabase.sql` 里已经写好：所有人可读、可插入，但不能改和删）。

## 愿望单

`WISHLIST` 里是 2026-10-24 从截图录入的 19 个心愿，合计 ¥1,637.85。
每条的字段：`title` 名称、`cover` 封面图路径、`price` 现价、`original` 原价、`cut` 折扣百分比、`tags` 标签、`hue` 封面色相（无图时的渐变兜底）、`note` 封面角标（试用版 / 抢先体验 / 已在购物车）。

## 头像

`assets/avatar.webp` 是 2026-10-24 主人给的 DeepSeek 头像（原图 166×165，已无损放大到 332×330 并轻微锐化）。
想换直接替换这个文件即可；原来那张 Steam 头像备份在 `E:\work\backup-avatar-steam.png`。
