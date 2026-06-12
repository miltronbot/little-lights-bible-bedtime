import { useState, useEffect, useRef, useCallback } from "react";

/* ━━━━━━━━━━━━━━━━━ DATA ━━━━━━━━━━━━━━━━━ */
const STORIES = [
  { id:"noahs-ark", title:"Noah's Ark", subtitle:"A promise in the rainbow", ref:"Genesis 6-9", category:"Trust", age:"3-5", duration:8, color:"#3b82f6", emoji:"🌈",
    prayer:"Dear God, thank You for keeping us safe, just like You kept Noah safe. Help me trust You always. Amen.",
    takeaway:"God keeps His promises and protects those who trust Him.",
    verse:"\"I have set my rainbow in the clouds.\" — Genesis 9:13",
    text:"Long ago, when the world had forgotten about God's love, there lived a kind man named Noah. Noah loved God with all his heart and tried to do what was right every single day.\n\nOne day, God spoke to Noah and said, \"I want you to build a big, big boat called an ark.\" Noah had never built a boat before, but he trusted God completely.\n\nNoah and his family worked day after day, hammering and sawing, building the enormous ark just as God had told them. Their neighbors laughed and said, \"Why are you building a boat on dry land?\" But Noah kept working because he trusted God's plan.\n\nWhen the ark was finished, God sent animals of every kind — two by two they came! Big elephants and tiny mice, tall giraffes and round little hedgehogs. Noah welcomed them all aboard.\n\nThen the rain began to fall. It rained and rained for forty days and forty nights. But inside the ark, Noah, his family, and all the animals were safe and warm.\n\nWhen the rain finally stopped, Noah sent out a dove. The dove came back with an olive branch — land was near! As they stepped off the ark, God painted the most beautiful rainbow across the sky.\n\n\"This rainbow is my promise,\" God said. \"I will always take care of you.\" And every time you see a rainbow, remember — God keeps His promises." },
  { id:"david-and-goliath", title:"David & Goliath", subtitle:"Courage from within", ref:"1 Samuel 17", category:"Courage", age:"6-8", duration:10, color:"#f97316", emoji:"⚔️",
    prayer:"Dear God, when I feel small or scared, remind me that You are with me and I can be brave. Amen.",
    takeaway:"With God's help, even the smallest person can overcome the biggest challenges.",
    verse:"\"The Lord who rescued me will rescue me.\" — 1 Samuel 17:37",
    text:"In a green valley between two hills, two armies faced each other. The army of Israel was on one side, and the Philistines on the other. Every day, a giant named Goliath would stomp out and shout, \"Send someone to fight me!\" He was so tall that he made the ground shake when he walked.\n\nAll the soldiers were terrified. Nobody wanted to face the giant.\n\nThen along came David — a young shepherd boy who had come to bring lunch to his brothers. David wasn't a soldier. He didn't wear armor or carry a sword. But David had something the soldiers didn't — he trusted God completely.\n\n\"I'll fight the giant,\" David said. Everyone laughed. \"You're just a boy!\" they said.\n\nBut David remembered all the times God had helped him protect his sheep from lions and bears. \"The same God who saved me then will save me now,\" David said.\n\nWith just five smooth stones and his sling, David walked toward the giant. Goliath laughed at the small boy. But David called out, \"You come with a sword, but I come in the name of the Lord!\"\n\nDavid placed a stone in his sling, swung it around, and let it fly. The stone struck Goliath right on his forehead, and the mighty giant fell to the ground with a tremendous crash.\n\nThat day, everyone learned that it doesn't matter how small you are — with God on your side, you can face any giant." },
  { id:"good-samaritan", title:"The Good Samaritan", subtitle:"Love your neighbor", ref:"Luke 10:25-37", category:"Kindness", age:"6-8", duration:7, color:"#14b8a6", emoji:"💝",
    prayer:"Dear God, help me see when people need help and give me a kind heart to help them. Amen.",
    takeaway:"Being kind means helping everyone, even those who are different from us.",
    verse:"\"Love your neighbor as yourself.\" — Luke 10:27",
    text:"One day, someone asked Jesus, \"Who is my neighbor?\" Jesus answered with a story.\n\nA man was walking down a lonely road when robbers attacked him. They took everything he had and left him hurt and alone by the side of the road.\n\nSoon, an important man came walking by. He saw the hurt man, but he crossed to the other side of the road and kept walking. Then another important man came along. He looked at the hurt man too, but he also walked right past.\n\nFinally, a Samaritan came along. Now, Samaritans and the hurt man's people didn't usually get along. But when the Samaritan saw the hurt man, his heart filled with compassion.\n\nHe knelt down beside the man, carefully cleaned his wounds, and bandaged them. Then he lifted the man onto his own donkey and took him to an inn where he could rest and get better. He even paid the innkeeper to take care of the man.\n\n\"Which one was a true neighbor?\" Jesus asked.\n\n\"The one who showed kindness,\" came the answer.\n\n\"Go and do the same,\" Jesus said with a smile." },
  { id:"daniel-lions-den", title:"Daniel & the Lions", subtitle:"Faith conquers fear", ref:"Daniel 6", category:"Courage", age:"6-8", duration:9, color:"#eab308", emoji:"🦁",
    prayer:"Dear God, give me courage like Daniel. Help me to always be faithful to You. Amen.",
    takeaway:"When we stay faithful to God, He protects us even in scary situations.",
    verse:"\"My God sent his angel and shut the lions' mouths.\" — Daniel 6:22",
    text:"Daniel was a man who loved God with all his heart. Three times every day, he would open his window and pray, thanking God for His goodness.\n\nDaniel was so wise and honest that the king made him one of the most important people in the whole kingdom. This made some other men very jealous.\n\nThese jealous men came up with a sneaky plan. They convinced the king to make a new law: \"For thirty days, everyone must pray only to the king. Anyone who prays to anyone else will be thrown into the den of lions!\"\n\nWhen Daniel heard about the new law, do you know what he did? He went straight to his window, knelt down, and prayed to God — just like he always did. Daniel wasn't going to stop talking to God, no matter what.\n\nThe jealous men caught Daniel praying and told the king. The king was very sad because he liked Daniel, but the law was the law. Daniel was thrown into the pit of hungry lions.\n\nBut God sent an angel to close the lions' mouths! All night long, Daniel sat safely among the lions. They didn't hurt him at all — they were as gentle as kittens.\n\nIn the morning, the king rushed to the den. \"Daniel! Did your God save you?\" he called out.\n\n\"Yes!\" Daniel called back. \"God sent His angel to protect me!\"\n\nThe king was overjoyed and made a new law: everyone should respect Daniel's God." },
  { id:"creation-story", title:"Creation", subtitle:"God made everything beautiful", ref:"Genesis 1-2", category:"Hope", age:"3-5", duration:8, color:"#22c55e", emoji:"🌍",
    prayer:"Dear God, thank You for making this beautiful world. Help me take care of it. Amen.",
    takeaway:"God created the whole world with love, and He made you special too.",
    verse:"\"God saw all that he had made, and it was very good.\" — Genesis 1:31",
    text:"In the very beginning, before there was anything at all, God spoke — and amazing things began to happen.\n\nOn the first day, God said, \"Let there be light!\" And warm, golden light appeared, pushing away the darkness. God called the light Day and the darkness Night.\n\nOn the second day, God made the beautiful blue sky, stretching it high above like a big, soft blanket.\n\nOn the third day, God gathered the waters together to make oceans and seas, and dry land appeared with green grass, colorful flowers, and tall trees with delicious fruit.\n\nOn the fourth day, God placed the bright sun in the sky for daytime, the gentle moon for nighttime, and scattered millions of twinkling stars across the heavens.\n\nOn the fifth day, God filled the oceans with fish of every color — blue, orange, silver, and gold! He filled the sky with birds that could sing the most beautiful songs.\n\nOn the sixth day, God made all the animals — bouncy rabbits, cuddly bears, spotted giraffes, and wiggly puppies. And then, the most special creation of all — God made people! He made them in His own image and loved them very much.\n\nOn the seventh day, God looked at everything He had made and smiled. It was all very good. And God rested.\n\nEvery sunrise, every flower, every star in the sky — they're all God's gifts to you." },
  { id:"jesus-calms-storm", title:"Jesus Calms the Storm", subtitle:"Peace in the chaos", ref:"Mark 4:35-41", category:"Peace", age:"3-5", duration:7, color:"#6366f1", emoji:"⛵",
    prayer:"Dear God, when life feels stormy, help me remember that You are always with me. Amen.",
    takeaway:"Jesus has power over everything, and we can find peace in Him.",
    verse:"\"Peace, be still.\" — Mark 4:39",
    text:"One evening, after a long day of teaching, Jesus said to His friends, \"Let's go to the other side of the lake.\" So they all climbed into a little boat and set off across the water.\n\nJesus was so tired that He fell asleep on a cushion at the back of the boat. The gentle rocking of the waves was like a lullaby.\n\nBut suddenly, a great storm came! The wind howled and the waves crashed against the boat. Water splashed over the sides. The boat rocked back and forth so much that the disciples thought it might tip over.\n\nThe friends were very scared. \"We're going to sink!\" they cried. They shook Jesus awake. \"Teacher! Don't you care that we're about to drown?!\"\n\nJesus stood up calmly. He looked at the wild wind and the crashing waves. Then He spoke in a strong, gentle voice: \"Peace, be still.\"\n\nAnd just like that — everything stopped. The wind became quiet. The waves became smooth as glass. The storm was completely gone.\n\nJesus turned to His friends and said softly, \"Why were you so afraid? Don't you know I'm with you?\"\n\nThe disciples looked at each other in amazement. \"Even the wind and the waves listen to Him!\" they whispered.\n\nWhenever you feel scared or worried, remember — Jesus is with you, and He can calm any storm." },
];

const CATS = [
  { name:"Trust", icon:"🤲", bg:"linear-gradient(135deg,#3b82f6,#06b6d4)" },
  { name:"Courage", icon:"🛡️", bg:"linear-gradient(135deg,#f97316,#ef4444)" },
  { name:"Peace", icon:"🍃", bg:"linear-gradient(135deg,#22c55e,#10b981)" },
  { name:"Love", icon:"❤️", bg:"linear-gradient(135deg,#ec4899,#f43f5e)" },
  { name:"Hope", icon:"☀️", bg:"linear-gradient(135deg,#eab308,#f97316)" },
  { name:"Prayer", icon:"🙏", bg:"linear-gradient(135deg,#8b5cf6,#6366f1)" },
  { name:"Kindness", icon:"😊", bg:"linear-gradient(135deg,#14b8a6,#22c55e)" },
];

const BADGES = [
  { id:"first-story", name:"First Light", icon:"⭐", desc:"Read your first story", earned:true },
  { id:"bookworm", name:"Bookworm", icon:"📚", desc:"Read 5 stories", earned:true },
  { id:"story-explorer", name:"Explorer", icon:"🗺️", desc:"Read 10 stories", earned:false },
  { id:"3-day-streak", name:"Getting Started", icon:"🔥", desc:"3-day streak", earned:true },
  { id:"week-warrior", name:"Week Warrior", icon:"⚡", desc:"7-day streak", earned:false },
  { id:"faithful-reader", name:"Faithful", icon:"✨", desc:"14-day streak", earned:false },
  { id:"bible-scholar", name:"Scholar", icon:"🎓", desc:"Read 25 stories", earned:false },
  { id:"master-reader", name:"Master", icon:"👑", desc:"Read all 50", earned:false },
  { id:"devotion-champion", name:"Champion", icon:"🏆", desc:"30-day streak", earned:false },
];

const QUESTIONS = {
  Trust:["What does it mean to trust God, even when things are hard?","Can you think of a time when you had to trust someone?","How did the person in the story show they trusted God?"],
  Courage:["What made the person in this story brave?","When is a time you felt really brave?","How can God help us when we feel scared?"],
  Peace:["What makes you feel peaceful inside?","How did God bring peace in this story?","What can you do when you feel worried?"],
  Love:["How did the people in this story show love?","What are some ways you show love to your family?","How does God show us His love?"],
  Hope:["What does hope mean to you?","How did hope help the person in this story?","What makes you feel hopeful about tomorrow?"],
  Prayer:["What is your favorite thing to pray about?","How did prayer help in this story?","When do you like to talk to God?"],
  Kindness:["How was kindness shown in this story?","What is the nicest thing someone did for you today?","How can you be kind to someone tomorrow?"],
};

const AFFIRM = ["I am loved by God","I am brave and strong","God is always with me","I am kind and good","Tomorrow is a new adventure"];
const TIPS = [
  {icon:"🌙",tip:"Start bedtime stories at the same time each night for better sleep patterns."},
  {icon:"📱",tip:"Use Bedtime Mode 30 min before sleep for a warmer, gentler display."},
  {icon:"🌬️",tip:"Try the breathing exercise before the story to help your child relax."},
  {icon:"🔊",tip:"Ambient sounds like rain or ocean waves help children fall asleep faster."},
  {icon:"⏱",tip:"The sleep timer gently fades audio so your child drifts off naturally."},
];

/* ━━━━━━━━━━━━ GLOBAL STYLES ━━━━━━━━━━━━ */
const css = `
  @keyframes twinkle{0%{opacity:.15}100%{opacity:.85}}
  @keyframes pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.05)}}
  @keyframes fadeUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
  @keyframes waveform{0%{height:4px}50%{height:var(--h)}100%{height:4px}}
  @keyframes breathe{0%{transform:scale(.5);box-shadow:0 0 30px rgba(99,102,241,.2)}50%{transform:scale(1);box-shadow:0 0 60px rgba(99,102,241,.5)}100%{transform:scale(.5);box-shadow:0 0 30px rgba(99,102,241,.2)}}
  @keyframes celebration{0%{transform:scale(0) rotate(0)}60%{transform:scale(1.2) rotate(10deg)}100%{transform:scale(1) rotate(0)}}
  @keyframes starBurst{0%{opacity:0;transform:translate(0,0) scale(0)}50%{opacity:1;transform:translate(var(--tx),var(--ty)) scale(1)}100%{opacity:0;transform:translate(var(--tx2),var(--ty2)) scale(.5)}}
  @keyframes slideIn{from{transform:translateX(100%)}to{transform:translateX(0)}}
  @keyframes slideOut{from{transform:translateX(0)}to{transform:translateX(-100%)}}
  .animate-fadeUp{animation:fadeUp .4s ease-out both}
  .delay-1{animation-delay:.05s}.delay-2{animation-delay:.1s}.delay-3{animation-delay:.15s}.delay-4{animation-delay:.2s}
  * {-webkit-tap-highlight-color:transparent; box-sizing:border-box;}
  ::-webkit-scrollbar{display:none}
  input::placeholder{color:rgba(255,255,255,.3)}
`;

/* ━━━━━━━━━━━━ STARRY NIGHT ━━━━━━━━━━━━ */
function Stars(){
  const [s]=useState(()=>Array.from({length:45},(_,i)=>({i,x:Math.random()*100,y:Math.random()*100,sz:Math.random()*2.5+.5,d:Math.random()*4,dur:Math.random()*2+1.5})));
  return <div className="absolute inset-0 overflow-hidden" style={{background:"linear-gradient(180deg,#070714 0%,#0d0b1e 40%,#151030 100%)"}}>
    <div className="absolute top-16 left-1/2 -translate-x-1/2 w-96 h-48 rounded-full opacity-15" style={{background:"radial-gradient(ellipse,#6366f1,transparent 70%)"}}/>
    {s.map(v=><div key={v.i} className="absolute rounded-full bg-white" style={{left:`${v.x}%`,top:`${v.y}%`,width:v.sz,height:v.sz,animation:`twinkle ${v.dur}s ease-in-out ${v.d}s infinite alternate`}}/>)}
  </div>;
}

/* ━━━━━━━━━━━━ AUDIO PLAYER ━━━━━━━━━━━━ */
function AudioPlayer({story,bedtime,onFinish}){
  const [playing,setPlaying]=useState(false);
  const [progress,setProgress]=useState(0);
  const [time,setTime]=useState(0);
  const iv=useRef(null);
  const total=story.duration*60;

  useEffect(()=>{
    if(playing){
      iv.current=setInterval(()=>{
        setTime(t=>{
          const next=t+1;
          setProgress(next/total);
          if(next>=total){clearInterval(iv.current);setPlaying(false);onFinish?.();return total;}
          return next;
        });
      },1000);
    } else { clearInterval(iv.current); }
    return ()=>clearInterval(iv.current);
  },[playing]);

  const fmt=s=>`${Math.floor(s/60)}:${String(s%60).padStart(2,'0')}`;
  const bars=Array.from({length:32},(_,i)=>({i,h:Math.random()*18+4}));

  return <div className={`rounded-2xl p-4 ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
    <div className="flex items-center gap-3 mb-3">
      <button onClick={()=>setPlaying(!playing)} className="w-12 h-12 rounded-full flex items-center justify-center text-white shrink-0 transition-transform active:scale-90" style={{background:`linear-gradient(135deg,${story.color},#7c3aed)`}}>
        <span style={{fontSize:18,marginLeft:playing?0:2}}>{playing?"⏸":"▶"}</span>
      </button>
      <div className="flex-1 min-w-0">
        <div className="flex items-end gap-[2px] h-6 mb-2">
          {bars.map(b=><div key={b.i} className="flex-1 rounded-full" style={{
            background:b.i/32<=progress ? (bedtime?"#818cf8":"#6366f1") : (bedtime?"rgba(255,255,255,.08)":"#e5e7eb"),
            height:playing?undefined:Math.max(3,b.h*progress||3),
            ["--h"]:b.h+"px",
            animation:playing?`waveform ${.3+Math.random()*.4}s ease-in-out ${Math.random()*.3}s infinite alternate`:undefined,
          }}/>)}
        </div>
        <div className="flex justify-between">
          <span className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{fmt(time)}</span>
          <span className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{fmt(total)}</span>
        </div>
      </div>
    </div>
    {/* scrubber */}
    <div className={`h-1 rounded-full cursor-pointer ${bedtime?"bg-white/10":"bg-gray-200"}`}
      onClick={e=>{const r=e.currentTarget.getBoundingClientRect();const p=Math.max(0,Math.min(1,(e.clientX-r.left)/r.width));setProgress(p);setTime(Math.floor(p*total));}}>
      <div className="h-full rounded-full transition-all" style={{width:`${progress*100}%`,background:`linear-gradient(90deg,${story.color},#7c3aed)`}}/>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ CELEBRATION ━━━━━━━━━━━━ */
function Celebration({onDone}){
  useEffect(()=>{const t=setTimeout(onDone,2500);return()=>clearTimeout(t);},[]);
  const bursts=Array.from({length:8},(_,i)=>({i,tx:(Math.random()-.5)*80,ty:(Math.random()-.5)*80,tx2:(Math.random()-.5)*120,ty2:-60-Math.random()*40}));
  return <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40" style={{backdropFilter:"blur(4px)"}}>
    <div className="relative">
      {bursts.map(b=><div key={b.i} className="absolute left-1/2 top-1/2 text-2xl" style={{["--tx"]:b.tx+"px",["--ty"]:b.ty+"px",["--tx2"]:b.tx2+"px",["--ty2"]:b.ty2+"px",animation:`starBurst .8s ease-out ${b.i*.07}s both`}}>⭐</div>)}
      <div className="text-center" style={{animation:"celebration .5s cubic-bezier(.34,1.56,.64,1) both"}}>
        <div className="text-6xl mb-3">✅</div>
        <p className="text-white text-xl font-bold">Story Complete!</p>
        <p className="text-yellow-400 text-sm mt-1">+1 Sleep Star earned</p>
      </div>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ ONBOARDING ━━━━━━━━━━━━ */
function Onboarding({onDone}){
  const [pg,setPg]=useState(0);
  const [name,setName]=useState("");
  const [age,setAge]=useState(null);
  const [vis,setVis]=useState(false);
  useEffect(()=>{setTimeout(()=>setVis(true),200)},[]);

  const pages=[
    // Welcome
    <div key={0} className="flex-1 flex flex-col items-center justify-center px-8 text-center animate-fadeUp">
      <div className="relative mb-8">
        <div className="absolute inset-0 rounded-full" style={{background:"radial-gradient(circle,rgba(99,102,241,.25),transparent 70%)",transform:"scale(2.5)"}}/>
        <div style={{fontSize:80,transition:"all .8s cubic-bezier(.34,1.56,.64,1)",transform:`scale(${vis?1:.3})`,opacity:vis?1:0}}>🌙</div>
      </div>
      <h1 className="text-4xl font-bold text-white mb-1" style={{fontFamily:"system-ui"}}>Firefly</h1>
      <p className="text-2xl font-bold mb-5" style={{color:"#818cf8"}}>Bible Bedtime</p>
      <p className="text-white/50 text-sm leading-relaxed mb-12">Beautiful Bible stories to help<br/>your little one drift off to sleep</p>
      <button onClick={()=>setPg(1)} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>Get Started</button>
    </div>,
    // Setup
    <div key={1} className="flex-1 flex flex-col items-center justify-center px-8 animate-fadeUp">
      <div className="text-5xl mb-5">👤</div>
      <h2 className="text-2xl font-bold text-white mb-8">Who's listening tonight?</h2>
      <div className="w-full mb-5">
        <label className="text-white/40 text-xs font-bold mb-2 block tracking-wider">CHILD'S NAME</label>
        <input value={name} onChange={e=>setName(e.target.value)} placeholder="Enter name" className="w-full p-4 rounded-2xl bg-white/8 border border-white/15 text-white text-lg outline-none focus:border-indigo-400 transition-colors" style={{background:"rgba(255,255,255,.06)"}}/>
      </div>
      <div className="w-full mb-8">
        <label className="text-white/40 text-xs font-bold mb-3 block tracking-wider">AGE GROUP</label>
        <div className="flex gap-3">
          {[{l:"3-5",e:"👶"},{l:"6-8",e:"🧒"},{l:"9-12",e:"📖"}].map(a=>
            <button key={a.l} onClick={()=>setAge(a.l)} className={`flex-1 py-4 rounded-2xl font-bold text-sm border-2 transition-all active:scale-95 ${age===a.l?"border-indigo-500 text-white":"border-white/10 text-white/60"}`} style={{background:age===a.l?"rgba(99,102,241,.3)":"rgba(255,255,255,.04)"}}>
              <div className="text-xl mb-1">{a.e}</div>{a.l}
            </button>
          )}
        </div>
      </div>
      <button onClick={()=>setPg(2)} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>Continue</button>
    </div>,
    // Ready
    <div key={2} className="flex-1 flex flex-col items-center justify-center px-8 animate-fadeUp">
      <div className="text-5xl mb-4">✨</div>
      <h2 className="text-3xl font-bold text-white mb-8">You're all set!</h2>
      <div className="w-full space-y-5 mb-10">
        {[["\u{1F4D6}","50 Bible stories with audio","#818cf8"],["\u{1F319}","Bedtime routine & sleep timer","#a78bfa"],["\u{1F32C}\u{FE0F}","Guided breathing exercise","#22d3ee"],["\u{2B50}","Earn Sleep Stars & badges","#facc15"],["\u{2764}\u{FE0F}","100% free — always","#f472b6"]].map(([ic,tx,cl])=>
          <div key={tx} className="flex items-center gap-4 animate-fadeUp"><span className="text-2xl">{ic}</span><span className="text-white/75 text-sm">{tx}</span></div>
        )}
      </div>
      <button onClick={()=>onDone(name)} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>Start Exploring →</button>
    </div>
  ];

  return <div className="h-full relative overflow-hidden flex flex-col" style={{background:"linear-gradient(180deg,#070714,#0d0b1e 50%,#151030)"}}>
    <Stars/><div className="relative z-10 flex-1 flex flex-col">{pages[pg]}</div>
    <div className="relative z-10 flex justify-center gap-2 pb-10">{[0,1,2].map(i=><div key={i} className={`h-2 rounded-full transition-all duration-300 ${i===pg?"w-6 bg-white":"w-2 bg-white/20"}`}/>)}</div>
  </div>;
}

/* ━━━━━━━━━━━━ BREATHING ━━━━━━━━━━━━ */
function Breathing({onBack}){
  const [phase,setPhase]=useState("ready");
  const [cyc,setCyc]=useState(0);
  const [label,setLabel]=useState("Get Cozy");
  const [emoji,setEmoji]=useState("🌙");
  const [scale,setScale]=useState(.5);
  const t=useRef([]);

  const clear=()=>t.current.forEach(clearTimeout);
  const run=(c)=>{
    if(c>=4){setPhase("done");setLabel("All Done!");setEmoji("⭐");setScale(.7);return;}
    setPhase("inhale");setLabel("Smell the flowers");setEmoji("🌸");setScale(1);
    t.current.push(setTimeout(()=>{setPhase("hold");setLabel("Hold it gently");setEmoji("✨");},4000));
    t.current.push(setTimeout(()=>{setPhase("exhale");setLabel("Blow out the candles");setEmoji("🕯️");setScale(.5);},8000));
    t.current.push(setTimeout(()=>{setCyc(c+1);setPhase("rest");setLabel("Rest");setEmoji("🌙");},12000));
    t.current.push(setTimeout(()=>run(c+1),14000));
  };
  useEffect(()=>()=>clear(),[]);

  return <div className="h-full flex flex-col" style={{background:"linear-gradient(180deg,#070714,#151030)"}}>
    <div className="flex items-center px-4 py-3"><button onClick={()=>{clear();onBack();}} className="text-white/50 text-sm active:text-white">← Back</button><p className="flex-1 text-center text-white font-bold">Breathing Exercise</p><div className="w-12"/></div>
    <p className="text-center text-white/40 text-sm">Let's calm our body and mind</p>
    <div className="flex-1 flex flex-col items-center justify-center">
      <div className="rounded-full flex flex-col items-center justify-center" style={{width:200,height:200,background:"radial-gradient(circle,rgba(99,102,241,.45),rgba(99,102,241,.1))",transform:`scale(${scale})`,transition:"transform 4s ease-in-out",boxShadow:`0 0 ${scale*80}px rgba(99,102,241,${scale*.4})`}}>
        <span style={{fontSize:44}}>{emoji}</span>
        <span className="text-white font-semibold text-sm mt-2">{label}</span>
      </div>
      <div className="flex gap-3 mt-8 mb-2">{[0,1,2,3].map(i=><div key={i} className={`w-3 h-3 rounded-full transition-colors duration-500 ${i<cyc?"bg-indigo-400":"bg-indigo-400/20"}`}/>)}</div>
      <p className="text-white/30 text-xs">Breath {Math.min(cyc+1,4)} of 4</p>
    </div>
    <div className="p-6">
      {phase==="ready"&&<button onClick={()=>run(0)} className="w-full py-4 rounded-2xl font-bold text-white active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>🌬️ Begin</button>}
      {phase==="done"&&<div className="text-center"><p className="text-white font-bold text-lg mb-1">Sweet dreams ahead</p><p className="text-white/40 text-sm mb-4">Your body is calm and ready for sleep</p><button onClick={onBack} className="w-full py-4 rounded-2xl font-bold text-white active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>📖 Continue to Story</button></div>}
      {!["ready","done"].includes(phase)&&<button onClick={()=>{clear();setPhase("ready");setLabel("Get Cozy");setEmoji("🌙");setCyc(0);setScale(.5);}} className="w-full text-center text-white/30 text-sm py-2">Stop</button>}
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ AFFIRMATIONS ━━━━━━━━━━━━ */
function Affirm({onClose}){
  const items=AFFIRM.slice(0,3);
  const [idx,setIdx]=useState(0);
  const [op,setOp]=useState(1);
  const [done,setDone]=useState(false);
  const advance=()=>{setOp(0);setTimeout(()=>{if(idx<items.length-1){setIdx(idx+1);setOp(1);}else{setDone(true);setOp(1);}},400);};

  return <div className="h-full flex flex-col items-center justify-center px-8" style={{background:"#070714"}}>
    <div className="mb-10" style={{filter:"drop-shadow(0 0 40px rgba(250,204,21,.25))"}}>
      <span style={{fontSize:56}}>⭐</span>
    </div>
    {!done?<>
      <p className="text-3xl font-bold text-white text-center mb-10" style={{transition:"opacity .4s",opacity:op}}>{items[idx]}</p>
      <div className="flex gap-3 mb-10">{items.map((_,i)=><div key={i} className={`w-2.5 h-2.5 rounded-full transition-colors ${i<=idx?"bg-yellow-400":"bg-white/15"}`}/>)}</div>
      <button onClick={advance} className="text-white/40 font-bold text-lg active:text-white/70 transition-colors">Next →</button>
    </>:<>
      <p className="text-2xl text-white/30 mb-6">Sweet Dreams</p>
      <button onClick={onClose} className="px-10 py-4 rounded-2xl font-bold text-white active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>🌙 Goodnight</button>
    </>}
  </div>;
}

/* ━━━━━━━━━━━━ STORY DETAIL ━━━━━━━━━━━━ */
function StoryDetail({story,bedtime,onBack,favorites,toggleFav,markRead,readStories}){
  const [showAffirm,setShowAffirm]=useState(false);
  const [showCelebration,setShowCelebration]=useState(false);
  const isRead=readStories.has(story.id);
  const isFav=favorites.has(story.id);
  const qs=QUESTIONS[story.category]||QUESTIONS.Trust;

  if(showAffirm) return <Affirm onClose={()=>setShowAffirm(false)}/>;

  return <div className="h-full flex flex-col relative">
    {bedtime&&<Stars/>}
    {showCelebration&&<Celebration onDone={()=>setShowCelebration(false)}/>}
    <div className={`relative z-10 flex-1 overflow-y-auto ${bedtime?"":"bg-gray-50"}`}>
      {/* Hero */}
      <div className="relative h-60" style={{background:`linear-gradient(135deg,${story.color}cc,#7c3aed)`}}>
        <div className="absolute inset-0 flex items-center justify-center text-8xl opacity-20">{story.emoji}</div>
        <button onClick={onBack} className="absolute top-4 left-4 z-20 w-9 h-9 rounded-full bg-black/30 backdrop-blur-sm flex items-center justify-center text-white text-sm active:bg-black/50 transition-colors">←</button>
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent"/>
        <div className="absolute bottom-0 left-0 p-5">
          <span className="text-xs px-2.5 py-1 bg-white/20 rounded-full text-white/90 backdrop-blur-sm font-medium">Ages {story.age}</span>
          <h1 className="text-3xl font-bold text-white mt-2">{story.title}</h1>
          <p className="text-white/60 text-sm">{story.subtitle}</p>
        </div>
      </div>

      <div className="p-5 space-y-5">
        {/* Info bar */}
        <div className={`flex text-xs font-medium ${bedtime?"text-gray-500":"text-gray-400"}`}>
          <span>📖 {story.ref}</span><span className="mx-3">·</span>
          <span>⏱ {story.duration} min</span><span className="mx-3">·</span>
          <span>{CATS.find(c=>c.name===story.category)?.icon} {story.category}</span>
        </div>

        {/* Play + Fav */}
        <div className="flex gap-3 animate-fadeUp">
          <div className="flex-1"><AudioPlayer story={story} bedtime={bedtime} onFinish={()=>{if(!isRead){markRead(story.id);setShowCelebration(true);}}}/></div>
          <button onClick={()=>toggleFav(story.id)} className={`w-14 shrink-0 rounded-2xl flex items-center justify-center text-2xl transition-all active:scale-90 ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
            {isFav?"❤️":"🤍"}
          </button>
        </div>

        {/* Quick Controls */}
        <div className="flex gap-2 animate-fadeUp delay-1">
          {[{i:"⏱",l:"Timer"},{i:"🌧️",l:"Sounds"},{i:bedtime?"🌙":"☀️",l:bedtime?"Bedtime":"Daytime"}].map(c=>
            <div key={c.l} className={`flex-1 flex flex-col items-center py-3 rounded-xl ${bedtime?"bg-white/5":"bg-gray-100"}`}>
              <span className="text-lg">{c.i}</span><span className={`text-xs mt-0.5 ${bedtime?"text-gray-400":"text-gray-500"}`}>{c.l}</span>
            </div>
          )}
        </div>

        {/* Memory Verse */}
        {story.verse&&<div className="animate-fadeUp delay-2">
          <h3 className={`font-bold mb-2 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>📜</span>Memory Verse</h3>
          <div className={`p-4 rounded-2xl ${bedtime?"bg-indigo-500/10 text-indigo-300":"bg-indigo-50 text-indigo-700"}`} style={{fontFamily:"Georgia,serif",fontStyle:"italic",lineHeight:"1.7"}}>{story.verse}</div>
        </div>}

        {/* Story */}
        <div className="animate-fadeUp delay-3">
          <h3 className={`text-xl font-bold mb-4 ${bedtime?"text-white":"text-gray-900"}`}>Story</h3>
          {story.text.split("\n\n").map((para,i)=><p key={i} className={`mb-4 leading-relaxed ${bedtime?"text-gray-300":"text-gray-700"}`} style={{fontSize:17,lineHeight:bedtime?"2em":"1.8em"}}>{para}</p>)}
        </div>

        {/* Takeaway */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-amber-50"}`}>
          <h3 className={`font-bold mb-2 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>💡</span>Takeaway</h3>
          <p className={`text-sm leading-relaxed ${bedtime?"text-gray-400":"text-gray-600"}`}>{story.takeaway}</p>
        </div>

        {/* Discussion Questions */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold mb-1 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>💬</span>Talk Together</h3>
          <p className={`text-xs mb-4 ${bedtime?"text-gray-600":"text-gray-400"}`}>Questions to explore with your child</p>
          {qs.map((q,i)=><div key={i} className="flex gap-3 mb-3 last:mb-0">
            <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0 ${bedtime?"bg-indigo-500/15 text-indigo-400":"bg-indigo-100 text-indigo-600"}`}>{i+1}</div>
            <p className={`text-sm leading-relaxed ${bedtime?"text-gray-300":"text-gray-700"}`}>{q}</p>
          </div>)}
        </div>

        {/* Prayer */}
        <div>
          <h3 className={`font-bold mb-2 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>🙏</span>Bedtime Prayer</h3>
          <div className={`p-4 rounded-2xl leading-relaxed ${bedtime?"bg-white/5 text-gray-300":"bg-gray-100 text-gray-600"}`}>{story.prayer}</div>
        </div>

        {/* Affirmations */}
        {bedtime&&<button onClick={()=>setShowAffirm(true)} className="w-full flex items-center gap-3 p-4 rounded-2xl active:scale-[.98] transition-transform" style={{background:"linear-gradient(135deg,rgba(67,56,202,.12),rgba(124,58,237,.08))"}}>
          <span className="text-xl">⭐</span>
          <div className="flex-1 text-left"><p className="text-white text-sm font-bold">Goodnight Affirmations</p><p className="text-white/30 text-xs">Positive words before sleep</p></div>
          <span className="text-white/20">›</span>
        </button>}

        {/* Mark as Read */}
        <button onClick={()=>{if(!isRead){markRead(story.id);setShowCelebration(true);}}} className={`w-full py-4 rounded-2xl font-bold transition-all active:scale-95 ${isRead?(bedtime?"bg-green-500/15 text-green-400":"bg-green-100 text-green-700"):(bedtime?"bg-white/5 text-indigo-400":"bg-gray-100 text-indigo-600")}`}>
          {isRead?"✅ Completed":"☐ Mark as Read"}
        </button>
        <div className="h-6"/>
      </div>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ BEDTIME ROUTINE ━━━━━━━━━━━━ */
function Routine({bedtime,onBack,onStory}){
  const [breathing,setBreathing]=useState(false);
  const [timer,setTimer]=useState(30);
  const [sound,setSound]=useState("Rain");
  if(breathing) return <Breathing onBack={()=>setBreathing(false)}/>;

  return <div className="h-full flex flex-col relative">
    {bedtime&&<Stars/>}
    <div className={`relative z-10 flex-1 overflow-y-auto ${bedtime?"":"bg-gray-50"}`}>
      <div className="flex items-center px-4 py-3"><button onClick={onBack} className={`text-sm ${bedtime?"text-white/50":"text-gray-500"} active:opacity-70`}>← Back</button><p className={`flex-1 text-center font-bold ${bedtime?"text-white":"text-gray-900"}`}>Bedtime Routine</p><div className="w-12"/></div>
      <div className="p-5 space-y-4">
        <p className={`text-center text-sm mb-2 ${bedtime?"text-gray-500":"text-gray-400"}`}>Let's get ready for a peaceful night</p>

        {/* Story pick */}
        <button onClick={()=>onStory(STORIES[0])} className={`w-full p-4 rounded-2xl flex items-center gap-3 text-left active:scale-[.98] transition-transform ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <div className="w-12 h-12 rounded-xl flex items-center justify-center text-xl" style={{background:`linear-gradient(135deg,${STORIES[0].color},#7c3aed)`}}>{STORIES[0].emoji}</div>
          <div className="flex-1"><p className={`font-bold text-sm ${bedtime?"text-white":"text-gray-900"}`}>Tonight's Story</p><p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{STORIES[0].title}</p></div>
          <span className="text-green-400">✓</span>
        </button>

        {/* Timer */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <p className={`font-bold text-sm mb-3 ${bedtime?"text-white":"text-gray-900"}`}>⏱ Sleep Timer</p>
          <div className="flex gap-2">{[15,30,45,60].map(m=><button key={m} onClick={()=>setTimer(m)} className={`flex-1 py-2.5 rounded-xl text-sm font-bold transition-all active:scale-95 ${timer===m?"text-white":"text-gray-400"}`} style={{background:timer===m?`linear-gradient(135deg,${bedtime?"#4f46e5":"#4f46e5"},#7c3aed)`:(bedtime?"rgba(255,255,255,.04)":"#f3f4f6")}}>{m}m</button>)}</div>
        </div>

        {/* Ambient */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <p className={`font-bold text-sm mb-3 ${bedtime?"text-white":"text-gray-900"}`}>🎵 Ambient Sound</p>
          <div className="flex gap-2 flex-wrap">{["None","Rain","Ocean","Crickets","Fireplace","Lullaby"].map(s=><button key={s} onClick={()=>setSound(s)} className={`px-3 py-2 rounded-xl text-xs font-bold transition-all active:scale-95 ${sound===s?"text-white":"text-gray-400"}`} style={{background:sound===s?"linear-gradient(135deg,#4f46e5,#7c3aed)":(bedtime?"rgba(255,255,255,.04)":"#f3f4f6")}}>{s}</button>)}</div>
        </div>

        {/* Breathing */}
        <button onClick={()=>setBreathing(true)} className={`w-full flex items-center gap-3 p-4 rounded-2xl text-left active:scale-[.98] transition-transform ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <div className="w-11 h-11 rounded-full flex items-center justify-center" style={{background:"linear-gradient(135deg,#06b6d4,#14b8a6)"}}><span className="text-lg">🌬️</span></div>
          <div className="flex-1"><p className={`font-bold text-sm ${bedtime?"text-white":"text-gray-900"}`}>Breathing Exercise</p><p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>Calm body and mind before sleep</p></div>
          <span className={`text-xs ${bedtime?"text-gray-600":"text-gray-300"}`}>Optional ›</span>
        </button>

        <button onClick={()=>onStory(STORIES[0])} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>🌙 Start Bedtime Routine</button>
      </div>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ HOME ━━━━━━━━━━━━ */
function Home({bedtime,childName,onStory,onRoutine,favorites}){
  const tonight=STORIES[new Date().getDay()%STORIES.length];
  const h=new Date().getHours();
  const greet=h<12?"Good Morning":h<17?"Good Afternoon":"Good Evening";

  return <div className="flex-1 overflow-y-auto relative">
    {bedtime&&<Stars/>}
    <div className={`relative z-10 p-5 space-y-6 ${bedtime?"":"bg-gray-50"}`}>
      <div className="animate-fadeUp">
        <p className={`text-lg ${bedtime?"text-gray-400":"text-gray-500"}`}>{greet}{childName?`, ${childName}`:""}</p>
        <h1 className="text-3xl font-bold"><span className={bedtime?"text-white":"text-gray-900"}>Firefly </span><span style={{color:"#818cf8"}}>Bible Bedtime</span></h1>
      </div>

      {/* Streak */}
      <div className={`flex items-center gap-4 p-4 rounded-2xl animate-fadeUp delay-1 ${bedtime?"bg-white/5 backdrop-blur-sm":"bg-white shadow-sm"}`}>
        {[{e:"🔥",v:"3",l:"Streak"},{e:"⭐",v:"7",l:"Stars"},{e:"📖",v:"7",l:"Stories"}].map((s,i)=><>
          {i>0&&<div className={`w-px h-10 ${bedtime?"bg-gray-800":"bg-gray-100"}`}/>}
          <div key={s.l} className="text-center flex-1"><div className="text-xl">{s.e}</div><p className={`text-xl font-bold ${bedtime?"text-white":"text-gray-900"}`}>{s.v}</p><p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{s.l}</p></div>
        </>)}
        <div className="text-xl">✅</div>
      </div>

      {/* Tonight */}
      <div className="animate-fadeUp delay-2">
        <div className="flex items-center gap-2 mb-3"><span style={{color:"#818cf8"}}>✨</span><h2 className={`text-lg font-bold ${bedtime?"text-white":"text-gray-900"}`}>Tonight's Story</h2></div>
        <button onClick={()=>onStory(tonight)} className="w-full text-left active:scale-[.98] transition-transform">
          <div className="relative h-48 rounded-3xl overflow-hidden" style={{background:`linear-gradient(135deg,${tonight.color}cc,#7c3aed)`}}>
            <div className="absolute inset-0 flex items-center justify-center text-8xl opacity-15">{tonight.emoji}</div>
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"/>
            <div className="absolute bottom-0 left-0 p-5">
              <div className="flex items-center gap-1 text-white/60 text-xs mb-1">🌙 Selected for tonight</div>
              <h3 className="text-2xl font-bold text-white">{tonight.title}</h3>
              <div className="flex gap-3 text-white/50 text-xs mt-1"><span>📖 {tonight.ref}</span><span>🎧 {tonight.duration} min</span></div>
            </div>
          </div>
        </button>
      </div>

      {/* Routine */}
      <button onClick={onRoutine} className={`w-full flex items-center gap-4 p-4 rounded-2xl text-left active:scale-[.98] transition-transform animate-fadeUp delay-3 ${bedtime?"bg-white/5 backdrop-blur-sm":"bg-white shadow-sm"}`}>
        <div className="w-14 h-14 rounded-2xl flex items-center justify-center" style={{background:"linear-gradient(135deg,#4338ca,#7c3aed)"}}><span className="text-2xl">🛏️</span></div>
        <div className="flex-1"><p className={`font-bold ${bedtime?"text-white":"text-gray-900"}`}>Start Bedtime Routine</p><p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>Story + Prayer + Breathing + Ambient Sounds</p></div>
        <span className={bedtime?"text-gray-600":"text-gray-300"}>›</span>
      </button>

      {/* Categories */}
      <div className="animate-fadeUp delay-4">
        <h2 className={`text-lg font-bold mb-3 ${bedtime?"text-white":"text-gray-900"}`}>Browse by Theme</h2>
        <div className="grid grid-cols-2 gap-3">{CATS.map(c=>
          <div key={c.name} className="flex flex-col items-center justify-center h-20 rounded-2xl active:scale-95 transition-transform cursor-pointer" style={{background:c.bg}}>
            <span className="text-2xl">{c.icon}</span><span className="text-white text-xs font-bold mt-1">{c.name}</span>
          </div>
        )}</div>
      </div>

      {/* Story list */}
      <div>
        <h2 className={`text-lg font-bold mb-3 ${bedtime?"text-white":"text-gray-900"}`}>All 50 Stories</h2>
        {STORIES.map((s,i)=><button key={s.id} onClick={()=>onStory(s)} className={`w-full flex items-center gap-3 p-3 rounded-2xl mb-2 text-left active:scale-[.98] transition-transform animate-fadeUp ${bedtime?"bg-white/5":"bg-white shadow-sm"}`} style={{animationDelay:`${i*.04}s`}}>
          <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0" style={{background:`linear-gradient(135deg,${s.color}cc,#7c3aed)`}}>{s.emoji}</div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2"><p className={`font-bold text-sm ${bedtime?"text-white":"text-gray-900"}`}>{s.title}</p>{favorites.has(s.id)&&<span className="text-xs">❤️</span>}</div>
            <p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{s.ref} · {s.category} · {s.duration} min</p>
          </div>
          <span className={`text-xs px-2 py-1 rounded-full font-medium ${bedtime?"bg-white/8 text-white/50":"bg-gray-100 text-gray-500"}`}>{s.age}</span>
        </button>)}
      </div>
      <div className="h-4"/>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ LIBRARY ━━━━━━━━━━━━ */
function Library({bedtime,onStory,favorites}){
  const [filter,setFilter]=useState("All");
  const [search,setSearch]=useState("");
  const filtered=STORIES.filter(s=>(filter==="All"||s.category===filter)&&(search===""||s.title.toLowerCase().includes(search.toLowerCase())));

  return <div className="flex-1 overflow-y-auto relative">
    {bedtime&&<Stars/>}
    <div className={`relative z-10 p-5 ${bedtime?"":"bg-gray-50"}`}>
      {/* Search */}
      <div className={`flex items-center gap-2 p-3 rounded-2xl mb-4 ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        <span className="text-gray-400">🔍</span>
        <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search stories..." className={`flex-1 bg-transparent outline-none text-sm ${bedtime?"text-white placeholder-gray-600":"text-gray-900 placeholder-gray-400"}`}/>
        {search&&<button onClick={()=>setSearch("")} className="text-gray-400 text-xs">✕</button>}
      </div>

      {/* Filter chips */}
      <div className="flex gap-2 mb-4 overflow-x-auto pb-1" style={{scrollbarWidth:"none"}}>
        {["All",...CATS.map(c=>c.name)].map(c=><button key={c} onClick={()=>setFilter(c)} className={`px-3 py-1.5 rounded-full text-xs font-bold whitespace-nowrap transition-all active:scale-95 ${c===filter?"text-white":"text-gray-400"}`} style={{background:c===filter?"linear-gradient(135deg,#4f46e5,#7c3aed)":(bedtime?"rgba(255,255,255,.05)":"#f3f4f6")}}>{c}</button>)}
      </div>

      <p className={`text-xs mb-3 ${bedtime?"text-gray-600":"text-gray-400"}`}>{filtered.length} stories</p>

      {filtered.map(s=><button key={s.id} onClick={()=>onStory(s)} className={`w-full flex items-center gap-3 p-3 rounded-2xl mb-2 text-left active:scale-[.98] transition-transform ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0" style={{background:`linear-gradient(135deg,${s.color}cc,#7c3aed)`}}>{s.emoji}</div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2"><p className={`font-bold text-sm ${bedtime?"text-white":"text-gray-900"}`}>{s.title}</p>{favorites.has(s.id)&&<span className="text-xs">❤️</span>}</div>
          <p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{s.ref} · {s.category} · {s.duration} min</p>
        </div>
        <span className={`text-xs px-2 py-1 rounded-full font-medium ${bedtime?"bg-white/8 text-white/50":"bg-gray-100 text-gray-500"}`}>{s.age}</span>
      </button>)}
      {filtered.length===0&&<div className="text-center py-12"><span className="text-4xl">📖</span><p className={`mt-3 font-bold ${bedtime?"text-white":"text-gray-900"}`}>No stories found</p><p className={`text-sm ${bedtime?"text-gray-500":"text-gray-400"}`}>Try a different search</p></div>}
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ FAVORITES ━━━━━━━━━━━━ */
function Favs({bedtime,favorites,onStory}){
  const favStories=STORIES.filter(s=>favorites.has(s.id));
  return <div className="flex-1 overflow-y-auto relative">
    {bedtime&&<Stars/>}
    <div className={`relative z-10 p-5 ${bedtime?"":"bg-gray-50"}`}>
      {favStories.length===0?<div className="flex flex-col items-center justify-center py-20">
        <span className="text-6xl mb-4">❤️</span>
        <p className={`font-bold text-lg ${bedtime?"text-white":"text-gray-900"}`}>No Favorites Yet</p>
        <p className={`text-sm mt-1 ${bedtime?"text-gray-500":"text-gray-400"}`}>Tap the heart on any story to save it here</p>
      </div>:favStories.map(s=><button key={s.id} onClick={()=>onStory(s)} className={`w-full flex items-center gap-3 p-3 rounded-2xl mb-2 text-left active:scale-[.98] transition-transform ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0" style={{background:`linear-gradient(135deg,${s.color}cc,#7c3aed)`}}>{s.emoji}</div>
        <div className="flex-1"><p className={`font-bold text-sm ${bedtime?"text-white":"text-gray-900"}`}>{s.title}</p><p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{s.ref} · {s.duration} min</p></div>
        <span className="text-lg">❤️</span>
      </button>)}
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ REWARDS ━━━━━━━━━━━━ */
function Rewards({bedtime,readCount,streak}){
  return <div className="flex-1 overflow-y-auto relative">
    {bedtime&&<Stars/>}
    <div className={`relative z-10 p-5 space-y-6 ${bedtime?"":"bg-gray-50"}`}>
      <div className="flex flex-col items-center pt-4 animate-fadeUp">
        <div className="relative"><div className="w-24 h-24 rounded-full flex items-center justify-center" style={{background:"radial-gradient(circle,rgba(250,204,21,.2),rgba(250,204,21,.05))"}}><span className="text-5xl">⭐</span></div></div>
        <p className={`text-5xl font-bold mt-3 ${bedtime?"text-white":"text-gray-900"}`}>{readCount}</p>
        <p className={`text-lg ${bedtime?"text-gray-400":"text-gray-500"}`}>Sleep Stars</p>
        <p className={`text-xs mt-1 ${bedtime?"text-gray-600":"text-gray-400"}`}>Earn stars by reading stories each night!</p>
      </div>
      <div className={`flex p-4 rounded-2xl animate-fadeUp delay-1 ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        {[{i:"🔥",v:String(streak),l:"Current"},{i:"🏆",v:String(Math.max(streak,3)),l:"Best"},{i:"📖",v:String(readCount),l:"Total"}].map((s,i)=>
          <div key={s.l} className={`flex-1 text-center ${i<2?`border-r ${bedtime?"border-gray-800":"border-gray-100"}`:""}`}>
            <div className="text-xl">{s.i}</div><p className={`text-2xl font-bold ${bedtime?"text-white":"text-gray-900"}`}>{s.v}</p><p className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{s.l}</p>
          </div>
        )}
      </div>
      <div className="animate-fadeUp delay-2">
        <h2 className={`text-lg font-bold mb-4 ${bedtime?"text-white":"text-gray-900"}`}>Badges</h2>
        <div className="grid grid-cols-3 gap-4">{BADGES.map(b=>
          <div key={b.id} className={`flex flex-col items-center transition-all ${b.earned?"":"opacity-30"}`}>
            <div className={`w-16 h-16 rounded-full flex items-center justify-center text-2xl ${b.earned?"shadow-lg":""}`} style={{background:b.earned?"linear-gradient(135deg,#facc15,#f97316)":(bedtime?"rgba(255,255,255,.05)":"#f3f4f6")}}>
              {b.icon}
            </div>
            <p className={`text-xs font-bold mt-2 text-center ${bedtime?"text-white":"text-gray-700"}`}>{b.name}</p>
            <p className={`text-xs text-center ${bedtime?"text-gray-600":"text-gray-400"}`}>{b.desc}</p>
          </div>
        )}</div>
      </div>
      <div className="h-4"/>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ PARENT DASHBOARD ━━━━━━━━━━━━ */
function Dashboard({bedtime,onBack,readCount,streak}){
  const [tipIdx,setTipIdx]=useState(0);
  return <div className="h-full flex flex-col relative">
    {bedtime&&<Stars/>}
    <div className={`relative z-10 flex-1 overflow-y-auto ${bedtime?"":"bg-gray-50"}`}>
      <div className="flex items-center px-4 py-3"><button onClick={onBack} className={`text-sm active:opacity-70 ${bedtime?"text-white/50":"text-gray-500"}`}>← Back</button><p className={`flex-1 text-center font-bold ${bedtime?"text-white":"text-gray-900"}`}>Parent Dashboard</p><div className="w-12"/></div>
      <div className="p-5 space-y-5">
        <p className={`text-sm ${bedtime?"text-gray-500":"text-gray-400"}`}>Track your child's reading journey</p>

        {/* Week days */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-4 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>📅</span>This Week</h3>
          <div className="flex gap-2">{["S","M","T","W","T","F","S"].map((d,i)=><div key={d+i} className="flex-1 flex flex-col items-center gap-1.5">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${i<streak?"text-white":"text-gray-500"}`} style={{background:i<streak?"linear-gradient(135deg,#6366f1,#7c3aed)":(bedtime?"rgba(255,255,255,.05)":"#f3f4f6")}}>{i<streak?"✓":""}</div>
            <span className={`text-xs ${bedtime?"text-gray-500":"text-gray-400"}`}>{d}</span>
          </div>)}</div>
        </div>

        {/* Consistency */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-3 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>📊</span>Reading Consistency</h3>
          <div className="flex justify-between text-sm mb-2"><span className={bedtime?"text-gray-400":"text-gray-500"}>Overall</span><span className={`font-bold ${bedtime?"text-white":"text-gray-900"}`}>{Math.round(streak/7*100)}%</span></div>
          <div className={`h-3 rounded-full overflow-hidden ${bedtime?"bg-white/10":"bg-gray-100"}`}><div className="h-full rounded-full transition-all duration-700" style={{width:`${streak/7*100}%`,background:"linear-gradient(90deg,#22c55e,#6366f1)"}}/></div>
          <p className={`text-xs mt-2 ${bedtime?"text-gray-600":"text-gray-400"}`}>{streak>=5?"Incredible consistency!":streak>=3?"Great progress! Keep building the habit.":"Try reading together every night this week."}</p>
        </div>

        {/* Sleep tip */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-3 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>💡</span>Sleep Tip</h3>
          <div className="flex gap-3"><span className="text-2xl">{TIPS[tipIdx%TIPS.length].icon}</span><p className={`text-sm leading-relaxed ${bedtime?"text-gray-400":"text-gray-500"}`}>{TIPS[tipIdx%TIPS.length].tip}</p></div>
          <button onClick={()=>setTipIdx(tipIdx+1)} className="mt-3 text-xs font-bold" style={{color:"#818cf8"}}>Next Tip →</button>
        </div>

        {/* Themes */}
        <div className={`p-4 rounded-2xl ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-3 flex items-center gap-2 ${bedtime?"text-white":"text-gray-900"}`}><span>❤️</span>Favorite Themes</h3>
          <div className="grid grid-cols-2 gap-2">{CATS.slice(0,4).map(c=><div key={c.name} className={`flex items-center gap-2 p-2.5 rounded-xl ${bedtime?"bg-white/5":"bg-gray-50"}`}><span>{c.icon}</span><div><p className={`text-xs font-bold ${bedtime?"text-white":"text-gray-700"}`}>{c.name}</p><p className={`text-xs ${bedtime?"text-gray-600":"text-gray-400"}`}>{STORIES.filter(s=>s.category===c.name).length} stories</p></div></div>)}</div>
        </div>
        <div className="h-4"/>
      </div>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ SETTINGS ━━━━━━━━━━━━ */
function Settings({bedtime,onToggle,onDashboard}){
  return <div className={`flex-1 overflow-y-auto ${bedtime?"bg-[#070714]":"bg-gray-50"}`}>
    <div className="p-5 space-y-1">
      <h3 className={`text-xs font-bold uppercase px-3 pt-4 pb-2 tracking-wider ${bedtime?"text-gray-600":"text-gray-400"}`}>Display</h3>
      <div className={`rounded-2xl overflow-hidden ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        <div className="flex items-center justify-between p-4">
          <div className="flex items-center gap-3"><span>🌙</span><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>Bedtime Mode</span></div>
          <button onClick={onToggle} className={`w-12 h-7 rounded-full transition-colors relative ${bedtime?"bg-indigo-500":"bg-gray-300"}`}>
            <div className={`absolute top-1 w-5 h-5 rounded-full bg-white shadow-sm transition-all ${bedtime?"left-6":"left-1"}`}/>
          </button>
        </div>
        <div className={`border-t px-4 py-3 ${bedtime?"border-gray-800/50":"border-gray-100"}`}>
          <div className="flex items-center gap-3 mb-2"><span>🔤</span><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>Font Size</span></div>
          <div className={`h-1.5 rounded-full ${bedtime?"bg-white/10":"bg-gray-200"}`}><div className="h-full w-2/5 rounded-full bg-indigo-500"/></div>
        </div>
      </div>

      <h3 className={`text-xs font-bold uppercase px-3 pt-5 pb-2 tracking-wider ${bedtime?"text-gray-600":"text-gray-400"}`}>Playback</h3>
      <div className={`rounded-2xl overflow-hidden ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        <div className="flex items-center justify-between p-4">
          <div className="flex items-center gap-3"><span>▶️</span><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>Auto-play Narration</span></div>
          <div className="w-12 h-7 rounded-full bg-gray-300 relative"><div className="absolute top-1 left-1 w-5 h-5 rounded-full bg-white shadow-sm"/></div>
        </div>
        <div className={`border-t px-4 py-3 ${bedtime?"border-gray-800/50":"border-gray-100"}`}>
          <div className="flex items-center gap-3 mb-2"><span>🔊</span><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>Narration Volume</span></div>
          <div className={`h-1.5 rounded-full ${bedtime?"bg-white/10":"bg-gray-200"}`}><div className="h-full w-3/4 rounded-full bg-indigo-500"/></div>
        </div>
        <div className={`border-t px-4 py-3 ${bedtime?"border-gray-800/50":"border-gray-100"}`}>
          <div className="flex items-center gap-3 mb-2"><span>🎵</span><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>Ambient Volume</span></div>
          <div className={`h-1.5 rounded-full ${bedtime?"bg-white/10":"bg-gray-200"}`}><div className="h-full w-1/3 rounded-full bg-indigo-500"/></div>
        </div>
      </div>

      <h3 className={`text-xs font-bold uppercase px-3 pt-5 pb-2 tracking-wider ${bedtime?"text-gray-600":"text-gray-400"}`}>For Parents</h3>
      <button onClick={onDashboard} className={`w-full rounded-2xl p-4 flex items-center gap-3 text-left active:scale-[.98] transition-transform ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        <span>📊</span><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>Parent Dashboard</span><span className={`ml-auto ${bedtime?"text-gray-600":"text-gray-300"}`}>›</span>
      </button>

      <h3 className={`text-xs font-bold uppercase px-3 pt-5 pb-2 tracking-wider ${bedtime?"text-gray-600":"text-gray-400"}`}>About</h3>
      <div className={`rounded-2xl overflow-hidden ${bedtime?"bg-white/5":"bg-white shadow-sm"}`}>
        {["🔒 Privacy Policy","📄 Terms of Use","✉️ Support"].map((it,i)=><div key={it} className={`p-4 flex items-center justify-between ${i>0?`border-t ${bedtime?"border-gray-800/50":"border-gray-100"}`:""}`}><span className={`text-sm font-medium ${bedtime?"text-white":"text-gray-900"}`}>{it}</span><span className={bedtime?"text-gray-600":"text-gray-300"}>›</span></div>)}
      </div>

      <div className={`text-center pt-8 pb-6 ${bedtime?"text-gray-600":"text-gray-400"}`}>
        <p className="text-xs font-bold">Firefly Bible Bedtime</p>
        <p className="text-xs">Version 2.0 — Free for all families</p>
        <p className="text-xs mt-0.5">Made with ❤️ for families everywhere</p>
      </div>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━ MAIN APP ━━━━━━━━━━━━ */
export default function App(){
  const [screen,setScreen]=useState("onboard");
  const [tab,setTab]=useState("home");
  const [bedtime,setBedtime]=useState(true);
  const [story,setStory]=useState(null);
  const [sub,setSub]=useState(null);
  const [name,setName]=useState("");
  const [favs,setFavs]=useState(new Set());
  const [reads,setReads]=useState(new Set());
  const streak=3;

  const toggleFav=id=>setFavs(f=>{const n=new Set(f);n.has(id)?n.delete(id):n.add(id);return n;});
  const markRead=id=>setReads(r=>new Set(r).add(id));
  const goStory=s=>{setStory(s);setScreen("story");};
  const goBack=()=>{setScreen("app");setSub(null);};

  const tabs=[
    {id:"home",icon:"🌙",label:"Home"},
    {id:"library",icon:"📚",label:"Library"},
    {id:"favorites",icon:"❤️",label:"Favorites"},
    {id:"rewards",icon:"⭐",label:"Rewards"},
    {id:"settings",icon:"⚙️",label:"Settings"},
  ];

  const content=()=>{
    if(screen==="onboard") return <Onboarding onDone={n=>{setName(n);setScreen("app");}}/>;
    if(screen==="story") return <StoryDetail story={story} bedtime={bedtime} onBack={goBack} favorites={favs} toggleFav={toggleFav} markRead={markRead} readStories={reads}/>;
    if(sub==="routine") return <Routine bedtime={bedtime} onBack={()=>setSub(null)} onStory={goStory}/>;
    if(sub==="dashboard") return <Dashboard bedtime={bedtime} onBack={()=>setSub(null)} readCount={reads.size+7} streak={streak}/>;

    switch(tab){
      case"home":return <Home bedtime={bedtime} childName={name} onStory={goStory} onRoutine={()=>setSub("routine")} favorites={favs}/>;
      case"library":return <Library bedtime={bedtime} onStory={goStory} favorites={favs}/>;
      case"favorites":return <Favs bedtime={bedtime} favorites={favs} onStory={goStory}/>;
      case"rewards":return <Rewards bedtime={bedtime} readCount={reads.size+7} streak={streak}/>;
      case"settings":return <Settings bedtime={bedtime} onToggle={()=>setBedtime(!bedtime)} onDashboard={()=>setSub("dashboard")}/>;
    }
  };

  return <>
    <style>{css}</style>
    <div className="w-full h-screen flex justify-center" style={{background:"#0a0a0a"}}>
      <div className="w-full max-w-sm h-full flex flex-col relative overflow-hidden" style={{background:bedtime?"#070714":"#f9fafb",borderRadius:0}}>
        {/* Status bar */}
        {screen==="app"&&!sub&&<div className={`flex items-center justify-between px-6 py-2 text-xs font-bold relative z-20 ${bedtime?"text-white/40":"text-gray-500"}`}><span>9:41</span><div className="flex items-center gap-1.5"><span style={{fontSize:10}}>📶</span><span style={{fontSize:10}}>🔋</span></div></div>}

        <div className="flex-1 flex flex-col overflow-hidden relative">{content()}</div>

        {/* Tab Bar */}
        {screen==="app"&&!sub&&<div className={`flex relative z-20 ${bedtime?"bg-[#0c0b1a]/95 border-t border-gray-800/50":"bg-white/95 border-t border-gray-200"}`} style={{backdropFilter:"blur(16px)"}}>
          {tabs.map(t=><button key={t.id} onClick={()=>setTab(t.id)} className={`flex-1 flex flex-col items-center py-2 gap-0.5 transition-colors ${tab===t.id?(bedtime?"text-indigo-400":"text-indigo-600"):(bedtime?"text-gray-600":"text-gray-400")}`}>
            <span className="text-lg">{t.icon}</span><span className="text-xs font-medium">{t.label}</span>
            {tab===t.id&&<div className="w-1 h-1 rounded-full" style={{background:bedtime?"#818cf8":"#4f46e5"}}/>}
          </button>)}
        </div>}
      </div>
    </div>
  </>;
}
