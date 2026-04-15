import React from 'react';

// Phone Frame Component
const PhoneFrame = ({ children, label, marketingText }) => {
  return (
    <div className="flex flex-col items-center gap-6">
      {/* Marketing Text Label */}
      <div className="text-center max-w-xs">
        <h3 className="text-xl font-bold text-white mb-2 leading-tight">{marketingText}</h3>
        <p className="text-xs text-gray-400 uppercase tracking-widest font-semibold">{label}</p>
      </div>

      {/* Phone Frame */}
      <div className="relative w-72 rounded-3xl border-8 border-gray-900 shadow-2xl overflow-hidden bg-black" style={{ aspectRatio: '9/19.5' }}>
        {/* Notch */}
        <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-32 h-6 bg-black rounded-b-3xl z-20"></div>

        {/* Screen Content */}
        <div className="w-full h-full overflow-hidden pt-8">
          {children}
        </div>

        {/* Phone Speaker Grill */}
        <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-24 h-1 bg-black/90 z-10 rounded-b-2xl"></div>
      </div>
    </div>
  );
};

// Screenshot 1: Home Screen - Tonight's Story
const HomeScreen = () => {
  return (
    <div className="w-full h-full bg-gradient-to-b from-[#0A0A1F] via-[#1A1030] to-[#0A0A1F] flex flex-col p-6 relative overflow-hidden">
      {/* Starry Background */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(15)].map((_, i) => (
          <div
            key={i}
            className="absolute rounded-full bg-white"
            style={{
              width: Math.random() * 1.5 + 0.5 + 'px',
              height: Math.random() * 1.5 + 0.5 + 'px',
              left: Math.random() * 100 + '%',
              top: Math.random() * 100 + '%',
              opacity: Math.random() * 0.5 + 0.3,
            }}
          ></div>
        ))}
      </div>

      {/* Status Bar Simulation */}
      <div className="relative z-10 flex justify-between items-center text-white text-xs mb-4">
        <span>9:41</span>
        <span>📶 📡 🔋</span>
      </div>

      {/* Greeting */}
      <div className="relative z-10 mb-6">
        <p className="text-white/60 text-sm">Good Evening, Emma</p>
        <h1 className="text-2xl font-bold text-white">Time to Relax</h1>
      </div>

      {/* Tonight's Story Featured Card */}
      <div className="relative z-10 mb-6 rounded-2xl overflow-hidden bg-gradient-to-br from-[#6366F1] via-[#818CF8] to-[#FBBF24] p-6 shadow-lg">
        <div className="flex justify-between items-start mb-4">
          <div>
            <p className="text-white/80 text-xs uppercase tracking-wide mb-2">Tonight's Story</p>
            <h2 className="text-xl font-bold text-white mb-1">Noah and the Big Boat</h2>
            <p className="text-white/70 text-sm">Genesis 6-9</p>
          </div>
          <span className="text-3xl">🚢</span>
        </div>
        <div className="flex items-center gap-2 text-white/80 text-xs">
          <span>⏱️ 8:42</span>
          <span>•</span>
          <span>🎙️ Narrated</span>
        </div>
      </div>

      {/* Quick Access - Continue Story */}
      <div className="relative z-10 rounded-xl bg-white/10 backdrop-blur-sm p-4 mb-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-white/60 text-xs mb-1">Continue Reading</p>
            <p className="text-white font-semibold">The Good Samaritan</p>
          </div>
          <div className="w-10 h-10 rounded-full bg-[#FBBF24]/20 flex items-center justify-center">
            <span className="text-white font-bold">▶</span>
          </div>
        </div>
      </div>

      {/* Category Quick Links */}
      <div className="relative z-10">
        <p className="text-white text-sm font-semibold mb-3">Browse Categories</p>
        <div className="grid grid-cols-3 gap-2">
          {['Peace', 'Love', 'Trust'].map((cat, idx) => (
            <div key={idx} className="rounded-lg bg-white/10 backdrop-blur-sm p-3 text-center">
              <p className="text-white text-sm font-medium">{cat}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom Navigation Simulation */}
      <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/50 to-transparent h-16"></div>
    </div>
  );
};

// Screenshot 2: Story Library with Filters
const StoryLibraryScreen = () => {
  const stories = [
    { title: 'Noah and the Big Boat', category: 'Trust', emoji: '🚢' },
    { title: 'Daniel and the Lions', category: 'Courage', emoji: '🦁' },
    { title: 'Jesus Calms the Storm', category: 'Peace', emoji: '⛈️' },
    { title: 'The Good Samaritan', category: 'Love', emoji: '🤝' },
    { title: 'David and Goliath', category: 'Courage', emoji: '💪' },
    { title: 'Ruth\'s Kindness', category: 'Love', emoji: '👑' },
  ];

  const categories = ['All', 'Peace', 'Love', 'Trust', 'Courage'];

  return (
    <div className="w-full h-full bg-gradient-to-b from-[#0A0A1F] to-[#1A1030] flex flex-col p-4 overflow-y-auto">
      {/* Status Bar */}
      <div className="flex justify-between items-center text-white text-xs mb-4">
        <span>9:41</span>
        <span>📶 📡 🔋</span>
      </div>

      {/* Header */}
      <h1 className="text-2xl font-bold text-white mb-4">Story Library</h1>

      {/* Category Filter Carousel */}
      <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
        {categories.map((cat, idx) => (
          <button
            key={idx}
            className={`px-4 py-2 rounded-full font-semibold text-sm whitespace-nowrap transition-all ${
              idx === 0
                ? 'bg-[#6366F1] text-white'
                : 'bg-white/10 text-white/70 hover:bg-white/20'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Story Grid */}
      <div className="grid grid-cols-2 gap-3 flex-1">
        {stories.map((story, idx) => (
          <div
            key={idx}
            className="rounded-xl p-4 backdrop-blur-sm transition-all cursor-pointer hover:scale-105 active:scale-95"
            style={{ backgroundColor: 'rgba(255,255,255,0.08)' }}
          >
            {/* Story Artwork */}
            <div className="w-full h-20 rounded-lg bg-gradient-to-br from-[#818CF8] to-[#6366F1] mb-3 flex items-center justify-center text-3xl shadow-md">
              {story.emoji}
            </div>
            <h3 className="text-white text-xs font-bold line-clamp-2 mb-2">{story.title}</h3>
            <div className="flex items-center justify-between">
              <span className="text-white/60 text-xs">{story.category}</span>
              <span className="text-white/40 text-xs">⏱️ 8m</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// Screenshot 3: Story Reading/Listening Experience
const StoryReadingScreen = () => {
  return (
    <div className="w-full h-full bg-gradient-to-b from-[#0A0A1F] via-[#1A1030] to-[#0A0A1F] flex flex-col p-6 relative overflow-hidden">
      {/* Status Bar */}
      <div className="flex justify-between items-center text-white text-xs mb-4">
        <span>9:41</span>
        <span>📶 📡 🔋</span>
      </div>

      {/* Back Header */}
      <div className="flex items-center gap-3 mb-6">
        <button className="text-[#818CF8] text-lg">←</button>
        <span className="text-white/60 text-sm">Bible Stories</span>
      </div>

      {/* Story Illustration */}
      <div className="w-full h-40 rounded-2xl bg-gradient-to-br from-[#FBBF24] via-[#818CF8] to-[#6366F1] mb-6 flex items-center justify-center relative overflow-hidden shadow-xl">
        <div className="text-6xl">🚢</div>
        <div className="absolute top-3 right-5 text-xl animate-pulse">✨</div>
        <div className="absolute bottom-3 left-5 text-lg animate-pulse" style={{ animationDelay: '0.5s' }}>⭐</div>
      </div>

      {/* Story Title & Reference */}
      <h2 className="text-2xl font-bold text-white mb-1">Noah and the Big Boat</h2>
      <p className="text-[#818CF8] text-sm mb-6">Genesis 6-9 • 8 minutes</p>

      {/* Audio Player */}
      <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 mb-6">
        {/* Progress Bar */}
        <div className="flex items-center gap-2 mb-4">
          <span className="text-white/60 text-xs">2:47</span>
          <div className="flex-1 h-2 bg-white/20 rounded-full overflow-hidden">
            <div className="h-full w-1/3 bg-[#FBBF24] rounded-full"></div>
          </div>
          <span className="text-white/60 text-xs">8:42</span>
        </div>

        {/* Play Controls */}
        <div className="flex items-center justify-center gap-6">
          <button className="text-white/60 text-xl hover:text-white">⏮️</button>
          <button className="w-16 h-16 rounded-full bg-gradient-to-br from-[#6366F1] to-[#818CF8] flex items-center justify-center text-white text-2xl shadow-lg hover:shadow-xl transition-all">
            ▶
          </button>
          <button className="text-white/60 text-xl hover:text-white">⏭️</button>
        </div>
      </div>

      {/* Story Features */}
      <div className="grid grid-cols-3 gap-3">
        <button className="rounded-xl bg-white/10 backdrop-blur-sm p-4 text-center hover:bg-white/20 transition">
          <span className="text-2xl block mb-1">📖</span>
          <span className="text-white text-xs font-semibold">Read</span>
        </button>
        <button className="rounded-xl bg-white/10 backdrop-blur-sm p-4 text-center hover:bg-white/20 transition">
          <span className="text-2xl block mb-1">🎵</span>
          <span className="text-white text-xs font-semibold">Listen</span>
        </button>
        <button className="rounded-xl bg-white/10 backdrop-blur-sm p-4 text-center hover:bg-white/20 transition">
          <span className="text-2xl block mb-1">❤️</span>
          <span className="text-white text-xs font-semibold">Favorite</span>
        </button>
      </div>
    </div>
  );
};

// Screenshot 4: Bedtime Routine with Breathing Exercise
const BedtimeRoutineScreen = () => {
  return (
    <div className="w-full h-full bg-gradient-to-b from-[#0A0A1F] via-[#1A1030] to-[#0A0A1F] flex flex-col items-center justify-center p-6 relative overflow-hidden">
      {/* Starry Background */}
      {[...Array(12)].map((_, i) => (
        <div
          key={i}
          className="absolute rounded-full bg-white"
          style={{
            width: Math.random() * 1.5 + 0.5 + 'px',
            height: Math.random() * 1.5 + 0.5 + 'px',
            left: Math.random() * 100 + '%',
            top: Math.random() * 100 + '%',
            opacity: Math.random() * 0.4 + 0.2,
          }}
        ></div>
      ))}

      {/* Status Bar */}
      <div className="absolute top-0 left-0 right-0 flex justify-between items-center text-white text-xs px-6 pt-4 z-10">
        <span>9:41</span>
        <span>📶 📡 🔋</span>
      </div>

      <div className="relative z-10 text-center flex flex-col items-center justify-center flex-1">
        {/* Title */}
        <h1 className="text-2xl font-bold text-white mb-2">Bedtime Breathing</h1>
        <p className="text-white/60 text-sm mb-8">Calm your mind before sleep</p>

        {/* Breathing Circle Animation */}
        <div className="relative w-48 h-48 mb-12 flex items-center justify-center">
          {/* Outer Circle */}
          <div className="absolute inset-0 rounded-full border-2 border-[#818CF8]/30 opacity-75"></div>

          {/* Middle Circle */}
          <div className="absolute inset-8 rounded-full border-2 border-[#6366F1]/50 opacity-75"></div>

          {/* Inner Breathing Circle */}
          <div
            className="absolute inset-16 rounded-full bg-gradient-to-br from-[#FBBF24] to-[#818CF8] opacity-80 flex items-center justify-center shadow-lg"
            style={{
              animation: 'breathe 6s ease-in-out infinite',
            }}
          >
            <span className="text-5xl">🌬️</span>
          </div>
        </div>

        {/* Instructions */}
        <p className="text-white text-sm mb-8">
          <span className="text-[#FBBF24] font-semibold">Breathe In</span> (4s) • <span className="text-[#6366F1] font-semibold">Hold</span> (4s) • <span className="text-[#818CF8] font-semibold">Out</span> (4s)
        </p>

        {/* Control Buttons */}
        <div className="flex gap-4">
          <button className="px-6 py-3 rounded-full bg-white/10 text-white text-sm font-semibold hover:bg-white/20 transition">
            Skip
          </button>
          <button className="px-6 py-3 rounded-full bg-[#6366F1] text-white text-sm font-semibold hover:bg-[#818CF8] transition">
            Continue
          </button>
        </div>
      </div>

      {/* CSS for breathing animation */}
      <style>{`
        @keyframes breathe {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.2); }
        }
      `}</style>
    </div>
  );
};

// Screenshot 5: Rewards - Sleep Stars & Badges
const RewardsScreen = () => {
  const stats = [
    { value: '24', label: 'Sleep Stars', emoji: '⭐', color: 'from-[#FBBF24]' },
    { value: '7', label: 'Day Streak', emoji: '🔥', color: 'from-[#FF6B6B]' },
  ];

  const badges = [
    { emoji: '🌙', label: 'Night Owl', earned: true },
    { emoji: '🎖️', label: 'Story Listener', earned: true },
    { emoji: '⏰', label: 'Early Bird', earned: true },
    { emoji: '🏆', label: 'Week Master', earned: false },
    { emoji: '👑', label: 'Bedtime Legend', earned: false },
    { emoji: '🌟', label: 'Star Collector', earned: false },
  ];

  return (
    <div className="w-full h-full bg-gradient-to-b from-[#0A0A1F] to-[#1A1030] flex flex-col p-4 overflow-y-auto">
      {/* Status Bar */}
      <div className="flex justify-between items-center text-white text-xs mb-4">
        <span>9:41</span>
        <span>📶 📡 🔋</span>
      </div>

      {/* Header */}
      <h1 className="text-2xl font-bold text-white mb-6">Your Rewards</h1>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 gap-4 mb-8">
        {stats.map((stat, idx) => (
          <div
            key={idx}
            className={`rounded-2xl bg-gradient-to-br ${stat.color} to-[#6366F1] p-6 text-white shadow-lg`}
          >
            <div className="text-4xl font-bold mb-1">{stat.value}</div>
            <div className="text-sm opacity-90">{stat.label}</div>
            <div className="text-3xl mt-2">{stat.emoji}</div>
          </div>
        ))}
      </div>

      {/* Badges Section */}
      <div className="mb-6">
        <h2 className="text-white font-bold text-lg mb-4">Achievements</h2>
        <div className="grid grid-cols-3 gap-3">
          {badges.map((badge, idx) => (
            <div
              key={idx}
              className={`rounded-xl p-4 text-center transition-all ${
                badge.earned
                  ? 'bg-white/10 backdrop-blur-sm'
                  : 'bg-white/5 opacity-50'
              }`}
            >
              <div className={`text-4xl mb-2 ${badge.earned ? '' : 'grayscale'}`}>
                {badge.emoji}
              </div>
              <p className="text-white text-xs font-semibold">{badge.label}</p>
              {!badge.earned && (
                <p className="text-white/50 text-xs mt-1">Locked</p>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Collectibles Section */}
      <div>
        <h2 className="text-white font-bold text-lg mb-4">Collectibles</h2>
        <div className="grid grid-cols-5 gap-2">
          {['🌈', '🦁', '🐳', '🦅', '🦋'].map((emoji, idx) => (
            <div key={idx} className="aspect-square rounded-lg bg-white/10 backdrop-blur-sm flex items-center justify-center text-2xl">
              {emoji}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// Screenshot 6: Settings with Bedtime Mode (Dark Theme)
const SettingsScreen = () => {
  const settings = [
    { icon: '🌙', label: 'Bedtime Mode', value: 'ON', highlight: true },
    { icon: '🔊', label: 'Sound Effects', value: 'ON' },
    { icon: '🔔', label: 'Reminders', value: 'ON' },
    { icon: '👨‍👧', label: 'Parental Controls', value: 'Set' },
  ];

  return (
    <div className="w-full h-full bg-gradient-to-b from-[#0A0A1F] to-[#1A1030] flex flex-col p-4 overflow-y-auto">
      {/* Status Bar */}
      <div className="flex justify-between items-center text-white text-xs mb-4">
        <span>9:41</span>
        <span>📶 📡 🔋</span>
      </div>

      {/* Header */}
      <h1 className="text-2xl font-bold text-white mb-6">Settings</h1>

      {/* Bedtime Mode Hero */}
      <div className="rounded-2xl bg-gradient-to-br from-[#6366F1] to-[#818CF8] p-6 mb-8 shadow-lg">
        <div className="flex items-start justify-between mb-4">
          <div>
            <h2 className="text-white font-bold text-xl mb-1">Bedtime Mode</h2>
            <p className="text-white/80 text-sm">Reduces blue light for better sleep</p>
          </div>
          <span className="text-3xl">🌙</span>
        </div>
        <div className="flex gap-2">
          <button className="flex-1 py-2 rounded-lg bg-white text-[#6366F1] font-semibold text-sm">
            ON
          </button>
          <button className="flex-1 py-2 rounded-lg bg-white/20 text-white font-semibold text-sm hover:bg-white/30">
            OFF
          </button>
        </div>
      </div>

      {/* Settings List */}
      <div className="space-y-3 mb-8">
        {settings.map((setting, idx) => (
          idx !== 0 && (
            <div
              key={idx}
              className="rounded-xl bg-white/10 backdrop-blur-sm p-4 flex items-center justify-between hover:bg-white/20 transition cursor-pointer"
            >
              <div className="flex items-center gap-4">
                <span className="text-2xl">{setting.icon}</span>
                <div>
                  <p className="text-white font-semibold text-sm">{setting.label}</p>
                  <p className="text-white/60 text-xs">{setting.value}</p>
                </div>
              </div>
              <span className="text-white/40">→</span>
            </div>
          )
        ))}
      </div>

      {/* About Section */}
      <div className="border-t border-white/10 pt-6">
        <h3 className="text-white font-semibold text-sm mb-3">About</h3>
        <div className="space-y-2 text-xs text-white/60">
          <p>Version 1.0.0</p>
          <p className="flex gap-2">
            <a href="#" className="text-[#818CF8] hover:text-white">Privacy Policy</a>
            <span>•</span>
            <a href="#" className="text-[#818CF8] hover:text-white">Terms</a>
          </p>
          <p className="text-white/40 mt-4">© 2024 Little Lights Bible Bedtime</p>
        </div>
      </div>
    </div>
  );
};

// Main App Component
export default function ScreenshotShowcase() {
  const screenshots = [
    {
      component: <HomeScreen />,
      label: 'Home Screen',
      marketing: 'Personalized Story Selection & Tonight\'s Pick',
    },
    {
      component: <StoryLibraryScreen />,
      label: 'Story Library',
      marketing: 'Browse 50+ Stories by Theme & Category',
    },
    {
      component: <StoryReadingScreen />,
      label: 'Reading Experience',
      marketing: 'Listen, Read & Interact with Stories',
    },
    {
      component: <BedtimeRoutineScreen />,
      label: 'Breathing Exercise',
      marketing: 'Guided Relaxation Before Bedtime',
    },
    {
      component: <RewardsScreen />,
      label: 'Rewards & Achievements',
      marketing: 'Earn Stars, Badges & Collectibles',
    },
    {
      component: <SettingsScreen />,
      label: 'Settings',
      marketing: 'Bedtime Mode & Customization',
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#0A0A1F] via-[#1A1030] to-[#0A0A1F] py-16 px-4">
      {/* Header Section */}
      <div className="max-w-7xl mx-auto mb-20">
        <div className="text-center mb-4">
          <h1 className="text-6xl font-black text-white mb-4 leading-tight">
            Little Lights<br />Bible Bedtime
          </h1>
          <p className="text-xl text-[#818CF8] font-semibold mb-2">
            Soothing Bible Stories for Peaceful Sleep
          </p>
          <p className="text-white/60 text-base max-w-2xl mx-auto">
            An interactive app designed to help children ages 3-8 wind down with engaging Bible stories, guided breathing exercises, and rewarding achievements before bedtime.
          </p>
        </div>

        {/* Key Features Pills */}
        <div className="flex flex-wrap justify-center gap-3 mt-8">
          {['📖 50+ Stories', '🎵 Audio Narration', '⭐ Rewards', '🌙 Dark Mode', '🧘 Breathing', '👨‍👧 Parental'].map((feat, idx) => (
            <div key={idx} className="px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 text-white text-sm font-medium">
              {feat}
            </div>
          ))}
        </div>
      </div>

      {/* Screenshots Grid */}
      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-16 place-items-center mb-20">
        {screenshots.map((screenshot, idx) => (
          <PhoneFrame
            key={idx}
            label={screenshot.label}
            marketingText={screenshot.marketing}
          >
            {screenshot.component}
          </PhoneFrame>
        ))}
      </div>

      {/* Footer Section */}
      <div className="max-w-7xl mx-auto border-t border-white/10 pt-12 text-center">
        <h2 className="text-2xl font-bold text-white mb-3">Ready for Bedtime?</h2>
        <p className="text-white/70 mb-6 max-w-2xl mx-auto">
          Download Little Lights Bible Bedtime from the App Store and start building better bedtime routines with your children today.
        </p>
        <div className="flex justify-center gap-4 mb-8">
          <button className="px-8 py-3 rounded-full bg-[#6366F1] text-white font-semibold hover:bg-[#818CF8] transition shadow-lg">
            Download on App Store
          </button>
        </div>
        <p className="text-white/50 text-sm">
          iOS 14+ • Free with Optional In-App Purchases • Designed for Kids 3-8<br />
          © 2024 Little Lights Bible Bedtime • All rights reserved
        </p>
      </div>
    </div>
  );
}
